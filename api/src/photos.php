<?php
declare(strict_types=1);

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\UploadedFileInterface;

// ═══════════════ Fotos dos produtos ═══════════════
// Os ficheiros ficam em api/storage/products/, FORA da pasta public/:
// ninguém os abre diretamente pelo endereço, e não há maneira de lá pôr um .php e corrê-lo.
// Quem os entrega é a rota GET /api/photos/{file} (com os cabeçalhos CORS, para a versão web).

/** Os tipos de imagem aceites, e a extensão com que se gravam. */
const PHOTO_TYPES = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
];

/** O tamanho máximo de uma foto: 2 MB (o limite habitual do PHP). A app reduz antes de enviar. */
const PHOTO_MAX_BYTES = 2 * 1024 * 1024;

/** Um problema com a foto, com uma mensagem em português para mostrar na app. */
final class PhotoError extends RuntimeException
{
}

/** A pasta onde as fotos vivem (cria-a se ainda não existir). */
function photoDir(): string
{
    $dir = __DIR__ . '/../storage/products';
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
    return $dir;
}

/**
 * Confere a foto enviada e grava-a com um nome aleatório.
 * Devolve o nome do ficheiro (ex.: "3f9a…c1.jpg"), que é o que fica na base de dados.
 * O tipo confirma-se pelo CONTEÚDO do ficheiro, nunca pelo nome nem pelo que o pedido diz.
 */
function storePhoto(?UploadedFileInterface $file): string
{
    if ($file === null || $file->getError() === UPLOAD_ERR_NO_FILE) {
        throw new PhotoError('Falta a foto do produto.');
    }
    if (in_array($file->getError(), [UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE], true)
        || ($file->getSize() ?? 0) > PHOTO_MAX_BYTES) {
        throw new PhotoError('A foto é demasiado grande (máximo 2 MB).');
    }
    if ($file->getError() !== UPLOAD_ERR_OK) {
        throw new PhotoError('A foto não chegou inteira. Tenta outra vez.');
    }

    // o PHP guarda o envio num ficheiro temporário; é esse que se analisa
    $tmp = $file->getStream()->getMetadata('uri');
    $mime = (new finfo(FILEINFO_MIME_TYPE))->file($tmp);
    if (!isset(PHOTO_TYPES[$mime]) || @getimagesize($tmp) === false) {
        throw new PhotoError('A foto tem de ser uma imagem JPG, PNG ou WebP.');
    }

    $name = bin2hex(random_bytes(16)) . '.' . PHOTO_TYPES[$mime];
    $file->moveTo(photoDir() . '/' . $name);
    return $name;
}

/** Apaga o ficheiro de uma foto (se ainda existir). */
function deletePhotoFile(?string $name): void
{
    if ($name !== null && isValidPhotoName($name)) {
        @unlink(photoDir() . '/' . $name);
    }
}

/** O nome tem o formato que a API cria? (32 letras/números + extensão) Impede caminhos como "../.env". */
function isValidPhotoName(string $name): bool
{
    return preg_match('/^[a-f0-9]{32}\.(jpg|png|webp)$/', $name) === 1;
}

/**
 * O endereço completo da foto, a partir do endereço por onde chegou o pedido.
 * Assim serve no PC (localhost:8080), no emulador (10.0.2.2:8080) e no servidor.
 */
function photoUrl(Request $request, ?string $name): ?string
{
    if ($name === null) {
        return null;
    }
    $uri = $request->getUri();
    $port = $uri->getPort() !== null ? ':' . $uri->getPort() : '';
    return $uri->getScheme() . '://' . $uri->getHost() . $port . '/api/photos/' . $name;
}
