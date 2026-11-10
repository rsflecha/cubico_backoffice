<?php
declare(strict_types=1);

// Cria um utilizador na base de dados, com a palavra-passe cifrada.
// Uso (dentro da pasta api):  php bin/create-user.php

require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../src/db.php';

Dotenv\Dotenv::createImmutable(__DIR__ . '/..')->load();

/** Faz uma pergunta no terminal e devolve a resposta. */
function ask(string $question): string
{
    echo $question;
    return trim((string) fgets(STDIN));
}

$name = ask('Nome: ');
$email = strtolower(ask('Email: '));
$role = ask('Papel (admin ou staff) [admin]: ') ?: 'admin';
$password = ask('Palavra-passe (pelo menos 10 caracteres): ');

if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    exit("Falta o nome, ou o email não é válido.\n");
}
if (!in_array($role, ['admin', 'staff'], true)) {
    exit("O papel tem de ser admin ou staff.\n");
}
if (strlen($password) < 10) {
    exit("A palavra-passe tem de ter pelo menos 10 caracteres.\n");
}

// a palavra-passe nunca é guardada: só o "hash" (bcrypt), que não se consegue reverter
$stmt = db()->prepare('INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)');
$stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT), $role]);

echo 'Utilizador criado, com o id ' . db()->lastInsertId() . ".\n";
