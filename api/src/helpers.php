<?php
declare(strict_types=1);

use Firebase\JWT\JWT;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/** Responde com JSON. */
function json(Response $response, mixed $data, int $status = 200): Response
{
    $response->getBody()->write(json_encode($data, JSON_UNESCAPED_UNICODE));
    return $response
        ->withHeader('Content-Type', 'application/json; charset=utf-8')
        ->withStatus($status);
}

/** Responde com um erro, com uma mensagem em português para mostrar na app. */
function fail(Response $response, string $message, int $status): Response
{
    return json($response, ['error' => $message], $status);
}

/** O corpo do pedido (o JSON que a app enviou), sempre como array. */
function body(Request $request): array
{
    return (array) $request->getParsedBody();
}

/** O que a app pode saber de um utilizador (nunca o hash da palavra-passe). */
function publicUser(array $user): array
{
    return [
        'id' => (int) $user['id'],
        'name' => $user['name'],
        'email' => $user['email'],
        'role' => $user['role'],
    ];
}

/** Cria o token de sessão de um utilizador, válido durante 12 horas. */
function makeToken(array $user): string
{
    $now = time();
    return JWT::encode([
        'sub' => (int) $user['id'],     // quem é
        'role' => $user['role'],        // o papel
        'iat' => $now,                  // quando foi criado
        'exp' => $now + 60 * 60 * 12,   // quando deixa de valer
    ], $_ENV['JWT_SECRET'], 'HS256');
}

/** Foi um erro de "valor repetido" numa coluna UNIQUE? (ex.: duas categorias com o mesmo nome) */
function isDuplicate(PDOException $e): bool
{
    return $e->getCode() === '23000';
}
