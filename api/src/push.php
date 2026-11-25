<?php
declare(strict_types=1);

// ═══════════════ Avisos de encomendas novas (Web Push) ═══════════════
// Cada aparelho que ligou os avisos (Definições → "Ligar avisos neste aparelho") fica na tabela
// push_subscriptions. Quando entra uma encomenda, a API cifra um aviso curto para cada aparelho e
// entrega-o ao serviço de push do browser (Apple, Google, Mozilla), que o faz chegar ao telemóvel.
//
// As chaves VAPID (a "assinatura" da loja nos avisos) vivem no .env: VAPID_PUBLIC_KEY,
// VAPID_PRIVATE_KEY e VAPID_SUBJECT. Gera-as o bin/vapid-setup.php. Nunca no Git.
//
// Regras: só administradores recebem; o aviso nunca leva dinheiro (preço, custo, lucro);
// e um erro aqui NUNCA impede uma encomenda de ficar gravada (nada sai daqui como exceção).

use Minishlink\WebPush\Subscription;
use Minishlink\WebPush\WebPush;

/** As chaves estão no .env? Sem elas não se envia nada (e a app diz que não está configurado). */
function pushConfigured(): bool
{
    return ($_ENV['VAPID_PUBLIC_KEY'] ?? '') !== '' && ($_ENV['VAPID_PRIVATE_KEY'] ?? '') !== '';
}

/**
 * Quem entrega os avisos. Nos testes troca-se por um falso (sem rede):
 * recebe [[linha da tabela, texto do aviso], …] e devolve, por linha, ['ok' => bool, 'gone' => bool, 'reason' => string].
 * gone = o serviço diz que o aparelho já não existe (desligou, desinstalou): apaga-se.
 */
function pushTransport(?callable $replace = null): callable
{
    static $transport = null;
    if ($replace !== null) {
        $transport = $replace;
    }
    return $transport ??= 'pushSendWithLibrary';
}

/** A entrega a sério, com a biblioteca minishlink/web-push. */
function pushSendWithLibrary(array $jobs): array
{
    $webPush = new WebPush(['VAPID' => [
        'subject' => $_ENV['VAPID_SUBJECT'] ?? 'https://app.fazendasubmersa.pt',
        'publicKey' => $_ENV['VAPID_PUBLIC_KEY'],
        'privateKey' => $_ENV['VAPID_PRIVATE_KEY'],
    ]], ['TTL' => 86400, 'urgency' => 'high'], 10); // guarda o aviso até 1 dia se o telemóvel estiver desligado
    $webPush->setReuseVAPIDHeaders(true);

    foreach ($jobs as [$row, $payload]) {
        $webPush->queueNotification(Subscription::create([
            'endpoint' => $row['endpoint'],
            'publicKey' => $row['p256dh'],
            'authToken' => $row['auth'],
            'contentEncoding' => 'aes128gcm',
        ]), $payload);
    }
    $results = [];
    foreach ($webPush->flush() as $report) {
        $results[] = [
            'ok' => $report->isSuccess(),
            'gone' => $report->isSubscriptionExpired(),
            'reason' => $report->isSuccess() ? '' : mb_substr((string) $report->getReason(), 0, 200),
        ];
    }
    return $results;
}

/**
 * Envia [$title, $body, $url] aos aparelhos dos administradores ativos (menos os de $exceptUserId),
 * ou só aos de $onlyUserId. Devolve ['sent' => n, 'failed' => n, 'removed' => n].
 * Nunca lança exceção: um erro fica no log do PHP.
 */
function pushNotify(string $title, string $body, string $url, ?int $exceptUserId = null, ?int $onlyUserId = null): array
{
    $result = ['sent' => 0, 'failed' => 0, 'removed' => 0];
    try {
        if (!pushConfigured()) {
            return $result;
        }
        $sql = "SELECT s.* FROM push_subscriptions s JOIN users u ON u.id = s.user_id
                WHERE u.role = 'admin' AND u.is_active = 1";
        $params = [];
        if ($onlyUserId !== null) {
            $sql .= ' AND s.user_id = ?';
            $params[] = $onlyUserId;
        } elseif ($exceptUserId !== null) {
            $sql .= ' AND s.user_id <> ?';
            $params[] = $exceptUserId;
        }
        $stmt = db()->prepare($sql . ' ORDER BY s.id');
        $stmt->execute($params);
        $rows = $stmt->fetchAll();
        if ($rows === []) {
            return $result;
        }

        $payload = json_encode(['title' => $title, 'body' => $body, 'url' => $url], JSON_UNESCAPED_UNICODE);
        $reports = (pushTransport())(array_map(fn ($row) => [$row, $payload], $rows));

        foreach ($rows as $i => $row) {
            $report = $reports[$i] ?? ['ok' => false, 'gone' => false, 'reason' => 'sem resposta'];
            if ($report['ok']) {
                $result['sent']++;
                db()->prepare('UPDATE push_subscriptions SET last_used_at = NOW() WHERE id = ?')->execute([(int) $row['id']]);
            } elseif ($report['gone']) {
                $result['removed']++;
                db()->prepare('DELETE FROM push_subscriptions WHERE id = ?')->execute([(int) $row['id']]);
            } else {
                $result['failed']++;
                error_log('Aviso push falhou (aparelho ' . $row['id'] . '): ' . $report['reason']);
            }
        }
    } catch (Throwable $e) {
        error_log('Avisos push: ' . $e->getMessage());
    }
    return $result;
}

/**
 * O aviso das encomendas novas. Até 3: um aviso por encomenda ("Nova encomenda #1043",
 * "Etsy · Ana Silva · 2 artigos"); mais do que 3 de uma vez: um aviso só, com o total.
 * $exceptUserId: quem a criou à mão não precisa de ser avisado.
 * $maxSingle: a partir de quantas se junta tudo num aviso só.
 */
function notifyNewOrders(array $orderIds, ?int $exceptUserId = null, int $maxSingle = 3): void
{
    try {
        $orderIds = array_values(array_unique(array_map('intval', $orderIds)));
        if ($orderIds === [] || !pushConfigured()) {
            return;
        }
        $marks = implode(', ', array_fill(0, count($orderIds), '?'));
        $stmt = db()->prepare(
            "SELECT o.id, o.order_number, o.customer_name, c.name AS channel,
                    COALESCE((SELECT SUM(l.quantity) FROM order_lines l WHERE l.order_id = o.id), 0) AS items
             FROM orders o LEFT JOIN channels c ON c.id = o.channel_id
             WHERE o.id IN ($marks) ORDER BY o.order_number"
        );
        $stmt->execute($orderIds);
        $orders = $stmt->fetchAll();

        if (count($orders) > $maxSingle) {
            $channels = array_unique(array_column($orders, 'channel'));
            $from = count($channels) === 1 && $channels[0] ? ' da ' . $channels[0] : '';
            pushNotify(count($orders) . " novas encomendas$from", 'Toca para ver as encomendas.', '/#/orders', $exceptUserId);
            return;
        }
        foreach ($orders as $o) {
            $items = (int) $o['items'];
            $body = implode(' · ', array_filter([
                $o['channel'],
                $o['customer_name'],
                $items . ($items === 1 ? ' artigo' : ' artigos'),
            ]));
            pushNotify('Nova encomenda #' . $o['order_number'], $body, '/#/orders/' . (int) $o['id'], $exceptUserId);
        }
    } catch (Throwable $e) {
        error_log('Avisos push: ' . $e->getMessage());
    }
}
