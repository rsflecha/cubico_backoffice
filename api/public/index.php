<?php
declare(strict_types=1);

use Dotenv\Dotenv;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';

// as definições do ficheiro .env (palavra-passe da base de dados, etc.)
Dotenv::createImmutable(__DIR__ . '/..')->load();
$debug = ($_ENV['APP_DEBUG'] ?? 'false') === 'true';

$app = AppFactory::create();
$app->addBodyParsingMiddleware();
$app->addRoutingMiddleware();
// mostrar os detalhes dos erros só em desenvolvimento, nunca no servidor a sério
$app->addErrorMiddleware($debug, true, true);

/** Responde com JSON. */
function json(Response $response, array $data, int $status = 200): Response
{
    $response->getBody()->write(json_encode($data, JSON_UNESCAPED_UNICODE));
    return $response
        ->withHeader('Content-Type', 'application/json; charset=utf-8')
        ->withStatus($status);
}

/** Uma ligação à base de dados, sempre em utf8mb4 (o servidor do cPanel está em latin1). */
function db(): PDO
{
    $dsn = sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $_ENV['DB_HOST'],
        $_ENV['DB_PORT'],
        $_ENV['DB_NAME'],
    );
    return new PDO($dsn, $_ENV['DB_USER'], $_ENV['DB_PASS'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,       // erros viram exceções
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,  // linhas como arrays com chaves
    ]);
}

// GET /api/health → a API está viva?
$app->get('/api/health', function (Request $request, Response $response) {
    return json($response, ['status' => 'ok', 'time' => date('c')]);
});

// GET /api/health/db → a API consegue falar com a base de dados?
$app->get('/api/health/db', function (Request $request, Response $response) {
    $channels = db()->query('SELECT code, name FROM channels ORDER BY id')->fetchAll();
    return json($response, ['status' => 'ok', 'channels' => $channels]);
});

$app->run();
