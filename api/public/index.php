<?php
declare(strict_types=1);

use Dotenv\Dotenv;
use Slim\Factory\AppFactory;

require __DIR__ . '/../vendor/autoload.php';

// as definições do ficheiro .env (palavra-passe da base de dados, segredo dos tokens…)
Dotenv::createImmutable(__DIR__ . '/..')->load();
$debug = ($_ENV['APP_DEBUG'] ?? 'false') === 'true';

require __DIR__ . '/../src/db.php';
require __DIR__ . '/../src/helpers.php';
require __DIR__ . '/../src/auth.php'; // os porteiros: $requireAuth e $requireAdmin
require __DIR__ . '/../src/tables.php'; // os pedidos habituais das tabelas simples
require __DIR__ . '/../src/costs.php';  // as contas oficiais (custo, portes)
require __DIR__ . '/../src/cors.php';   // quem pode usar a API a partir de um browser

$app = AppFactory::create();
$app->addBodyParsingMiddleware();
$app->addRoutingMiddleware();
// mostrar os detalhes dos erros só em desenvolvimento, nunca no servidor a sério
$app->addErrorMiddleware($debug, true, true);
// o CORS por último: é o primeiro a correr, e junta os cabeçalhos a todas as respostas, até às de erro
$app->add($cors);

// as rotas, um ficheiro por módulo
require __DIR__ . '/../routes/health.php';
require __DIR__ . '/../routes/auth.php';
require __DIR__ . '/../routes/categories.php';
require __DIR__ . '/../routes/costs.php';
require __DIR__ . '/../routes/products.php';
require __DIR__ . '/../routes/customers.php';
require __DIR__ . '/../routes/orders.php';
require __DIR__ . '/../routes/production.php';
require __DIR__ . '/../routes/users.php';

$app->run();
