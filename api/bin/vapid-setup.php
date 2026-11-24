<?php
declare(strict_types=1);

// Cria as chaves VAPID dos avisos (a "assinatura" da loja) e junta-as ao .env — só se ainda lá
// não estiverem. Corre-se uma vez, em cada sítio onde a API vive (o PC e o servidor):
//
//   php bin/vapid-setup.php
//   (no servidor, por uma tarefa agendada do cPanel de uma só vez:
//    /opt/alt/php83/usr/bin/php -d extension=mbstring.so /home/<conta>/repositories/cubico_backoffice/api/bin/vapid-setup.php)
//
// Nunca mostra as chaves: escreve-as direto no .env (que não vai para o Git).
// Trocar as chaves obriga a ligar outra vez os avisos em cada aparelho.

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require __DIR__ . '/../vendor/autoload.php';
$envFile = __DIR__ . '/../.env';
if (!is_file($envFile)) {
    fwrite(STDERR, "Não encontrei o .env da API.\n");
    exit(1);
}
Dotenv\Dotenv::createImmutable(__DIR__ . '/..')->load();

if (($_ENV['VAPID_PUBLIC_KEY'] ?? '') !== '' && ($_ENV['VAPID_PRIVATE_KEY'] ?? '') !== '') {
    echo date('Y-m-d H:i') . " As chaves dos avisos já existiam no .env: não mudei nada.\n";
    exit(0);
}

$keys = Minishlink\WebPush\VAPID::createVapidKeys();
$lines = "\n# avisos de encomendas novas (Web Push): criadas por bin/vapid-setup.php em " . date('Y-m-d') . "\n"
    . 'VAPID_PUBLIC_KEY=' . $keys['publicKey'] . "\n"
    . 'VAPID_PRIVATE_KEY=' . $keys['privateKey'] . "\n"
    . (($_ENV['VAPID_SUBJECT'] ?? '') === '' ? "VAPID_SUBJECT=https://app.fazendasubmersa.pt\n" : '');
if (file_put_contents($envFile, $lines, FILE_APPEND | LOCK_EX) === false) {
    fwrite(STDERR, "Não consegui escrever no .env.\n");
    exit(1);
}
echo date('Y-m-d H:i') . " Chaves dos avisos criadas e guardadas no .env.\n";
