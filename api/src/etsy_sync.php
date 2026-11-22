<?php
declare(strict_types=1);

/**
 * A importação das encomendas da Etsy (os "receipts", na linguagem da Etsy).
 *
 * Regras:
 *  - cada recibo entra UMA vez (orders.uq_source = canal + external_ref);
 *  - os artigos digitais (downloads) ignoram-se; uma encomenda só com digitais não entra;
 *  - cada artigo liga-se a uma variante pelo SKU (ou, sem SKU, pelo número da listagem);
 *    se um artigo não tiver variante, a encomenda inteira fica "por associar" e não entra —
 *    entra na sincronização seguinte, depois de o SKU existir;
 *  - uma encomenda que já entrou só acompanha a Etsy em três coisas: paga, enviada, cancelada;
 *  - as contas (custo, taxas, portes reais) são as mesmas das encomendas manuais.
 */

const ETSY_PAGE = 100;      // o máximo que a Etsy deixa por pedido
const ETSY_MAX_PAGES = 30;  // trava de segurança: 3000 recibos por sincronização

/** Um valor de dinheiro da Etsy ({amount: 1250, divisor: 100}) em euros. */
function etsyMoney(?array $money): float
{
    if (!$money || empty($money['divisor'])) {
        return 0.0;
    }
    return round($money['amount'] / $money['divisor'], 2);
}

/** A partir de que dia se importam encomendas: a definição etsy_import_from, ou o dia em que se ligou. */
function etsyImportFrom(): int
{
    $stmt = db()->prepare('SELECT setting_value FROM settings WHERE setting_key = ?');
    $stmt->execute(['etsy_import_from']);
    $day = $stmt->fetchColumn();
    if ($day === false) {
        $day = substr((string) (etsyConnection()['connected_at'] ?? date('Y-m-d')), 0, 10);
    }
    return (int) strtotime($day . ' 00:00:00');
}

/** O canal da Etsy (com as taxas). */
function etsyChannel(): array
{
    $channel = db()->query("SELECT * FROM channels WHERE code = 'etsy'")->fetch();
    if (!$channel) {
        throw new EtsyException('Falta o canal "etsy" na tabela channels.');
    }
    return $channel;
}

/**
 * A variante de um artigo, por esta ordem:
 *   1. pelo SKU (o SKU da Etsy igual ao de uma variante);
 *   2. associada à mão no "Conferir os SKU" (tabela etsy_links, pelo produto do anúncio);
 *   3. sem SKU, pela listagem (só se essa listagem tiver uma variante).
 */
function etsyFindVariant(array $t): ?int
{
    $sku = trim((string) ($t['sku'] ?? ''));
    if ($sku !== '') {
        $bySku = etsyVariantBySku($sku);
        if ($bySku !== null) {
            return $bySku;
        }
    }
    $linked = etsyLinkedVariant($t['product_id'] ?? null);
    if ($linked !== null) {
        return $linked;
    }
    if ($sku !== '') {
        return null; // um SKU que não existe na app não cai para a listagem
    }
    if (!empty($t['listing_id'])) {
        $stmt = db()->prepare('SELECT id FROM variants WHERE etsy_listing_id = ?');
        $stmt->execute([(string) $t['listing_id']]);
        $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);
        return count($ids) === 1 ? (int) $ids[0] : null;
    }
    return null;
}

/** A variante com este SKU (sem diferença entre maiúsculas e minúsculas), ou null. */
function etsyVariantBySku(string $sku): ?int
{
    $stmt = db()->prepare('SELECT id FROM variants WHERE UPPER(sku) = UPPER(?)');
    $stmt->execute([$sku]);
    $id = $stmt->fetchColumn();
    return $id === false ? null : (int) $id;
}

/** A variante associada à mão a este produto de um anúncio da Etsy, ou null. */
function etsyLinkedVariant(mixed $etsyProductId): ?int
{
    $id = trim((string) ($etsyProductId ?? ''));
    if ($id === '') {
        return null;
    }
    $stmt = db()->prepare('SELECT variant_id FROM etsy_links WHERE etsy_product_id = ?');
    $stmt->execute([$id]);
    $variantId = $stmt->fetchColumn();
    return $variantId === false ? null : (int) $variantId;
}

/** Um artigo digital (download)? Esses não entram na app: não se imprimem nem se enviam. */
function etsyIsDigital(array $t): bool
{
    return !empty($t['is_digital']);
}

/**
 * Packs de quantidade: uma variação do anúncio com um nome como "Quantidade" (ou Quantity, Pack,
 * Unidades) e um número no valor ("10", "Pack de 10") quer dizer que cada unidade vendida
 * na Etsy são N peças. Devolve N, ou 1 se a variação não for de quantidade.
 */
function etsyPackFrom(string $name, string $value): int
{
    if (!preg_match('/quantidade|quantity|qtd|pack|unidades|units|pe[çc]as|pieces/iu', $name)) {
        return 1;
    }
    if (!preg_match('/\d+/', $value, $m)) {
        return 1;
    }
    $n = (int) $m[0];
    return $n >= 1 && $n <= 1000 ? $n : 1;
}

/** As peças por unidade vendida de um artigo da Etsy (ver etsyPackFrom). */
function etsyPackSize(array $t): int
{
    foreach ((array) ($t['variations'] ?? []) as $v) {
        $n = etsyPackFrom((string) ($v['formatted_name'] ?? ''), (string) ($v['formatted_value'] ?? ''));
        if ($n > 1) {
            return $n;
        }
    }
    return 1;
}

/** As escolhas do comprador (personalização, cor…) num texto curto. */
function etsyCustomization(array $t): ?string
{
    $parts = [];
    foreach ((array) ($t['variations'] ?? []) as $v) {
        $name = trim((string) ($v['formatted_name'] ?? ''));
        $value = trim((string) ($v['formatted_value'] ?? ''));
        if ($value !== '') {
            $parts[] = $name === '' ? $value : "$name: $value";
        }
    }
    $text = implode(' · ', $parts);
    return $text === '' ? null : mb_substr($text, 0, 255);
}

/** A zona de portes de um país (a que tem o código na lista; senão, a que não tem lista: "Resto do mundo"). */
function etsyZoneId(?string $country): int
{
    $country = strtoupper(trim((string) $country));
    $fallback = 1;
    foreach (db()->query('SELECT id, countries FROM shipping_zones ORDER BY id')->fetchAll() as $z) {
        if ($z['countries'] === null || trim($z['countries']) === '') {
            $fallback = (int) $z['id'];
            continue;
        }
        if (in_array($country, array_map('trim', explode(',', strtoupper($z['countries']))), true)) {
            return (int) $z['id'];
        }
    }
    return $fallback;
}

/** O estado da encomenda e do pagamento, a partir do recibo. */
function etsyStatuses(array $r): array
{
    $etsy = (string) ($r['status'] ?? '');
    if ($etsy === 'canceled' || $etsy === 'fully refunded') {
        return ['cancelled', $etsy === 'fully refunded' ? 'refunded' : (!empty($r['is_paid']) ? 'paid' : 'unpaid')];
    }
    return [!empty($r['is_shipped']) ? 'shipped' : 'pending', !empty($r['is_paid']) ? 'paid' : 'unpaid'];
}

/** O código de seguimento do primeiro envio, se houver. */
function etsyTracking(array $r): ?string
{
    foreach ((array) ($r['shipments'] ?? []) as $s) {
        $code = trim((string) ($s['tracking_code'] ?? ''));
        if ($code !== '') {
            return mb_substr($code, 0, 40);
        }
    }
    return null;
}

/** O cliente do recibo: o mesmo comprador Etsy, ou um novo. Devolve [customer_id, address_id]. */
function etsyCustomer(array $r): array
{
    $buyer = (int) ($r['buyer_user_id'] ?? 0);
    $name = trim((string) ($r['name'] ?? '')) ?: 'Cliente Etsy';
    $customerId = null;
    if ($buyer > 0) {
        $stmt = db()->prepare('SELECT id FROM customers WHERE etsy_buyer_user_id = ?');
        $stmt->execute([$buyer]);
        $found = $stmt->fetchColumn();
        $customerId = $found === false ? null : (int) $found;
    }
    if ($customerId === null) {
        db()->prepare('INSERT INTO customers (name, email, etsy_buyer_user_id, notes) VALUES (?, ?, ?, ?)')
            ->execute([mb_substr($name, 0, 120), $r['buyer_email'] ?? null, $buyer > 0 ? $buyer : null, 'Cliente da Etsy']);
        $customerId = (int) db()->lastInsertId();
    }

    // a morada: a mesma (1.ª linha + código postal) volta a usar-se; senão, uma nova
    $line1 = trim((string) ($r['first_line'] ?? ''));
    if ($line1 === '') {
        return [$customerId, null];
    }
    $zip = trim((string) ($r['zip'] ?? ''));
    $stmt = db()->prepare('SELECT id FROM addresses WHERE customer_id = ? AND line1 = ? AND postal_code = ?');
    $stmt->execute([$customerId, mb_substr($line1, 0, 150), mb_substr($zip, 0, 12)]);
    $addressId = $stmt->fetchColumn();
    if ($addressId === false) {
        $line2 = trim(implode(', ', array_filter([trim((string) ($r['second_line'] ?? '')), trim((string) ($r['state'] ?? ''))])));
        db()->prepare('INSERT INTO addresses (customer_id, line1, line2, postal_code, city, country) VALUES (?, ?, ?, ?, ?, ?)')
            ->execute([
                $customerId,
                mb_substr($line1, 0, 150),
                $line2 === '' ? null : mb_substr($line2, 0, 150),
                mb_substr($zip, 0, 12),
                mb_substr(trim((string) ($r['city'] ?? '')), 0, 80),
                strtoupper(substr(trim((string) ($r['country_iso'] ?? 'PT')), 0, 2)) ?: 'PT',
            ]);
        $addressId = db()->lastInsertId();
    }
    return [$customerId, (int) $addressId];
}

/**
 * Importa (ou atualiza) um recibo. Devolve 'created', 'updated', 'unchanged',
 * ou ['skipped', motivo] se ficar por associar.
 */
function etsyImportReceipt(array $r, array $channel, float $perHour): string|array
{
    $ref = (string) $r['receipt_id'];
    [$status, $payment] = etsyStatuses($r);

    $stmt = db()->prepare('SELECT id, status, payment_status, tracking_code FROM orders WHERE channel_id = ? AND external_ref = ?');
    $stmt->execute([(int) $channel['id'], $ref]);
    $existing = $stmt->fetch();
    if ($existing) {
        return etsyUpdateOrder($existing, $status, $payment, etsyTracking($r));
    }

    // um recibo cancelado que nunca entrou: não vale a pena criá-lo
    if ($status === 'cancelled') {
        return 'unchanged';
    }
    $currency = $r['grandtotal']['currency_code'] ?? 'EUR';
    if ($currency !== 'EUR') {
        return ['skipped', "recibo #$ref em $currency (só se importa em EUR)"];
    }

    // os produtos digitais (downloads) não entram: não se imprimem nem se enviam.
    // Uma encomenda só com digitais fica de fora, calada (não é "por associar").
    $transactions = (array) ($r['transactions'] ?? []);
    $physical = array_values(array_filter($transactions, fn ($t) => !etsyIsDigital($t)));
    if ($transactions !== [] && $physical === []) {
        return 'unchanged';
    }

    // todos os artigos físicos têm de ter variante; senão, a encomenda fica por associar
    $lines = [];
    $missing = [];
    foreach ($physical as $t) {
        $variantId = etsyFindVariant($t);
        if ($variantId === null) {
            $missing[] = trim((string) ($t['sku'] ?? '')) !== ''
                ? 'SKU ' . $t['sku']
                : '«' . mb_substr((string) ($t['title'] ?? 'sem título'), 0, 40) . '» sem SKU';
            continue;
        }
        $lines[] = ['t' => $t, 'variant_id' => $variantId, 'pack' => etsyPackSize($t)];
    }
    if ($missing !== []) {
        return ['skipped', "recibo #$ref: " . implode(', ', $missing)];
    }
    if ($lines === []) {
        return ['skipped', "recibo #$ref sem artigos"];
    }

    db()->beginTransaction();
    try {
        [$customerId, $addressId] = etsyCustomer($r);
        $next = (int) db()->query('SELECT COALESCE(MAX(order_number), 1000) + 1 FROM orders FOR UPDATE')->fetchColumn();

        // os portes reais: o escalão do peso total, na zona do país
        $weight = 0;
        foreach ($lines as $l) {
            // um pack de 10 pesa 10 peças
            $weight += max(1, (int) $l['t']['quantity']) * $l['pack'] * variantShippingWeightG($l['variant_id']);
        }
        $shippingPaid = shippingPrice($weight, etsyZoneId($r['country_iso'] ?? null)) ?? 0.0;

        // a data limite de envio: a mais cedo dos artigos
        $shipBy = null;
        foreach ($lines as $l) {
            $ts = (int) ($l['t']['expected_ship_date'] ?? 0);
            if ($ts > 0 && ($shipBy === null || $ts < $shipBy)) {
                $shipBy = $ts;
            }
        }

        $notes = array_filter([
            trim((string) ($r['message_from_buyer'] ?? '')) === '' ? null : 'Mensagem do comprador: ' . trim((string) $r['message_from_buyer']),
            !empty($r['is_gift']) ? 'Presente' . (trim((string) ($r['gift_message'] ?? '')) === '' ? '' : ': ' . trim((string) $r['gift_message'])) : null,
        ]);
        $created = (int) ($r['create_timestamp'] ?? $r['created_timestamp'] ?? time());

        db()->prepare(
            'INSERT INTO orders (order_number, channel_id, external_ref, customer_id, customer_name, address_id,
                status, payment_status, payment_method, delivery_method, carrier_name, tracking_code,
                shipping_charged, shipping_paid, ship_by_date, notes, created_manually, created_by, is_seen, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'carrier\', \'CTT\', ?, ?, ?, ?, ?, 0, NULL, 0, FROM_UNIXTIME(?))'
        )->execute([
            $next,
            (int) $channel['id'],
            $ref,
            $customerId,
            mb_substr(trim((string) ($r['name'] ?? '')) ?: 'Cliente Etsy', 0, 120),
            $addressId,
            $status,
            $payment,
            'Etsy Payments',
            etsyTracking($r),
            $shippingCharged = etsyMoney($r['total_shipping_cost'] ?? null),
            $shippingPaid,
            $shipBy === null ? null : date('Y-m-d', $shipBy),
            $notes === [] ? null : implode("\n", $notes),
            $created,
        ]);
        $orderId = (int) db()->lastInsertId();

        // o desconto da loja vem no recibo inteiro: reparte-se pelas linhas, na proporção do valor.
        // Se o recibo tiver digitais, só a parte dos físicos fica cá (o resto era desconto dos digitais).
        $gross = 0.0;
        foreach ($lines as $l) {
            $gross += max(1, (int) $l['t']['quantity']) * etsyMoney($l['t']['price'] ?? null);
        }
        $allGross = 0.0;
        foreach ($transactions as $t) {
            $allGross += max(1, (int) ($t['quantity'] ?? 1)) * etsyMoney($t['price'] ?? null);
        }
        $discount = etsyMoney($r['discount_amt'] ?? null);
        if ($allGross > $gross && $allGross > 0) {
            $discount = round($discount * $gross / $allGross, 2);
        }
        $discountLeft = min($discount, $gross);

        $insert = db()->prepare(
            'INSERT INTO order_lines (order_id, variant_id, quantity, unit_price, discount, customization, unit_cost, channel_fee)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
        );
        $last = count($lines) - 1;
        foreach ($lines as $i => $l) {
            $qty = max(1, (int) $l['t']['quantity']);
            $unitPrice = etsyMoney($l['t']['price'] ?? null);
            $lineGross = $qty * $unitPrice;
            $discount = $i === $last ? $discountLeft : ($gross > 0 ? round($discountLeft * $lineGross / $gross, 2) : 0.0);
            if ($i !== $last) {
                $gross -= $lineGross;
                $discountLeft = round($discountLeft - $discount, 2);
            }
            // a mesma conta das encomendas manuais (channelLineFee), sobre o valor já com o desconto.
            // A taxa de anúncio é por unidade vendida NA ETSY: um pack conta 1, não 10.
            $fee = channelLineFee($channel, $lineGross - $discount, $qty, $i === 0 ? $shippingCharged : 0.0, $i === 0);

            // pack de N: a linha guarda as PEÇAS (custo, tempo de impressão e tarefas certos).
            // O preço por peça arredonda-se ao cêntimo PARA CIMA e a diferença vai para o desconto,
            // para o total da linha ficar igual ao da Etsy (12,99 € ÷ 10 → 1,30 × 10 − 0,01).
            $pieces = $qty * $l['pack'];
            $piecePrice = $unitPrice;
            $lineDiscount = $discount;
            if ($l['pack'] > 1) {
                $piecePrice = ceil(round($unitPrice / $l['pack'] * 100, 6)) / 100;
                $lineDiscount = round($discount + $pieces * $piecePrice - $lineGross, 2);
            }
            $insert->execute([
                $orderId,
                $l['variant_id'],
                $pieces,
                $piecePrice,
                $lineDiscount,
                etsyCustomization($l['t']),
                variantUnitCost($l['variant_id'], $perHour),
                $fee,
            ]);
        }

        db()->prepare('INSERT INTO order_events (order_id, description, new_status, source) VALUES (?, ?, ?, \'sync\')')
            ->execute([$orderId, "Entrou pela Etsy (recibo #$ref)", $status]);
        // paga (é o normal na Etsy) → vai logo para "Por imprimir" (src/production.php)
        autoStartProduction($orderId, 'sync');
        db()->commit();
    } catch (Throwable $e) {
        if (db()->inTransaction()) {
            db()->rollBack();
        }
        throw $e;
    }
    return 'created';
}

/** Uma encomenda que já entrou: acompanha a Etsy em pago, enviado e cancelado. Nunca volta para trás. */
function etsyUpdateOrder(array $o, string $status, string $payment, ?string $tracking): string
{
    $events = [];
    $newStatus = $o['status'];
    $newPayment = $o['payment_status'];
    $newTracking = $o['tracking_code'];

    if ($status === 'cancelled' && $o['status'] !== 'cancelled') {
        $newStatus = 'cancelled';
        $events[] = ['Cancelada na Etsy', 'cancelled'];
    } elseif ($status === 'shipped' && in_array($o['status'], ['pending', 'in_production', 'ready'], true)) {
        $newStatus = 'shipped';
        $events[] = ['Enviada (marcada na Etsy)', 'shipped'];
    }
    if ($payment !== $o['payment_status'] && ($payment === 'refunded' || ($payment === 'paid' && $o['payment_status'] === 'unpaid'))) {
        $newPayment = $payment;
        $events[] = [$payment === 'refunded' ? 'Reembolsada na Etsy' : 'Pagamento confirmado na Etsy', null];
    }
    if ($tracking !== null && ($o['tracking_code'] ?? '') === '') {
        $newTracking = $tracking;
    }
    if ($events === [] && $newTracking === $o['tracking_code']) {
        return 'unchanged';
    }

    db()->beginTransaction();
    try {
        db()->prepare('UPDATE orders SET status = ?, payment_status = ?, tracking_code = ? WHERE id = ?')
            ->execute([$newStatus, $newPayment, $newTracking, (int) $o['id']]);
        $insert = db()->prepare('INSERT INTO order_events (order_id, description, new_status, source) VALUES (?, ?, ?, \'sync\')');
        foreach ($events as [$text, $st]) {
            $insert->execute([(int) $o['id'], $text, $st]);
        }
        // o pagamento chegou agora? então também vai para "Por imprimir"
        autoStartProduction((int) $o['id'], 'sync');
        db()->commit();
    } catch (Throwable $e) {
        if (db()->inTransaction()) {
            db()->rollBack();
        }
        throw $e;
    }
    return 'updated';
}

/**
 * Uma sincronização completa: vai buscar os recibos desde etsyImportFrom() e importa-os.
 * Fica registada em sync_runs. Só corre uma de cada vez.
 */
function etsySync(): array
{
    $channel = etsyChannel();
    // só uma sincronização de cada vez (dois cliques, ou o cron ao mesmo tempo que o botão)
    if ((int) db()->query("SELECT GET_LOCK('cubico_etsy_sync', 0)")->fetchColumn() !== 1) {
        throw new EtsyException('Já está a correr uma sincronização. Espera um pouco.');
    }
    db()->prepare("INSERT INTO sync_runs (channel_id, status) VALUES (?, 'running')")->execute([(int) $channel['id']]);
    $runId = (int) db()->lastInsertId();

    $count = ['created' => 0, 'updated' => 0, 'unchanged' => 0];
    $skipped = [];
    try {
        $shopId = (int) (etsyConnection()['shop_id'] ?? 0);
        if ($shopId === 0) {
            throw new EtsyException('A loja ainda não está ligada à Etsy. Liga-a nas Definições.');
        }
        $perHour = printerCostPerHour();
        $from = etsyImportFrom();
        for ($page = 0; $page < ETSY_MAX_PAGES; $page++) {
            $data = etsyGet("/application/shops/$shopId/receipts", [
                'min_created' => max($from, 946684800),
                'limit' => ETSY_PAGE,
                'offset' => $page * ETSY_PAGE,
                'sort_on' => 'created',
                'sort_order' => 'asc',
            ]);
            $results = (array) ($data['results'] ?? []);
            foreach ($results as $receipt) {
                $result = etsyImportReceipt($receipt, $channel, $perHour);
                if (is_array($result)) {
                    $skipped[] = $result[1];
                } else {
                    $count[$result]++;
                }
            }
            if (count($results) < ETSY_PAGE) {
                break;
            }
        }
        db()->prepare(
            "UPDATE sync_runs SET status = 'ok', finished_at = NOW(), created_count = ?, updated_count = ?,
                skipped_count = ?, notes = ? WHERE id = ?"
        )->execute([$count['created'], $count['updated'], count($skipped), $skipped === [] ? null : implode("\n", $skipped), $runId]);
    } catch (Throwable $e) {
        $message = $e instanceof EtsyException ? $e->getMessage() : 'Erro inesperado: ' . $e->getMessage();
        db()->prepare("UPDATE sync_runs SET status = 'error', finished_at = NOW(), created_count = ?, updated_count = ?,
                error_message = ? WHERE id = ?")
            ->execute([$count['created'], $count['updated'], mb_substr($message, 0, 1000), $runId]);
        throw $e instanceof EtsyException ? $e : new EtsyException($message);
    } finally {
        db()->query("SELECT RELEASE_LOCK('cubico_etsy_sync')");
    }
    return ['created' => $count['created'], 'updated' => $count['updated'], 'skipped' => $skipped];
}

/** A última sincronização (para a app mostrar "Etsy há 5 min"). */
function etsyLastSync(): ?array
{
    $row = db()->query(
        "SELECT r.* FROM sync_runs r JOIN channels c ON c.id = r.channel_id WHERE c.code = 'etsy' ORDER BY r.id DESC LIMIT 1"
    )->fetch();
    if (!$row) {
        return null;
    }
    return [
        'status' => $row['status'],
        'started_at' => $row['started_at'],
        'finished_at' => $row['finished_at'],
        'created_count' => (int) $row['created_count'],
        'updated_count' => (int) $row['updated_count'],
        'skipped_count' => (int) $row['skipped_count'],
        'error_message' => $row['error_message'],
        'notes' => $row['notes'],
    ];
}
