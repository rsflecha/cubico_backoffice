<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Custos e preços ═══════════════
// Tudo o que custa produzir e enviar. Só o administrador vê e muda,
// exceto os canais, que o colaborador vê sem as taxas (precisa deles para criar encomendas).

// ─────────── Filamentos ───────────
tableRoutes($app, '/api/filaments', 'filaments', [
    'id' => 'int',
    'material' => 'string',
    'brand' => 'string',
    'color_name' => 'string',
    'color_hex' => 'string',
    'spool_weight_g' => 'int',
    'list_price' => 'float',
    'paid_price' => 'float',
    'shipping_cost' => 'float',
    'spools_in_order' => 'int',
    'min_stock_g' => 'int',
    'is_active' => 'bool',
], required: ['material', 'color_name', 'list_price', 'paid_price'], canCreate: true,
   orderBy: 'material, color_name', requireAuth: $requireAuth, requireAdmin: $requireAdmin);

// ─────────── Embalagens e componentes ───────────
tableRoutes($app, '/api/components', 'components', [
    'id' => 'int',
    'name' => 'string',
    'kind' => 'string',
    'size_label' => 'string',
    'weight_g' => 'int',
    'pack_price' => 'float',
    'units_per_pack' => 'int',
    'stock_qty' => 'int',
    'min_stock_qty' => 'int',
], required: ['name', 'kind', 'pack_price'], canCreate: true,
   orderBy: 'kind, name', requireAuth: $requireAuth, requireAdmin: $requireAdmin);

// ─────────── Impressoras (só mudar) ───────────
tableRoutes($app, '/api/printers', 'printers', [
    'id' => 'int',
    'name' => 'string',
    'power_w' => 'int',
    'purchase_price' => 'float',
    'lifespan_hours' => 'int',
    'yearly_maintenance' => 'float',
    'yearly_hours' => 'int',
    'is_default' => 'bool',
], required: [], canCreate: false,
   orderBy: 'is_default DESC, name', requireAuth: $requireAuth, requireAdmin: $requireAdmin);

// ─────────── Escalões de portes (só mudar) ───────────
tableRoutes($app, '/api/shipping-rates', 'shipping_rates', [
    'id' => 'int',
    'carrier_id' => 'int',
    'zone_id' => 'int',
    'max_weight_g' => 'int',
    'price' => 'float',
], required: [], canCreate: false,
   orderBy: 'zone_id, max_weight_g', requireAuth: $requireAuth, requireAdmin: $requireAdmin);

// ─────────── Canais de venda ───────────
const CHANNEL_TYPES = [
    'id' => 'int',
    'code' => 'string',
    'name' => 'string',
    'transaction_fee' => 'float',
    'processing_fee' => 'float',
    'flat_fee' => 'float',
    'listing_fee' => 'float',
    'is_automatic' => 'bool',
];

// GET /api/channels → todos com sessão; o colaborador não recebe as taxas
$app->get('/api/channels', function (Request $request, Response $response) {
    $rows = db()->query('SELECT * FROM channels ORDER BY id')->fetchAll();
    $isAdmin = $request->getAttribute('role') === 'admin';
    $channels = array_map(function ($row) use ($isAdmin) {
        $channel = typed($row, CHANNEL_TYPES);
        if (!$isAdmin) {
            // esconder no servidor, e não só no ecrã: o colaborador nem recebe estes valores
            unset($channel['transaction_fee'], $channel['processing_fee'], $channel['flat_fee'], $channel['listing_fee']);
        }
        return $channel;
    }, $rows);
    return json($response, $channels);
})->add($requireAuth);

// PUT /api/channels/{id} → mudar as taxas (só o administrador; o código e o nome não mudam)
$app->put('/api/channels/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $body = body($request);
    $fees = ['transaction_fee', 'processing_fee', 'flat_fee', 'listing_fee'];
    foreach ($fees as $fee) {
        if (!isset($body[$fee]) || (float) $body[$fee] < 0) {
            return fail($response, 'As taxas têm de estar preenchidas e não podem ser negativas.', 422);
        }
    }
    if ((float) $body['transaction_fee'] + (float) $body['processing_fee'] >= 100) {
        return fail($response, 'As percentagens juntas têm de ficar abaixo de 100%.', 422);
    }
    $stmt = db()->prepare(
        'UPDATE channels SET transaction_fee = ?, processing_fee = ?, flat_fee = ?, listing_fee = ? WHERE id = ?'
    );
    $stmt->execute([...array_map(fn ($f) => (float) $body[$f], $fees), $id]);

    $row = db()->prepare('SELECT * FROM channels WHERE id = ?');
    $row->execute([$id]);
    $channel = $row->fetch();
    if (!$channel) {
        return fail($response, 'Este canal já não existe.', 404);
    }
    return json($response, typed($channel, CHANNEL_TYPES));
})->add($requireAdmin)->add($requireAuth);

// ─────────── Definições (tabela settings: chave → valor) ───────────
// Na base de dados são linhas soltas (kwh_price = 0.21…); a app recebe um objeto só.
// À esquerda o nome na app, à direita a chave na tabela e o tipo.
const SETTINGS_MAP = [
    'kwh_price' => ['kwh_price', 'float'],
    'target_margin_pct' => ['target_margin', 'float'],
    'min_margin_pct' => ['min_margin', 'float'],
    'rounding' => ['rounding', 'float'],
    'hourly_rate' => ['hourly_rate', 'float'],
    'include_fixed_costs' => ['include_fixed_costs', 'bool'],
];

/** As definições, como um objeto para a app. */
function readSettings(): array
{
    $rows = db()->query('SELECT setting_key, setting_value FROM settings')->fetchAll();
    $byKey = array_column($rows, 'setting_value', 'setting_key');
    $out = [];
    foreach (SETTINGS_MAP as $field => [$key, $type]) {
        $value = $byKey[$key] ?? '0';
        $out[$field] = $type === 'bool' ? $value === '1' : (float) $value;
    }
    return $out;
}

// GET /api/settings → as definições de custos
$app->get('/api/settings', function (Request $request, Response $response) {
    return json($response, readSettings());
})->add($requireAdmin)->add($requireAuth);

// PUT /api/settings → gravar as definições
$app->put('/api/settings', function (Request $request, Response $response) {
    $body = body($request);
    if (isset($body['target_margin_pct'], $body['min_margin_pct'])
        && (float) $body['min_margin_pct'] >= (float) $body['target_margin_pct']) {
        return fail($response, 'A margem mínima tem de ser menor do que a margem alvo.', 422);
    }
    // grava cada valor que veio; se a chave não existir na tabela, cria-a
    $stmt = db()->prepare(
        'INSERT INTO settings (setting_key, setting_value) VALUES (?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
    );
    foreach (SETTINGS_MAP as $field => [$key, $type]) {
        if (array_key_exists($field, $body)) {
            $value = $type === 'bool' ? ($body[$field] ? '1' : '0') : (string) (float) $body[$field];
            $stmt->execute([$key, $value]);
        }
    }
    return json($response, readSettings());
})->add($requireAdmin)->add($requireAuth);
