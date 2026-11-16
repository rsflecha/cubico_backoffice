<?php
declare(strict_types=1);

// ═══════════════ As contas oficiais ═══════════════
// As mesmas fórmulas da CostCalculator da app (e dos testes dela).
// A app calcula para mostrar enquanto se escreve; a API refaz as contas e é o valor
// dela que fica gravado nas encomendas (a decisão do documento: "a API refaz e grava os oficiais").

/** €/kg de um filamento, já com a parte dos portes de cada rolo. */
function filamentPricePerKg(array $f): float
{
    $perSpool = (float) $f['paid_price'] + (float) $f['shipping_cost'] / max(1, (int) $f['spools_in_order']);
    return $perSpool / ((int) $f['spool_weight_g'] / 1000);
}

/** Custo por hora da impressora principal: luz + desgaste + manutenção. */
function printerCostPerHour(): float
{
    $printer = db()->query('SELECT * FROM printers ORDER BY is_default DESC, id LIMIT 1')->fetch();
    if (!$printer) {
        return 0;
    }
    $kwh = readSettings()['kwh_price'];
    return (int) $printer['power_w'] / 1000 * $kwh
        + (float) $printer['purchase_price'] / max(1, (int) $printer['lifespan_hours'])
        + (float) $printer['yearly_maintenance'] / max(1, (int) $printer['yearly_hours']);
}

/** Custo de produção de uma unidade de uma variante: filamento + impressão + componentes. */
function variantUnitCost(int $variantId, float $costPerHour): float
{
    $stmt = db()->prepare('SELECT print_time_min FROM variants WHERE id = ?');
    $stmt->execute([$variantId]);
    $minutes = (int) $stmt->fetchColumn();
    $total = $minutes / 60 * $costPerHour;

    $filaments = db()->prepare(
        'SELECT vf.grams, f.* FROM variant_filaments vf JOIN filaments f ON f.id = vf.filament_id WHERE vf.variant_id = ?'
    );
    $filaments->execute([$variantId]);
    foreach ($filaments->fetchAll() as $f) {
        $total += (int) $f['grams'] * filamentPricePerKg($f) / 1000;
    }

    $components = db()->prepare(
        'SELECT vc.quantity, c.pack_price, c.units_per_pack
         FROM variant_components vc JOIN components c ON c.id = vc.component_id WHERE vc.variant_id = ?'
    );
    $components->execute([$variantId]);
    foreach ($components->fetchAll() as $c) {
        $total += (int) $c['quantity'] * (float) $c['pack_price'] / max(1, (int) $c['units_per_pack']);
    }
    return round($total, 2);
}

/** Peso de envio de uma unidade de uma variante: a peça + os componentes e a embalagem. */
function variantShippingWeightG(int $variantId): int
{
    $stmt = db()->prepare('SELECT weight_g FROM variants WHERE id = ?');
    $stmt->execute([$variantId]);
    $weight = (int) $stmt->fetchColumn();

    $components = db()->prepare(
        'SELECT vc.quantity, c.weight_g FROM variant_components vc JOIN components c ON c.id = vc.component_id WHERE vc.variant_id = ?'
    );
    $components->execute([$variantId]);
    foreach ($components->fetchAll() as $c) {
        $weight += (int) $c['quantity'] * (int) $c['weight_g'];
    }
    return $weight;
}

/** O preço dos portes para um peso numa zona, ou null se for mais pesado do que todos os escalões. */
function shippingPrice(int $weightG, int $zoneId): ?float
{
    $stmt = db()->prepare(
        'SELECT price FROM shipping_rates WHERE zone_id = ? AND max_weight_g >= ? ORDER BY max_weight_g LIMIT 1'
    );
    $stmt->execute([$zoneId, $weightG]);
    $price = $stmt->fetchColumn();
    return $price === false ? null : (float) $price;
}

/**
 * A taxa do canal numa linha de encomenda (as regras da Etsy, iguais em
 * app/lib/features/costs/domain/cost_calculator.dart → channelFees):
 * - transação e processamento: % sobre o valor da linha e sobre os portes cobrados
 *   (os portes entram só na primeira linha, para não contarem duas vezes);
 * - o valor fixo (flat_fee): uma vez por encomenda, na primeira linha;
 * - a taxa de anúncio (listing_fee): uma vez por cada unidade vendida.
 */
function channelLineFee(array $channel, float $lineValue, int $qty, float $shipping, bool $isFirst): float
{
    $pct = ((float) $channel['transaction_fee'] + (float) $channel['processing_fee']) / 100;
    $fee = ($lineValue + $shipping) * $pct + (float) $channel['listing_fee'] * $qty;
    if ($isFirst) {
        $fee += (float) $channel['flat_fee'];
    }
    return round($fee, 2);
}

// ═══ Definições (tabela settings) ═══
// Aqui, e não em routes/costs.php, porque as contas também as usam (e o bin/etsy-sync.php).
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
