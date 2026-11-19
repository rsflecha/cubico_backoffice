<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Encomendas ═══════════════
// Todos com sessão veem, criam (manuais) e mudam o estado.
// O colaborador recebe-as SEM os custos (custo de produção, taxas, portes pagos).

const ORDER_TYPES = [
    'id' => 'int',
    'order_number' => 'int',
    'channel_id' => 'int',
    'external_ref' => 'string',
    'customer_id' => 'int',
    'customer_name' => 'string',
    'customer_contact' => 'string',
    'status' => 'string',
    'payment_status' => 'string',
    'payment_method' => 'string',
    'delivery_method' => 'string',
    'carrier_name' => 'string',
    'tracking_code' => 'string',
    'shipping_charged' => 'float',
    'shipping_paid' => 'float',
    'ship_by_date' => 'string',
    'notes' => 'string',
    'created_manually' => 'bool',
    'is_seen' => 'bool',
    'created_at' => 'string',
    'updated_at' => 'string',
];
const LINE_TYPES = [
    'id' => 'int',
    'variant_id' => 'int',
    'quantity' => 'int',
    'unit_price' => 'float',
    'discount' => 'float',
    'customization' => 'string',
    'unit_cost' => 'float',
    'channel_fee' => 'float',
];

/** As encomendas (todas, ou uma), com as linhas. Sem custos, se $withCosts for false. */
function readOrders(bool $withCosts, ?int $id = null): array
{
    $stmt = db()->prepare('SELECT * FROM orders' . ($id === null ? '' : ' WHERE id = ?') . ' ORDER BY created_at DESC');
    $stmt->execute($id === null ? [] : [$id]);
    $orders = array_map(fn ($row) => typed($row, ORDER_TYPES), $stmt->fetchAll());
    if ($orders === []) {
        return [];
    }

    $ids = array_column($orders, 'id');
    $marks = implode(', ', array_fill(0, count($ids), '?'));
    $lines = db()->prepare("SELECT * FROM order_lines WHERE order_id IN ($marks) ORDER BY id");
    $lines->execute($ids);
    $byOrder = [];
    foreach ($lines->fetchAll() as $line) {
        $typed = typed($line, LINE_TYPES);
        if (!$withCosts) {
            $typed['unit_cost'] = 0.0;   // o modelo da app exige o campo: vai a 0
            $typed['channel_fee'] = 0.0;
        }
        $byOrder[(int) $line['order_id']][] = $typed;
    }
    foreach ($orders as &$order) {
        $order['lines'] = $byOrder[$order['id']] ?? [];
        if (!$withCosts) {
            $order['shipping_paid'] = 0.0;
        }
    }
    return $orders;
}

/** "2026-11-12T00:00:00.000" (da app) → "2026-11-12" (para uma coluna DATE). null se vazio. */
function toDate(mixed $value): ?string
{
    return $value ? substr((string) $value, 0, 10) : null;
}

// GET /api/orders → as encomendas, com as linhas
$app->get('/api/orders', function (Request $request, Response $response) {
    return json($response, readOrders($request->getAttribute('role') === 'admin'));
})->add($requireAuth);

// POST /api/orders → criar uma encomenda manual. As contas oficiais são feitas AQUI.
$app->post('/api/orders', function (Request $request, Response $response) {
    $body = body($request);
    $lines = (array) ($body['lines'] ?? []);
    $customerName = trim((string) ($body['customer_name'] ?? ''));

    $channelStmt = db()->prepare('SELECT * FROM channels WHERE id = ?');
    $channelStmt->execute([(int) ($body['channel_id'] ?? 0)]);
    $channel = $channelStmt->fetch();
    if (!$channel || $channel['is_automatic']) {
        return fail($response, 'Escolhe a origem (as encomendas da Etsy entram sozinhas).', 422);
    }
    if ($customerName === '') {
        return fail($response, 'Escreve para quem é.', 422);
    }
    if ($lines === []) {
        return fail($response, 'Junta pelo menos um artigo.', 422);
    }

    // a cor escolhida em cada artigo (opcional): tem de ser um filamento que existe.
    // Um produto a 2 cores (a árvore de Natal) manda também a segunda, em filament_id_2.
    $colors = [];
    $colors2 = [];
    $colorStmt = db()->prepare('SELECT id FROM filaments WHERE id = ?');
    foreach (array_values($lines) as $i => $l) {
        foreach (['filament_id', 'filament_id_2'] as $key) {
            if (!isset($l[$key]) || $l[$key] === null || $l[$key] === '') {
                continue;
            }
            $colorStmt->execute([(int) $l[$key]]);
            $color = $colorStmt->fetch();
            if (!$color) {
                return fail($response, 'A cor escolhida já não existe. Escolhe outra.', 422);
            }
            if ($key === 'filament_id') {
                $colors[$i] = $color;
            } else {
                $colors2[$i] = $color;
            }
        }
    }

    $perHour = printerCostPerHour();
    $byCarrier = ($body['delivery_method'] ?? '') === 'carrier';

    db()->beginTransaction();
    try {
        // o número seguinte ao maior que existe (FOR UPDATE: dois pedidos ao mesmo tempo não apanham o mesmo)
        $next = (int) db()->query('SELECT COALESCE(MAX(order_number), 1000) + 1 FROM orders FOR UPDATE')->fetchColumn();

        // os portes reais: o escalão do peso total, em Portugal (zona 1)
        $shippingPaid = 0.0;
        if ($byCarrier) {
            $weight = 0;
            foreach ($lines as $l) {
                $weight += max(1, (int) ($l['quantity'] ?? 1)) * variantShippingWeightG((int) $l['variant_id']);
            }
            $price = shippingPrice($weight, 1);
            if ($price === null) {
                db()->rollBack();
                return fail($response, 'O pacote é demasiado pesado para o correio (mais de 2 kg).', 422);
            }
            $shippingPaid = $price;
        }

        db()->prepare(
            'INSERT INTO orders (order_number, channel_id, customer_id, customer_name, customer_contact,
                status, payment_status, payment_method, delivery_method, carrier_name,
                shipping_charged, shipping_paid, ship_by_date, notes, created_manually, created_by, is_seen)
             VALUES (?, ?, ?, ?, ?, \'pending\', ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, 1)'
        )->execute([
            $next,
            (int) $channel['id'],
            isset($body['customer_id']) ? (int) $body['customer_id'] : null,
            $customerName,
            ($c = trim((string) ($body['customer_contact'] ?? ''))) === '' ? null : $c,
            in_array($body['payment_status'] ?? '', ['paid', 'unpaid'], true) ? $body['payment_status'] : 'unpaid',
            $body['payment_method'] ?? null,
            in_array($body['delivery_method'] ?? '', ['carrier', 'hand', 'pickup', 'other'], true) ? $body['delivery_method'] : 'hand',
            $byCarrier ? 'CTT' : null,
            $shippingCharged = $byCarrier ? (float) ($body['shipping_charged'] ?? 0) : 0.0,
            $shippingPaid,
            toDate($body['ship_by_date'] ?? null),
            ($n = trim((string) ($body['notes'] ?? ''))) === '' ? null : $n,
            $request->getAttribute('userId'),
        ]);
        $orderId = (int) db()->lastInsertId();

        // as linhas, com as "fotografias" do custo e da taxa, calculadas aqui
        $insert = db()->prepare(
            'INSERT INTO order_lines (order_id, variant_id, quantity, unit_price, customization, unit_cost, channel_fee)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );
        foreach (array_values($lines) as $i => $l) {
            $qty = max(1, (int) ($l['quantity'] ?? 1));
            $unitPrice = (float) ($l['unit_price'] ?? 0);
            $fee = channelLineFee($channel, $qty * $unitPrice, $qty, $i === 0 ? $shippingCharged : 0.0, $i === 0);
            // a cor escolhida conta no custo; o texto "Cor: White" já vem na personalização (a app escreve-o)
            $color = $colors[$i] ?? null;
            $unitCost = variantUnitCost((int) $l['variant_id'], $perHour, $color ? (int) $color['id'] : null);
            // 2 cores: o custo fica pela mais cara das duas (do lado seguro)
            if (isset($colors2[$i])) {
                $unitCost = max($unitCost, variantUnitCost((int) $l['variant_id'], $perHour, (int) $colors2[$i]['id']));
            }
            $customization = trim((string) ($l['customization'] ?? ''));
            $insert->execute([
                $orderId,
                (int) $l['variant_id'],
                $qty,
                $unitPrice,
                $customization === '' ? null : mb_substr($customization, 0, 255), // a coluna é VARCHAR(255)
                $unitCost,
                $fee,
            ]);
        }
        // já vem paga? então vai logo para "Por imprimir" (src/production.php)
        autoStartProduction($orderId, 'user');
        db()->commit();
    } catch (Throwable $e) {
        if (db()->inTransaction()) {
            db()->rollBack();
        }
        throw $e;
    }
    return json($response, readOrders($request->getAttribute('role') === 'admin', $orderId)[0], 201);
})->add($requireAuth);

// PUT /api/orders/{id} → mudar o estado, o pagamento, o envio e as notas
// (as linhas e as contas de uma encomenda feita não mudam)
$app->put('/api/orders/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $isAdmin = $request->getAttribute('role') === 'admin';
    if (readOrders(true, $id) === []) {
        return fail($response, 'Esta encomenda já não existe.', 404);
    }
    $body = body($request);
    $allowed = [
        'status' => ['pending', 'in_production', 'ready', 'shipped', 'delivered', 'cancelled'],
        'payment_status' => ['unpaid', 'paid', 'refunded'],
    ];
    foreach ($allowed as $field => $values) {
        if (isset($body[$field]) && !in_array($body[$field], $values, true)) {
            return fail($response, "Valor inválido em $field.", 422);
        }
    }

    $sets = [];
    $values = [];
    foreach (['status', 'payment_status', 'payment_method', 'tracking_code', 'carrier_name', 'notes'] as $field) {
        if (array_key_exists($field, $body)) {
            $sets[] = "$field = ?";
            $values[] = $body[$field] === '' ? null : $body[$field];
        }
    }
    if (array_key_exists('ship_by_date', $body)) {
        $sets[] = 'ship_by_date = ?';
        $values[] = toDate($body['ship_by_date']);
    }
    if (array_key_exists('is_seen', $body)) {
        $sets[] = 'is_seen = ?';
        $values[] = $body['is_seen'] ? 1 : 0;
    }
    if ($sets !== []) {
        $values[] = $id;
        db()->prepare('UPDATE orders SET ' . implode(', ', $sets) . ' WHERE id = ?')->execute($values);
    }
    // ficou paga e ainda está pendente? vai para "Por imprimir", tarefas e estado juntos
    db()->beginTransaction();
    try {
        autoStartProduction($id, 'user');
        db()->commit();
    } catch (Throwable $e) {
        db()->rollBack();
        throw $e;
    }
    return json($response, readOrders($isAdmin, $id)[0]);
})->add($requireAuth);
