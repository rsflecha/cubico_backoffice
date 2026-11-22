<?php
declare(strict_types=1);

// Conferir os SKU dos anúncios ativos da Etsy contra as variantes da app, na linha de comandos.
// É o mesmo que o botão "Conferir os SKU" da app (Definições → Etsy), para correr sem abrir a app:
//
//   /opt/alt/php83/usr/bin/php -d extension=mbstring.so .../api/bin/etsy-listings-check.php
//
// Só lê: não mexe em nada na Etsy nem na base de dados. Sai com 1 se houver anúncios por ligar.

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require __DIR__ . '/../vendor/autoload.php';
Dotenv\Dotenv::createImmutable(__DIR__ . '/..')->load();
require __DIR__ . '/../src/db.php';
require __DIR__ . '/../src/helpers.php';
require __DIR__ . '/../src/etsy.php';
require __DIR__ . '/../src/etsy_sync.php';
require __DIR__ . '/../src/etsy_listings.php';

try {
    $check = etsyListingsCheck();
} catch (Throwable $e) {
    fwrite(STDERR, 'Não foi possível conferir: ' . $e->getMessage() . "\n");
    exit(1);
}

$label = ['ok' => 'OK        ', 'unknown_sku' => 'SKU NOVO  ', 'no_sku' => 'SEM SKU   '];
echo "Conferido a {$check['checked_at']}: {$check['ok']} ligam, {$check['problems']} por ligar"
    . ($check['digital_skipped'] > 0 ? ", {$check['digital_skipped']} digitais (não entram)" : '') . "\n\n";
foreach ($check['listings'] as $l) {
    echo "Anúncio {$l['listing_id']} — {$l['title']}\n";
    foreach ($l['products'] as $p) {
        $what = trim(($p['sku'] ?? '(sem SKU)') . ($p['variation'] !== '' ? "  [{$p['variation']}]" : '') . ($p['pack'] > 1 ? "  pack de {$p['pack']}" : ''));
        $to = $p['variant'] ? "→ {$p['variant']['sku']} {$p['variant']['label']}" : '';
        echo '  ' . $label[$p['status']] . "$what $to\n";
    }
}
if ($check['unlisted_variants'] !== []) {
    echo "\nVariantes da app que nenhum anúncio usa:\n";
    foreach ($check['unlisted_variants'] as $v) {
        echo "  {$v['sku']}  {$v['label']}\n";
    }
}
exit($check['problems'] > 0 ? 1 : 0);
