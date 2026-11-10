<?php
declare(strict_types=1);

use Dotenv\Dotenv;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as Handler;
use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../src/db.php';

// as definições do ficheiro .env (palavra-passe da base de dados, segredo dos tokens…)
Dotenv::createImmutable(__DIR__ . '/..')->load();
$debug = ($_ENV['APP_DEBUG'] ?? 'false') === 'true';

$app = AppFactory::create();
$app->addBodyParsingMiddleware();
$app->addRoutingMiddleware();
// mostrar os detalhes dos erros só em desenvolvimento, nunca no servidor a sério
$app->addErrorMiddleware($debug, true, true);

// ─────────────────────────── Ajudas ───────────────────────────

/** Responde com JSON. */
function json(Response $response, array $data, int $status = 200): Response
{
    $response->getBody()->write(json_encode($data, JSON_UNESCAPED_UNICODE));
    return $response
        ->withHeader('Content-Type', 'application/json; charset=utf-8')
        ->withStatus($status);
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
        'sub' => (int) $user['id'], // quem é
        'role' => $user['role'],    // o papel
        'iat' => $now,              // quando foi criado
        'exp' => $now + 60 * 60 * 12, // quando deixa de valer
    ], $_ENV['JWT_SECRET'], 'HS256');
}

/**
 * O "porteiro" da API: só deixa passar pedidos com um token válido.
 * Junta ao pedido o id e o papel de quem está a pedir.
 */
$requireAuth = function (Request $request, Handler $handler): Response {
    $header = $request->getHeaderLine('Authorization');
    if (!preg_match('/^Bearer\s+(.+)$/', $header, $matches)) {
        return json(new Slim\Psr7\Response(), ['error' => 'Falta iniciar sessão.'], 401);
    }
    try {
        $claims = JWT::decode($matches[1], new Key($_ENV['JWT_SECRET'], 'HS256'));
    } catch (Throwable $e) {
        return json(new Slim\Psr7\Response(), ['error' => 'A sessão expirou. Entra outra vez.'], 401);
    }
    return $handler->handle(
        $request->withAttribute('userId', (int) $claims->sub)->withAttribute('role', $claims->role)
    );
};

// ─────────────────────────── Saúde ───────────────────────────

// GET /api/health → a API está viva?
$app->get('/api/health', function (Request $request, Response $response) {
    return json($response, ['status' => 'ok', 'time' => date('c')]);
});

// GET /api/health/db → a API consegue falar com a base de dados?
$app->get('/api/health/db', function (Request $request, Response $response) {
    $channels = db()->query('SELECT code, name FROM channels ORDER BY id')->fetchAll();
    return json($response, ['status' => 'ok', 'channels' => $channels]);
});

// ─────────────────────────── Sessão ───────────────────────────

// POST /api/auth/login → email e palavra-passe; devolve o token e o utilizador
$app->post('/api/auth/login', function (Request $request, Response $response) {
    $body = (array) $request->getParsedBody();
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    $password = (string) ($body['password'] ?? '');

    // o "?" é preenchido pelo PDO de forma segura (nunca juntar texto do utilizador ao SQL)
    $stmt = db()->prepare('SELECT * FROM users WHERE email = ? AND is_active = 1');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    // a mesma mensagem para email errado e palavra-passe errada, de propósito
    if (!$user || !password_verify($password, $user['password_hash'])) {
        return json($response, ['error' => 'Email ou palavra-passe errados.'], 401);
    }

    db()->prepare('UPDATE users SET last_login_at = NOW() WHERE id = ?')->execute([$user['id']]);
    return json($response, ['token' => makeToken($user), 'user' => publicUser($user)]);
});

// GET /api/auth/me → quem sou eu? (precisa de token)
$app->get('/api/auth/me', function (Request $request, Response $response) {
    $stmt = db()->prepare('SELECT * FROM users WHERE id = ? AND is_active = 1');
    $stmt->execute([$request->getAttribute('userId')]);
    $user = $stmt->fetch();
    if (!$user) {
        return json($response, ['error' => 'Este utilizador já não tem acesso.'], 401);
    }
    return json($response, ['user' => publicUser($user)]);
})->add($requireAuth);

$app->run();
