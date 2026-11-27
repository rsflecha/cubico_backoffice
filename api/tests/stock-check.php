<?php
declare(strict_types=1);

// Prova das contas do stock (src/stock.php), na linha de comandos:
//
//   php api/tests/stock-check.php
//
// Corre tudo dentro de uma transação e acaba SEMPRE em rollBack(): a base fica igual.
// Imprime PASS/FAIL por caso e sai com o número de falhas (0 = tudo bem).

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require __DIR__ . '/../vendor/autoload.php';
Dotenv\Dotenv::createImmutable(__DIR__ . '/..')->load();
require __DIR__ . '/../src/db.php';
require __DIR__ . '/../src/helpers.php';
require __DIR__ . '/../src/stock.php';

$failures = 0;

/** Regista um caso: PASS se $ok, senão FAIL com o que se obteve. */
function check(string $name, bool $ok, mixed $got = null): void
{
    global $failures;
    if ($ok) {
        echo "PASS  $name\n";
        return;
    }
    $failures++;
    echo "FAIL  $name  (obtido: " . json_encode($got) . ")\n";
}

/** Chama $fn e devolve a mensagem da InvalidArgumentException, ou null se não lançou. */
function thrownMessage(callable $fn): ?string
{
    try {
        $fn();
    } catch (InvalidArgumentException $e) {
        return $e->getMessage();
    }
    return null;
}

$pdo = db();
$pdo->beginTransaction();

try {
    $filamentId = (int) $pdo->query('SELECT id FROM filaments WHERE is_active = 1 ORDER BY id LIMIT 1')->fetchColumn();
    if ($filamentId === 0) {
        throw new RuntimeException('Não há filamentos ativos para testar.');
    }
    // Valores fixos, só dentro desta transação.
    $pdo->prepare('UPDATE filaments SET spool_weight_g = 1000, empty_spool_g = 250 WHERE id = ?')->execute([$filamentId]);
    $pdo->prepare('DELETE FROM filament_movements WHERE filament_id = ?')->execute([$filamentId]);

    // Sem movimentos
    $s = filamentStock($filamentId);
    check('sem movimentos: stock 0.0', $s === 0.0, $s);

    // Compra
    $id = recordPurchase($filamentId, 2, 15.00, 4.90, null);
    $s = filamentStock($filamentId);
    check('compra de 2 rolos: stock 2000.0', $s === 2000.0, $s);
    $f = $pdo->query("SELECT paid_price, shipping_cost, spools_in_order FROM filaments WHERE id = $filamentId")->fetch();
    check(
        'compra atualiza paid_price/shipping_cost/spools_in_order',
        (float) $f['paid_price'] === 15.0 && (float) $f['shipping_cost'] === 4.9 && (int) $f['spools_in_order'] === 2,
        $f
    );
    check('recordPurchase devolve o id', $id > 0, $id);
    check(
        'compra com 0 rolos recusada',
        thrownMessage(fn() => recordPurchase($filamentId, 0, 15.0, 0.0, null)) !== null
    );
    check(
        'compra com preço negativo recusada',
        thrownMessage(fn() => recordPurchase($filamentId, 1, -1.0, 0.0, null)) !== null
    );

    // weighedTotal
    $t = weighedTotal(2, 1000, [712], 250);
    check('weighedTotal(2,1000,[712],250) = 2462.0', $t === 2462.0, $t);
    $t = weighedTotal(0, 750, [], 250);
    check('weighedTotal(0,750,[],250) = 0.0', $t === 0.0, $t);
    $t = weighedTotal(3, 750, [], 0);
    check('weighedTotal(3,750,[],0) = 2250.0', $t === 2250.0, $t);
    $m = thrownMessage(fn() => weighedTotal(0, 1000, [240], 250));
    check('aberto mais leve que a tara recusado (carretel)', $m !== null && str_contains($m, 'carretel'), $m);
    $m = thrownMessage(fn() => weighedTotal(0, 1000, [500], 0));
    check('aberto com tara 0 recusado (Custos e preços)', $m !== null && str_contains($m, 'Custos e preços'), $m);
    check('fechados negativos recusados', thrownMessage(fn() => weighedTotal(-1, 1000, [], 250)) !== null);
    check('peso aberto 0 recusado', thrownMessage(fn() => weighedTotal(0, 1000, [0], 250)) !== null);

    // Acertos
    $adj = recordAdjustment($filamentId, 2, [712], 'pesado', null);
    $row = $pdo->query("SELECT grams, note, movement_type FROM filament_movements WHERE id = $adj")->fetch();
    $s = filamentStock($filamentId);
    check('acerto: movimento +462.00', $row['grams'] === '462.00' && $row['movement_type'] === 'adjustment', $row);
    check('acerto: stock 2462.0', $s === 2462.0, $s);
    check(
        'acerto: nota com 712 g e pesado',
        str_contains((string) $row['note'], '712 g') && str_contains((string) $row['note'], 'pesado'),
        $row['note']
    );
    $adj2 = recordAdjustment($filamentId, 2, [712], 'pesado', null);
    $row2 = $pdo->query("SELECT grams FROM filament_movements WHERE id = $adj2")->fetch();
    $s = filamentStock($filamentId);
    check('segundo acerto igual: movimento 0.00 gravado', $row2['grams'] === '0.00', $row2);
    check('segundo acerto igual: stock igual', $s === 2462.0, $s);

    // Movimentos
    $without = filamentMovements($filamentId, false);
    $with = filamentMovements($filamentId, true);
    check(
        'sem preços: sem paid_price nem shipping_cost',
        !array_key_exists('paid_price', $without[0]) && !array_key_exists('shipping_cost', $without[0]),
        array_keys($without[0])
    );
    check(
        'com preços: tem paid_price e shipping_cost',
        array_key_exists('paid_price', $with[0]) && array_key_exists('shipping_cost', $with[0]),
        array_keys($with[0])
    );
    check('o primeiro é o mais recente', (int) $with[0]['id'] === $adj2, $with[0]['id']);
    check('tem user_name', array_key_exists('user_name', $with[0]), array_keys($with[0]));

    // Todos os filamentos
    $all = filamentStocks();
    $mine = null;
    foreach ($all as $row) {
        if ($row['filament_id'] === $filamentId) {
            $mine = $row;
        }
    }
    check(
        'filamentStocks: stock 2462.0 e spools 2.5',
        $mine !== null && $mine['stock_g'] === 2462.0 && $mine['spools'] === 2.5 && is_int($mine['min_stock_g']),
        $mine
    );
} catch (Throwable $e) {
    $failures++;
    echo 'FAIL  exceção: ' . get_class($e) . ': ' . $e->getMessage() . "\n";
} finally {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
}

echo $failures === 0 ? "\nTudo bem.\n" : "\n$failures falha(s).\n";
exit($failures);
