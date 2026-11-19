<?php
declare(strict_types=1);

use lbuchs\WebAuthn\Binary\ByteBuffer;
use lbuchs\WebAuthn\WebAuthn;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Passkeys (Face ID, impressão digital, Windows Hello) ═══════════════
// Como funciona, em 2 passos de cada vez:
//   ativar: 1) a API dá um desafio (números aleatórios); 2) o aparelho cria um par de chaves,
//           assina o desafio e manda a chave PÚBLICA, que fica guardada em `passkeys`.
//   entrar: 1) a API dá um desafio novo; 2) o aparelho pede a cara/dedo, assina com a chave
//           PRIVADA (que nunca sai dele) e a API confere a assinatura com a pública guardada.
// A biblioteca lbuchs/webauthn faz as contas da criptografia; aqui ficam as regras da loja.

const PASSKEY_CHALLENGE_MINUTES = 5;
/** Mais do que isto à espera (em 5 minutos) é alguém a abusar: recusa até expirarem. */
const PASSKEY_MAX_PENDING = 500;

/**
 * O "site" da passkey (rpId): o domínio de onde vem o pedido, ex.: app.fazendasubmersa.pt.
 * Só vale se a origem estiver na lista CORS_ORIGINS do .env (os sites de confiança).
 * null = pedido sem origem conhecida (ex.: a app de Windows): sem passkeys.
 */
function passkeyRpId(Request $request): ?string
{
    $origin = $request->getHeaderLine('Origin');
    if (!isAllowedOrigin($origin)) {
        return null;
    }
    $host = parse_url($origin, PHP_URL_HOST);
    if (!is_string($host) || $host === '') {
        return null;
    }
    // fora do PC (APP_DEBUG desligado), só sites com https: um "localhost" na lista do CORS
    // não pode passar a valer para as passkeys
    $debug = ($_ENV['APP_DEBUG'] ?? 'false') === 'true';
    if (parse_url($origin, PHP_URL_SCHEME) !== 'https' && !($debug && $host === 'localhost')) {
        return null;
    }
    return strtolower($host);
}

/** A biblioteca, já a dar os dados binários em base64url (o formato que o browser usa). */
function passkeyLib(string $rpId): WebAuthn
{
    $lib = new WebAuthn('CubicoDesign3D', $rpId, null, true);
    ByteBuffer::$useBase64UrlEncoding = true;
    return $lib;
}

function b64urlEncode(string $binary): string
{
    return rtrim(strtr(base64_encode($binary), '+/', '-_'), '=');
}

function b64urlDecode(string $text): string
{
    $decoded = base64_decode(strtr($text, '-_', '+/'), true);
    return $decoded === false ? '' : $decoded;
}

/**
 * Guarda o desafio desta tentativa e devolve o número dela (que a app manda de volta).
 * null = demasiadas tentativas à espera (ver PASSKEY_MAX_PENDING).
 */
function savePasskeyChallenge(string $purpose, string $rpId, ?int $userId, string $challenge): ?string
{
    // aproveita para limpar as tentativas que já expiraram
    db()->exec('DELETE FROM passkey_challenges WHERE expires_at < NOW()');
    if ((int) db()->query('SELECT COUNT(*) FROM passkey_challenges')->fetchColumn() >= PASSKEY_MAX_PENDING) {
        return null;
    }
    $id = bin2hex(random_bytes(16));
    db()->prepare(
        'INSERT INTO passkey_challenges (id, challenge, purpose, user_id, rp_id, expires_at)
         VALUES (?, ?, ?, ?, ?, NOW() + INTERVAL ' . PASSKEY_CHALLENGE_MINUTES . ' MINUTE)'
    )->execute([$id, bin2hex($challenge), $purpose, $userId, $rpId]);
    return $id;
}

/**
 * Tira o desafio de uma tentativa (só se usa uma vez: apaga-o logo).
 * null se não existir, se expirou, ou se for de outro tipo, site ou utilizador.
 */
function takePasskeyChallenge(string $id, string $purpose, string $rpId, ?int $userId): ?string
{
    $stmt = db()->prepare(
        'SELECT * FROM passkey_challenges WHERE id = ? AND purpose = ? AND rp_id = ? AND expires_at >= NOW()'
    );
    $stmt->execute([$id, $purpose, $rpId]);
    $row = $stmt->fetch();
    // só vale quem o apagar: dois pedidos ao mesmo tempo com o mesmo desafio, só um passa
    $delete = db()->prepare('DELETE FROM passkey_challenges WHERE id = ?');
    $delete->execute([$id]);
    if (!$row || $delete->rowCount() !== 1) {
        return null;
    }
    if ($userId !== null && (int) $row['user_id'] !== $userId) {
        return null;
    }
    return hex2bin((string) $row['challenge']) ?: null;
}

/**
 * O clientDataJSON diz de que site veio a resposta. A biblioteca só confere o fim do nome;
 * aqui exige-se que seja EXATAMENTE a origem do pedido (e que essa esteja na lista).
 */
function passkeyOriginMatches(string $clientDataJSON, Request $request): bool
{
    $data = json_decode($clientDataJSON, true);
    $origin = $request->getHeaderLine('Origin');
    return is_array($data) && isAllowedOrigin($origin) && ($data['origin'] ?? '') === $origin;
}

/** Um nome para o aparelho, tirado do browser: "iPhone", "iPad", "Android"… */
function passkeyDeviceLabel(string $userAgent): string
{
    foreach (['iPhone' => 'iPhone', 'iPad' => 'iPad', 'Android' => 'Android', 'Windows' => 'Windows',
        'Macintosh' => 'Mac', 'Linux' => 'Linux'] as $needle => $label) {
        if (stripos($userAgent, $needle) !== false) {
            return $label;
        }
    }
    return 'Aparelho';
}

/**
 * A palavra-passe mudou (pela própria pessoa ou reposta pelo administrador): as passkeys vão.
 * Senão, quem tivesse ativado o Face ID com um acesso roubado continuava a entrar.
 */
function deletePasskeys(int $userId): void
{
    db()->prepare('DELETE FROM passkeys WHERE user_id = ?')->execute([$userId]);
}

/** As passkeys de um utilizador, para a lista nas Definições (sem as chaves). */
function listPasskeys(int $userId): array
{
    $stmt = db()->prepare(
        'SELECT id, label, created_at, last_used_at FROM passkeys WHERE user_id = ? ORDER BY created_at'
    );
    $stmt->execute([$userId]);
    return array_map(fn ($r) => [
        'id' => (int) $r['id'],
        'label' => (string) $r['label'],
        'created_at' => (string) $r['created_at'],
        'last_used_at' => $r['last_used_at'],
    ], $stmt->fetchAll());
}
