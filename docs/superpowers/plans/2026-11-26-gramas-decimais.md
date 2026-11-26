# Gramas com 2 casas decimais — plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `86,4 g` grava-se, mostra-se e conta-se como `86,4 g` (hoje fica `86 g` sem aviso), na base, na API e na app.

**Architecture:** Migração 014 muda as colunas de gramas para `DECIMAL(8,2)`. A API deixa de as converter para inteiro (`(int)` → `round((float) …, 2)`). Na app, `VariantFilament.grams` e `Variant.gramsColor2` passam a `double`, com um formatador novo `gramsText()` para o ecrã e `gramsField()` para os campos. `variants.weight_g` (peso dos portes) fica inteiro.

**Tech Stack:** MariaDB · PHP 8.3 + Slim 4 · Flutter 3.47 + Riverpod 3 + Freezed (`dart run build_runner build`).

**Spec:** `docs/superpowers/specs/2026-11-26-stock-filamento-design.md`, secção 5.1 (passo 1 da secção 6). Os passos 2–5 terão planos próprios.

## Global Constraints

- Colunas: `variant_filaments.grams`, `variants.grams_color_2`, `print_failures.wasted_grams` → `DECIMAL(8,2)`. `variants.weight_g` fica `INT`.
- Gramas guardam-se com **2 casas** (arredondar a 2, nunca truncar).
- Interface em português de Portugal, vírgula decimal (`86,4 g`); código em inglês, aspas duplas, `package:material_ui/material_ui.dart`, imports `package:cubico_backoffice/...`.
- PHP 8.3 (nada só do 8.4). Valores do utilizador sempre por `?`.
- Migração nova numerada em `database/migrations/`, e atualizar `schema.sql` (e `seed.sql` se preciso). **No servidor só com aprovação do Rui e com cópia da base antes.**
- Antes de cada commit: `flutter analyze` sem problemas e `flutter test` a passar.
- Modo demo continua a funcionar sem servidor.
- Encomendas antigas não mudam (cada linha guarda a "fotografia" do custo).

## Review Focus

1. **Mais de 2 casas escritas** (`86,456`): grava `86,46`, e o cartão não fica a dizer "alterações por gravar" depois de gravar → teste no Task 3 (`applyTo` arredonda a 2).
2. **Valores antigos inteiros** (`120`) aparecem `120 g` e `120` no campo, nunca `120,00` nem `120.0` → testes do Task 2 (`gramsText`, `gramsField`).
3. **Somas de decimais** (`86,4 × 3` = `259.20000000000002`) aparecem `259,2 g` → teste do Task 2.
4. **Peso dos portes com decimais** (`100,4 g`): `weightG` = 101 (arredonda para cima, para não cair num escalão dos CTT abaixo) → teste no Task 3.
5. **API antiga com app nova** (durante a publicação a API ainda manda `"grams": 120`): o `fromJson` aceita inteiros → teste no Task 2.

---

### Task 1: Base de dados e API

**Files:**
- Create: `database/migrations/014-gramas-decimais.sql`
- Modify: `database/schema.sql:210` (`grams_color_2`), `:222` (`grams`), `:378` (`wasted_grams`)
- Modify: `api/routes/products.php:287` (`VARIANT_TYPES`), `:325` (leitura da receita), `:344-345` (gravação da receita)
- Modify: `api/src/costs.php:45`, `:74-80`

**Interfaces:**
- Produces: a API devolve `grams` e `grams_color_2` como números com até 2 casas (`86.4`); aceita o mesmo ao gravar.

- [ ] **Step 1: Escrever a migração 014**

Cabeçalho no estilo das anteriores (o que muda, "Não apaga nada."). Três `ALTER TABLE … MODIFY COLUMN`:
`variant_filaments.grams DECIMAL(8,2) NOT NULL`, `variants.grams_color_2 DECIMAL(8,2) NOT NULL DEFAULT 0`,
`print_failures.wasted_grams DECIMAL(8,2) NOT NULL`. Mesmas definições no `schema.sql`.

- [ ] **Step 2: Aplicar na base do PC e confirmar**

Run (phpMyAdmin do PC ou `mysql`): a migração 014, depois `SHOW COLUMNS FROM variant_filaments LIKE 'grams'`.
Expected: `decimal(8,2)`. E `SELECT COUNT(*), SUM(grams) FROM variant_filaments` igual a antes da migração.

- [ ] **Step 3: API sem inteiros nas gramas**

- `VARIANT_TYPES['grams_color_2']` → `'float'`.
- Leitura da receita: `'grams' => (float) $f['grams']`.
- Gravação: `$grams = round((float) ($f['grams'] ?? 0), 2);` grava se `> 0`.
- `costs.php`: `$grams2 = (float) …`; `$moved`, `$recipe[0]['grams']` e a soma com `(float)` em vez de `(int)`.
- `grams_color_2` gravado pelo `dbValue(..., 'float')`: arredondar a 2 antes (`round(..., 2)`) no mesmo sítio onde se montam os `$values`.

- [ ] **Step 4: Provar na API do PC**

Run: API do PC (`iniciar-api.bat`), entrar como administrador, `PUT /api/variants/{id}` com `{"grams_color_2": 12.345, "filaments":[{"filament_id":1,"grams":86.456}]}`, depois `GET /api/variants?product_id=…`.
Expected: a resposta traz `"grams": 86.46` e `"grams_color_2": 12.35`; o custo de uma encomenda nova com essa variante usa 86,46 g (comparar com a conta à mão: `86.46 × €/kg / 1000`).

- [ ] **Step 5: Commit**

```bash
git add database/migrations/014-gramas-decimais.sql database/schema.sql api/routes/products.php api/src/costs.php
git commit -m "Gramas com 2 casas decimais: migração 014 e API"
```

### Task 2: Modelo e formatação na app

**Files:**
- Modify: `app/lib/features/products/domain/variant.dart:26` e `:52` (e regenerar `variant.freezed.dart`, `variant.g.dart`)
- Modify: `app/lib/core/formatting.dart`
- Modify: `app/lib/features/costs/domain/cost_calculator.dart:158-168`
- Modify: `app/lib/features/production/presentation/production_screen.dart:250`
- Modify: `app/lib/features/products/presentation/product_form_screen.dart:267`
- Modify: `app/lib/features/products/data/demo_variant_repository.dart` (só se o analyze pedir)
- Test: `app/test/core/formatting_test.dart`, `app/test/features/costs/cost_calculator_test.dart`, `app/test/features/products/variant_json_test.dart` (novo)

**Interfaces:**
- Produces: `VariantFilament.grams: double`; `Variant.gramsColor2: double` (`@Default(0)`);
  `String gramsText(double grams)` → `"86,4 g"`; `String gramsField(double grams)` → `"86,4"` (vazio não: quem chama decide).

- [ ] **Step 1: Testes que falham**

```dart
// formatting_test.dart, group("gramsText")
expect(gramsText(120), "120 g");
expect(gramsText(86.4), "86,4 g");
expect(gramsText(86.45), "86,45 g");
expect(gramsText(86.4 * 3), "259,2 g"); // sem 259,20000000000002
expect(gramsText(1500), "1500 g");
// group("gramsField")
expect(gramsField(120), "120");
expect(gramsField(86.4), "86,4");
expect(gramsField(86.456), "86,46");

// variant_json_test.dart
test("aceita gramas inteiras (API antiga) e com decimais", () {
  expect(VariantFilament.fromJson({"filament_id": 1, "grams": 120}).grams, 120.0);
  expect(VariantFilament.fromJson({"filament_id": 1, "grams": 86.4}).grams, 86.4);
});

// cost_calculator_test.dart
test("as gramas com decimais contam no custo", () {
  // variante com 86,4 g de um filamento a 20 €/kg, sem tempo nem componentes
  // → 86.4 × 20 / 1000 = 1,728
  expect(cost, closeTo(1.728, 0.0001));
});
```

(Ver no `formatting_test.dart`/`cost_calculator_test.dart` como os testes existentes criam `Filament` e `Variant`; o JSON usa as chaves que o `variant.g.dart` já usa.)

- [ ] **Step 2: Correr e ver falhar**

Run: `cd app; flutter test test/core/formatting_test.dart test/features/costs/cost_calculator_test.dart test/features/products/variant_json_test.dart`
Expected: FAIL (`gramsText` não existe; `grams` é `int`).

- [ ] **Step 3: Implementar**

- `variant.dart`: `required double grams`; `@Default(0) double gramsColor2`. Depois `dart run build_runner build`.
- `formatting.dart`: `gramsField` = `toStringAsFixed(2)`, tirar zeros finais e a vírgula solta, `.`→`,`. `gramsText(g)` = `"${gramsField(g)} g"`.
- `cost_calculator.dart`: `grams`/`moved` passam a `double` (tirar os `.toDouble()`).
- `production_screen.dart:250`: `gramsText(l.grams * job.quantity)`.
- `product_form_screen.dart:267`: `fold<double>(0, …)`.

- [ ] **Step 4: Correr os testes**

Run: `flutter analyze` e `flutter test`
Expected: `No issues found!` e `All tests passed!` (o `cost_card.dart` pode precisar dos ajustes do Task 3 para compilar; nesse caso fazer o Task 3 antes de correr tudo e juntar os dois commits num só).

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/products/domain app/lib/core/formatting.dart app/lib/features/costs app/lib/features/production app/lib/features/products/presentation/product_form_screen.dart app/test
git commit -m "Gramas com decimais na app: modelo, custo e formatação"
```

### Task 3: Cartão de custo do produto (os campos das gramas)

**Files:**
- Modify: `app/lib/features/products/presentation/widgets/cost_card.dart:94-100`, `:120-155`, `:705`
- Test: `app/test/features/products/cost_card_test.dart`

**Interfaces:**
- Consumes: `gramsField(double)`, `VariantFilament.grams: double`, `Variant.gramsColor2: double` (Task 2).
- Produces: `applyTo(base)` devolve gramas arredondadas a 2 casas e `weightG = total.ceil()`.

- [ ] **Step 1: Testes que falham** (no estilo dos existentes em `cost_card_test.dart`)

```dart
testWidgets("as gramas guardam as décimas: 86,4 não passa a 86", ...);
  // escrever "86,4" no campo das gramas → applyTo(v).filaments.single.grams == 86.4
testWidgets("mais de 2 casas arredonda a 2, e depois de gravar não há alterações por gravar", ...);
  // "86,456" → grams == 86.46; isChangedFrom(applyTo(v)) == false
testWidgets("o peso dos portes arredonda para cima", ...);
  // "100,4" → weightG == 101
testWidgets("uma receita gravada com 86,4 g aparece 86,4 no campo", ...);
  // Variant com VariantFilament(grams: 86.4) → o campo mostra "86,4"
```

- [ ] **Step 2: Correr e ver falhar**

Run: `flutter test test/features/products/cost_card_test.dart`
Expected: FAIL nos quatro.

- [ ] **Step 3: Implementar**

- Tirar os `.round()` das gramas (`_grams2`, `_recipeGrams`, `_totalGrams`) e passar a `double`, com `double _round2(double g) => (g * 100).round() / 100;` aplicado a cada valor lido.
- `weightG: grams.ceil()`.
- Campos: `gramsField(first)` / `gramsField(second)` em vez de `"$first"`; `_RecipeLine(this.filamentId, double grams)` com `gramsField(grams)`.
- `fold<double>` na soma da receita (linha 94); `v.gramsColor2.clamp(0, total)` com doubles.

- [ ] **Step 4: Correr tudo**

Run: `flutter analyze` e `flutter test`
Expected: `No issues found!` e `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/products/presentation/widgets/cost_card.dart app/test/features/products/cost_card_test.dart
git commit -m "Cartão de custo: gramas com décimas, peso dos portes arredonda para cima"
```

### Task 4: Prova de ponta a ponta no PC e documentação

**Files:**
- Modify: `docs/architecture.md` (migração 014; gramas `double`), `CLAUDE.md` (secção "Feito")

- [ ] **Step 1: Prova na app com a API do PC**

Run: `flutter run -d chrome` (API do PC). Numa variante, escrever `86,4` g e gravar; fechar e abrir de novo.
Expected: o campo mostra `86,4`; o custo é o de 86,4 g; uma encomenda nova com essa variante tem esse custo; o cartão da Produção (cores fixas) mostra `… 86,4 g`.

- [ ] **Step 2: Modo demo**

Run: a app em modo demo (sem API).
Expected: produtos, encomendas e Produção abrem sem erros; gramas inteiras aparecem sem `,0`.

- [ ] **Step 3: Documentação e commit**

```bash
git add docs/architecture.md CLAUDE.md
git commit -m "Docs: gramas com 2 casas decimais (migração 014)"
```

### Task 5: Publicar (só com aprovação do Rui)

Pedir ao Rui antes de começar. Ordem pensada para não haver erro a meio:

- [ ] **Step 1:** Cópia da base no cPanel (`getsqlbackup`) e confirmar que o ficheiro existe.
- [ ] **Step 2:** Migração 014 no phpMyAdmin. Conferir `SHOW COLUMNS` (as três colunas `decimal(8,2)`) e `COUNT(*)`/`SUM(grams)` de `variant_filaments` iguais a antes. (A API antiga continua a funcionar: lê e trunca como hoje.)
- [ ] **Step 3:** API: comparar o hash de `api/routes/products.php` e `api/src/costs.php` no servidor com o Git (`HEAD~` antes destes commits), guardar cópia, enviar os novos pelo File Manager, conferir o hash.
- [ ] **Step 4:** Web: `flutter build web --dart-define=API_URL=https://api.fazendasubmersa.pt/api`, `dart run tool/cache_bust.dart`, cópia da pasta, envio, conferir os ficheiros publicados com `curl --compressed`.
- [ ] **Step 5:** Conferir no site uma variante existente: as gramas aparecem iguais a antes (inteiras) e o custo das encomendas antigas não mudou.
- [ ] **Step 6:** Windows e APK ficam para a próxima versão (v0.3.2). **Atenção (erro mudo):** a app antiga lê `86,4` como `86` (`toInt()`) e, se **gravar** a variante, escreve `86` na base. Até haver Windows/APK novos, os produtos editam-se **só no site**. Dizer isto ao Rui ao publicar.
