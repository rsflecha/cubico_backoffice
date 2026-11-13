<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as Handler;

// ═══════════════ CORS ═══════════════
// O browser só deixa um site (ex.: https://app.fazendasubmersa.pt) falar com uma API noutro
// endereço (https://api.fazendasubmersa.pt) se a API disser que esse site é de confiança.
// A app de Windows e a de Android não passam por isto: só os browsers.

/** Este endereço de origem está na lista CORS_ORIGINS do .env? */
function isAllowedOrigin(string $origin): bool
{
    if ($origin === '') {
        return false;
    }
    $allowed = array_filter(array_map('trim', explode(',', $_ENV['CORS_ORIGINS'] ?? '')));
    foreach ($allowed as $entry) {
        if ($entry === $origin) {
            return true;
        }
        // "http://localhost:*" aceita qualquer porta (o flutter run -d chrome usa uma porta diferente cada vez)
        if (str_ends_with($entry, ':*') && str_starts_with($origin, substr($entry, 0, -1))) {
            return true;
        }
    }
    return false;
}

$cors = function (Request $request, Handler $handler): Response {
    // o browser pergunta primeiro "posso?" com um pedido OPTIONS; responde-se logo, sem ir às rotas
    $response = $request->getMethod() === 'OPTIONS'
        ? new Slim\Psr7\Response(204)
        : $handler->handle($request);

    $origin = $request->getHeaderLine('Origin');
    if (!isAllowedOrigin($origin)) {
        return $response; // sem os cabeçalhos, o browser bloqueia a resposta
    }
    return $response
        ->withHeader('Access-Control-Allow-Origin', $origin)
        ->withHeader('Vary', 'Origin')
        ->withHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type')
        ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        ->withHeader('Access-Control-Max-Age', '600'); // o browser guarda a resposta 10 minutos
};
