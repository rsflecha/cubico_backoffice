<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Produtos ═══════════════
// Todos com sessão veem a lista; só o administrador cria, muda e apaga.
// Cada produto tem UMA foto (a linha de product_photos com sort_order 0), obrigatória ao criar.
// Já não usa o tableRoutes(): a lista junta a foto, e criar recebe um ficheiro.

const PRODUCT_TYPES = [
    'id' => 'int',
    'name' => 'string',
    'base_sku' => 'string',
    'description' => 'string',
    'category_id' => 'int',
    'status' => 'string',
    'is_customizable' => 'bool',
    'is_pack' => 'bool',
    'colors_per_piece' => 'int', // 1 ou 2: quantas cores o cliente escolhe por peça
    'created_at' => 'string',
    'updated_at' => 'string',
];

/** As colunas que a app pode escrever. O base_sku não: é a API que o dá (src/sku.php). */
const PRODUCT_WRITABLE = ['name', 'description', 'category_id', 'status', 'is_customizable', 'is_pack', 'colors_per_piece'];

/** Os produtos (todos, ou só um), cada um com o nome do ficheiro da sua foto em "photo". */
function readProducts(?int $id = null): array
{
    // LEFT JOIN: um produto sem foto (dos antigos) aparece na mesma, com photo = NULL
    $sql = 'SELECT p.*, ph.url AS photo
              FROM products p
              LEFT JOIN product_photos ph ON ph.product_id = p.id AND ph.sort_order = 0'
        . ($id !== null ? ' WHERE p.id = ?' : '')
        . ' ORDER BY p.name';
    $stmt = db()->prepare($sql);
    $stmt->execute($id !== null ? [$id] : []);
    $rows = $stmt->fetchAll();

    // as cores disponíveis de cada produto, numa só consulta
    $colors = [];
    $all = db()->query('SELECT product_id, filament_id FROM product_colors ORDER BY filament_id');
    foreach ($all->fetchAll() as $c) {
        $colors[(int) $c['product_id']][] = (int) $c['filament_id'];
    }
    foreach ($rows as &$row) {
        $row['color_ids'] = $colors[(int) $row['id']] ?? [];
    }
    return $rows;
}

/** Um produto pronto para a app: os tipos certos, o endereço da foto e as cores disponíveis. */
function productJson(Request $request, array $row): array
{
    return typed($row, PRODUCT_TYPES) + [
        'photo_url' => photoUrl($request, $row['photo'] ?? null),
        'color_ids' => $row['color_ids'] ?? [],
    ];
}

/**
 * Os ids das cores que vieram no pedido (null = o pedido não fala de cores: ficam como estão).
 * Só valem filamentos que existem; os outros ignoram-se.
 */
function productColorIds(array $body): ?array
{
    if (!array_key_exists('color_ids', $body) || !is_array($body['color_ids'])) {
        return null;
    }
    $ids = array_values(array_unique(array_map('intval', $body['color_ids'])));
    if ($ids === []) {
        return [];
    }
    $marks = implode(', ', array_fill(0, count($ids), '?'));
    $stmt = db()->prepare("SELECT id FROM filaments WHERE id IN ($marks)");
    $stmt->execute($ids);
    return array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
}

/** Troca as cores disponíveis de um produto (chamar dentro da transação). */
function saveProductColors(int $productId, array $colorIds): void
{
    db()->prepare('DELETE FROM product_colors WHERE product_id = ?')->execute([$productId]);
    $insert = db()->prepare('INSERT INTO product_colors (product_id, filament_id) VALUES (?, ?)');
    foreach ($colorIds as $filamentId) {
        $insert->execute([$productId, $filamentId]);
    }
}

/** Os valores das colunas que vieram no pedido, prontos para o SQL. */
function productValues(array $body): array
{
    // cores por peça: só 1 ou 2 (outro valor qualquer conta como 1)
    if (array_key_exists('colors_per_piece', $body)) {
        $body['colors_per_piece'] = (int) $body['colors_per_piece'] === 2 ? 2 : 1;
    }
    $columns = array_values(array_filter(PRODUCT_WRITABLE, fn ($c) => array_key_exists($c, $body)));
    $values = array_map(fn ($c) => dbValue($body[$c], PRODUCT_TYPES[$c]), $columns);
    return [$columns, $values];
}

// GET /api/products → a lista (todos com sessão)
$app->get('/api/products', function (Request $request, Response $response) {
    return json($response, array_map(fn ($row) => productJson($request, $row), readProducts()));
})->add($requireAuth);

// POST /api/products → criar, COM a foto
// O pedido é "multipart/form-data" (o formato dos formulários com ficheiros), com duas partes:
//   product → o JSON do produto, como texto
//   photo   → o ficheiro da imagem
// O JSON vai inteiro numa parte porque num formulário tudo é texto: "false" seria lido como verdadeiro.
$app->post('/api/products', function (Request $request, Response $response) {
    $body = json_decode((string) (body($request)['product'] ?? ''), true);
    if (!is_array($body)) {
        return fail($response, 'O pedido não traz os dados do produto.', 422);
    }
    if (trim((string) ($body['name'] ?? '')) === '') {
        return fail($response, 'Falta preencher o nome.', 422);
    }

    // primeiro a foto: se estiver mal, não se cria nada
    try {
        $photo = storePhoto($request->getUploadedFiles()['photo'] ?? null);
    } catch (PhotoError $e) {
        return fail($response, $e->getMessage(), 422);
    }

    [$columns, $values] = productValues($body);
    // o SKU: o próximo número da categoria (CD3-SUP-03)
    $columns[] = 'base_sku';
    $values[] = nextProductSku(isset($body['category_id']) ? (int) $body['category_id'] : null);
    $marks = implode(', ', array_fill(0, count($columns), '?'));
    $pdo = db();
    try {
        // produto e foto gravam-se juntos: ou ficam os dois, ou nenhum
        $pdo->beginTransaction();
        $pdo->prepare('INSERT INTO products (' . implode(', ', $columns) . ") VALUES ($marks)")->execute($values);
        $id = (int) $pdo->lastInsertId();
        $pdo->prepare('INSERT INTO product_photos (product_id, url, sort_order) VALUES (?, ?, 0)')->execute([$id, $photo]);
        saveProductColors($id, productColorIds($body) ?? []);
        $pdo->commit();
    } catch (PDOException $e) {
        $pdo->rollBack();
        deletePhotoFile($photo); // o produto não ficou: a foto também não fica
        if (isDuplicate($e)) {
            // dois produtos criados ao mesmo tempo na mesma categoria
            return fail($response, 'Não foi possível dar o SKU ao produto. Tenta outra vez.', 409);
        }
        throw $e;
    }
    return json($response, productJson($request, readProducts($id)[0]), 201);
})->add($requireAdmin)->add($requireAuth);

// PUT /api/products/{id} → mudar os dados (JSON normal; a foto muda-se na rota de baixo)
$app->put('/api/products/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $found = readProducts($id);
    if ($found === []) {
        return fail($response, 'Este produto já não existe.', 404);
    }
    $body = body($request);
    [$columns, $values] = productValues($body);
    $colorIds = productColorIds($body);
    if ($columns === [] && $colorIds === null) {
        return fail($response, 'Não há nada para mudar.', 422);
    }

    // mudou de categoria: SKU novo, no fim da numeração da categoria nova (e as variantes com ele)
    $oldCategory = $found[0]['category_id'] === null ? null : (int) $found[0]['category_id'];
    $newCategory = array_key_exists('category_id', $body)
        ? ($body['category_id'] === null ? null : (int) $body['category_id'])
        : $oldCategory;
    $categoryChanged = $newCategory !== $oldCategory;
    if ($categoryChanged) {
        $columns[] = 'base_sku';
        $values[] = nextProductSku($newCategory);
    }

    $sets = implode(', ', array_map(fn ($c) => "$c = ?", $columns));
    $values[] = $id;
    $pdo = db();
    try {
        $pdo->beginTransaction();
        if ($columns !== []) {
            $pdo->prepare("UPDATE products SET $sets WHERE id = ?")->execute($values);
        }
        if ($categoryChanged) {
            refreshVariantSkus($id);
        }
        if ($colorIds !== null) {
            saveProductColors($id, $colorIds);
        }
        $pdo->commit();
    } catch (PDOException $e) {
        $pdo->rollBack();
        if (isDuplicate($e)) {
            return fail($response, 'Não foi possível dar o SKU novo ao produto. Tenta outra vez.', 409);
        }
        throw $e;
    }
    return json($response, productJson($request, readProducts($id)[0]));
})->add($requireAdmin)->add($requireAuth);

// POST /api/products/{id}/photo → trocar a foto (multipart, só a parte "photo")
// Não há rota para TIRAR a foto: é obrigatória, por isso só se troca.
$app->post('/api/products/{id}/photo', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $found = readProducts($id);
    if ($found === []) {
        return fail($response, 'Este produto já não existe.', 404);
    }
    $old = $found[0]['photo'];

    try {
        $photo = storePhoto($request->getUploadedFiles()['photo'] ?? null);
    } catch (PhotoError $e) {
        return fail($response, $e->getMessage(), 422);
    }

    $pdo = db();
    try {
        $pdo->beginTransaction();
        $pdo->prepare('DELETE FROM product_photos WHERE product_id = ? AND sort_order = 0')->execute([$id]);
        $pdo->prepare('INSERT INTO product_photos (product_id, url, sort_order) VALUES (?, ?, 0)')->execute([$id, $photo]);
        $pdo->commit();
    } catch (PDOException $e) {
        $pdo->rollBack();
        deletePhotoFile($photo);
        throw $e;
    }
    deletePhotoFile($old); // só depois de a nova estar gravada
    return json($response, productJson($request, readProducts($id)[0]));
})->add($requireAdmin)->add($requireAuth);

// GET /api/photos/{file} → a imagem em si
// Sem sessão de propósito: o Image.network da versão web não consegue enviar o token.
// O nome é aleatório (32 letras), por isso não se adivinha; e são fotos de produtos que vão para a Etsy.
$app->get('/api/photos/{file}', function (Request $request, Response $response, array $args) {
    $name = (string) $args['file'];
    $path = photoDir() . '/' . $name;
    if (!isValidPhotoName($name) || !is_file($path)) {
        return fail($response, 'Esta foto não existe.', 404);
    }
    $mime = array_search(pathinfo($name, PATHINFO_EXTENSION), PHOTO_TYPES, true);
    $response->getBody()->write((string) file_get_contents($path));
    return $response
        ->withHeader('Content-Type', $mime)
        // o nome muda sempre que a foto muda, por isso o browser pode guardá-la para sempre
        ->withHeader('Cache-Control', 'public, max-age=31536000, immutable');
});

// DELETE /api/products/{id} → apagar (as variantes e a linha da foto vão com ele; o ficheiro apaga-se aqui)
$app->delete('/api/products/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $found = readProducts($id);
    try {
        $stmt = db()->prepare('DELETE FROM products WHERE id = ?');
        $stmt->execute([$id]);
    } catch (PDOException $e) {
        // uma variante deste produto já foi vendida: as encomendas guardam-na
        if ($e->getCode() === '23000') {
            return fail($response, 'Este produto já tem vendas. Em vez de o apagar, muda-o para "Arquivado".', 409);
        }
        throw $e;
    }
    deletePhotoFile($found[0]['photo'] ?? null);
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

/** A mensagem para um nome que dá um SKU já usado. */
function variantNameTakenMessage(string $name): string
{
    return trim($name) === ''
        ? 'Só uma variante pode ficar sem nome. Dá um nome a esta (ex.: Hamilton).'
        : 'Já existe uma variante com esse nome neste produto.';
}

// POST /api/variants → uma variante nova, com o nome que vem da app ({product_id, name})
// Se o produto já tiver variantes, a nova copia o preço, o tempo, o peso e a receita da primeira:
// as variantes por nome (Hamilton, Verstappen…) costumam custar o mesmo, e o Rui só acerta o que muda.
$app->post('/api/variants', function (Request $request, Response $response) {
    $body = body($request);
    $productId = (int) ($body['product_id'] ?? 0);
    $name = trim((string) ($body['name'] ?? ''));
    $stmt = db()->prepare('SELECT base_sku FROM products WHERE id = ?');
    $stmt->execute([$productId]);
    $baseSku = $stmt->fetchColumn();
    if ($baseSku === false) {
        return fail($response, 'Este produto já não existe.', 404);
    }

    $sku = variantSku((string) $baseSku, $name);
    if (variantSkuTaken($sku)) {
        return fail($response, variantNameTakenMessage($name), 409);
    }

    $first = readVariants($productId)[0] ?? null;
    $pdo = db();
    $pdo->beginTransaction();
    try {
        $pdo->prepare(
            'INSERT INTO variants (product_id, name, sku, sale_price, print_time_min, plate_count, weight_g, printer_id)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
        )->execute([
            $productId, $name, $sku,
            $first['sale_price'] ?? 0,
            $first['print_time_min'] ?? 0,
            $first['plate_count'] ?? 1,
            $first['weight_g'] ?? 0,
            $first['printer_id'] ?? null,
        ]);
        $id = (int) $pdo->lastInsertId();
        if ($first !== null) {
            saveRecipe($id, ['filaments' => $first['filaments'], 'components' => $first['components']]);
        }
        $pdo->commit();
    } catch (PDOException $e) {
        $pdo->rollBack();
        if (isDuplicate($e)) {
            return fail($response, variantNameTakenMessage($name), 409);
        }
        throw $e;
    }
    return json($response, readVariants(variantId: $id)[0], 201);
})->add($requireAdmin)->add($requireAuth);

// PUT /api/variants/{id} → mudar a variante e a receita, tudo ou nada
$app->put('/api/variants/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $found = readVariants(variantId: $id);
    if ($found === []) {
        return fail($response, 'Esta variante já não existe.', 404);
    }
    $body = body($request);
    // o sku não se escreve: sai do nome
    $writable = ['name', 'sale_price', 'print_time_min', 'plate_count', 'weight_g',
        'printer_id', 'model_file', 'etsy_listing_id', 'is_active'];
    $columns = array_values(array_filter($writable, fn ($c) => array_key_exists($c, $body)));
    $values = array_map(fn ($c) => dbValue($body[$c], VARIANT_TYPES[$c]), $columns);

    if (array_key_exists('name', $body)) {
        $name = trim((string) $body['name']);
        $values[array_search('name', $columns, true)] = $name;
        $stmt = db()->prepare('SELECT base_sku FROM products WHERE id = ?');
        $stmt->execute([$found[0]['product_id']]);
        $sku = variantSku((string) $stmt->fetchColumn(), $name);
        if (variantSkuTaken($sku, $id)) {
            return fail($response, variantNameTakenMessage($name), 409);
        }
        $columns[] = 'sku';
        $values[] = $sku;
    }

    // uma transação: ou grava a variante E a receita, ou não grava nada
    db()->beginTransaction();
    try {
        if ($columns !== []) {
            $sets = implode(', ', array_map(fn ($c) => "$c = ?", $columns));
            $values[] = $id;
            db()->prepare("UPDATE variants SET $sets WHERE id = ?")->execute($values);
        }
        saveRecipe($id, $body);
        db()->commit();
    } catch (PDOException $e) {
        db()->rollBack();
        if (isDuplicate($e)) {
            return fail($response, variantNameTakenMessage((string) ($body['name'] ?? '')), 409);
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
