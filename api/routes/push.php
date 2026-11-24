<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ─────────── Avisos de encomendas novas (Web Push) ───────────
// Só o administrador liga avisos (src/push.php envia só a administradores).
// O aparelho manda o que o browser lhe deu: o endpoint e as chaves p256dh e auth.

// GET /api/push/key → a chave pública VAPID (o browser precisa dela para se inscrever)
$app->get('/api/push/key', function (Request $request, Response $response) {
    if (!pushConfigured()) {
        return fail($response, 'Os avisos ainda não estão configurados no servidor.', 503);
    }
    return json($response, ['public_key' => $_ENV['VAPID_PUBLIC_KEY']]);
})->add($requireAdmin)->add($requireAuth);

/** O endpoint e as chaves que vieram no pedido, já conferidos (null = pedido mal feito). */
function pushSubscriptionFrom(array $body): ?array
{
    $endpoint = trim((string) ($body['endpoint'] ?? ''));
    $keys = (array) ($body['keys'] ?? []);
    $p256dh = trim((string) ($keys['p256dh'] ?? ''));
    $auth = trim((string) ($keys['auth'] ?? ''));
    // só endereços https (os serviços de push são todos https), e chaves em base64url
    if (!str_starts_with($endpoint, 'https://') || strlen($endpoint) > 2000
        || !preg_match('/^[A-Za-z0-9_\-=]{20,255}$/', $p256dh)
        || !preg_match('/^[A-Za-z0-9_\-=]{8,64}$/', $auth)) {
        return null;
    }
    return ['endpoint' => $endpoint, 'p256dh' => $p256dh, 'auth' => $auth];
}

// POST /api/push/subscriptions → este aparelho passa a receber avisos (o mesmo aparelho atualiza)
$app->post('/api/push/subscriptions', function (Request $request, Response $response) {
    $sub = pushSubscriptionFrom(body($request));
    if ($sub === null) {
        return fail($response, 'O browser mandou um pedido de avisos inválido.', 422);
    }
    $userAgent = mb_substr($request->getHeaderLine('User-Agent'), 0, 255);
    db()->prepare(
        'INSERT INTO push_subscriptions (user_id, endpoint, endpoint_hash, p256dh, auth, user_agent)
         VALUES (?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE user_id = VALUES(user_id), p256dh = VALUES(p256dh), auth = VALUES(auth),
                                 user_agent = VALUES(user_agent)'
    )->execute([
        (int) $request->getAttribute('userId'),
        $sub['endpoint'],
        hash('sha256', $sub['endpoint']),
        $sub['p256dh'],
        $sub['auth'],
        $userAgent === '' ? null : $userAgent,
    ]);
    return json($response, ['ok' => true], 201);
})->add($requireAdmin)->add($requireAuth);

// DELETE /api/push/subscriptions → este aparelho deixa de receber (o endpoint vem no corpo)
$app->delete('/api/push/subscriptions', function (Request $request, Response $response) {
    $endpoint = trim((string) (body($request)['endpoint'] ?? ''));
    db()->prepare('DELETE FROM push_subscriptions WHERE endpoint_hash = ? AND user_id = ?')
        ->execute([hash('sha256', $endpoint), (int) $request->getAttribute('userId')]);
    return json($response, ['ok' => true]);
})->add($requireAdmin)->add($requireAuth);

// POST /api/push/test → um aviso de teste para os aparelhos de quem pede
$app->post('/api/push/test', function (Request $request, Response $response) {
    if (!pushConfigured()) {
        return fail($response, 'Os avisos ainda não estão configurados no servidor.', 503);
    }
    $result = pushNotify('Aviso de teste', 'Os avisos de encomendas novas estão a funcionar.', '/#/settings',
        null, (int) $request->getAttribute('userId'));
    return json($response, $result);
})->add($requireAdmin)->add($requireAuth);
