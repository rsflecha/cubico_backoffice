<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// GET /api/etsy/status → a loja está ligada? (só o administrador)
$app->get('/api/etsy/status', function (Request $request, Response $response) {
    return json($response, etsyStatus());
})->add($requireAdmin)->add($requireAuth);

// POST /api/etsy/connect → o endereço da Etsy onde se autoriza a app (só o administrador)
$app->post('/api/etsy/connect', function (Request $request, Response $response) {
    if (!etsyConfigured()) {
        return fail($response, 'Falta a chave da app Etsy no .env do servidor (ETSY_KEYSTRING, ETSY_SHARED_SECRET e ETSY_REDIRECT_URI).', 409);
    }
    return json($response, ['url' => etsyStartConnect((int) $request->getAttribute('userId'))]);
})->add($requireAdmin)->add($requireAuth);

// DELETE /api/etsy/connection → desligar a loja (só o administrador)
$app->delete('/api/etsy/connection', function (Request $request, Response $response) {
    db()->exec('DELETE FROM etsy_connection WHERE id = 1');
    return $response->withStatus(204);
})->add($requireAdmin)->add($requireAuth);

// GET /api/etsy/callback → a Etsy volta aqui depois de o Rui autorizar.
// Não leva token de sessão (quem chega é o browser, vindo da Etsy): quem protege é o "state",
// que só existe se um administrador tiver carregado em "Ligar à Etsy" há menos de 10 minutos.
$app->get('/api/etsy/callback', function (Request $request, Response $response) {
    $q = $request->getQueryParams();
    try {
        if (isset($q['error'])) {
            // o Rui carregou em "recusar", ou a Etsy deu erro
            throw new EtsyException('A Etsy não autorizou a ligação: ' . (string) ($q['error_description'] ?? $q['error']));
        }
        if (!etsyConfigured() || empty($q['state']) || empty($q['code'])) {
            throw new EtsyException('Faltam dados no regresso da Etsy.');
        }
        $shop = etsyFinishConnect((string) $q['state'], (string) $q['code']);
        return etsyPage($response, 'Loja ligada', "A loja «{$shop}» ficou ligada ao backoffice. Podes fechar esta janela e voltar à app.", 200);
    } catch (EtsyException $e) {
        return etsyPage($response, 'Não foi possível ligar', $e->getMessage(), 400);
    }
});

/** Uma página simples para o fim da ligação (quem a vê é o browser, não a app). */
function etsyPage(Response $response, string $title, string $message, int $status): Response
{
    $t = htmlspecialchars($title, ENT_QUOTES);
    $m = htmlspecialchars($message, ENT_QUOTES);
    $response->getBody()->write(<<<HTML
        <!doctype html><html lang="pt-PT"><head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1"><title>{$t}</title>
        <style>body{font-family:system-ui,sans-serif;background:#1c1917;color:#f5f5f4;display:grid;place-items:center;min-height:100vh;margin:0;padding:16px}
        main{max-width:420px}h1{font-size:1.4rem}p{line-height:1.5;color:#d6d3d1}</style></head>
        <body><main><h1>{$t}</h1><p>{$m}</p></main></body></html>
        HTML);
    return $response->withHeader('Content-Type', 'text/html; charset=utf-8')->withStatus($status);
}
