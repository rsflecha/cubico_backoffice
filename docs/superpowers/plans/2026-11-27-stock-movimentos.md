# Stock de filamento, passo 2 — movimentos, compras, acertos e ecrã Stock — plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** a app sabe quanto filamento há de cada cor, em gramas e em rolos, com o histórico de cada número; o Rui regista compras e acerta o stock pesando os rolos com o carretel.

**Architecture:** Migração 015 cria o livro `filament_movements` (nunca se edita nem se apaga; stock = soma) e a tara `filaments.empty_spool_g`, e tira as tabelas `spools`/`stock_movements` nunca usadas. As contas ficam na API, num `api/src/stock.php` novo, servido por `api/routes/stock.php`. Na app, uma funcionalidade nova `features/stock` (Demo… e Api…, como as outras) com dois ecrãs: a lista e o histórico de um filamento.

**Tech Stack:** MariaDB 10.6 · PHP 8.3 + Slim 4 · Flutter 3.47 + Riverpod 3 + GoRouter 18 + Freezed (`dart run build_runner build`).

**Spec:** `docs/superpowers/specs/2026-11-26-stock-filamento-design.md` — secções 5.2, 5.3 (Compra e Acerto, com a alteração da tara de 2026-11-27), 5.5, 5.6 e o passo 2 da secção 6. O consumo, as falhas e o stock no cartão da tarefa da Produção (passo 3), o aviso e o cartão do Dashboard (passo 4) e os dados de demonstração completos (passo 5) **não** entram aqui.

## Global Constraints

- Movimentos **nunca se editam nem se apagam**: não há `PUT` nem `DELETE` em `filament_movements`.
- `movement_type` ∈ `purchase`, `consumption`, `failure`, `adjustment`, `reversal`; `grams DECIMAL(10,2)`, positivo entra, negativo sai. Neste passo só se gravam `purchase` e `adjustment`.
- Stock = `SUM(grams)`; rolos = stock ÷ `spool_weight_g`, com **uma** casa decimal.
- Compra grava `+spools × spool_weight_g` e atualiza `filaments.paid_price`, `shipping_cost`, `spools_in_order = spools` (o preço da última compra passa a ser o do filamento).
- Acerto: total real = `fechados × spool_weight_g + Σ (peso na balança − empty_spool_g)`; grava `real − stock atual`, **mesmo que seja 0**. Rolo aberto mais leve do que a tara → recusado. Tara `0` com rolos abertos → recusado ("Falta o peso do carretel vazio deste filamento, em Custos e preços.").
- Compra e acerto só para o administrador (403 para o colaborador). O colaborador vê stock e histórico, mas **nunca** `paid_price` nem `shipping_cost` (esconder na API, não só no ecrã).
- Interface em PT-PT, vírgula decimal; código em inglês, aspas duplas, `package:material_ui/material_ui.dart`, imports `package:cubico_backoffice/...`. Gramas com `gramsText()`/`gramsField()`/`roundGrams()` de `core/formatting.dart`; dinheiro com `euro()`.
- Valores do utilizador sempre por `?`. Gravar em várias tabelas = transação.
- Migração nova numerada e `schema.sql` atualizado. **No servidor só com aprovação do Rui e com cópia da base antes.**
- Modo demo continua a funcionar sem servidor. Antes de cada commit: `flutter analyze` limpo e `flutter test` a passar.

## Review Focus

1. **Peso na balança menor do que a tara** (o Rui pesa um carretel quase vazio e escreve 240 g com tara 250 g): recusado com mensagem, nada gravado → testes no Task 1 (API) e no Task 3 (app).
2. **Tara por preencher (0) e um rolo aberto**: recusado, a dizer onde se preenche; só rolos fechados passa → testes no Task 1 e no Task 3.
3. **Colaborador**: o histórico chega sem preços e a compra dá 403; no ecrã não há botões nem preços → teste HTTP no Task 2 e de widget no Task 5.
4. **Duplo toque em Gravar** na compra ou no acerto: um só movimento (botão desligado enquanto grava) → teste de widget no Task 5.
5. **Filamento com rolos de 750 g**: os fechados contam 750 g, não 1000 → testes no Task 1 e no Task 3.

---

### Task 1: Migração 015 e as contas do stock na API

**Files:**
- Create: `database/migrations/015-stock-filamento.sql`
- Modify: `database/schema.sql` (tabela `filaments`: `empty_spool_g`; secção "Stock": sai `spools`/`stock_movements`, entra `filament_movements`)
- Create: `api/src/stock.php`
- Modify: `api/public/index.php` (`require` de `src/stock.php`, ao lado dos outros `src/`)
- Create: `api/tests/stock-check.php`

**Interfaces:**
- Produces (PHP, em `api/src/stock.php`):
  - `filamentStock(int $filamentId): float` — `SUM(grams)`, 0 se não houver movimentos.
  - `filamentStocks(): array` — para cada filamento ativo: `['filament_id' => int, 'stock_g' => float, 'spools' => float (1 casa), 'min_stock_g' => int]`.
  - `weighedTotal(int $closedSpools, int $spoolWeightG, array $openGrossG, int $emptySpoolG): float` — a conta do acerto; lança `InvalidArgumentException` com a mensagem em PT-PT nos casos recusados.
  - `recordPurchase(int $filamentId, int $spools, float $paidPrice, float $shippingCost, ?int $userId): int` — devolve o id do movimento; numa transação grava o movimento e atualiza o filamento.
  - `recordAdjustment(int $filamentId, int $closedSpools, array $openGrossG, ?string $note, ?int $userId): int` — numa transação, com `SELECT … FOR UPDATE` na linha do filamento; grava `real − stock`, com a nota automática.
  - `filamentMovements(int $filamentId, bool $withPrices): array` — mais recente primeiro; `user_name` pelo `LEFT JOIN users`; sem `paid_price`/`shipping_cost` quando `$withPrices` é falso.

- [ ] **Step 1: Escrever a migração 015**

Cabeçalho no estilo das anteriores. Por esta ordem: `ALTER TABLE filaments ADD COLUMN empty_spool_g SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER spool_weight_g`; `CREATE TABLE filament_movements` exatamente como na secção 5.2 do desenho; `DROP TABLE stock_movements`; `DROP TABLE spools` (o `DROP` da que tem a chave estrangeira primeiro). Comentário: "Antes de correr no servidor: confirmar que `spools` e `stock_movements` estão vazias." Mesmas definições no `schema.sql`.

- [ ] **Step 2: Aplicar na base do PC**

Antes: `SELECT COUNT(*) FROM spools; SELECT COUNT(*) FROM stock_movements;` → `0` e `0`. Correr a 015.
Expected: `SHOW COLUMNS FROM filaments LIKE 'empty_spool_g'` → `smallint(5) unsigned`, default `0`; `SHOW TABLES LIKE 'spools'` vazio; `DESCRIBE filament_movements` com as 13 colunas.

- [ ] **Step 3: Escrever o teste que falha, `api/tests/stock-check.php`**

Script PHP como os anteriores (carrega `vendor/autoload.php`, o Dotenv sem mostrar o `.env`, `src/db.php`, `src/helpers.php`, `src/stock.php`), corre tudo dentro de `db()->beginTransaction()` e acaba **sempre** em `rollBack()`. Imprime `PASS`/`FAIL` por caso e sai com o número de falhas. Num filamento escolhido pelo script (`spool_weight_g` forçado a 1000 e `empty_spool_g` a 250 dentro da transação):
- sem movimentos: `filamentStock` = `0.0`;
- `recordPurchase(f, 2, 15.00, 4.90, null)` → stock `2000.0`; filamento com `paid_price 15.00`, `shipping_cost 4.90`, `spools_in_order 2`;
- `weighedTotal(2, 1000, [712], 250)` = `2462.0`; `weighedTotal(0, 750, [], 250)` = `0.0`; `weighedTotal(3, 750, [], 0)` = `2250.0`;
- `weighedTotal(0, 1000, [240], 250)` lança, mensagem contém `carretel`; `weighedTotal(0, 1000, [500], 0)` lança, mensagem contém `Custos e preços`;
- `recordAdjustment(f, 2, [712], "pesado", null)` depois da compra → movimento de `+462.00`, stock `2462.0`, nota contém `712 g` e `pesado`;
- outro `recordAdjustment` com os mesmos valores → movimento de `0.00` gravado, stock igual;
- `filamentMovements(f, false)` não tem as chaves `paid_price` nem `shipping_cost`; `filamentMovements(f, true)` tem; o primeiro é o mais recente;
- `filamentStocks()` traz o filamento com `spools` = `2.5` para `2462` g (uma casa).

- [ ] **Step 4: Correr e ver falhar**

Run: `php api/tests/stock-check.php`
Expected: erro fatal por `src/stock.php` não existir (ou funções por definir).

- [ ] **Step 5: Implementar `api/src/stock.php`** com as assinaturas do bloco Interfaces. `weighedTotal` valida `closedSpools ≥ 0` e cada peso `> 0`. A nota automática: `"{n} fechados"` e, por rolo aberto, `"{peso} g na balança − {tara} g"`, juntos por `" + "`, e a nota do Rui depois de `" · "`. Os pesos lidos da balança passam por `cleanGrams()`; o movimento grava-se com `round($diff, 2)` (pode ser negativo, por isso não leva `cleanGrams()`).

- [ ] **Step 6: Correr e ver passar**

Run: `php api/tests/stock-check.php`
Expected: só `PASS`, sai com 0. A base do PC fica igual (rollback): `SELECT COUNT(*) FROM filament_movements` = 0.

- [ ] **Step 7: Commit**

```bash
git add database/migrations/015-stock-filamento.sql database/schema.sql api/src/stock.php api/public/index.php api/tests/stock-check.php
git commit -m "Stock: migração 015, livro de movimentos e as contas na API"
```

### Task 2: Rotas da API e a tara nos filamentos

**Files:**
- Create: `api/routes/stock.php`
- Modify: `api/public/index.php` (`require` de `routes/stock.php`)
- Modify: `api/routes/costs.php:13-28` (`'empty_spool_g' => 'int'` nos tipos dos filamentos; não vai para `hiddenFromStaff`)
- Create: `api/tests/stock-http-check.php`

**Interfaces:**
- Consumes: as funções do Task 1.
- Produces (HTTP):
  - `GET /api/filaments/stock` (com sessão) → `[{filament_id, stock_g, spools, min_stock_g}]`.
  - `GET /api/filaments/{id}/movements` (com sessão) → `[{id, movement_type, grams, spools, paid_price?, shipping_cost?, note, user_name, print_job_id, created_at}]`; sem preços para o colaborador; 404 se o filamento não existir.
  - `POST /api/filaments/{id}/purchases` (admin) `{spools, paid_price, shipping_cost}` → 201 com o movimento; 422 se `spools < 1` ou preço `< 0`.
  - `POST /api/filaments/{id}/adjustments` (admin) `{closed_spools, open_gross_g: [number], note?}` → 201 com o movimento; 422 com a mensagem do `InvalidArgumentException`.
  - `GET/PUT /api/filaments` passam a trazer e aceitar `empty_spool_g`.
  - Registar `/api/filaments/stock` **antes** de qualquer rota `/api/filaments/{id}` que o pudesse apanhar.

- [ ] **Step 1: Escrever o teste HTTP que falha, `api/tests/stock-http-check.php`**

Como o `check-http.php` das gramas: tokens com `makeToken()` para um admin e para um colaborador. O colaborador é um utilizador `stock-check@local.test` criado pelo script e apagado no `finally` (não pode ser dentro de uma transação: a API corre noutro processo e não a veria). Os movimentos que o script cria apagam-se no `finally` com `DELETE … WHERE id IN (…)` (só a limpeza do teste; a API não tem `DELETE`). Casos:
- admin `POST …/purchases {spools: 1, paid_price: 15, shipping_cost: 0}` → 201;
- colaborador o mesmo → 403; colaborador `POST …/adjustments` → 403;
- colaborador `GET …/movements` → 200 e o JSON não contém `paid_price`; admin → contém;
- admin `POST …/adjustments {closed_spools: 0, open_gross_g: [240]}` com tara 250 → 422 e mensagem com `carretel`;
- `GET /api/filaments/stock` → 200, traz o filamento; `GET /api/filaments` traz `empty_spool_g`.

- [ ] **Step 2: Correr e ver falhar**

Run: arrancar `php -S localhost:8080 -t public` em `api/`; `php api/tests/stock-http-check.php`
Expected: `FAIL` (404 nas rotas novas).

- [ ] **Step 3: Implementar `api/routes/stock.php`** com o padrão das outras rotas: `$requireAuth` nas leituras, `->add($requireAdmin)->add($requireAuth)` na compra e no acerto; `userId` do pedido para `user_id`; mensagens com `fail()`; respostas com `typed()`.

- [ ] **Step 4: Correr e ver passar**

Run: `php api/tests/stock-http-check.php`
Expected: só `PASS`; no fim, `filament_movements` sem as linhas do teste e o utilizador de teste apagado.

- [ ] **Step 5: Commit**

```bash
git add api/routes/stock.php api/public/index.php api/routes/costs.php api/tests/stock-http-check.php
git commit -m "Stock: rotas da API (stock, histórico, compras, acertos) e a tara nos filamentos"
```

### Task 3: Domínio e repositórios da app

**Files:**
- Modify: `app/lib/features/costs/domain/filament.dart` (`@Default(0) int emptySpoolG`) e regenerar
- Modify: `app/lib/features/costs/data/demo_filament_repository.dart` (o filamento 1 do demo com `emptySpoolG: 250`; os outros a 0, para o demo mostrar os dois casos)
- Create: `app/lib/features/stock/domain/filament_stock.dart`, `filament_movement.dart` (Freezed, JSON em snake_case como os outros modelos), `stock_repository.dart`, `weighing.dart`
- Create: `app/lib/features/stock/data/api_stock_repository.dart`, `demo_stock_repository.dart`
- Create: `app/lib/features/stock/presentation/stock_providers.dart`
- Test: `app/test/features/stock/weighing_test.dart`, `app/test/features/stock/demo_stock_repository_test.dart`

**Interfaces:**
- Produces (Dart):
  - `FilamentStock({required int filamentId, required double stockG, required double spools, required int minStockG})`.
  - `enum MovementType { purchase, consumption, failure, adjustment, reversal }` e `FilamentMovement({required int id, required MovementType type, required double grams, int? spools, double? paidPrice, double? shippingCost, String? note, String? userName, int? printJobId, required DateTime createdAt})`, com `@JsonKey(name: "movement_type")`.
  - `abstract interface class StockRepository { Future<List<FilamentStock>> fetchStock(); Future<List<FilamentMovement>> fetchMovements(int filamentId); Future<FilamentMovement> recordPurchase(int filamentId, {required int spools, required double paidPrice, required double shippingCost}); Future<FilamentMovement> recordAdjustment(int filamentId, {required int closedSpools, required List<double> openGrossG, String? note}); }`
  - Em `weighing.dart`: `double weighedTotal({required int closedSpools, required int spoolWeightG, required List<double> openGrossG, required int emptySpoolG})` e `String? weighingProblem({required int closedSpools, required List<double> openGrossG, required int emptySpoolG})` — as mesmas regras e mensagens da API (é a pré-visualização; a API refaz a conta).
  - `stockRepositoryProvider` (`Demo…`/`Api…` pelo `demoModeProvider`), `filamentStockProvider` (`FutureProvider<List<FilamentStock>>`), `filamentMovementsProvider` (`FutureProvider.family<List<FilamentMovement>, int>`).

- [ ] **Step 1: Testes que falham**

`weighing_test.dart`:
```dart
expect(weighedTotal(closedSpools: 2, spoolWeightG: 1000, openGrossG: [712], emptySpoolG: 250), 2462);
expect(weighedTotal(closedSpools: 3, spoolWeightG: 750, openGrossG: [], emptySpoolG: 0), 2250);
expect(weighedTotal(closedSpools: 0, spoolWeightG: 1000, openGrossG: [712.5, 300], emptySpoolG: 250), 512.5);
expect(weighingProblem(closedSpools: 0, openGrossG: [240], emptySpoolG: 250), contains("carretel"));
expect(weighingProblem(closedSpools: 0, openGrossG: [500], emptySpoolG: 0), contains("Custos e preços"));
expect(weighingProblem(closedSpools: 2, openGrossG: [], emptySpoolG: 0), isNull);
expect(weighingProblem(closedSpools: -1, openGrossG: [], emptySpoolG: 250), isNotNull);
```
`demo_stock_repository_test.dart`: uma compra de 2 rolos no filamento 1 do demo sobe o stock 2000 g e aparece primeiro no histórico; um acerto `closedSpools: 1, openGrossG: []` deixa o stock em 1000 g; `FilamentMovement.fromJson` de um JSON da API sem `paid_price` dá `paidPrice == null`.

- [ ] **Step 2: Correr e ver falhar**

Run: `flutter test test/features/stock/` (dentro de `app/`)
Expected: erros de compilação (ficheiros por criar).

- [ ] **Step 3: Implementar** os modelos (`dart run build_runner build`), `weighing.dart`, `ApiStockRepository` (pedidos com `apiCall`, como `api_order_repository.dart`), `DemoStockRepository` (em memória: para cada filamento do `DemoFilamentRepository` uma compra inicial de 1 rolo; compra e acerto calculam como a API, com a tara do filamento) e os providers. Depois de gravar, quem chama faz `ref.invalidate(filamentStockProvider)` e `ref.invalidate(filamentMovementsProvider(id))`.

- [ ] **Step 4: Correr e ver passar**

Run: `flutter test test/features/stock/` e `flutter analyze`
Expected: tudo verde, sem problemas.

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/costs/domain/filament*.dart app/lib/features/costs/data/demo_filament_repository.dart app/lib/features/stock app/test/features/stock
git commit -m "Stock na app: modelos, conta da pesagem e repositórios (demo e API)"
```

### Task 4: A tara na ficha do filamento, com cópia para a marca

**Files:**
- Modify: `app/lib/features/costs/presentation/tabs/filaments_tab.dart` (campo, `_draft()`, `_problem()`, gravação)
- Create: `app/lib/features/costs/domain/same_brand.dart`
- Test: `app/test/features/costs/same_brand_test.dart`

**Interfaces:**
- Consumes: `Filament.emptySpoolG` (Task 3).
- Produces: `List<Filament> sameBrandOthers(List<Filament> all, Filament edited)` — os outros filamentos com a mesma marca (sem ligar a maiúsculas nem a espaços à volta) cuja tara é diferente da do `edited`; vazio se a marca for nula ou vazia.

- [ ] **Step 1: Teste que falha** — `same_brand_test.dart`: com Bambu Lab (tara 250, editado), "bambu lab " (tara 0), Bambu Lab (tara 250) e Sunlu (tara 0): devolve só o "bambu lab " de tara 0; com a marca `null` devolve `[]`.

- [ ] **Step 2: Correr e ver falhar** — Run: `flutter test test/features/costs/same_brand_test.dart` → Expected: erro de compilação.

- [ ] **Step 3: Implementar** `sameBrandOthers`, e na ficha: campo "Carretel vazio" (sufixo `g`, ajuda "Pesa um carretel vazio desta marca. Serve para acertar o stock."), `_problem()` recusa valor negativo. Depois de gravar, se `sameBrandOthers` não estiver vazio, um diálogo "Usar {tara} g nos outros {n} filamentos {marca}?" com "Agora não" e "Usar"; "Usar" grava cada um pelo `FilamentRepository.update` e faz `ref.invalidate(filamentsProvider)`.

- [ ] **Step 4: Correr e ver passar** — Run: `flutter test test/features/costs/` e `flutter analyze` → Expected: verde, sem problemas.

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/costs app/test/features/costs/same_brand_test.dart
git commit -m "Filamentos: tara do carretel vazio, com cópia para a mesma marca"
```

### Task 5: Os ecrãs do Stock e o menu

**Files:**
- Create: `app/lib/features/stock/presentation/stock_screen.dart`, `filament_stock_screen.dart`, `widgets/purchase_dialog.dart`, `widgets/adjustment_dialog.dart`
- Modify: `app/lib/app/router.dart` (novo `StatefulShellBranch` **no fim**, índice 7: `/stock` e `/stock/:id`)
- Modify: `app/lib/app/shell/app_shell.dart` (`_Section(7, Icons.inventory_outlined, "Stock")` na lista **entre Produtos e Clientes**; o mesmo `ListTile` no menu lateral fixo, entre Produtos e Clientes, com `goBranch(7)`)
- Modify: `app/test/responsive_scan_test.dart` (`/stock` e `/stock/1` nas duas listas de rotas)
- Test: `app/test/features/stock/stock_screens_test.dart`

**Interfaces:**
- Consumes: os providers e o repositório do Task 3; `filamentsProvider` para nomes, cores, `spoolWeightG` e `emptySpoolG`.
- Produces: rotas `/stock` e `/stock/:id`.

O ramo novo vai no fim do `StatefulShellRoute` para não renumerar os outros (o `_Section.branch` é a posição no router; a ordem no menu é a da lista). No telemóvel, o Stock cai no "Mais".

- [ ] **Step 1: Testes que falham** — `stock_screens_test.dart`, em modo demo:
  - a lista mostra cada filamento do demo com os gramas e os rolos ("1,0 rolos"); o administrador vê "Registar compra", o colaborador não;
  - no histórico, o colaborador não vê "Acertar" nem nenhum "€";
  - acerto no filamento 1 do demo (tara 250) com 2 fechados e um rolo aberto de 712 g mostra "Total real: 2462 g" (com `gramsText`) e "Diferença: +1462 g" (o demo começa com 1000 g); com 240 g mostra a mensagem com "carretel" e o "Gravar" fica desligado;
  - dois toques seguidos em "Gravar" na compra gravam **um** movimento (contar no histórico).

- [ ] **Step 2: Correr e ver falhar** — Run: `flutter test test/features/stock/stock_screens_test.dart` → Expected: erro de compilação.

- [ ] **Step 3: Implementar** os ecrãs segundo os esboços da secção 5.5 do desenho (lista com barra, rolos e gramas sem décimas e ⚠ quando `stockG ≤ minStockG`; histórico com gramas com décimas, data, tipo, quem e, para o admin, o preço por rolo nas compras). Diálogos como `StatefulWidget` que criam e deitam fora os seus controllers; `_saving` desliga o botão; `try`/`catch` com `ApiException`; `mounted` depois de cada `await`. Linhas de rolo aberto: "+ outro rolo aberto" acrescenta um campo; com a tara a 0, as linhas de rolo aberto não aparecem e fica o aviso de onde preencher.

- [ ] **Step 4: Correr e ver passar** — Run: `flutter test` (toda a bateria, com o varrimento de ecrãs) e `flutter analyze` → Expected: tudo verde, sem problemas.

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/stock app/lib/app app/test
git commit -m "Ecrã Stock: lista, histórico, registar compra e acertar pesando com o carretel"
```

### Task 6: Documentação

**Files:**
- Modify: `docs/architecture.md` (migração 015, `features/stock`, `src/stock.php`, as rotas)
- Modify: `CLAUDE.md` ("Feito": passo 2 do stock; a tara; os scripts `api/tests/stock-check.php` e `stock-http-check.php` e como os correr)

- [ ] **Step 1: Escrever** as duas atualizações, curtas, no estilo das entradas que lá estão.
- [ ] **Step 2: Commit** — `git add docs/architecture.md CLAUDE.md && git commit -m "Docs: stock de filamento, passo 2"`

### Task 7: Publicar (só com aprovação do Rui)

Não começa sem o Rui dizer que sim.

- [ ] **Step 1:** cópia da base no cPanel (`getsqlbackup`) guardada em `~/backups-db/` com nome manual; confirmar o tamanho.
- [ ] **Step 2:** no phpMyAdmin, `SELECT COUNT(*)` de `spools` e `stock_movements` → `0` e `0` (se não, **parar** e falar com o Rui); correr a 015; conferir `empty_spool_g` e `DESCRIBE filament_movements`.
- [ ] **Step 3:** API: os ficheiros que já existem no servidor (`public/index.php`, `routes/costs.php`) comparados por hash com a versão anterior no Git e guardados como `.bak-AAAAMMDD`; enviar `src/stock.php` e `routes/stock.php` **antes** do `index.php`; conferir hashes; `GET /api/filaments/stock` sem sessão → 401.
- [ ] **Step 4:** web: build com o `API_URL` do servidor, `dart run tool/cache_bust.dart`, cópia da pasta, envio, conferência por md5 dos 5 ficheiros.
- [ ] **Step 5:** avisar o Rui: pesar um carretel vazio de cada marca e preencher a tara; depois, o acerto inicial de cada filamento (passo 5 do desenho). Windows e APK só numa versão seguinte.
