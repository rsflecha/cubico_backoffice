<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Códigos postais ═══════════════
// A localidade de um código postal português (tabela postal_codes, base dos CTT).
// Com sessão: serve o formulário do cliente.

// GET /api/postal-codes/4700-000 → { postal_code, locality, municipality, district }, ou 404
$app->get('/api/postal-codes/{code}', function (Request $request, Response $response, array $args) {
    $code = (string) $args['code'];
    if (!preg_match('/^\d{4}-\d{3}$/', $code)) {
        return fail($response, 'O código postal tem o formato 4700-000.', 422);
    }
    $stmt = db()->prepare('SELECT code, locality, municipality, district FROM postal_codes WHERE code = ?');
    $stmt->execute([$code]);
    $row = $stmt->fetch();
    if (!$row) {
        return fail($response, 'Código postal não encontrado.', 404);
    }
    return json($response, [
        'postal_code' => $row['code'],
        'locality' => $row['locality'],
        'municipality' => $row['municipality'],
        'district' => $row['district'],
    ]);
})->add($requireAuth);
