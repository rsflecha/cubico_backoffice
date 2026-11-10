<?php
declare(strict_types=1);

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as Handler;

/**
 * Porteiro 1: só deixa passar pedidos com um token válido.
 * Junta ao pedido o id e o papel de quem está a pedir.
 */
$requireAuth = function (Request $request, Handler $handler): Response {
    $header = $request->getHeaderLine('Authorization');
    if (!preg_match('/^Bearer\s+(.+)$/', $header, $matches)) {
        return fail(new Slim\Psr7\Response(), 'Falta iniciar sessão.', 401);
    }
    try {
        $claims = JWT::decode($matches[1], new Key($_ENV['JWT_SECRET'], 'HS256'));
    } catch (Throwable $e) {
        return fail(new Slim\Psr7\Response(), 'A sessão expirou. Entra outra vez.', 401);
    }
    return $handler->handle(
        $request->withAttribute('userId', (int) $claims->sub)->withAttribute('role', $claims->role)
    );
};

/**
 * Porteiro 2: só deixa passar o administrador.
 * Tem de correr DEPOIS do porteiro 1 (é ele que sabe o papel).
 */
$requireAdmin = function (Request $request, Handler $handler): Response {
    if ($request->getAttribute('role') !== 'admin') {
        return fail(new Slim\Psr7\Response(), 'Só o administrador pode fazer isto.', 403);
    }
    return $handler->handle($request);
};
