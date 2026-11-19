<?php
declare(strict_types=1);

// ═══════════════ SKU automático ═══════════════
// Decisão de 2026-11-16 (variantes por número desde 2026-11-19) — ninguém escreve SKU à mão:
//   categoria "Suportes"                → código SUP (3 letras do nome, sem acentos)
//   produto                             → CD3-SUP-01, CD3-SUP-02… (recomeça em cada categoria)
//   produto sem categoria               → CD3-GER-01…  (GER fica reservado para isto)
//   variantes com nome                  → CD3-SUP-01-01, CD3-SUP-01-02… (pela ordem de criação;
//                                         o número não muda se o nome mudar, e não se reaproveita)
//   variante sem nome (modelo único)    → CD3-SUP-01
// A migração 008 renumerou as variantes que já existiam (antes levavam o nome: CD3-SUP-01-HAMILTON).

const SKU_PREFIX = 'CD3';
const NO_CATEGORY_CODE = 'GER';

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

/** O SKU de uma variante: o do produto, mais o número (3 → "-03"). Sem número = o do produto. */
function variantSku(string $productSku, ?int $number): string
{
    return $number === null ? $productSku : $productSku . '-' . str_pad((string) $number, 2, '0', STR_PAD_LEFT);
}

/** O número de uma variante, lido do SKU dela ("CD3-NAT-01-03" → 3). null se não tiver. */
function variantNumber(string $productSku, string $sku): ?int
{
    $prefix = "$productSku-";
    if (!str_starts_with($sku, $prefix)) {
        return null;
    }
    $number = substr($sku, strlen($prefix));
    return ctype_digit($number) ? (int) $number : null;
}

/** O número da próxima variante com nome: o maior já usado no produto, mais 1. */
function nextVariantNumber(int $productId, string $productSku): int
{
    $stmt = db()->prepare('SELECT sku FROM variants WHERE product_id = ?');
    $stmt->execute([$productId]);
    $max = 0;
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $sku) {
        $max = max($max, variantNumber($productSku, (string) $sku) ?? 0);
    }
    return $max + 1;
}

/**
 * Já há outra variante com este nome no produto? (sem contar maiúsculas: "Azul" e "azul").
 * O nome vazio também conta: só uma variante pode ficar sem nome.
 */
function variantNameTaken(int $productId, string $name, ?int $exceptId = null): bool
{
    $stmt = db()->prepare('SELECT COUNT(*) FROM variants WHERE product_id = ? AND UPPER(TRIM(name)) = UPPER(?) AND id <> ?');
    $stmt->execute([$productId, trim($name), $exceptId ?? 0]);
    return (int) $stmt->fetchColumn() > 0;
}

/** O SKU do produto mudou (mudou de categoria): as variantes trocam o início e ficam com o número. */
function refreshVariantSkus(int $productId, string $oldProductSku): void
{
    $stmt = db()->prepare('SELECT base_sku FROM products WHERE id = ?');
    $stmt->execute([$productId]);
    $productSku = (string) $stmt->fetchColumn();

    $variants = db()->prepare('SELECT id, name, sku FROM variants WHERE product_id = ? ORDER BY id');
    $variants->execute([$productId]);
    $rows = $variants->fetchAll();
    $max = 0;
    foreach ($rows as $v) {
        $max = max($max, variantNumber($oldProductSku, (string) $v['sku']) ?? 0);
    }
    $update = db()->prepare('UPDATE variants SET sku = ? WHERE id = ?');
    foreach ($rows as $v) {
        if (trim((string) $v['name']) === '') {
            $number = null;
        } else {
            // uma com nome e sem número (não devia haver): recebe o próximo
            $number = variantNumber($oldProductSku, (string) $v['sku']) ?? ++$max;
        }
        $update->execute([variantSku($productSku, $number), (int) $v['id']]);
    }
}
