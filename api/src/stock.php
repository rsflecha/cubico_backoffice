<?php
declare(strict_types=1);

// Stock de filamento: o stock de um filamento é a SOMA dos seus movimentos (tabela
// filament_movements, migração 015). Os movimentos nunca se editam nem se apagam: um engano
// corrige-se com um movimento novo. Aqui vivem as contas e as gravações; as rotas só as chamam.

/** Executa $fn dentro de uma transação; se já houver uma aberta, junta-se a ela (quem a abriu fecha-a). */
function stockInTransaction(callable $fn): mixed
{
    $pdo = db();
    if ($pdo->inTransaction()) {
        return $fn($pdo);
    }
    $pdo->beginTransaction();
    try {
        $result = $fn($pdo);
        $pdo->commit();
        return $result;
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $e;
    }
}

/** Stock atual de um filamento, em gramas: a soma dos movimentos (0 se não houver nenhum). */
function filamentStock(int $filamentId): float
{
    $st = db()->prepare('SELECT COALESCE(SUM(grams), 0) FROM filament_movements WHERE filament_id = ?');
    $st->execute([$filamentId]);
    return round((float) $st->fetchColumn(), 2);
}

/**
 * O stock de todos os filamentos ativos, na ordem da lista de filamentos.
 * Cada linha: filament_id, stock_g, spools (stock ÷ peso do rolo, 1 casa) e min_stock_g.
 */
function filamentStocks(): array
{
    $rows = db()->query(
        'SELECT f.id, f.spool_weight_g, f.min_stock_g, COALESCE(SUM(m.grams), 0) AS stock_g
           FROM filaments f
           LEFT JOIN filament_movements m ON m.filament_id = f.id
          WHERE f.is_active = 1
          GROUP BY f.id, f.spool_weight_g, f.min_stock_g, f.material, f.color_name
          ORDER BY f.material, f.color_name'
    )->fetchAll();

    $out = [];
    foreach ($rows as $r) {
        $stock = round((float) $r['stock_g'], 2);
        $weight = (int) $r['spool_weight_g'];
        $out[] = [
            'filament_id' => (int) $r['id'],
            'stock_g' => $stock,
            'spools' => $weight > 0 ? round($stock / $weight, 1) : 0.0,
            'min_stock_g' => (int) $r['min_stock_g'],
        ];
    }
    return $out;
}

/**
 * A conta do acerto por pesagem: rolos fechados × peso do rolo + Σ (peso na balança − tara).
 * A balança pesa o filamento COM o carretel, por isso cada rolo aberto perde a tara.
 * Recusa o que é engano (InvalidArgumentException, mensagem em português).
 *
 * @param float[]|int[] $openGrossG peso na balança de cada rolo aberto
 */
function weighedTotal(int $closedSpools, int $spoolWeightG, array $openGrossG, int $emptySpoolG): float
{
    if ($closedSpools < 0) {
        throw new InvalidArgumentException('Os rolos fechados não podem ser negativos.');
    }
    $total = (float) ($closedSpools * $spoolWeightG);

    foreach ($openGrossG as $gross) {
        $gross = cleanGrams($gross);
        if ($gross <= 0) {
            throw new InvalidArgumentException('O peso de cada rolo aberto tem de ser maior que zero.');
        }
        if ($emptySpoolG <= 0) {
            throw new InvalidArgumentException(
                'Falta o peso do carretel vazio deste filamento, em Custos e preços.'
            );
        }
        if ($gross < $emptySpoolG) {
            throw new InvalidArgumentException(
                'Um rolo aberto não pode pesar menos do que o carretel vazio (' . $emptySpoolG . ' g).'
            );
        }
        $total += $gross - $emptySpoolG;
    }
    return round($total, 2);
}

/**
 * Compra de rolos: grava +rolos × peso do rolo e passa o preço da última compra para o filamento
 * (paid_price, shipping_cost, spools_in_order). Devolve o id do movimento.
 */
function recordPurchase(int $filamentId, int $spools, float $paidPrice, float $shippingCost, ?int $userId): int
{
    if ($spools < 1 || $spools > 255) {
        // 255 é o máximo de filaments.spools_in_order (TINYINT UNSIGNED).
        throw new InvalidArgumentException('O número de rolos tem de estar entre 1 e 255.');
    }
    if ($paidPrice < 0 || $shippingCost < 0) {
        throw new InvalidArgumentException('O preço e os portes não podem ser negativos.');
    }

    return stockInTransaction(function (PDO $pdo) use ($filamentId, $spools, $paidPrice, $shippingCost, $userId): int {
        $st = $pdo->prepare('SELECT spool_weight_g FROM filaments WHERE id = ? FOR UPDATE');
        $st->execute([$filamentId]);
        $weight = $st->fetchColumn();
        if ($weight === false) {
            throw new InvalidArgumentException('Esse filamento não existe.');
        }

        $pdo->prepare(
            "INSERT INTO filament_movements
               (filament_id, movement_type, grams, spools, paid_price, shipping_cost, user_id)
             VALUES (?, 'purchase', ?, ?, ?, ?, ?)"
        )->execute([
            $filamentId,
            round($spools * (int) $weight, 2),
            $spools,
            round($paidPrice, 2),
            round($shippingCost, 2),
            $userId,
        ]);
        $id = (int) $pdo->lastInsertId();

        // O preço da última compra passa a ser o do filamento (a calculadora de custo usa estes campos).
        $pdo->prepare('UPDATE filaments SET paid_price = ?, shipping_cost = ?, spools_in_order = ? WHERE id = ?')
            ->execute([round($paidPrice, 2), round($shippingCost, 2), $spools, $filamentId]);

        return $id;
    });
}

/** Mostra gramas sem zeros a mais: 712.0 vira "712", 712.5 vira "712.5". */
function stockGramsText(float $g): string
{
    return rtrim(rtrim(number_format($g, 2, '.', ''), '0'), '.');
}

/**
 * Acerto por pesagem: o stock passa a ser o total pesado. Grava a diferença (real − stock), que pode
 * ser negativa ou zero (um acerto igual também fica registado). Devolve o id do movimento.
 *
 * @param float[]|int[] $openGrossG peso na balança de cada rolo aberto
 */
function recordAdjustment(int $filamentId, int $closedSpools, array $openGrossG, ?string $note, ?int $userId): int
{
    return stockInTransaction(function (PDO $pdo) use ($filamentId, $closedSpools, $openGrossG, $note, $userId): int {
        // Bloqueia a linha do filamento: duas pesagens ao mesmo tempo não se pisam.
        $st = $pdo->prepare('SELECT spool_weight_g, empty_spool_g FROM filaments WHERE id = ? FOR UPDATE');
        $st->execute([$filamentId]);
        $f = $st->fetch();
        if ($f === false) {
            throw new InvalidArgumentException('Esse filamento não existe.');
        }
        $weight = (int) $f['spool_weight_g'];
        $tare = (int) $f['empty_spool_g'];

        $real = weighedTotal($closedSpools, $weight, $openGrossG, $tare);
        $diff = round($real - filamentStock($filamentId), 2);

        // Nota automática: o que foi pesado; a nota do Rui vem depois.
        $parts = [$closedSpools . ' fechados'];
        foreach ($openGrossG as $gross) {
            $parts[] = stockGramsText(cleanGrams($gross)) . ' g na balança − ' . $tare . ' g';
        }
        $text = implode(' + ', $parts);
        $extra = trim((string) $note);
        if ($extra !== '') {
            $text .= ' · ' . $extra;
        }
        // A coluna tem 255 caracteres.
        $text = preg_replace('/^(.{0,255}).*$/su', '$1', $text) ?? $text;

        $pdo->prepare(
            "INSERT INTO filament_movements (filament_id, movement_type, grams, note, user_id)
             VALUES (?, 'adjustment', ?, ?, ?)"
        )->execute([$filamentId, $diff, $text, $userId]);

        return (int) $pdo->lastInsertId();
    });
}

/**
 * Os movimentos de um filamento, o mais recente primeiro. Sem $withPrices, as compras não trazem
 * paid_price nem shipping_cost (o colaborador não vê o que a loja pagou).
 * Com $onlyMovementId devolve só esse movimento (ou lista vazia se não for deste filamento).
 */
function filamentMovements(int $filamentId, bool $withPrices, ?int $onlyMovementId = null): array
{
    $st = db()->prepare(
        'SELECT m.id, m.filament_id, m.movement_type, m.grams, m.spools, m.paid_price, m.shipping_cost,
                m.print_job_id, m.print_failure_id, m.reverses_id, m.note, m.user_id, m.created_at,
                u.name AS user_name
           FROM filament_movements m
           LEFT JOIN users u ON u.id = m.user_id
          WHERE m.filament_id = ? AND (? IS NULL OR m.id = ?)
          ORDER BY m.created_at DESC, m.id DESC'
    );
    $st->execute([$filamentId, $onlyMovementId, $onlyMovementId]);

    $out = [];
    foreach ($st->fetchAll() as $r) {
        $row = [
            'id' => (int) $r['id'],
            'filament_id' => (int) $r['filament_id'],
            'movement_type' => $r['movement_type'],
            'grams' => (float) $r['grams'],
            'spools' => $r['spools'] === null ? null : (int) $r['spools'],
            'print_job_id' => $r['print_job_id'] === null ? null : (int) $r['print_job_id'],
            'print_failure_id' => $r['print_failure_id'] === null ? null : (int) $r['print_failure_id'],
            'reverses_id' => $r['reverses_id'] === null ? null : (int) $r['reverses_id'],
            'note' => $r['note'],
            'user_id' => $r['user_id'] === null ? null : (int) $r['user_id'],
            'user_name' => $r['user_name'],
            'created_at' => $r['created_at'],
        ];
        if ($withPrices) {
            $row['paid_price'] = $r['paid_price'] === null ? null : (float) $r['paid_price'];
            $row['shipping_cost'] = $r['shipping_cost'] === null ? null : (float) $r['shipping_cost'];
        }
        $out[] = $row;
    }
    return $out;
}
