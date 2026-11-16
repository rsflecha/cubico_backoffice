<?php
declare(strict_types=1);

// ═══════════════ Produção automática ═══════════════
// Regra (decidida a 2026-11-16): uma encomenda PAGA não espera pelo botão
// "Enviar para produção". Assim que está paga e ainda "Pendente", passa a
// "Em produção" e cada artigo vira uma tarefa em "Por imprimir".
//
// Corre em todos os sítios onde uma encomenda pode ficar paga: criar uma encomenda
// manual, mudar o pagamento, e as encomendas da Etsy (ao entrar e ao atualizar).
// As que estão por pagar continuam à espera do botão, como antes.
// A mesma regra está na app (ProductionService.startIfPaid) para o modo demo.

/**
 * Se a encomenda estiver paga, pendente e sem tarefas, cria as tarefas e passa-a
 * a "Em produção". Devolve true se o fez. Não abre transação: quem chama decide
 * (dentro de uma, as tarefas e a encomenda gravam-se juntas).
 */
function autoStartProduction(int $orderId, string $source = 'system'): bool
{
    $stmt = db()->prepare('SELECT status, payment_status FROM orders WHERE id = ?');
    $stmt->execute([$orderId]);
    $order = $stmt->fetch();
    if (!$order || $order['status'] !== 'pending' || $order['payment_status'] !== 'paid') {
        return false;
    }

    // já tem tarefas (alguém a enviou à mão)? então não se duplica nada
    $stmt = db()->prepare(
        'SELECT COUNT(*) FROM print_jobs pj JOIN order_lines ol ON ol.id = pj.order_line_id WHERE ol.order_id = ?'
    );
    $stmt->execute([$orderId]);
    if ((int) $stmt->fetchColumn() > 0) {
        return false;
    }

    $lines = db()->prepare(
        'SELECT ol.id, ol.variant_id, ol.quantity, ol.customization, v.print_time_min
           FROM order_lines ol JOIN variants v ON v.id = ol.variant_id
          WHERE ol.order_id = ? ORDER BY ol.id'
    );
    $lines->execute([$orderId]);
    $lines = $lines->fetchAll();
    if ($lines === []) {
        return false;
    }

    // uma tarefa por artigo, como o "Enviar para produção" da app
    $insert = db()->prepare(
        'INSERT INTO print_jobs (order_line_id, variant_id, quantity, status, estimated_min, notes)
         VALUES (?, ?, ?, \'queued\', ?, ?)'
    );
    foreach ($lines as $l) {
        $insert->execute([
            (int) $l['id'],
            (int) $l['variant_id'],
            (int) $l['quantity'],
            (int) $l['print_time_min'] * (int) $l['quantity'],
            $l['customization'] === null ? null : mb_substr('«' . $l['customization'] . '»', 0, 255),
        ]);
    }
    db()->prepare('UPDATE orders SET status = \'in_production\' WHERE id = ?')->execute([$orderId]);
    db()->prepare('INSERT INTO order_events (order_id, description, new_status, source) VALUES (?, ?, \'in_production\', ?)')
        ->execute([$orderId, 'Paga: enviada para produção sozinha', $source]);
    return true;
}
