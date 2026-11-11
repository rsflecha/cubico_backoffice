<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Produtos ═══════════════
// Todos com sessão veem a lista; só o administrador cria, muda e apaga.

tableRoutes($app, '/api/products', 'products', [
    'id' => 'int',
    'name' => 'string',
    'base_sku' => 'string',
    'description' => 'string',
    'category_id' => 'int',
    'status' => 'string',
    'is_customizable' => 'bool',
    'is_pack' => 'bool',
    'created_at' => 'string',
    'updated_at' => 'string',
], required: ['name', 'base_sku'], canCreate: true, orderBy: 'name',
   requireAuth: $requireAuth, requireAdmin: $requireAdmin, everyoneCanList: true);

// DELETE /api/products/{id} → apagar (as variantes vão com ele)
$app->delete('/api/products/{id}', function (Request $request, Response $response, array $args) {
    try {
        $stmt = db()->prepare('DELETE FROM products WHERE id = ?');
        $stmt->execute([(int) $args['id']]);
    } catch (PDOException $e) {
        // uma variante deste produto já foi vendida: as encomendas guardam-na
        if ($e->getCode() === '23000') {
            return fail($response, 'Este produto já tem vendas. Em vez de o apagar, muda-o para "Arquivado".', 409);
        }
        throw $e;
    }
    return $response->withStatus(204);
})->add($requireAdmin)->add($requireAuth);

// ═══════════════ Variantes ═══════════════
// Uma variante traz a "receita" dentro dela: os filamentos (gramas) e os componentes (quantidade).
// Na base de dados são três tabelas; a app recebe e envia tudo junto.

const VARIANT_TYPES = [
    'id' => 'int',
    'product_id' => 'int',
    'name' => 'string',
    'sku' => 'string',
    'sale_price' => 'float',
    'print_time_min' => 'int',
    'plate_count' => 'int',
    'weight_g' => 'int',
    'printer_id' => 'int',
    'model_file' => 'string',
    'etsy_listing_id' => 'string',
    'is_active' => 'bool',
];

/** As variantes (de um produto, ou todas), cada uma com a sua receita. */
function readVariants(?int $productId = null, ?int $variantId = null): array
{
    $where = [];
    $params = [];
    if ($productId !== null) {
        $where[] = 'product_id = ?';
        $params[] = $productId;
    }
    if ($variantId !== null) {
        $where[] = 'id = ?';
        $params[] = $variantId;
    }
    $sql = 'SELECT * FROM variants' . ($where ? ' WHERE ' . implode(' AND ', $where) : '') . ' ORDER BY product_id, id';
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    $variants = array_map(fn ($row) => typed($row, VARIANT_TYPES), $stmt->fetchAll());
    if ($variants === []) {
        return [];
    }

    // as receitas de todas estas variantes, em duas consultas (e não duas por variante)
    $ids = array_column($variants, 'id');
    $marks = implode(', ', array_fill(0, count($ids), '?'));
    $filaments = db()->prepare("SELECT variant_id, filament_id, grams FROM variant_filaments WHERE variant_id IN ($marks)");
    $filaments->execute($ids);
    $components = db()->prepare("SELECT variant_id, component_id, quantity FROM variant_components WHERE variant_id IN ($marks)");
    $components->execute($ids);

    $recipe = [];
    foreach ($filaments->fetchAll() as $f) {
        $recipe[(int) $f['variant_id']]['filaments'][] = ['filament_id' => (int) $f['filament_id'], 'grams' => (int) $f['grams']];
    }
    foreach ($components->fetchAll() as $c) {
        $recipe[(int) $c['variant_id']]['components'][] = ['component_id' => (int) $c['component_id'], 'quantity' => (int) $c['quantity']];
    }
    foreach ($variants as &$v) {
        $v['filaments'] = $recipe[$v['id']]['filaments'] ?? [];
        $v['components'] = $recipe[$v['id']]['components'] ?? [];
    }
    return $variants;
}

/** Troca a receita de uma variante pela que veio da app. */
function saveRecipe(int $variantId, array $body): void
{
    if (array_key_exists('filaments', $body)) {
        db()->prepare('DELETE FROM variant_filaments WHERE variant_id = ?')->execute([$variantId]);
        $insert = db()->prepare('INSERT INTO variant_filaments (variant_id, filament_id, grams) VALUES (?, ?, ?)');
        foreach ((array) $body['filaments'] as $f) {
            if ((int) ($f['grams'] ?? 0) > 0) {
                $insert->execute([$variantId, (int) $f['filament_id'], (int) $f['grams']]);
            }
        }
    }
    if (array_key_exists('components', $body)) {
        db()->prepare('DELETE FROM variant_components WHERE variant_id = ?')->execute([$variantId]);
        $insert = db()->prepare('INSERT INTO variant_components (variant_id, component_id, quantity) VALUES (?, ?, ?)');
        foreach ((array) $body['components'] as $c) {
            if ((int) ($c['quantity'] ?? 0) > 0) {
                $insert->execute([$variantId, (int) $c['component_id'], (int) $c['quantity']]);
            }
        }
    }
}

// GET /api/variants            → todas
// GET /api/variants?product_id=3 → as de um produto
$app->get('/api/variants', function (Request $request, Response $response) {
    $productId = $request->getQueryParams()['product_id'] ?? null;
    return json($response, readVariants($productId === null ? null : (int) $productId));
})->add($requireAuth);

// POST /api/variants → uma variante nova, vazia, para depois se preencher
$app->post('/api/variants', function (Request $request, Response $response) {
    $productId = (int) (body($request)['product_id'] ?? 0);
    $stmt = db()->prepare('SELECT base_sku FROM products WHERE id = ?');
    $stmt->execute([$productId]);
    $baseSku = $stmt->fetchColumn();
    if ($baseSku === false) {
        return fail($response, 'Este produto já não existe.', 404);
    }

    // o primeiro SKU livre: CD3-SDA-01-V1, -V2…
    $n = 1;
    $check = db()->prepare('SELECT COUNT(*) FROM variants WHERE sku = ?');
    do {
        $sku = "$baseSku-V$n";
        $check->execute([$sku]);
        $n++;
    } while ((int) $check->fetchColumn() > 0);

    db()->prepare('INSERT INTO variants (product_id, name, sku, sale_price) VALUES (?, ?, ?, 0)')
        ->execute([$productId, 'Nova variante', $sku]);
    return json($response, readVariants(variantId: (int) db()->lastInsertId())[0], 201);
})->add($requireAdmin)->add($requireAuth);

// PUT /api/variants/{id} → mudar a variante e a receita, tudo ou nada
$app->put('/api/variants/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    if (readVariants(variantId: $id) === []) {
        return fail($response, 'Esta variante já não existe.', 404);
    }
    $body = body($request);
    $writable = ['name', 'sku', 'sale_price', 'print_time_min', 'plate_count', 'weight_g',
        'printer_id', 'model_file', 'etsy_listing_id', 'is_active'];
    $columns = array_values(array_filter($writable, fn ($c) => array_key_exists($c, $body)));

    // uma transação: ou grava a variante E a receita, ou não grava nada
    db()->beginTransaction();
    try {
        if ($columns !== []) {
            $sets = implode(', ', array_map(fn ($c) => "$c = ?", $columns));
            $values = array_map(fn ($c) => dbValue($body[$c], VARIANT_TYPES[$c]), $columns);
            $values[] = $id;
            db()->prepare("UPDATE variants SET $sets WHERE id = ?")->execute($values);
        }
        saveRecipe($id, $body);
        db()->commit();
    } catch (PDOException $e) {
        db()->rollBack();
        if (isDuplicate($e)) {
            return fail($response, 'Já existe uma variante com esse SKU.', 409);
        }
        throw $e;
    }
    return json($response, readVariants(variantId: $id)[0]);
})->add($requireAdmin)->add($requireAuth);

// DELETE /api/variants/{id} → apagar (só se nunca foi vendida nem usada)
$app->delete('/api/variants/{id}', function (Request $request, Response $response, array $args) {
    try {
        $stmt = db()->prepare('DELETE FROM variants WHERE id = ?');
        $stmt->execute([(int) $args['id']]);
    } catch (PDOException $e) {
        // está numa encomenda, numa tarefa de produção ou num pack: a base de dados não deixa
        if ($e->getCode() === '23000') {
            return fail(
                $response,
                'Esta variante já foi vendida, está na produção ou num pack. Fica guardada para o histórico.',
                409,
            );
        }
        throw $e;
    }
    return $response->withStatus(204);
})->add($requireAdmin)->add($requireAuth);
