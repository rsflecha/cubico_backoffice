<?php
declare(strict_types=1);

// Prova por HTTP das rotas do stock (API do PC a correr em localhost:8080):
//
//   php -S localhost:8080 -t public      (dentro de api/)
//   php tests/stock-http-check.php
//
// A API corre noutro processo, por isso não dá para usar uma transação: o que o teste cria
// (utilizador colaborador, movimentos, tara e último preço do filamento) é desfeito no `finally`.
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

function check(string $name, bool $ok, mixed $got = null): void
{
    global $failures;
    if ($ok) {
        echo "PASS  $name\n";
        return;
    }
    $failures++;
    echo "FAIL  $name  (obtido: " . (is_string($got) ? $got : json_encode($got, JSON_UNESCAPED_UNICODE)) . ")\n";
}

/** Faz um pedido à API do PC; devolve [código HTTP, corpo em texto, corpo em array]. */
function call(string $method, string $path, ?array $body, string $token): array
{
    $ctx = stream_context_create(['http' => [
        'method' => $method,
        'header' => "Authorization: Bearer $token\r\nContent-Type: application/json\r\n",
        'content' => $body === null ? '' : json_encode($body),
        'ignore_errors' => true,
    ]]);
    $raw = (string) @file_get_contents("http://localhost:8080/api$path", false, $ctx);
    $code = 0;
    if (isset($http_response_header[0]) && preg_match('/\s(\d{3})\s/', $http_response_header[0], $m)) {
        $code = (int) $m[1];
    }
    $json = json_decode($raw, true);
    return [$code, $raw, is_array($json) ? $json : []];
}

$pdo = db();
$admin = $pdo->query("SELECT * FROM users WHERE role = 'admin' AND is_active = 1 ORDER BY id LIMIT 1")->fetch();
$adminToken = makeToken($admin);

$filamentId = (int) $pdo->query('SELECT id FROM filaments WHERE is_active = 1 ORDER BY id LIMIT 1')->fetchColumn();
$maxMovement = (int) $pdo->query('SELECT COALESCE(MAX(id), 0) FROM filament_movements')->fetchColumn();
$before = $pdo->query("SELECT empty_spool_g, paid_price, shipping_cost, spools_in_order FROM filaments WHERE id = $filamentId")->fetch();

try {
    // Função: limite de rolos (o campo spools_in_order é TINYINT UNSIGNED)
    $threw = false;
    try {
        recordPurchase($filamentId, 256, 15.0, 0.0, null);
    } catch (InvalidArgumentException $e) {
        $threw = true;
    }
    check('recordPurchase com 256 rolos recusada', $threw);

    $pdo->prepare('UPDATE filaments SET empty_spool_g = 250 WHERE id = ?')->execute([$filamentId]);

    // Colaborador de teste (apagado no finally)
    $pdo->prepare("DELETE FROM users WHERE email = 'stock-check@local.test'")->execute();
    $pdo->prepare("INSERT INTO users (name, email, password_hash, role) VALUES ('Teste stock', 'stock-check@local.test', ?, 'staff')")
        ->execute([password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT)]);
    $staffId = (int) $pdo->lastInsertId();
    $staffToken = makeToken($pdo->query("SELECT * FROM users WHERE id = $staffId")->fetch());

    // Compras
    [$c, , $j] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 1, 'paid_price' => 15, 'shipping_cost' => 0], $adminToken);
    check('admin compra 1 rolo: 201', $c === 201 && ($j['movement_type'] ?? '') === 'purchase', [$c, $j]);
    [$c] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 1, 'paid_price' => 15, 'shipping_cost' => 0], $staffToken);
    check('colaborador compra: 403', $c === 403, $c);
    [$c] = call('POST', "/filaments/$filamentId/adjustments", ['closed_spools' => 0, 'open_gross_g' => []], $staffToken);
    check('colaborador acerta: 403', $c === 403, $c);
    [$c] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 0, 'paid_price' => 15, 'shipping_cost' => 0], $adminToken);
    check('0 rolos: 422', $c === 422, $c);
    [$c] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 256, 'paid_price' => 15, 'shipping_cost' => 0], $adminToken);
    check('256 rolos: 422', $c === 422, $c);
    [$c] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 1, 'paid_price' => -1, 'shipping_cost' => 0], $adminToken);
    check('preço negativo: 422', $c === 422, $c);
    [$c, , $j] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 'abc', 'paid_price' => 15, 'shipping_cost' => 0], $adminToken);
    check('rolos "abc": 422 com mensagem', $c === 422 && !empty($j['error']), [$c, $j]);
    [$c] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 1, 'paid_price' => 'xyz', 'shipping_cost' => 0], $adminToken);
    check('preço "xyz": 422', $c === 422, $c);
    [$c] = call('POST', "/filaments/$filamentId/purchases", ['spools' => 1.5, 'paid_price' => 15, 'shipping_cost' => 0], $adminToken);
    check('1,5 rolos: 422', $c === 422, $c);
    [$c] = call('POST', '/filaments/999999/purchases', ['spools' => 1, 'paid_price' => 15, 'shipping_cost' => 0], $adminToken);
    check('compra num filamento que não existe: 404', $c === 404, $c);

    // Histórico
    [$c, $raw] = call('GET', "/filaments/$filamentId/movements", null, $staffToken);
    check('colaborador vê o histórico sem preços', $c === 200 && !str_contains($raw, 'paid_price') && !str_contains($raw, 'shipping_cost'), $c);
    [$c, $raw] = call('GET', "/filaments/$filamentId/movements", null, $adminToken);
    check('admin vê o histórico com preços', $c === 200 && str_contains($raw, 'paid_price'), $c);
    [$c] = call('GET', '/filaments/999999/movements', null, $adminToken);
    check('histórico de filamento que não existe: 404', $c === 404, $c);

    // Acertos
    [$c, , $j] = call('POST', "/filaments/$filamentId/adjustments", ['closed_spools' => 0, 'open_gross_g' => [240]], $adminToken);
    check('aberto mais leve que a tara: 422 com "carretel"', $c === 422 && str_contains((string) ($j['error'] ?? ''), 'carretel'), [$c, $j]);
    [$c, , $j] = call('POST', "/filaments/$filamentId/adjustments", ['closed_spools' => 'abc', 'open_gross_g' => []], $adminToken);
    check('fechados "abc": 422', $c === 422, [$c, $j]);
    [$c] = call('POST', "/filaments/$filamentId/adjustments", ['closed_spools' => 0, 'open_gross_g' => ['abc']], $adminToken);
    check('peso aberto "abc": 422', $c === 422, $c);
    [$c] = call('POST', "/filaments/$filamentId/adjustments", ['closed_spools' => 0, 'open_gross_g' => 'abc'], $adminToken);
    check('open_gross_g que não é lista: 422', $c === 422, $c);
    [$c, , $j] = call('POST', "/filaments/$filamentId/adjustments", ['closed_spools' => 1, 'open_gross_g' => [500], 'note' => 'teste'], $adminToken);
    check('acerto válido: 201', $c === 201 && ($j['movement_type'] ?? '') === 'adjustment', [$c, $j]);
    [$c, , $j] = call('POST', "/filaments/$filamentId/adjustments", ['closed_spools' => 1], $adminToken);
    check('acerto sem open_gross_g (= lista vazia): 201', $c === 201, [$c, $j]);
    [$c] = call('POST', '/filaments/999999/adjustments', ['closed_spools' => 1], $adminToken);
    check('acerto num filamento que não existe: 404', $c === 404, $c);

    // Stock e lista
    [$c, , $j] = call('GET', '/filaments/stock', null, $staffToken);
    $mine = null;
    foreach ($j as $row) {
        if (($row['filament_id'] ?? 0) === $filamentId) {
            $mine = $row;
        }
    }
    check('GET /filaments/stock: 200 e traz o filamento', $c === 200 && $mine !== null && isset($mine['stock_g'], $mine['spools'], $mine['min_stock_g']), [$c, $mine]);
    [$c, , $j] = call('GET', '/filaments', null, $staffToken);
    check('GET /filaments (colaborador) traz empty_spool_g', $c === 200 && ($j[0]['empty_spool_g'] ?? null) !== null, $j[0] ?? null);
    [$c, , $j] = call('PUT', "/filaments/$filamentId", ['empty_spool_g' => 260], $adminToken);
    check('PUT /filaments aceita empty_spool_g', $c === 200 && ($j['empty_spool_g'] ?? null) === 260, [$c, $j]);
} catch (Throwable $e) {
    $failures++;
    echo 'FAIL  exceção: ' . get_class($e) . ': ' . $e->getMessage() . "\n";
} finally {
    // Só a limpeza do teste, na base do PC: a API em si nunca apaga movimentos.
    $pdo->prepare('DELETE FROM filament_movements WHERE id > ?')->execute([$maxMovement]);
    $pdo->prepare('UPDATE filaments SET empty_spool_g = ?, paid_price = ?, shipping_cost = ?, spools_in_order = ? WHERE id = ?')
        ->execute([$before['empty_spool_g'], $before['paid_price'], $before['shipping_cost'], $before['spools_in_order'], $filamentId]);
    $pdo->prepare("DELETE FROM users WHERE email = 'stock-check@local.test'")->execute();
}

echo $failures === 0 ? "\nTudo bem.\n" : "\n$failures falha(s).\n";
exit($failures);
