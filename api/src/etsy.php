<?php
declare(strict_types=1);

/**
 * A ligação à Etsy (API v3, OAuth 2 com PKCE).
 *
 * Como funciona, em quatro passos:
 *  1. o administrador carrega em "Ligar à Etsy": etsyStartConnect() guarda um "state" e um
 *     segredo (code_verifier) e devolve o endereço da Etsy;
 *  2. na Etsy, o Rui autoriza a app;
 *  3. a Etsy volta a /api/etsy/callback com um código: etsyFinishConnect() confere o state,
 *     troca o código pelos tokens e descobre a loja;
 *  4. daí em diante, etsyGet() faz os pedidos e renova o token de acesso sozinho.
 *
 * A chave da app vem do .env (ETSY_KEYSTRING, ETSY_SHARED_SECRET, ETSY_REDIRECT_URI).
 * Os tokens ficam cifrados na base de dados.
 */

const ETSY_AUTH_URL = 'https://www.etsy.com/oauth/connect';
const ETSY_API = 'https://api.etsy.com/v3';
const ETSY_TOKEN_URL = ETSY_API . '/public/oauth/token';
// ler encomendas e transações; ler a loja; ler os anúncios (para conferir os SKU).
// Só leitura: a app nunca escreve na Etsy. Mudar esta lista obriga a "Ligar outra vez".
const ETSY_SCOPES = 'transactions_r shops_r listings_r';
const ETSY_STATE_MINUTES = 10;

/** Um erro da ligação à Etsy, com uma mensagem em português para mostrar. */
class EtsyException extends RuntimeException
{
}

/** A chave da app está no .env? */
function etsyConfigured(): bool
{
    return ($_ENV['ETSY_KEYSTRING'] ?? '') !== ''
        && ($_ENV['ETSY_SHARED_SECRET'] ?? '') !== ''
        && ($_ENV['ETSY_REDIRECT_URI'] ?? '') !== '';
}

// ───────────── Cifrar os tokens ─────────────

/** A chave de cifra: tirada do JWT_SECRET, para não haver mais um segredo a gerir. */
function etsyCipherKey(): string
{
    return hash('sha256', 'etsy-tokens|' . $_ENV['JWT_SECRET'], true);
}

/** Cifra um token (AES-256-GCM). Guarda iv + tag + texto, em base64. */
function etsySeal(string $plain): string
{
    $iv = random_bytes(12);
    $tag = '';
    $cipher = openssl_encrypt($plain, 'aes-256-gcm', etsyCipherKey(), OPENSSL_RAW_DATA, $iv, $tag);
    return base64_encode($iv . $tag . $cipher);
}

/** Decifra um token. Se alguém mexeu no valor (ou o JWT_SECRET mudou), falha. */
function etsyOpen(string $sealed): string
{
    $raw = base64_decode($sealed, true);
    $plain = $raw === false || strlen($raw) < 29 ? false : openssl_decrypt(
        substr($raw, 28),
        'aes-256-gcm',
        etsyCipherKey(),
        OPENSSL_RAW_DATA,
        substr($raw, 0, 12),
        substr($raw, 12, 16),
    );
    if ($plain === false) {
        throw new EtsyException('A ligação à Etsy ficou inválida. Liga outra vez nas Definições.');
    }
    return $plain;
}

/** base64 próprio para URLs (sem +, / nem =), como o PKCE pede. */
function base64url(string $bytes): string
{
    return rtrim(strtr(base64_encode($bytes), '+/', '-_'), '=');
}

// ───────────── Pedidos HTTP ─────────────

/**
 * Faz um pedido HTTP e devolve [código, corpo]. Nos testes, $GLOBALS['etsyHttpFake']
 * substitui a Etsy verdadeira (nunca se fala com a Etsy a sério nos testes).
 */
function etsyHttp(string $method, string $url, array $headers = [], ?array $form = null): array
{
    if (isset($GLOBALS['etsyHttpFake'])) {
        return ($GLOBALS['etsyHttpFake'])($method, $url, $headers, $form);
    }
    $curl = curl_init($url);
    curl_setopt_array($curl, [
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 25,
        CURLOPT_HTTPHEADER => $headers,
    ]);
    if ($form !== null) {
        curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($form));
    }
    $body = curl_exec($curl);
    $status = (int) curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
    $error = curl_error($curl);
    curl_close($curl);
    if ($body === false) {
        throw new EtsyException('Não foi possível falar com a Etsy: ' . $error);
    }
    return [$status, (string) $body];
}

/** O cabeçalho que a Etsy pede em todos os pedidos: "keystring:shared_secret". */
function etsyApiKeyHeader(): string
{
    return 'x-api-key: ' . $_ENV['ETSY_KEYSTRING'] . ':' . $_ENV['ETSY_SHARED_SECRET'];
}

/** Pede tokens à Etsy (código novo ou renovação) e devolve a resposta já lida. */
function etsyTokenRequest(array $form): array
{
    [$status, $body] = etsyHttp('POST', ETSY_TOKEN_URL, [
        'Content-Type: application/x-www-form-urlencoded',
        etsyApiKeyHeader(),
    ], $form + ['client_id' => $_ENV['ETSY_KEYSTRING']]);
    $data = json_decode($body, true);
    if ($status !== 200 || !is_array($data) || empty($data['access_token']) || empty($data['refresh_token'])) {
        $reason = is_array($data) ? ($data['error_description'] ?? $data['error'] ?? '') : '';
        throw new EtsyException("A Etsy recusou o pedido ($status). $reason");
    }
    return $data;
}

// ───────────── Ligar ─────────────

/** Passo 1: prepara a ligação e devolve o endereço da Etsy para onde o browser vai. */
function etsyStartConnect(int $userId): string
{
    // limpa os pedidos velhos (abandonados a meio)
    db()->prepare('DELETE FROM etsy_oauth_states WHERE created_at < NOW() - INTERVAL ? MINUTE')
        ->execute([ETSY_STATE_MINUTES]);

    $state = base64url(random_bytes(32));    // 43 caracteres
    $verifier = base64url(random_bytes(48)); // 64 caracteres (o PKCE pede 43 a 128)
    db()->prepare('INSERT INTO etsy_oauth_states (state, code_verifier, user_id) VALUES (?, ?, ?)')
        ->execute([$state, $verifier, $userId]);

    return ETSY_AUTH_URL . '?' . http_build_query([
        'response_type' => 'code',
        'client_id' => $_ENV['ETSY_KEYSTRING'],
        'redirect_uri' => $_ENV['ETSY_REDIRECT_URI'],
        'scope' => ETSY_SCOPES,
        'state' => $state,
        'code_challenge' => base64url(hash('sha256', $verifier, true)),
        'code_challenge_method' => 'S256',
    ], '', '&', PHP_QUERY_RFC3986);
}

/**
 * Passo 3: a Etsy voltou com o código. Confere o state, troca o código pelos tokens,
 * descobre a loja e grava tudo. Devolve o nome da loja.
 */
function etsyFinishConnect(string $state, string $code): string
{
    // o state tem de existir, ser recente e só serve uma vez (apaga-se já)
    $stmt = db()->prepare(
        'SELECT * FROM etsy_oauth_states WHERE state = ? AND created_at >= NOW() - INTERVAL ? MINUTE'
    );
    $stmt->execute([$state, ETSY_STATE_MINUTES]);
    $pending = $stmt->fetch();
    db()->prepare('DELETE FROM etsy_oauth_states WHERE state = ?')->execute([$state]);
    if (!$pending) {
        throw new EtsyException('Este pedido de ligação já não vale (passaram mais de 10 minutos, ou já foi usado). Volta a carregar em "Ligar à Etsy".');
    }

    $tokens = etsyTokenRequest([
        'grant_type' => 'authorization_code',
        'redirect_uri' => $_ENV['ETSY_REDIRECT_URI'],
        'code' => $code,
        'code_verifier' => $pending['code_verifier'],
    ]);

    // o id do utilizador Etsy é o número antes do ponto no token de acesso
    $userId = (int) strtok($tokens['access_token'], '.');
    if ($userId <= 0) {
        throw new EtsyException('A Etsy devolveu um token num formato inesperado.');
    }
    $shop = etsyRequest('GET', "/application/users/$userId/shops", $tokens['access_token']);
    if (empty($shop['shop_id'])) {
        throw new EtsyException('Esta conta Etsy não tem loja.');
    }

    db()->prepare(
        'REPLACE INTO etsy_connection (id, etsy_user_id, shop_id, shop_name, access_token, refresh_token,
            access_expires_at, refresh_expires_at, connected_by, connected_at)
         VALUES (1, ?, ?, ?, ?, ?, NOW() + INTERVAL ? SECOND, NOW() + INTERVAL 90 DAY, ?, NOW())'
    )->execute([
        $userId,
        (int) $shop['shop_id'],
        (string) ($shop['shop_name'] ?? ''),
        etsySeal($tokens['access_token']),
        etsySeal($tokens['refresh_token']),
        (int) ($tokens['expires_in'] ?? 3600),
        (int) $pending['user_id'],
    ]);
    return (string) ($shop['shop_name'] ?? '');
}

// ───────────── Usar ─────────────

/** A ligação gravada, ou null se a loja não está ligada. */
function etsyConnection(): ?array
{
    $row = db()->query('SELECT * FROM etsy_connection WHERE id = 1')->fetch();
    return $row ?: null;
}

/** Um token de acesso válido: renova-o se faltar menos de 5 minutos para expirar. */
function etsyAccessToken(): string
{
    $c = etsyConnection();
    if ($c === null) {
        throw new EtsyException('A loja ainda não está ligada à Etsy. Liga-a nas Definições.');
    }
    if (strtotime($c['access_expires_at']) > time() + 300) {
        return etsyOpen($c['access_token']);
    }
    if (strtotime($c['refresh_expires_at']) <= time()) {
        throw new EtsyException('A ligação à Etsy expirou (90 dias sem uso). Liga outra vez nas Definições.');
    }
    $tokens = etsyTokenRequest([
        'grant_type' => 'refresh_token',
        'refresh_token' => etsyOpen($c['refresh_token']),
    ]);
    // cada renovação traz um token de renovação novo, com mais 90 dias
    db()->prepare(
        'UPDATE etsy_connection SET access_token = ?, refresh_token = ?,
            access_expires_at = NOW() + INTERVAL ? SECOND, refresh_expires_at = NOW() + INTERVAL 90 DAY
         WHERE id = 1'
    )->execute([
        etsySeal($tokens['access_token']),
        etsySeal($tokens['refresh_token']),
        (int) ($tokens['expires_in'] ?? 3600),
    ]);
    return $tokens['access_token'];
}

/** Um pedido à API da Etsy com um token dado. Devolve o JSON lido. */
function etsyRequest(string $method, string $path, string $accessToken, array $query = []): array
{
    $url = ETSY_API . $path . ($query === [] ? '' : '?' . http_build_query($query));
    [$status, $body] = etsyHttp($method, $url, [etsyApiKeyHeader(), 'Authorization: Bearer ' . $accessToken]);
    $data = json_decode($body, true);
    if ($status < 200 || $status >= 300 || !is_array($data)) {
        $reason = is_array($data) ? ($data['error'] ?? '') : '';
        throw new EtsyException("A Etsy respondeu com erro ($status). $reason");
    }
    return $data;
}

/** Um GET à API da Etsy em nome da loja ligada (com o token sempre em dia). */
function etsyGet(string $path, array $query = []): array
{
    return etsyRequest('GET', $path, etsyAccessToken(), $query);
}

/** O estado da ligação, para as Definições (sem tokens, claro). */
function etsyStatus(): array
{
    $c = etsyConnection();
    return [
        'configured' => etsyConfigured(),
        'connected' => $c !== null,
        'shop_name' => $c['shop_name'] ?? null,
        'connected_at' => $c['connected_at'] ?? null,
        'refresh_expires_at' => $c['refresh_expires_at'] ?? null,
    ];
}
