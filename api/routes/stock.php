<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Stock de filamento ═══════════════
// O stock é a soma dos movimentos (src/stock.php). Aqui só há pedidos: validar o que veio,
// chamar as contas e responder. Os movimentos nunca se editam nem se apagam: não há PUT nem DELETE.
// "/api/filaments/stock" tem de ser registada antes de qualquer "/api/filaments/{id}" que o apanhasse
// (hoje só há PUT com {id}, mas assim fica à prova de futuro).

/** Um inteiro vindo do JSON (aceita "3" em texto); null se não for um inteiro. */
function stockInt(mixed $value): ?int
{
    if (is_int($value)) {
        return $value;
    }
    if (is_string($value) && preg_match('/^\s*-?\d+\s*$/', $value) === 1) {
        return (int) trim($value);
    }
    if (is_float($value) && floor($value) === $value && abs($value) < 1e9) {
        return (int) $value;
    }
    return null;
}

/** Um número vindo do JSON (aceita "12.5" em texto); null se não for um número. */
function stockNumber(mixed $value): ?float
{
    if (is_int($value) || is_float($value)) {
        return (float) $value;
    }
    if (is_string($value) && is_numeric(trim($value))) {
        return (float) trim($value);
    }
    return null;
}

/** O filamento existe? */
function stockFilamentExists(int $id): bool
{
    $st = db()->prepare('SELECT 1 FROM filaments WHERE id = ?');
    $st->execute([$id]);
    return $st->fetchColumn() !== false;
}

/** O movimento acabado de gravar (com preços: só o administrador chega aqui); null se não aparecer. */
function stockMovementById(int $filamentId, int $movementId): ?array
{
    return filamentMovements($filamentId, true, $movementId)[0] ?? null;
}

/** Responde 201 com o movimento; se não o encontrar, é erro do servidor, nunca um 201 vazio. */
function stockCreated(Response $response, int $filamentId, int $movementId): Response
{
    $movement = stockMovementById($filamentId, $movementId);
    if ($movement === null) {
        return fail($response, 'O movimento foi gravado mas não foi possível lê-lo. Atualize a página e confirme o histórico.', 500);
    }
    return json($response, $movement, 201);
}

// GET /api/filaments/stock → [{filament_id, stock_g, spools, min_stock_g}] (todos com sessão)
$app->get('/api/filaments/stock', function (Request $request, Response $response) {
    return json($response, filamentStocks());
})->add($requireAuth);

// GET /api/filaments/{id}/movements → o histórico; o colaborador não recebe preços
$app->get('/api/filaments/{id}/movements', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    if (!stockFilamentExists($id)) {
        return fail($response, 'Esse filamento não existe.', 404);
    }
    $isAdmin = $request->getAttribute('role') === 'admin';
    return json($response, filamentMovements($id, $isAdmin));
})->add($requireAuth);

// POST /api/filaments/{id}/purchases → comprar rolos (só administrador)
$app->post('/api/filaments/{id}/purchases', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $body = body($request);

    $spools = stockInt($body['spools'] ?? null);
    if ($spools === null) {
        return fail($response, 'O número de rolos tem de ser um número inteiro.', 422);
    }
    $paid = stockNumber($body['paid_price'] ?? null);
    $shipping = stockNumber($body['shipping_cost'] ?? 0);
    if ($paid === null || $shipping === null) {
        return fail($response, 'O preço e os portes têm de ser números.', 422);
    }
    if (!stockFilamentExists($id)) {
        return fail($response, 'Esse filamento não existe.', 404);
    }

    try {
        $movementId = recordPurchase($id, $spools, $paid, $shipping, $request->getAttribute('userId'));
    } catch (InvalidArgumentException $e) {
        return fail($response, $e->getMessage(), 422);
    }
    return stockCreated($response, $id, $movementId);
})->add($requireAdmin)->add($requireAuth);

// POST /api/filaments/{id}/adjustments → acerto por pesagem (só administrador)
$app->post('/api/filaments/{id}/adjustments', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $body = body($request);

    $closed = stockInt($body['closed_spools'] ?? null);
    if ($closed === null) {
        return fail($response, 'Os rolos fechados têm de ser um número inteiro.', 422);
    }
    $gross = $body['open_gross_g'] ?? [];
    if (!is_array($gross) || !array_is_list($gross)) {
        return fail($response, 'Os pesos dos rolos abertos têm de ser uma lista de números.', 422);
    }
    $grossNumbers = [];
    foreach ($gross as $value) {
        $number = stockNumber($value);
        if ($number === null) {
            return fail($response, 'O peso de cada rolo aberto tem de ser um número.', 422);
        }
        $grossNumbers[] = $number;
    }
    $note = $body['note'] ?? null;
    if ($note !== null && !is_string($note)) {
        return fail($response, 'A nota tem de ser texto.', 422);
    }
    if (!stockFilamentExists($id)) {
        return fail($response, 'Esse filamento não existe.', 404);
    }

    try {
        $movementId = recordAdjustment($id, $closed, $grossNumbers, $note, $request->getAttribute('userId'));
    } catch (InvalidArgumentException $e) {
        return fail($response, $e->getMessage(), 422);
    }
    return stockCreated($response, $id, $movementId);
})->add($requireAdmin)->add($requireAuth);
