<?php
declare(strict_types=1);

// Cópia de segurança automática da base de dados, corrida pela tarefa agendada (cron) do cPanel,
// uma vez por noite:
//
//   /opt/alt/php83/usr/bin/php /home/<conta>/repositories/cubico_backoffice/api/bin/db-backup.php
//
// Grava ~/backups-db/cubicodesign-auto-AAAAMMDD-HHMM.sql.gz e apaga as cópias automáticas com
// mais de BACKUP_KEEP_DAYS dias (as cópias feitas à mão, com outro nome, nunca se apagam).
//
// É PHP puro (PDO), sem mysqldump: no alojamento partilhado não há terminal e o exec() pode
// estar desligado. Repor uma cópia: phpMyAdmin → Importar → escolher o .sql.gz.
//
// Só escreve quando há um erro (o cPanel manda por email o que a tarefa escrever). Sai com 1 se falhar.
// A cópia leva os hashes das palavras-passe e os tokens da Etsy: fica FORA de public/ e só
// a conta a pode ler (0600).
//
// Uso no PC (para testar): php bin/db-backup.php <pasta> [--verbose]

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

$missing = array_filter(['pdo_mysql', 'zlib'], fn ($e) => !extension_loaded($e));
if ($missing !== []) {
    fwrite(STDERR, date('Y-m-d H:i') . ' Faltam extensões do PHP: ' . implode(', ', $missing) . "\n");
    exit(1);
}

require __DIR__ . '/../vendor/autoload.php';
Dotenv\Dotenv::createImmutable(__DIR__ . '/..')->load();
require __DIR__ . '/../src/db.php';

/** Quantos dias se guardam as cópias automáticas. */
const BACKUP_KEEP_DAYS = 14;

/** Tabelas de passagem: copia-se a estrutura, não as linhas (desafios e tentativas que expiram em minutos). */
const BACKUP_SKIP_DATA = ['login_attempts', 'passkey_challenges', 'etsy_oauth_states'];

/** O nome das cópias automáticas (só estas se apagam). */
const BACKUP_PATTERN = '/^cubicodesign-auto-\d{8}-\d{4}\.sql\.gz$/';

$args = array_slice($argv, 1);
$verbose = in_array('--verbose', $args, true);
$args = array_values(array_filter($args, fn ($a) => $a !== '--verbose'));
$dir = $args[0] ?? ($_ENV['BACKUP_DIR'] ?? ((getenv('HOME') ?: dirname(__DIR__, 4)) . '/backups-db'));

try {
    $file = backupDatabase($dir);
    $removed = removeOldBackups($dir, BACKUP_KEEP_DAYS);
    if ($verbose) {
        echo 'Cópia: ' . $file . ' (' . round(filesize($file) / 1024) . " KB)\n";
        echo 'Apagadas (mais de ' . BACKUP_KEEP_DAYS . ' dias): ' . count($removed) . "\n";
    }
} catch (Throwable $e) {
    fwrite(STDERR, date('Y-m-d H:i') . ' A cópia da base de dados FALHOU: ' . $e->getMessage() . "\n");
    exit(1);
}

/**
 * Escreve a cópia completa num .part e só no fim lhe dá o nome definitivo:
 * uma cópia a meio (sem espaço, erro) nunca fica com ar de cópia boa.
 */
function backupDatabase(string $dir): string
{
    if (!is_dir($dir) && !@mkdir($dir, 0700, true)) {
        throw new RuntimeException("não consegui criar a pasta $dir");
    }
    $pdo = db();
    $final = $dir . '/cubicodesign-auto-' . date('Ymd-Hi') . '.sql.gz';
    $part = $final . '.part';

    // as tabelas e o CREATE de cada uma, antes de começar a ler linhas
    $tables = [];
    foreach ($pdo->query("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'")->fetchAll(PDO::FETCH_NUM) as [$name]) {
        $tables[$name] = $pdo->query('SHOW CREATE TABLE `' . str_replace('`', '``', $name) . '`')->fetch(PDO::FETCH_NUM)[1];
    }

    $gz = gzopen($part, 'wb6');
    if ($gz === false) {
        throw new RuntimeException("não consegui escrever em $part");
    }
    $write = function (string $text) use ($gz): void {
        if (gzwrite($gz, $text) === false) {
            throw new RuntimeException('falhou a escrita da cópia (sem espaço?)');
        }
    };

    $write("-- CubicoDesign3D: cópia da base de dados, " . date('Y-m-d H:i:s') . "\n"
        . "-- Repor: phpMyAdmin → Importar. APAGA e volta a criar cada tabela.\n"
        . "SET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS = 0;\nSET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';\n\n");

    // ler as linhas uma a uma, sem as guardar todas na memória (os códigos postais são muitos)
    $pdo->setAttribute(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, false);
    $counts = [];
    foreach ($tables as $name => $create) {
        $q = '`' . str_replace('`', '``', $name) . '`';
        $write("DROP TABLE IF EXISTS $q;\n$create;\n");
        $counts[$name] = 0;
        if (in_array($name, BACKUP_SKIP_DATA, true)) {
            $write("\n");
            continue;
        }
        $stmt = $pdo->query("SELECT * FROM $q");
        $batch = [];
        while (($row = $stmt->fetch(PDO::FETCH_NUM)) !== false) {
            $batch[] = '(' . implode(',', array_map(
                fn ($v) => $v === null ? 'NULL' : $pdo->quote((string) $v),
                $row
            )) . ')';
            $counts[$name]++;
            if (count($batch) === 200) {
                $write("INSERT INTO $q VALUES\n" . implode(",\n", $batch) . ";\n");
                $batch = [];
            }
        }
        $stmt->closeCursor();
        if ($batch !== []) {
            $write("INSERT INTO $q VALUES\n" . implode(",\n", $batch) . ";\n");
        }
        $write("\n");
    }
    $pdo->setAttribute(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, true);

    // o rodapé prova que a cópia chegou ao fim, com as linhas de cada tabela
    $summary = implode(', ', array_map(fn ($t, $n) => "$t=$n", array_keys($counts), $counts));
    $write("SET FOREIGN_KEY_CHECKS = 1;\n-- fim da cópia: " . count($counts) . " tabelas; $summary\n");
    if (!gzclose($gz)) {
        throw new RuntimeException('falhou o fecho da cópia');
    }

    // confirmar: o .gz abre-se e acaba no rodapé (uma cópia que não se lê não vale nada)
    if (!backupLooksComplete($part)) {
        @unlink($part);
        throw new RuntimeException('a cópia ficou incompleta');
    }
    chmod($part, 0600);
    if (!rename($part, $final)) {
        throw new RuntimeException("não consegui dar o nome final a $final");
    }
    return $final;
}

/** O .gz descomprime até ao fim e a última linha é o rodapé "-- fim da cópia". */
function backupLooksComplete(string $path): bool
{
    $gz = gzopen($path, 'rb');
    if ($gz === false) {
        return false;
    }
    $last = '';
    while (!gzeof($gz)) {
        $chunk = gzread($gz, 1 << 16);
        if ($chunk === false) {
            gzclose($gz);
            return false;
        }
        $last = substr($last . $chunk, -4096);
    }
    gzclose($gz);
    return preg_match('/-- fim da cópia: \d+ tabelas;[^\n]*\n$/u', $last) === 1;
}

/**
 * Apaga as cópias automáticas mais velhas que $days dias. Fica sempre pelo menos a mais recente.
 * @return string[] os ficheiros apagados
 */
function removeOldBackups(string $dir, int $days): array
{
    $files = array_values(array_filter(scandir($dir) ?: [], fn ($f) => preg_match(BACKUP_PATTERN, $f) === 1));
    sort($files); // o nome tem a data: por ordem alfabética = por ordem de data
    array_pop($files); // a mais recente nunca se apaga
    $limit = time() - $days * 86400;
    $removed = [];
    foreach ($files as $f) {
        if (filemtime("$dir/$f") < $limit && @unlink("$dir/$f")) {
            $removed[] = $f;
        }
    }
    // restos de cópias que falharam a meio
    foreach (glob("$dir/cubicodesign-auto-*.part") ?: [] as $p) {
        if (filemtime($p) < time() - 86400) {
            @unlink($p);
        }
    }
    return $removed;
}
