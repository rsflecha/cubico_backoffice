<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/** A palavra-passe nova tem de ter pelo menos isto. */
const MIN_PASSWORD_LENGTH = 10; // o mesmo que o bin/create-user.php

// POST /api/auth/login → email, palavra-passe e "remember" (Manter sessão); devolve o token e o utilizador
$app->post('/api/auth/login', function (Request $request, Response $response) {
    $body = body($request);
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    $password = (string) ($body['password'] ?? '');
    $remember = ($body['remember'] ?? false) === true;

    // o "?" é preenchido pelo PDO de forma segura (nunca juntar texto do utilizador ao SQL)
    $stmt = db()->prepare('SELECT * FROM users WHERE email = ? AND is_active = 1');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    // a mesma mensagem para email errado e palavra-passe errada, de propósito
    if (!$user || !password_verify($password, $user['password_hash'])) {
        return fail($response, 'Email ou palavra-passe errados.', 401);
    }

    db()->prepare('UPDATE users SET last_login_at = NOW() WHERE id = ?')->execute([$user['id']]);
    return json($response, ['token' => makeToken($user, $remember), 'user' => publicUser($user)]);
});

// GET /api/auth/me → quem sou eu? (a app usa-o para confirmar uma sessão guardada)
$app->get('/api/auth/me', function (Request $request, Response $response) {
    $stmt = db()->prepare('SELECT * FROM users WHERE id = ? AND is_active = 1');
    $stmt->execute([$request->getAttribute('userId')]);
    $user = $stmt->fetch();
    if (!$user) {
        return fail($response, 'Já não tens acesso a esta loja.', 401);
    }
    return json($response, ['user' => publicUser($user)]);
})->add($requireAuth);

// POST /api/auth/password → mudar a própria palavra-passe (pede a atual)
// Devolve um token novo: o antigo deixa de valer, porque a "impressão" da palavra-passe mudou.
$app->post('/api/auth/password', function (Request $request, Response $response) {
    $body = body($request);
    $current = (string) ($body['current_password'] ?? '');
    $new = (string) ($body['new_password'] ?? '');
    $remember = ($body['remember'] ?? false) === true;

    $stmt = db()->prepare('SELECT * FROM users WHERE id = ? AND is_active = 1');
    $stmt->execute([$request->getAttribute('userId')]);
    $user = $stmt->fetch();
    if (!$user) {
        return fail($response, 'Já não tens acesso a esta loja.', 401);
    }
    // 422 e não 401: a sessão está boa, só a palavra-passe atual é que está errada
    if (!password_verify($current, $user['password_hash'])) {
        return fail($response, 'A palavra-passe atual está errada.', 422);
    }
    if (mb_strlen($new) < MIN_PASSWORD_LENGTH) {
        return fail($response, 'A palavra-passe nova tem de ter pelo menos ' . MIN_PASSWORD_LENGTH . ' caracteres.', 422);
    }
    if (password_verify($new, $user['password_hash'])) {
        return fail($response, 'A palavra-passe nova tem de ser diferente da atual.', 422);
    }

    $hash = password_hash($new, PASSWORD_DEFAULT);
    db()->prepare('UPDATE users SET password_hash = ? WHERE id = ?')->execute([$hash, $user['id']]);
    $user['password_hash'] = $hash;
    return json($response, ['token' => makeToken($user, $remember)]);
})->add($requireAuth);
