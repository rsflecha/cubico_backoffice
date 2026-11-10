<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// POST /api/auth/login → email e palavra-passe; devolve o token e o utilizador
$app->post('/api/auth/login', function (Request $request, Response $response) {
    $body = body($request);
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    $password = (string) ($body['password'] ?? '');

    // o "?" é preenchido pelo PDO de forma segura (nunca juntar texto do utilizador ao SQL)
    $stmt = db()->prepare('SELECT * FROM users WHERE email = ? AND is_active = 1');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    // a mesma mensagem para email errado e palavra-passe errada, de propósito
    if (!$user || !password_verify($password, $user['password_hash'])) {
        return fail($response, 'Email ou palavra-passe errados.', 401);
    }

    db()->prepare('UPDATE users SET last_login_at = NOW() WHERE id = ?')->execute([$user['id']]);
    return json($response, ['token' => makeToken($user), 'user' => publicUser($user)]);
});

// GET /api/auth/me → quem sou eu?
$app->get('/api/auth/me', function (Request $request, Response $response) {
    $stmt = db()->prepare('SELECT * FROM users WHERE id = ? AND is_active = 1');
    $stmt->execute([$request->getAttribute('userId')]);
    $user = $stmt->fetch();
    if (!$user) {
        return fail($response, 'Este utilizador já não tem acesso.', 401);
    }
    return json($response, ['user' => publicUser($user)]);
})->add($requireAuth);
