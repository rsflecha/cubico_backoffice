<?php
declare(strict_types=1);

use lbuchs\WebAuthn\WebAuthnException;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Entrar com Face ID / impressão digital (passkeys) ═══════════════
// As regras e a explicação estão em src/passkeys.php.
// Só funciona a partir do site (browser): a app de Windows não manda "Origin" e recebe 422.

const PASSKEY_NO_SITE = 'O Face ID só funciona no site da app (no browser).';
const PASSKEY_TOO_MANY = 'Demasiadas tentativas. Espera uns minutos.';

// ── Ativar (com sessão iniciada) ──

// POST /api/auth/passkeys/register/options → o desafio e os dados para o aparelho criar a chave.
// Pede a palavra-passe: com um token roubado não se cria uma entrada permanente.
$app->post('/api/auth/passkeys/register/options', function (Request $request, Response $response) {
    $rpId = passkeyRpId($request);
    if ($rpId === null) {
        return fail($response, PASSKEY_NO_SITE, 422);
    }
    $stmt = db()->prepare('SELECT * FROM users WHERE id = ? AND is_active = 1');
    $stmt->execute([$request->getAttribute('userId')]);
    $user = $stmt->fetch();
    if (!$user) {
        return fail($response, 'Já não tens acesso a esta loja.', 401);
    }
    // 422 e não 401: a sessão está boa, só a palavra-passe é que está errada
    if (!password_verify((string) (body($request)['password'] ?? ''), (string) $user['password_hash'])) {
        return fail($response, 'A palavra-passe está errada.', 422);
    }
    // as que já existem neste site: o aparelho não cria outra igual
    $existing = db()->prepare('SELECT credential_id FROM passkeys WHERE user_id = ? AND rp_id = ?');
    $existing->execute([(int) $user['id'], $rpId]);
    $exclude = array_map(fn ($id) => b64urlDecode((string) $id), $existing->fetchAll(PDO::FETCH_COLUMN));

    $lib = passkeyLib($rpId);
    // userId: um identificador que não diz nada de pessoal (o nome e o email são só para o aparelho mostrar)
    $args = $lib->getCreateArgs('cubico-user-' . $user['id'], (string) $user['email'], (string) $user['name'],
        120, true, true, null, $exclude);
    $args->publicKey->attestation = 'none'; // não se pede o certificado do fabricante
    $challengeId = savePasskeyChallenge('register', $rpId, (int) $user['id'], $lib->getChallenge()->getBinaryString());
    if ($challengeId === null) {
        return fail($response, PASSKEY_TOO_MANY, 429);
    }
    return json($response, ['challenge_id' => $challengeId, 'options' => $args->publicKey]);
})->add($requireAuth);

// POST /api/auth/passkeys/register → a resposta do aparelho; guarda a chave pública
$app->post('/api/auth/passkeys/register', function (Request $request, Response $response) {
    $rpId = passkeyRpId($request);
    if ($rpId === null) {
        return fail($response, PASSKEY_NO_SITE, 422);
    }
    $userId = (int) $request->getAttribute('userId');
    $body = body($request);
    $challenge = takePasskeyChallenge((string) ($body['challenge_id'] ?? ''), 'register', $rpId, $userId);
    if ($challenge === null) {
        return fail($response, 'O pedido expirou. Tenta outra vez.', 422);
    }
    $clientData = b64urlDecode((string) ($body['client_data_json'] ?? ''));
    $attestation = b64urlDecode((string) ($body['attestation_object'] ?? ''));
    if (!passkeyOriginMatches($clientData, $request)) {
        return fail($response, 'Não foi possível ativar o Face ID neste aparelho.', 422);
    }
    try {
        $data = passkeyLib($rpId)->processCreate($clientData, $attestation, $challenge, true, true, false);
    } catch (WebAuthnException) {
        return fail($response, 'Não foi possível ativar o Face ID neste aparelho.', 422);
    }

    $credentialId = b64urlEncode($data->credentialId);
    $taken = db()->prepare('SELECT COUNT(*) FROM passkeys WHERE credential_id = ?');
    $taken->execute([$credentialId]);
    if ((int) $taken->fetchColumn() > 0) {
        return fail($response, 'Este aparelho já tem o Face ID ativo.', 409);
    }
    $label = passkeyDeviceLabel($request->getHeaderLine('User-Agent'));
    db()->prepare(
        'INSERT INTO passkeys (user_id, credential_id, public_key, sign_count, rp_id, label) VALUES (?, ?, ?, ?, ?, ?)'
    )->execute([$userId, $credentialId, $data->credentialPublicKey, (int) $data->signatureCounter, $rpId, $label]);
    return json($response, ['passkeys' => listPasskeys($userId)], 201);
})->add($requireAuth);

// GET /api/auth/passkeys → os meus aparelhos com Face ID
$app->get('/api/auth/passkeys', function (Request $request, Response $response) {
    return json($response, ['passkeys' => listPasskeys((int) $request->getAttribute('userId'))]);
})->add($requireAuth);

// DELETE /api/auth/passkeys/{id} → tirar o Face ID de um aparelho (só os meus)
$app->delete('/api/auth/passkeys/{id:[0-9]+}', function (Request $request, Response $response, array $args) {
    $userId = (int) $request->getAttribute('userId');
    $stmt = db()->prepare('DELETE FROM passkeys WHERE id = ? AND user_id = ?');
    $stmt->execute([(int) $args['id'], $userId]);
    if ($stmt->rowCount() === 0) {
        return fail($response, 'Este aparelho já não tem o Face ID.', 404);
    }
    return json($response, ['passkeys' => listPasskeys($userId)]);
})->add($requireAuth);

// ── Entrar (sem sessão) ──

// POST /api/auth/passkeys/login/options → um desafio novo. Não pede o email:
// o aparelho mostra as contas que tem para este site.
$app->post('/api/auth/passkeys/login/options', function (Request $request, Response $response) {
    $rpId = passkeyRpId($request);
    if ($rpId === null) {
        return fail($response, PASSKEY_NO_SITE, 422);
    }
    $lib = passkeyLib($rpId);
    $args = $lib->getGetArgs([], 120, true, true, true, true, true, true);
    $challengeId = savePasskeyChallenge('login', $rpId, null, $lib->getChallenge()->getBinaryString());
    if ($challengeId === null) {
        return fail($response, PASSKEY_TOO_MANY, 429);
    }
    return json($response, ['challenge_id' => $challengeId, 'options' => $args->publicKey]);
});

// POST /api/auth/passkeys/login → a assinatura do aparelho; se bater certo, dá o token
$app->post('/api/auth/passkeys/login', function (Request $request, Response $response) {
    // a mesma mensagem para tudo o que falha, de propósito (como no login com palavra-passe)
    $denied = 'Não foi possível entrar com o Face ID. Usa a palavra-passe.';
    $rpId = passkeyRpId($request);
    if ($rpId === null) {
        return fail($response, PASSKEY_NO_SITE, 422);
    }
    $body = body($request);
    $remember = ($body['remember'] ?? false) === true;
    $challenge = takePasskeyChallenge((string) ($body['challenge_id'] ?? ''), 'login', $rpId, null);
    if ($challenge === null) {
        return fail($response, 'O pedido expirou. Tenta outra vez.', 401);
    }

    $stmt = db()->prepare(
        'SELECT p.id AS passkey_id, p.public_key, p.sign_count, u.*
         FROM passkeys p JOIN users u ON u.id = p.user_id
         WHERE p.credential_id = ? AND p.rp_id = ? AND u.is_active = 1'
    );
    $stmt->execute([(string) ($body['id'] ?? ''), $rpId]);
    $row = $stmt->fetch();
    if (!$row) {
        return fail($response, $denied, 401);
    }
    // o aparelho diz de quem é a chave: tem de ser a mesma pessoa
    $handle = b64urlDecode((string) ($body['user_handle'] ?? ''));
    if ($handle !== '' && $handle !== 'cubico-user-' . $row['id']) {
        return fail($response, $denied, 401);
    }
    $clientData = b64urlDecode((string) ($body['client_data_json'] ?? ''));
    if (!passkeyOriginMatches($clientData, $request)) {
        return fail($response, $denied, 401);
    }
    $lib = passkeyLib($rpId);
    try {
        $lib->processGet(
            $clientData,
            b64urlDecode((string) ($body['authenticator_data'] ?? '')),
            b64urlDecode((string) ($body['signature'] ?? '')),
            (string) $row['public_key'],
            $challenge,
            (int) $row['sign_count'],
            true
        );
    } catch (WebAuthnException) {
        return fail($response, $denied, 401);
    }

    $count = $lib->getSignatureCounter();
    db()->prepare('UPDATE passkeys SET last_used_at = NOW(), sign_count = ? WHERE id = ?')
        ->execute([$count ?? (int) $row['sign_count'], (int) $row['passkey_id']]);
    db()->prepare('UPDATE users SET last_login_at = NOW() WHERE id = ?')->execute([$row['id']]);
    unset($row['passkey_id'], $row['public_key'], $row['sign_count']);
    return json($response, ['token' => makeToken($row, $remember), 'user' => publicUser($row)]);
});
