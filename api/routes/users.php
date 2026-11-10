<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Utilizadores ═══════════════
// Só o administrador. Retirar o acesso DESATIVA o utilizador (is_active = 0) em vez de o apagar:
// as encomendas que ele criou continuam a saber quem as fez.

/** Os utilizadores ativos (ou um). */
function readUsers(?int $id = null): array
{
    $stmt = db()->prepare(
        'SELECT * FROM users WHERE is_active = 1' . ($id === null ? '' : ' AND id = ?') . ' ORDER BY name'
    );
    $stmt->execute($id === null ? [] : [$id]);
    return array_map('publicUser', $stmt->fetchAll());
}

/** Quantos administradores ativos há. */
function adminCount(): int
{
    return (int) db()->query("SELECT COUNT(*) FROM users WHERE is_active = 1 AND role = 'admin'")->fetchColumn();
}

// GET /api/users
$app->get('/api/users', function (Request $request, Response $response) {
    return json($response, readUsers());
})->add($requireAdmin)->add($requireAuth);

// POST /api/users → criar, com uma palavra-passe provisória que só aparece nesta resposta
$app->post('/api/users', function (Request $request, Response $response) {
    $body = body($request);
    $name = trim((string) ($body['name'] ?? ''));
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    $role = ($body['role'] ?? 'staff') === 'admin' ? 'admin' : 'staff';
    if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return fail($response, 'Falta o nome, ou o email não é válido.', 422);
    }

    // 12 caracteres aleatórios, sem letras que se confundem (0/O, 1/l/I)
    $alphabet = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $temporary = '';
    for ($i = 0; $i < 12; $i++) {
        $temporary .= $alphabet[random_int(0, strlen($alphabet) - 1)];
    }

    try {
        db()->prepare('INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)')
            ->execute([$name, $email, password_hash($temporary, PASSWORD_DEFAULT), $role]);
    } catch (PDOException $e) {
        if (isDuplicate($e)) {
            return fail($response, 'Já existe um utilizador com este email.', 409);
        }
        throw $e;
    }
    return json($response, [
        'user' => readUsers((int) db()->lastInsertId())[0],
        'temporary_password' => $temporary,
    ], 201);
})->add($requireAdmin)->add($requireAuth);

// PUT /api/users/{id} → mudar o nome ou o papel
$app->put('/api/users/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $current = readUsers($id)[0] ?? null;
    if ($current === null) {
        return fail($response, 'Este utilizador já não existe.', 404);
    }
    $body = body($request);
    $role = ($body['role'] ?? $current['role']) === 'admin' ? 'admin' : 'staff';

    if ($role !== $current['role']) {
        if ($id === $request->getAttribute('userId')) {
            return fail($response, 'Não podes mudar o teu próprio papel.', 409);
        }
        if ($current['role'] === 'admin' && adminCount() <= 1) {
            return fail($response, 'Tem de haver sempre pelo menos um administrador.', 409);
        }
    }
    $name = trim((string) ($body['name'] ?? $current['name']));
    db()->prepare('UPDATE users SET name = ?, role = ? WHERE id = ?')->execute([$name, $role, $id]);
    return json($response, readUsers($id)[0]);
})->add($requireAdmin)->add($requireAuth);

// DELETE /api/users/{id} → retirar o acesso (desativar)
$app->delete('/api/users/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $current = readUsers($id)[0] ?? null;
    if ($current === null) {
        return fail($response, 'Este utilizador já não existe.', 404);
    }
    if ($id === $request->getAttribute('userId')) {
        return fail($response, 'Não te podes retirar a ti próprio.', 409);
    }
    if ($current['role'] === 'admin' && adminCount() <= 1) {
        return fail($response, 'Tem de haver sempre pelo menos um administrador.', 409);
    }
    db()->prepare('UPDATE users SET is_active = 0 WHERE id = ?')->execute([$id]);
    return $response->withStatus(204);
})->add($requireAdmin)->add($requireAuth);
