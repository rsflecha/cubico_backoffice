# CLAUDE.md — CubicoDesign3D Backoffice

Instruções para o Claude Code. São lidas no início de cada sessão.

## O projeto

Backoffice da loja de impressão 3D **CubicoDesign3D** (vendas na Etsy, Instagram, Facebook e em mão).
Gere encomendas, produção (quadro kanban), produtos e variantes com a calculadora de custo,
custos e preços, clientes e utilizadores com dois papéis. É também o **primeiro projeto de
portfólio** do Rui, que acabou um curso de Flutter em outubro de 2026.

- **Documento de decisões:** `docs/cubico-backoffice.md` — âmbito, ecrãs, permissões, base de dados, plano.
  Segue-o, e avisa quando um pedido for contra ele.
- **Arquitetura:** `docs/architecture.md` — atualizar no fim de cada fatia ou módulo.
- **Desenhos dos ecrãs:** `docs/ecras/`.

## Como trabalhar com o Rui (importante)

- **Responder sempre em português de Portugal.**
- Ele está a **aprender**: explica passo a passo, com palavras simples, o porquê de cada mudança.
  Conceitos novos (do Dart, do Flutter, do PHP, do SQL) explicam-se na primeira vez que aparecem.
- Por omissão, **ele escreve o código** e tu explicas, revês e ajudas quando encrava.
  Se ele pedir, fazes tu as alterações; nesse caso, mostra o que mudou e explica.
- Nas revisões: aponta primeiro o que está errado ou é má prática, explica porquê, e mostra só o excerto a corrigir.
- **Uma coisa de cada vez.** Dividir trabalho grande em passos pequenos, testados um a um.
- Pergunta as versões dos pacotes antes de explicar algo que mude entre versões (Riverpod, GoRouter…).
- Antes de cada commit: `flutter analyze` sem problemas e `flutter test` a passar.

## Segurança

- **Nunca ler, mostrar nem copiar o conteúdo dos ficheiros `.env`** (palavras-passe da base de dados, segredo JWT).
  Para os ajudar a configurar, pede só os nomes das variáveis, sem os valores. O modelo está em `api/.env.example`.
- Nunca juntar segredos ao código nem ao Git. O repositório é **público**.
- Na API, os valores do utilizador entram **sempre** por `?` (consultas preparadas). Nunca juntar texto ao SQL.

## Estrutura

```
cubico_backoffice/
├── app/        a app Flutter (Windows, Android e web)
├── api/        a API em PHP 8.3+ com Slim 4
├── database/   schema.sql, seed.sql e migrations/
└── docs/       documento de decisões, arquitetura, ecrãs, capturas
```

## Comandos

App (dentro de `app/`):
- `flutter run -d windows` — com a API do PC (`http://localhost:8080/api`)
- `flutter run -d chrome` — a versão web, com a API do PC
- `flutter run -d windows --dart-define=API_URL=https://api.fazendasubmersa.pt/api` — com o servidor
- `dart run build_runner build` — depois de mudar modelos Freezed
- `flutter analyze` · `flutter test`
- `flutter build windows|web --dart-define=API_URL=https://api.fazendasubmersa.pt/api`
- Depois de `flutter build web`, SEMPRE: `dart run tool/cache_bust.dart` (põe `?v=` no flutter_bootstrap.js, no main.dart.js e no passkeys.js; o nginx do alojamento guarda os .js antigos e não se limpa; só o index.html chega fresco)

API (dentro de `api/`):
- `php -S localhost:8080 -t public` (ou o `iniciar-api.bat`)
- `composer install` · `php bin/create-user.php`

## Convenções da app (Flutter)

- **Técnico em inglês** (código, nomes, base de dados, API); **só a interface em português de Portugal**.
- `import 'package:material_ui/material_ui.dart';` — **nunca** `package:flutter/material.dart`.
- Imports sempre `package:cubico_backoffice/...`, nunca relativos.
- **Aspas duplas** no código; plicas só nos imports.
- Dinheiro sempre com `euro()` e `euroPer()` de `core/formatting.dart` (vírgula decimal); campos com `decimalField()` e `parseDecimal()`.
- Estado: Riverpod 3 (`Notifier`, `FutureProvider`); estado local de um ecrã com `setState`.
- Navegação: GoRouter 18 com `StatefulShellRoute.indexedStack`; `redirect` faz de porteiro (sessão e papéis).
- Pastas por funcionalidade: `features/<x>/domain` (modelos e contratos), `data` (`Demo…` e `Api…`), `presentation`.
- **Cada placa de repositório escolhe** `Demo…` ou `Api…` pelo `demoModeProvider`. O modo demo tem de continuar a funcionar sem servidor.
- Permissões nos ecrãs: `user.canSeeCosts` e `user.isAdmin`; na dúvida, esconder. A API também protege.
- Formulários: rascunho do modelo (`_draft()`), validação com `_problem()`, `try`/`catch` ao gravar, `mounted` depois de cada `await`.
- Janelas com campos de texto: o próprio diálogo é um `StatefulWidget` que cria e deita fora os seus controllers (nunca `dispose` logo a seguir a um `showDialog`).
- Num `DataTable`, coluna e célula condicionais levam **o mesmo** `if`.
- Fora do `build`, para dados que podem não ter chegado: `await ref.read(xProvider.future)`.
- Material 3; tema em `app/theme.dart` (`AppColors`, `AppTextStyles`).

## Convenções da API (PHP)

- `public/index.php` junta tudo; `src/` (db, helpers, auth, tables, costs, cors); `routes/` um ficheiro por módulo.
- Porteiros `$requireAuth` e `$requireAdmin`; no Slim o último `add` corre primeiro: `->add($requireAdmin)->add($requireAuth)`.
- `typed()` converte DECIMAL e BOOLEAN antes de responder; `fail()` responde com mensagens em português.
- Transações quando se grava em várias tabelas. As contas oficiais (custo, taxas, portes) são feitas na API (`src/costs.php`).
- O colaborador nunca recebe custos, taxas nem portes pagos.
- Mudanças a bases de dados existentes: nova migração em `database/migrations/` (numerada), e atualizar `schema.sql`/`seed.sql`.

## Servidor (alojamento cPanel)

- API em `https://api.fazendasubmersa.pt` (pasta `repositories/cubico_backoffice/api/public`); app web em `https://app.fazendasubmersa.pt` (pasta `apps/backoffice-web`).
- **PHP 8.3 no servidor** (o PC tem 8.4): o `composer.json` tem `config.platform.php = 8.3.0`. Não usar funcionalidades só do 8.4.
- Sem terminal nem SSH. O "Update from Remote" do Git Version Control está a falhar: as mudanças da API vão pelo **File Manager**. A pasta `vendor` e o `.env` vão à mão.
- O `.htaccess` da `apps/backoffice-web` (só no servidor, não vem na build) manda `Cache-Control: no-cache` no index, `flutter_bootstrap.js` e `main.dart.js`: o browser vai sempre buscar a versão nova. O nginx do alojamento ignora isto e guarda o `main.dart.js` e o `flutter_bootstrap.js` muito tempo (não se limpa: `ea-nginx` não está na conta); por isso o `tool/cache_bust.dart` muda-lhe o endereço a cada build. Para conferir a web publicada, pedir os ficheiros SEM `?v=` aleatório e com `--compressed`, como um browser.
- Lembra o Rui de que `app.fazendasubmersa.pt` usa a **base de dados verdadeira** da loja; para testes, usar a API do PC.

## Decisões a respeitar

- Encomendas canceladas contam 0 € recebidos, 0 € de custo e 0 € de lucro.
- Cada linha de encomenda guarda a "fotografia" do preço, do custo e da taxa do dia da venda.
- Envios: Portugal por CTT Correio Registado; estrangeiro (só Etsy) por CTT Correio Azul Internacional. Preços base de 2026, por zona e escalão.
- Custos fixos mensais (Etsy Plus, Claude Pro…) não entram no lucro das encomendas: o Dashboard tira-os ao lucro do mês.
- SKU automático: CD3-<código da categoria>-01; variantes com nome = produto + número pela ordem de criação (CD3-SUP-01-01, -02…; mudar o nome não muda o SKU; números não se reaproveitam; migração 008). Variantes são nomes (Hamilton, Verstappen), não filamentos; "Modelo único" = sem nome. Regras iguais em `api/src/sku.php` e `app/…/domain/sku.dart`. Só se apagam se nunca foram vendidas.

## Por fazer

- Etsy: conferir os SKU dos anúncios ativos contra as variantes da app, antes de haver vendas
  (sem SKU igual, a encomenda não entra). Depois: associar à mão um artigo desconhecido.
- Provar com a primeira venda verdadeira que a encomenda paga vai sozinha para "Por imprimir"
  (a base da loja ainda não tem encomendas; está provado só nos testes do PC).
- Face ID / impressão digital (passkeys, migração 010): feito só para o site (browser). Falta provar num iPhone verdadeiro; a APK e a app de Windows ficam para uma 2.ª fase (outro pacote). Ativar pede a palavra-passe; mudá-la ou repô-la apaga as passkeys.
- APK com chave própria (hoje vai com a chave de testes do Flutter): só se for para a Play Store.
- Impressora Bambu Lab A1: só depois da Etsy. O Rui usa a app Bambu Handy, por isso o "Developer Mode" está fora de questão; a opção seria a nuvem da Bambu (não oficial).

## Feito (2026-11)

- v0.3.0 publicada (Windows e Android) a 2026-11-16, ligada à API do servidor.
- Etsy ligada e sozinha: tarefa agendada do cPanel a cada 15 minutos (`api/bin/etsy-sync.php`).
- Encomenda paga vai sozinha para produção; taxas da Etsy como a Etsy as cobra.
- Clientes: telemóvel validado e localidade pelo código postal (tabela `postal_codes`, migração 005).
- Android com permissão de internet; versão web, iPad e iPhone revistos.
