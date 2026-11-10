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

/**
 * Uma linha da base de dados com os tipos certos para a app.
 * O PHP lê os DECIMAL como texto ("13.99") e os BOOLEAN como 0/1;
 * a app espera números e true/false.
 * $types: ['id' => 'int', 'paid_price' => 'float', 'is_active' => 'bool', 'name' => 'string', …]
 */
function typed(array $row, array $types): array
{
    $out = [];
    foreach ($types as $column => $type) {
        $value = $row[$column] ?? null;
        $out[$column] = $value === null ? null : match ($type) {
            'int' => (int) $value,
            'float' => (float) $value,
            'bool' => (bool) $value,
            default => (string) $value,
        };
    }
    return $out;
}

/** Um valor que veio da app, pronto para gravar na coluna (true/false → 1/0). */
function dbValue(mixed $value, string $type): mixed
{
    if ($value === null) {
        return null;
    }
    return match ($type) {
        'int' => (int) $value,
        'float' => (float) $value,
        'bool' => $value ? 1 : 0,
        default => trim((string) $value),
    };
}
