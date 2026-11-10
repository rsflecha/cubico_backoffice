<?php
declare(strict_types=1);

/**
 * A ligação à base de dados, partilhada pela API e pelos scripts.
 * Sempre em utf8mb4 (o servidor do cPanel está em latin1).
 * Abre uma vez por pedido e volta a usar a mesma.
 */
function db(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
            $_ENV['DB_HOST'],
            $_ENV['DB_PORT'],
            $_ENV['DB_NAME'],
        );
        $pdo = new PDO($dsn, $_ENV['DB_USER'], $_ENV['DB_PASS'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,       // erros viram exceções
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,  // linhas como arrays com chaves
        ]);
    }
    return $pdo;
}
