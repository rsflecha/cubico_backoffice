<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// ═══════════════ Produção ═══════════════
// O quadro das tarefas de impressão. Todos com sessão veem e mudam (é trabalho operacional).

const JOB_TYPES = [
    'id' => 'int',
    'order_line_id' => 'int',
    'order_id' => 'int',
    'order_number' => 'int',
    'variant_id' => 'int',
    'quantity' => 'int',
    'status' => 'string',
    'estimated_min' => 'int',
    'started_at' => 'string',
    'finished_at' => 'string',
    'notes' => 'string',
];

/** As tarefas (todas, ou uma), com o número da encomenda a que pertencem. */
function readJobs(?int $id = null): array
{
    // a tabela print_jobs só sabe a linha da encomenda; o JOIN vai buscar a encomenda e o número
    $sql = 'SELECT pj.*, ol.order_id, o.order_number
            FROM print_jobs pj
            LEFT JOIN order_lines ol ON ol.id = pj.order_line_id
            LEFT JOIN orders o ON o.id = ol.order_id'
        . ($id === null ? '' : ' WHERE pj.id = ?')
        . ' ORDER BY pj.board_position, pj.id';
    $stmt = db()->prepare($sql);
    $stmt->execute($id === null ? [] : [$id]);
    return array_map(fn ($row) => typed($row, JOB_TYPES), $stmt->fetchAll());
}

/** "2026-11-10T18:30:00.000" (da app) → "2026-11-10 18:30:00" (para uma coluna DATETIME). */
function toDateTime(mixed $value): ?string
{
    return $value ? date('Y-m-d H:i:s', strtotime((string) $value)) : null;
}

$statuses = ['queued', 'printing', 'post_processing', 'done'];

// GET /api/print-jobs → o quadro
$app->get('/api/print-jobs', function (Request $request, Response $response) {
    return json($response, readJobs());
})->add($requireAuth);

// POST /api/print-jobs → uma tarefa nova (ao enviar para produção, ou manual)
$app->post('/api/print-jobs', function (Request $request, Response $response) use ($statuses) {
    $body = body($request);
    if ((int) ($body['variant_id'] ?? 0) === 0) {
        return fail($response, 'Falta a variante.', 422);
    }
    db()->prepare(
        'INSERT INTO print_jobs (order_line_id, variant_id, quantity, status, estimated_min, notes) VALUES (?, ?, ?, ?, ?, ?)'
    )->execute([
        isset($body['order_line_id']) ? (int) $body['order_line_id'] : null,
        (int) $body['variant_id'],
        max(1, (int) ($body['quantity'] ?? 1)),
        in_array($body['status'] ?? '', $statuses, true) ? $body['status'] : 'queued',
        (int) ($body['estimated_min'] ?? 0),
        $body['notes'] ?? null,
    ]);
    return json($response, readJobs((int) db()->lastInsertId())[0], 201);
})->add($requireAuth);

// PUT /api/print-jobs/{id} → mudar de coluna, as horas e as notas
$app->put('/api/print-jobs/{id}', function (Request $request, Response $response, array $args) use ($statuses) {
    $id = (int) $args['id'];
    if (readJobs($id) === []) {
        return fail($response, 'Esta tarefa já não existe.', 404);
    }
    $body = body($request);
    if (isset($body['status']) && !in_array($body['status'], $statuses, true)) {
        return fail($response, 'Coluna inválida.', 422);
    }
    db()->prepare(
        'UPDATE print_jobs SET status = ?, started_at = ?, finished_at = ?, notes = ? WHERE id = ?'
    )->execute([
        $body['status'] ?? 'queued',
        toDateTime($body['started_at'] ?? null),
        toDateTime($body['finished_at'] ?? null),
        $body['notes'] ?? null,
        $id,
    ]);
    return json($response, readJobs($id)[0]);
})->add($requireAuth);
