<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/** Uma linha da tabela categories, no formato que a app espera. */
function categoryJson(array $row): array
{
    return [
        'id' => (int) $row['id'],
        'name' => $row['name'],
        'color' => $row['color'],
        'sort_order' => (int) $row['sort_order'],
    ];
}

/** Uma categoria pelo id, ou null se não existir. */
function findCategory(int $id): ?array
{
    $stmt = db()->prepare('SELECT * FROM categories WHERE id = ?');
    $stmt->execute([$id]);
    return $stmt->fetch() ?: null;
}

// GET /api/categories → a lista (todos com sessão)
$app->get('/api/categories', function (Request $request, Response $response) {
    $rows = db()->query('SELECT * FROM categories ORDER BY sort_order, name')->fetchAll();
    return json($response, array_map('categoryJson', $rows));
})->add($requireAuth);

// POST /api/categories → criar (só o administrador)
$app->post('/api/categories', function (Request $request, Response $response) {
    $body = body($request);
    $name = trim((string) ($body['name'] ?? ''));
    if ($name === '') {
        return fail($response, 'O nome é obrigatório.', 422);
    }
    $color = (string) ($body['color'] ?? '#A1A1AA');
    // sem ordem escolhida: fica no fim da lista
    $sortOrder = isset($body['sort_order']) && (int) $body['sort_order'] > 0
        ? (int) $body['sort_order']
        : (int) db()->query('SELECT COALESCE(MAX(sort_order), 0) + 1 FROM categories')->fetchColumn();

    try {
        db()->prepare('INSERT INTO categories (name, color, sort_order) VALUES (?, ?, ?)')
            ->execute([$name, $color, $sortOrder]);
    } catch (PDOException $e) {
        if (isDuplicate($e)) {
            return fail($response, 'Já existe uma categoria com esse nome.', 409);
        }
        throw $e;
    }
    return json($response, categoryJson(findCategory((int) db()->lastInsertId())), 201);
})->add($requireAdmin)->add($requireAuth);

// PUT /api/categories/{id} → mudar (só o administrador)
$app->put('/api/categories/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $current = findCategory($id);
    if ($current === null) {
        return fail($response, 'Esta categoria já não existe.', 404);
    }
    $body = body($request);
    $name = trim((string) ($body['name'] ?? $current['name']));
    if ($name === '') {
        return fail($response, 'O nome é obrigatório.', 422);
    }

    try {
        db()->prepare('UPDATE categories SET name = ?, color = ?, sort_order = ? WHERE id = ?')
            ->execute([
                $name,
                (string) ($body['color'] ?? $current['color']),
                (int) ($body['sort_order'] ?? $current['sort_order']),
                $id,
            ]);
    } catch (PDOException $e) {
        if (isDuplicate($e)) {
            return fail($response, 'Já existe uma categoria com esse nome.', 409);
        }
        throw $e;
    }
    return json($response, categoryJson(findCategory($id)));
})->add($requireAdmin)->add($requireAuth);

// DELETE /api/categories/{id} → apagar (só o administrador, e só sem produtos)
$app->delete('/api/categories/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    $category = findCategory($id);
    if ($category === null) {
        return fail($response, 'Esta categoria já não existe.', 404);
    }

    $stmt = db()->prepare('SELECT COUNT(*) FROM products WHERE category_id = ?');
    $stmt->execute([$id]);
    $count = (int) $stmt->fetchColumn();
    if ($count > 0) {
        return fail(
            $response,
            "\"{$category['name']}\" tem $count produto(s). Muda-os de categoria antes de a apagar.",
            409,
        );
    }

    db()->prepare('DELETE FROM categories WHERE id = ?')->execute([$id]);
    return $response->withStatus(204); // 204 = feito, sem nada para devolver
})->add($requireAdmin)->add($requireAuth);
