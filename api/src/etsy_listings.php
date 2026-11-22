<?php
declare(strict_types=1);

/**
 * Conferir os SKU: os anúncios ativos da Etsy contra as variantes da app.
 *
 * Uma encomenda da Etsy só entra se TODOS os artigos tiverem variante (ver etsy_sync.php).
 * Isto mostra, antes de haver vendas, que anúncios iam falhar e porquê.
 * Usa o MESMO etsyFindVariant() da sincronização: o que aqui diz "liga" liga mesmo.
 *
 * Só lê: não mexe em nada na Etsy nem na base de dados.
 * Precisa do scope listings_r (a ligação feita antes disto só tinha transactions_r e shops_r).
 */

/** Trava de segurança: 1000 anúncios ativos chega para esta loja. */
const ETSY_LISTINGS_MAX_PAGES = 10;

/** As escolhas de um produto do anúncio (ex.: "Piloto: Hamilton"), num texto curto. */
function etsyProductVariation(array $product): string
{
    $parts = [];
    foreach ((array) ($product['property_values'] ?? []) as $p) {
        $values = implode('/', array_map('strval', (array) ($p['values'] ?? [])));
        if ($values !== '') {
            $name = trim((string) ($p['property_name'] ?? ''));
            $parts[] = $name === '' ? $values : "$name: $values";
        }
    }
    return implode(' · ', $parts);
}

/** As peças de um produto do anúncio, se for um pack de quantidade (a mesma regra da sincronização). */
function etsyProductPack(array $product): int
{
    foreach ((array) ($product['property_values'] ?? []) as $p) {
        $n = etsyPackFrom((string) ($p['property_name'] ?? ''), (string) (((array) ($p['values'] ?? []))[0] ?? ''));
        if ($n > 1) {
            return $n;
        }
    }
    return 1;
}

/** As variantes que existem na app, por id (para mostrar o nome e o SKU de cada uma). */
function etsyAppVariants(): array
{
    $rows = db()->query(
        "SELECT v.id, v.sku, v.name, v.product_id, p.name AS product_name
           FROM variants v JOIN products p ON p.id = v.product_id
          WHERE v.is_active = 1 AND p.status = 'active'
          ORDER BY v.sku"
    )->fetchAll();
    $byId = [];
    foreach ($rows as $r) {
        $label = $r['name'] === $r['product_name'] ? $r['product_name'] : "{$r['product_name']} · {$r['name']}";
        $byId[(int) $r['id']] = ['variant_id' => (int) $r['id'], 'product_id' => (int) $r['product_id'], 'sku' => $r['sku'], 'label' => $label];
    }
    return $byId;
}

/** Os anúncios ativos da loja, com o inventário (onde estão os SKU de cada produto). */
function etsyActiveListings(int $shopId): array
{
    $all = [];
    for ($page = 0; $page < ETSY_LISTINGS_MAX_PAGES; $page++) {
        try {
            $data = etsyGet("/application/shops/$shopId/listings", [
                'state' => 'active',
                'includes' => 'Inventory',
                'limit' => 100,
                'offset' => $page * 100,
            ]);
        } catch (EtsyException $e) {
            // 403 = a ligação é antiga e não tem autorização para ler anúncios
            if (str_contains($e->getMessage(), '(403)')) {
                throw new EtsyException('A ligação à Etsy não tem autorização para ler os anúncios. '
                    . 'Carrega em «Ligar outra vez» (Definições → Etsy) e autoriza; as encomendas que já entraram ficam.');
            }
            throw $e;
        }
        $results = (array) ($data['results'] ?? []);
        array_push($all, ...$results);
        if (count($results) < 100 || count($all) >= (int) ($data['count'] ?? 0)) {
            break;
        }
    }
    return $all;
}

/**
 * O confronto. Cada produto de cada anúncio fica com um estado:
 *  - ok          liga a uma variante (pelo SKU, ou, sem SKU, pela listagem);
 *  - unknown_sku tem SKU, mas nenhuma variante da app tem esse SKU;
 *  - no_sku      não tem SKU (e a listagem não está ligada a uma única variante).
 * Junta as variantes da app que nenhum anúncio usa (não é erro: pode não estar à venda na Etsy).
 */
function etsyListingsCheck(): array
{
    $shopId = (int) (etsyConnection()['shop_id'] ?? 0);
    if ($shopId === 0) {
        throw new EtsyException('A loja ainda não está ligada à Etsy. Liga-a nas Definições.');
    }
    $variants = etsyAppVariants();
    $used = [];
    $listings = [];
    $ok = 0;
    $problems = 0;
    $digital = 0;

    foreach (etsyActiveListings($shopId) as $l) {
        // os digitais (downloads) não entram na app, por isso não há SKU a conferir
        if (($l['listing_type'] ?? '') === 'download') {
            $digital++;
            continue;
        }
        $products = [];
        foreach ((array) ($l['inventory']['products'] ?? []) as $p) {
            if (!empty($p['is_deleted'])) {
                continue;
            }
            $sku = trim((string) ($p['sku'] ?? ''));
            $productId = trim((string) ($p['product_id'] ?? ''));
            // exatamente o que a sincronização faz com um artigo vendido
            $variantId = etsyFindVariant(['sku' => $sku, 'listing_id' => $l['listing_id'] ?? null, 'product_id' => $productId]);
            // associado à mão: o SKU não serviu e quem liga é a tabela etsy_links
            $linked = $variantId !== null
                && ($sku === '' || etsyVariantBySku($sku) === null)
                && etsyLinkedVariant($productId) === $variantId;
            $status = $variantId !== null ? 'ok' : ($sku === '' ? 'no_sku' : 'unknown_sku');
            $status === 'ok' ? $ok++ : $problems++;
            if ($variantId !== null) {
                $used[$variantId] = true;
            }
            $products[] = [
                'product_id' => $productId === '' ? null : $productId,
                'linked' => $linked,
                'sku' => $sku === '' ? null : $sku,
                'variation' => etsyProductVariation($p),
                'pack' => etsyProductPack($p), // 10 = cada venda deste produto são 10 peças
                'status' => $status,
                'variant' => $variantId === null ? null : ($variants[$variantId] ?? ['variant_id' => $variantId, 'product_id' => null, 'sku' => null, 'label' => 'variante inativa']),
            ];
        }
        $listings[] = [
            'listing_id' => (string) ($l['listing_id'] ?? ''),
            'title' => html_entity_decode((string) ($l['title'] ?? ''), ENT_QUOTES | ENT_HTML5),
            'url' => (string) ($l['url'] ?? ''),
            'products' => $products,
        ];
    }

    return [
        'checked_at' => date('c'),
        'ok' => $ok,
        'problems' => $problems,
        'digital_skipped' => $digital,
        'listings' => $listings,
        'unlisted_variants' => array_values(array_filter($variants, fn ($v) => !isset($used[$v['variant_id']]))),
        'variants' => array_values($variants), // para escolher uma ao associar à mão
    ];
}
