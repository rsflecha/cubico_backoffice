<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Clientes ═══════════════
// Todos com sessão consultam; só o administrador cria e muda.
// Cada cliente traz as moradas dentro dele (tabela addresses).

const CUSTOMER_TYPES = [
    'id' => 'int',
    'name' => 'string',
    'email' => 'string',
    'phone' => 'string',
    'instagram' => 'string',
    'notes' => 'string',
    'created_at' => 'string',
];
const ADDRESS_TYPES = [
    'id' => 'int',
    'line1' => 'string',
    'line2' => 'string',
    'postal_code' => 'string',
    'city' => 'string',
    'country' => 'string',
];

/** Os clientes (todos, ou um), cada um com as suas moradas. */
function readCustomers(?int $id = null): array
{
    $stmt = db()->prepare('SELECT * FROM customers' . ($id === null ? '' : ' WHERE id = ?') . ' ORDER BY name');
    $stmt->execute($id === null ? [] : [$id]);
    $customers = array_map(fn ($row) => typed($row, CUSTOMER_TYPES), $stmt->fetchAll());

    $addresses = db()->query('SELECT * FROM addresses ORDER BY id')->fetchAll();
    $byCustomer = [];
    foreach ($addresses as $a) {
        $byCustomer[(int) $a['customer_id']][] = typed($a, ADDRESS_TYPES);
    }
    foreach ($customers as &$c) {
        $c['addresses'] = $byCustomer[$c['id']] ?? [];
    }
    return $customers;
}

/** Troca as moradas de um cliente pelas que vieram da app. */
function saveAddresses(int $customerId, array $addresses): void
{
    db()->prepare('DELETE FROM addresses WHERE customer_id = ?')->execute([$customerId]);
    $insert = db()->prepare(
        'INSERT INTO addresses (customer_id, line1, line2, postal_code, city, country) VALUES (?, ?, ?, ?, ?, ?)'
    );
    foreach ($addresses as $a) {
        if (trim((string) ($a['line1'] ?? '')) === '') {
            continue;
        }
        $insert->execute([
            $customerId,
            trim((string) $a['line1']),
            ($a['line2'] ?? null) === null ? null : trim((string) $a['line2']),
            trim((string) ($a['postal_code'] ?? '')),
            trim((string) ($a['city'] ?? '')),
            (string) ($a['country'] ?? 'PT'),
        ]);
    }
}

/** Os campos do cliente que vieram da app, prontos para gravar (texto vazio → NULL). */
function customerValues(array $body): array
{
    $text = fn (string $key) => ($v = trim((string) ($body[$key] ?? ''))) === '' ? null : $v;
    return [$text('name'), $text('email'), $text('phone'), $text('instagram'), $text('notes')];
}

// GET /api/customers → a lista, com as moradas
$app->get('/api/customers', function (Request $request, Response $response) {
    return json($response, readCustomers());
})->add($requireAuth);

// POST /api/customers → criar (com as moradas, tudo ou nada)
$app->post('/api/customers', function (Request $request, Response $response) {
    $body = body($request);
    if (trim((string) ($body['name'] ?? '')) === '') {
        return fail($response, 'O nome é obrigatório.', 422);
    }
    db()->beginTransaction();
    try {
        db()->prepare('INSERT INTO customers (name, email, phone, instagram, notes) VALUES (?, ?, ?, ?, ?)')
            ->execute(customerValues($body));
        $id = (int) db()->lastInsertId();
        saveAddresses($id, (array) ($body['addresses'] ?? []));
        db()->commit();
    } catch (Throwable $e) {
        db()->rollBack();
        throw $e;
    }
    return json($response, readCustomers($id)[0], 201);
})->add($requireAdmin)->add($requireAuth);

// PUT /api/customers/{id} → mudar (com as moradas, tudo ou nada)
$app->put('/api/customers/{id}', function (Request $request, Response $response, array $args) {
    $id = (int) $args['id'];
    if (readCustomers($id) === []) {
        return fail($response, 'Este cliente já não existe.', 404);
    }
    $body = body($request);
    if (trim((string) ($body['name'] ?? '')) === '') {
        return fail($response, 'O nome é obrigatório.', 422);
    }
    db()->beginTransaction();
    try {
        db()->prepare('UPDATE customers SET name = ?, email = ?, phone = ?, instagram = ?, notes = ? WHERE id = ?')
            ->execute([...customerValues($body), $id]);
        if (array_key_exists('addresses', $body)) {
            saveAddresses($id, (array) $body['addresses']);
        }
        db()->commit();
    } catch (Throwable $e) {
        db()->rollBack();
        throw $e;
    }
    return json($response, readCustomers($id)[0]);
})->add($requireAdmin)->add($requireAuth);
