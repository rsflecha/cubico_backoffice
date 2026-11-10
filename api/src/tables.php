<?php
declare(strict_types=1);

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\App;

/**
 * Cria os pedidos habituais de uma tabela simples, só para o administrador:
 *   GET    {path}        → a lista
 *   POST   {path}        → criar           (se $canCreate)
 *   PUT    {path}/{id}   → mudar uma linha
 *
 * Muitas tabelas são iguais (filamentos, componentes, impressoras, portes…):
 * em vez de escrever os mesmos pedidos seis vezes, escrevem-se uma vez, aqui.
 *
 * Os nomes da tabela e das colunas vêm do NOSSO código, nunca da app,
 * por isso podem ir diretamente no SQL. Os VALORES vão sempre por "?".
 *
 * @param array $types    as colunas e os tipos: ['id' => 'int', 'name' => 'string', …]
 * @param array $required as colunas obrigatórias ao criar
 */
function tableRoutes(
    App $app,
    string $path,
    string $table,
    array $types,
    array $required,
    bool $canCreate,
    string $orderBy,
    callable $requireAuth,
    callable $requireAdmin,
): void {
    // as colunas que a app pode mudar: todas menos o id
    $writable = array_values(array_filter(array_keys($types), fn ($c) => $c !== 'id'));

    $find = function (int $id) use ($table): ?array {
        $stmt = db()->prepare("SELECT * FROM $table WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    };

    // GET → a lista
    $app->get($path, function (Request $request, Response $response) use ($table, $types, $orderBy) {
        $rows = db()->query("SELECT * FROM $table ORDER BY $orderBy")->fetchAll();
        return json($response, array_map(fn ($row) => typed($row, $types), $rows));
    })->add($requireAdmin)->add($requireAuth);

    // POST → criar
    if ($canCreate) {
        $app->post($path, function (Request $request, Response $response) use ($table, $types, $writable, $required, $find) {
            $body = body($request);
            foreach ($required as $column) {
                if (!isset($body[$column]) || trim((string) $body[$column]) === '') {
                    return fail($response, "Falta preencher: $column.", 422);
                }
            }
            // só as colunas que vieram no pedido (as outras ficam com o valor por omissão da tabela)
            $columns = array_values(array_filter($writable, fn ($c) => array_key_exists($c, $body)));
            $values = array_map(fn ($c) => dbValue($body[$c], $types[$c]), $columns);
            $marks = implode(', ', array_fill(0, count($columns), '?'));

            try {
                db()->prepare("INSERT INTO $table (" . implode(', ', $columns) . ") VALUES ($marks)")
                    ->execute($values);
            } catch (PDOException $e) {
                if (isDuplicate($e)) {
                    return fail($response, 'Já existe um registo igual.', 409);
                }
                throw $e;
            }
            return json($response, typed($find((int) db()->lastInsertId()), $types), 201);
        })->add($requireAdmin)->add($requireAuth);
    }

    // PUT {id} → mudar
    $app->put("$path/{id}", function (Request $request, Response $response, array $args) use ($table, $types, $writable, $find) {
        $id = (int) $args['id'];
        if ($find($id) === null) {
            return fail($response, 'Este registo já não existe.', 404);
        }
        $body = body($request);
        $columns = array_values(array_filter($writable, fn ($c) => array_key_exists($c, $body)));
        if ($columns === []) {
            return fail($response, 'Não há nada para mudar.', 422);
        }
        $sets = implode(', ', array_map(fn ($c) => "$c = ?", $columns));
        $values = array_map(fn ($c) => dbValue($body[$c], $types[$c]), $columns);
        $values[] = $id;

        try {
            db()->prepare("UPDATE $table SET $sets WHERE id = ?")->execute($values);
        } catch (PDOException $e) {
            if (isDuplicate($e)) {
                return fail($response, 'Já existe um registo igual.', 409);
            }
            throw $e;
        }
        return json($response, typed($find($id), $types));
    })->add($requireAdmin)->add($requireAuth);
}
