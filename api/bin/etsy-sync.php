<?php
declare(strict_types=1);

// Sincronização automática da Etsy: o mesmo que o botão "Sincronizar agora",
// mas corrido pela tarefa agendada (cron) do cPanel, por exemplo a cada 15 minutos:
//
//   /usr/local/bin/php /home/<conta>/repositories/cubico_backoffice/api/bin/etsy-sync.php
//
// Só escreve quando há um erro (o cPanel manda por email o que a tarefa escrever,
// e não queremos 96 emails por dia). Sai com 1 quando falha.
// Não está dentro de public/, por isso não se pode chamar pelo browser.

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require __DIR__ . '/../vendor/autoload.php';
Dotenv\Dotenv::createImmutable(__DIR__ . '/..')->load();

// as mesmas peças do public/index.php, sem as rotas
require __DIR__ . '/../src/db.php';
require __DIR__ . '/../src/helpers.php';
require __DIR__ . '/../src/tables.php';
require __DIR__ . '/../src/costs.php';
require __DIR__ . '/../src/sku.php';
require __DIR__ . '/../src/production.php';
require __DIR__ . '/../src/etsy.php';
require __DIR__ . '/../src/etsy_sync.php';

/** Quantos dias de registos das sincronizações se guardam (a cada 15 min são 96 por dia). */
const SYNC_RUNS_KEEP_DAYS = 30;

try {
    // sem a chave da Etsy no .env, ou sem a loja ligada: não há nada a fazer (e não é um erro)
    if (!etsyConfigured() || (int) (etsyConnection()['shop_id'] ?? 0) === 0) {
        exit(0);
    }
    etsySync();
} catch (EtsyException $e) {
    // alguém carregou no botão ao mesmo tempo: esta fica para a próxima vez
    if (str_starts_with($e->getMessage(), 'Já está a correr')) {
        exit(0);
    }
    fwrite(STDERR, date('Y-m-d H:i') . ' Etsy: ' . $e->getMessage() . "\n");
    exit(1);
} catch (Throwable $e) {
    fwrite(STDERR, date('Y-m-d H:i') . ' Erro inesperado: ' . $e->getMessage() . "\n");
    exit(1);
} finally {
    // a lista das sincronizações não cresce para sempre
    try {
        db()->prepare('DELETE FROM sync_runs WHERE started_at < NOW() - INTERVAL ? DAY')->execute([SYNC_RUNS_KEEP_DAYS]);
    } catch (Throwable) {
        // limpar é só arrumação: se falhar, fica para a próxima
    }
}
