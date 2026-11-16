<?php
declare(strict_types=1);

// Converte a base dos códigos postais dos CTT (o cp.db em SQLite da app do curso,
// xlo_mobx) num ficheiro SQL para a tabela postal_codes (migração 005).
//
//   php -d extension=pdo_sqlite bin/postal-codes.php <cp.db> <saída.sql> [--load]
//
// --load  também carrega os dados na base do .env (a do PC). No servidor não há
//         terminal: lá importa-se o <saída.sql> pelo phpMyAdmin.
//
// O cp.db tem uma linha por rua; aqui fica UMA linha por código postal. Quando um
// código tem mais de uma localidade (cerca de 3 400 casos), fica a que tem mais ruas.

if ($argc < 3) {
    fwrite(STDERR, "Uso: php -d extension=pdo_sqlite bin/postal-codes.php <cp.db> <saída.sql> [--load]\n");
    exit(1);
}
[$source, $target] = [$argv[1], $argv[2]];
$load = in_array('--load', $argv, true);
if (!is_file($source)) {
    fwrite(STDERR, "Não encontrei $source\n");
    exit(1);
}

$sqlite = new PDO('sqlite:' . $source, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
// por código: a localidade com mais ruas (empate → a primeira por ordem alfabética)
$rows = $sqlite->query(
    'SELECT cp4, cp3, localidade, concelho, distrito, COUNT(*) AS n
       FROM cp
      WHERE cp4 GLOB \'[0-9][0-9][0-9][0-9]\' AND cp3 GLOB \'[0-9][0-9][0-9]\' AND TRIM(localidade) <> \'\'
      GROUP BY cp4, cp3, localidade, concelho, distrito
      ORDER BY cp4, cp3, n DESC, localidade'
);

$codes = [];
foreach ($rows as $r) {
    $code = $r['cp4'] . '-' . $r['cp3'];
    if (isset($codes[$code])) {
        continue; // já ficou a localidade com mais ruas
    }
    $codes[$code] = [trim($r['localidade']), trim((string) $r['concelho']), trim((string) $r['distrito'])];
}

// o ficheiro SQL: INSERT de 1 000 em 1 000 (o phpMyAdmin e o MariaDB aguentam bem)
$quote = fn (string $s) => "'" . str_replace(["\\", "'"], ["\\\\", "''"], $s) . "'";
$out = fopen($target, 'wb');
fwrite($out, "-- Códigos postais de Portugal (CTT), gerado por api/bin/postal-codes.php em " . date('Y-m-d') . "\n");
fwrite($out, "-- " . count($codes) . " códigos. Não vai para o Git.\nSET NAMES utf8mb4;\nDELETE FROM postal_codes;\n");
$batches = [];
foreach (array_chunk($codes, 1000, true) as $chunk) {
    $values = [];
    foreach ($chunk as $code => [$locality, $municipality, $district]) {
        $values[] = '(' . implode(', ', array_map($quote, [$code, mb_substr($locality, 0, 80), mb_substr($municipality, 0, 80), mb_substr($district, 0, 80)])) . ')';
    }
    $batch = 'INSERT INTO postal_codes (code, locality, municipality, district) VALUES ' . implode(",\n", $values) . ";\n";
    $batches[] = $batch;
    fwrite($out, $batch);
}
fclose($out);
echo count($codes) . " códigos → $target (" . round(filesize($target) / 1048576, 1) . " MB)\n";

if ($load) {
    require __DIR__ . '/../vendor/autoload.php';
    Dotenv\Dotenv::createImmutable(__DIR__ . '/..')->load();
    require __DIR__ . '/../src/db.php';
    db()->beginTransaction();
    db()->exec('DELETE FROM postal_codes');
    foreach ($batches as $batch) {
        db()->exec($batch);
    }
    db()->commit();
    echo db()->query('SELECT COUNT(*) FROM postal_codes')->fetchColumn() . " códigos carregados na base do .env\n";
}
