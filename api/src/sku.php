<?php
declare(strict_types=1);

// ═══════════════ SKU automático ═══════════════
// Decisão de 2026-11-16 — ninguém escreve SKU à mão:
//   categoria "Suportes"                → código SUP (3 letras do nome, sem acentos)
//   produto                             → CD3-SUP-01, CD3-SUP-02… (recomeça em cada categoria)
//   produto sem categoria               → CD3-GER-01…  (GER fica reservado para isto)
//   variante "Hamilton"                 → CD3-SUP-01-HAMILTON
//   variante sem nome (produto simples) → CD3-SUP-01
// As mesmas regras estão na migração 002 (para os produtos que já existiam).

const SKU_PREFIX = 'CD3';
const NO_CATEGORY_CODE = 'GER';
const VARIANT_SLUG_MAX = 30;

/** "Fórmula 1" → "FORMULA 1": maiúsculas e sem acentos. */
function plainUpper(string $text): string
{
    return strtr(mb_strtoupper(trim($text), 'UTF-8'), [
        'Á' => 'A', 'À' => 'A', 'Â' => 'A', 'Ã' => 'A', 'Ä' => 'A',
        'É' => 'E', 'È' => 'E', 'Ê' => 'E', 'Ë' => 'E',
        'Í' => 'I', 'Ì' => 'I', 'Î' => 'I', 'Ï' => 'I',
        'Ó' => 'O', 'Ò' => 'O', 'Ô' => 'O', 'Õ' => 'O', 'Ö' => 'O',
        'Ú' => 'U', 'Ù' => 'U', 'Û' => 'U', 'Ü' => 'U',
        'Ç' => 'C', 'Ñ' => 'N',
    ]);
}

/** Um código de categoria aceitável: 2 a 5 letras ou algarismos. */
function isValidCategoryCode(string $code): bool
{
    return preg_match('/^[A-Z0-9]{2,5}$/', $code) === 1;
}

/**
 * O código para uma categoria nova: as 3 primeiras letras do nome ("Suportes" → SUP).
 * Se já existir (ou for GER, que está reservado), tenta SU2, SU3…
 */
function newCategoryCode(string $name): string
{
    $base = substr((string) preg_replace('/[^A-Z0-9]/', '', plainUpper($name)), 0, 3);
    if ($base === '') {
        $base = 'CAT';
    }
    $taken = db()->prepare('SELECT COUNT(*) FROM categories WHERE code = ?');
    for ($n = 1; ; $n++) {
        $code = $n === 1 ? $base : substr($base, 0, 2) . $n;
        if ($code === NO_CATEGORY_CODE) {
            continue;
        }
        $taken->execute([$code]);
        if ((int) $taken->fetchColumn() === 0) {
            return $code;
        }
    }
}

/** O SKU do próximo produto de uma categoria (ou dos sem categoria): CD3-SUP-03. */
function nextProductSku(?int $categoryId): string
{
    $code = NO_CATEGORY_CODE;
    if ($categoryId !== null) {
        $stmt = db()->prepare('SELECT code FROM categories WHERE id = ?');
        $stmt->execute([$categoryId]);
        $code = (string) ($stmt->fetchColumn() ?: NO_CATEGORY_CODE);
    }
    $prefix = SKU_PREFIX . "-$code-";

    // o maior número já usado com este prefixo (mesmo de produtos que mudaram de categoria)
    $stmt = db()->prepare('SELECT base_sku FROM products WHERE base_sku LIKE ?');
    $stmt->execute([$prefix . '%']);
    $max = 0;
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $sku) {
        $number = substr((string) $sku, strlen($prefix));
        if (ctype_digit($number)) {
            $max = max($max, (int) $number);
        }
    }
    return $prefix . str_pad((string) ($max + 1), 2, '0', STR_PAD_LEFT);
}

/** "Ação & Côr!" → "ACAO-COR"; um nome vazio dá "" (a variante é o próprio produto). */
function variantSlug(string $name): string
{
    if (trim($name) === '') {
        return '';
    }
    $slug = trim((string) preg_replace('/[^A-Z0-9]+/', '-', plainUpper($name)), '-');
    $slug = trim(substr($slug, 0, VARIANT_SLUG_MAX), '-');
    return $slug === '' ? 'V' : $slug;
}

/** O SKU de uma variante: o do produto, mais o nome. */
function variantSku(string $productSku, string $variantName): string
{
    $slug = variantSlug($variantName);
    return $slug === '' ? $productSku : "$productSku-$slug";
}

/** Já existe outra variante com este SKU? (dois nomes que dão o mesmo, ex.: "Azul" e "azul") */
function variantSkuTaken(string $sku, ?int $exceptId = null): bool
{
    $stmt = db()->prepare('SELECT COUNT(*) FROM variants WHERE sku = ? AND id <> ?');
    $stmt->execute([$sku, $exceptId ?? 0]);
    return (int) $stmt->fetchColumn() > 0;
}

/** Volta a calcular o SKU de todas as variantes de um produto (depois de o SKU dele mudar). */
function refreshVariantSkus(int $productId): void
{
    $stmt = db()->prepare('SELECT base_sku FROM products WHERE id = ?');
    $stmt->execute([$productId]);
    $productSku = (string) $stmt->fetchColumn();

    $variants = db()->prepare('SELECT id, name FROM variants WHERE product_id = ?');
    $variants->execute([$productId]);
    $update = db()->prepare('UPDATE variants SET sku = ? WHERE id = ?');
    foreach ($variants->fetchAll() as $v) {
        $update->execute([variantSku($productSku, (string) $v['name']), (int) $v['id']]);
    }
}
