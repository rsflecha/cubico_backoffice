<?php
declare(strict_types=1);

// ═══════════════ Limite de tentativas de login ═══════════════
// Sem limite, um robô pode experimentar milhares de palavras-passe seguidas.
// Regra: nos últimos 15 minutos,
//   - 5 falhas no MESMO email bloqueiam esse email (o robô que ataca uma conta);
//   - 30 falhas do MESMO endereço IP bloqueiam esse IP (o robô que experimenta muitas contas).
// O bloqueio acaba sozinho: quando a falha mais antiga sai da janela dos 15 minutos.
// Entrar bem limpa as falhas do email (não as do IP: senão bastava ter uma conta para
// "limpar" o IP entre ataques a outras).

const LOGIN_WINDOW_MINUTES = 15;
const LOGIN_MAX_PER_EMAIL = 5;
const LOGIN_MAX_PER_IP = 30;

/** Um hash que serve só para gastar o mesmo tempo quando o email não existe (não é segredo). */
const LOGIN_DUMMY_HASH = '$2y$12$LZ8yHZKDMvSBlwlE7XXOV.vKhn9//YKU5DdzmjG7TmNGGOkTS1PBy';

/**
 * As "chaves" a contar, com o limite de cada uma: o IP sempre, e o email se houver.
 * Guarda-se só o sha256 (nem o email nem o IP ficam em claro na base de dados).
 * @return array<string, int>  hash => limite
 */
function loginKeys(?string $email): array
{
    $keys = [hash('sha256', 'ip:' . ($_SERVER['REMOTE_ADDR'] ?? '')) => LOGIN_MAX_PER_IP];
    if ($email !== null && $email !== '') {
        $keys[hash('sha256', 'email:' . $email)] = LOGIN_MAX_PER_EMAIL;
    }
    return $keys;
}

/**
 * Está bloqueado? Devolve quantos minutos faltam (1 ou mais), ou null se pode tentar.
 * @param array<string, int> $keys  de loginKeys()
 */
function loginBlockedMinutes(array $keys): ?int
{
    $stmt = db()->prepare(
        'SELECT COUNT(*) AS n, TIMESTAMPDIFF(SECOND, NOW(), MIN(created_at) + INTERVAL ? MINUTE) AS wait
         FROM login_attempts WHERE key_hash = ? AND created_at > NOW() - INTERVAL ? MINUTE'
    );
    $minutes = null;
    foreach ($keys as $key => $limit) {
        $stmt->execute([LOGIN_WINDOW_MINUTES, $key, LOGIN_WINDOW_MINUTES]);
        $row = $stmt->fetch();
        if ((int) $row['n'] >= $limit) {
            $wait = max(1, (int) ceil(max(0, (int) $row['wait']) / 60));
            $minutes = max($minutes ?? 0, $wait);
        }
    }
    return $minutes;
}

/** A mensagem do bloqueio, para a app mostrar. */
function loginBlockedMessage(int $minutes): string
{
    return "Demasiadas tentativas falhadas. Espera {$minutes} " . ($minutes === 1 ? 'minuto' : 'minutos') . ' e tenta outra vez.';
}

/**
 * Regista uma falha em todas as chaves. De vez em quando, apaga as falhas com mais de um dia.
 * @param array<string, int> $keys
 */
function recordLoginFailure(array $keys): void
{
    $insert = db()->prepare('INSERT INTO login_attempts (key_hash) VALUES (?)');
    foreach (array_keys($keys) as $key) {
        $insert->execute([$key]);
    }
    if (random_int(1, 50) === 1) {
        db()->exec('DELETE FROM login_attempts WHERE created_at < NOW() - INTERVAL 1 DAY');
    }
}

/** Entrou bem: as falhas deste email deixam de contar. */
function clearLoginFailures(string $email): void
{
    db()->prepare('DELETE FROM login_attempts WHERE key_hash = ?')
        ->execute([hash('sha256', 'email:' . $email)]);
}
