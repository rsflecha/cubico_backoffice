<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// GET /api/health → a API está viva?
$app->get('/api/health', function (Request $request, Response $response) {
    return json($response, ['status' => 'ok', 'time' => date('c')]);
});

// GET /api/health/db → a API consegue falar com a base de dados?
$app->get('/api/health/db', function (Request $request, Response $response) {
    $channels = db()->query('SELECT code, name FROM channels ORDER BY id')->fetchAll();
    return json($response, ['status' => 'ok', 'channels' => $channels]);
});
