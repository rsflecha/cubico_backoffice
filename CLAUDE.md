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
- Depois de `flutter build web`, SEMPRE: `dart run tool/cache_bust.dart` (põe `?v=` no flutter_bootstrap.js, no main.dart.js, no passkeys.js e no push.js; o nginx do alojamento guarda os .js antigos e não se limpa; só o index.html chega fresco)

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
- Login com limite de tentativas (`src/login_limit.php`, migração 011): 5 falhas por email ou 30 por IP em 15 minutos dão 429. O Face ID conta só pelo IP. Entrar bem limpa as falhas do email, não as do IP.
- Mudanças a bases de dados existentes: nova migração em `database/migrations/` (numerada), e atualizar `schema.sql`/`seed.sql`.

## Servidor (alojamento cPanel)

- API em `https://api.fazendasubmersa.pt` (pasta `repositories/cubico_backoffice/api/public`); app web em `https://app.fazendasubmersa.pt` (pasta `apps/backoffice-web`).
- **PHP 8.3 no servidor** (o PC tem 8.4): o `composer.json` tem `config.platform.php = 8.3.0`. Não usar funcionalidades só do 8.4.
- Sem terminal nem SSH. O "Update from Remote" do Git Version Control está a falhar: as mudanças da API vão pelo **File Manager**. A pasta `vendor` e o `.env` vão à mão.
- O `.htaccess` da `apps/backoffice-web` (só no servidor, não vem na build) manda `Cache-Control: no-cache` no index, `flutter_bootstrap.js` e `main.dart.js`: o browser vai sempre buscar a versão nova. O nginx do alojamento ignora isto e guarda o `main.dart.js` e o `flutter_bootstrap.js` muito tempo (não se limpa: `ea-nginx` não está na conta); por isso o `tool/cache_bust.dart` muda-lhe o endereço a cada build. Para conferir a web publicada, pedir os ficheiros SEM `?v=` aleatório e com `--compressed`, como um browser.
- Cabeçalhos de segurança (2026-11-20): na API vêm do `public/.htaccess` (o do servidor tem também um bloco do cPanel que não está no Git: juntar, nunca substituir); na web, um bloco "Cubico — segurança" no `.htaccess` da `apps/backoffice-web` (só no servidor). `/api/health/db` pede sessão.
- Lembra o Rui de que `app.fazendasubmersa.pt` usa a **base de dados verdadeira** da loja; para testes, usar a API do PC.

## Decisões a respeitar

- Encomendas canceladas contam 0 € recebidos, 0 € de custo e 0 € de lucro.
- Cada linha de encomenda guarda a "fotografia" do preço, do custo e da taxa do dia da venda.
- Cores na encomenda (`colors_per_piece`): 1 ou 2 = o cliente escolhe (custo pela cor escolhida); 0 = fixas em cada variante (suporte F1): a receita (`variant_filaments`) tem as cores e as gramas de cada uma, a encomenda não pede cor e o custo é a receita cor a cor. Gravar o produto só reescreve as outras variantes quando as cores são à escolha.
- Envios: Portugal por CTT Correio Registado; estrangeiro (só Etsy) por CTT Correio Azul Internacional. Preços base de 2026, por zona e escalão.
- Custos fixos mensais (Etsy Plus, Claude Pro…) não entram no lucro das encomendas: o Dashboard tira-os ao lucro do mês.
- SKU automático: CD3-<código da categoria>-01; variantes com nome = produto + número pela ordem de criação (CD3-SUP-01-01, -02…; mudar o nome não muda o SKU; números não se reaproveitam; migração 008). Variantes são nomes (Hamilton, Verstappen), não filamentos; "Modelo único" = sem nome. Regras iguais em `api/src/sku.php` e `app/…/domain/sku.dart`. Só se apagam se nunca foram vendidas.

## Por fazer

- Etsy (2026-11-25): deck box ligado. Faltam as variantes e o porta-chaves, adiados por decisão do Rui.
  O porta-chaves fica fora até segunda ordem; enquanto o anúncio estiver ativo, uma venda dele
  NÃO entra nas Encomendas (o recibo fica "por associar", `etsy_sync.php`) — desativá-lo na Etsy.
- Face ID / impressão digital (passkeys, migração 010): feito só para o site (browser), provado num iPhone verdadeiro a 2026-11-19. A APK fica para uma 2.ª fase (outro pacote); a app de Windows não precisa (decisão do Rui). Ativar pede a palavra-passe; mudá-la ou repô-la apaga as passkeys.
- Stock de filamento, a seguir ao passo 2: o Rui pesa um carretel vazio de cada marca e preenche a tara; depois faz o acerto inicial de cada filamento. Windows e APK com o ecrã Stock só numa versão seguinte (a v0.3.2 não o tem; a web tem).
- Impressora Bambu Lab A1: só depois da Etsy. O Rui usa a app Bambu Handy, por isso o "Developer Mode" está fora de questão; a opção seria a nuvem da Bambu (não oficial).

## Feito (2026-11)

- v0.3.0 publicada (Windows e Android) a 2026-11-16, ligada à API do servidor.
- v0.3.1 a 2026-11-22: associar à mão um artigo da Etsy a uma variante (migração 012, `etsy_links`; a sincronização procura SKU → associação → anúncio) e cartão Histórico no detalhe da encomenda (`order_events`, `GET /api/orders/{id}/events`). Conferir os SKU pela linha de comandos: `api/bin/etsy-listings-check.php` (sai com 1 se houver artigos por ligar).
- v0.3.2 a 2026-11-26: gramas com décimas no Windows e na APK; 1.ª APK com a chave própria (obriga a desinstalar a antiga). Notas em `docs/release-v0.3.2.md`, ficheiros em `dist/`.
- APK assinada com chave própria (2026-11-25): `C:\Users\PC\chaves-android\cubico-upload.jks` (alias `cubico`),
  lida do `app/android/key.properties` (fora do Git; nunca ler nem mostrar). Sem esse ficheiro a build usa a
  chave de testes. Conferir: `apksigner verify --print-certs` → `CN=Rui Santos`. A 1.ª APK com esta chave
  obriga a desinstalar a antiga (chave de testes) em cada telemóvel. Perder o .jks = nunca mais atualizar a app.
- Etsy ligada e sozinha: tarefa agendada do cPanel a cada 15 minutos (`api/bin/etsy-sync.php`).
- Cópia automática da base todas as noites (`api/bin/db-backup.php`, tarefa agendada do cPanel): `~/backups-db/cubicodesign-auto-AAAAMMDD-HHMM.sql.gz`, guardadas 14 dias; as cópias feitas à mão (outro nome) nunca se apagam. Repor: phpMyAdmin → Importar. Provado no PC: reposta numa base nova, contagem e checksum iguais nas 35 tabelas.
- Encomenda paga vai sozinha para produção; taxas da Etsy como a Etsy as cobra. Provado com a primeira venda verdadeira da Etsy (confirmado pelo Rui a 2026-11-25).
- Clientes: telemóvel validado e localidade pelo código postal (tabela `postal_codes`, migração 005).
- Android com permissão de internet; versão web, iPad e iPhone revistos.
- Gramas com 2 casas decimais (migração 014, 2026-11-26): 86,4 g já não se grava como 86 g. Passo 1 do stock de filamento (`docs/superpowers/specs/2026-11-26-stock-filamento-design.md`). A v0.3.1 (Windows e APK) lê as gramas sem décimas e, se gravar uma variante, corta-as: só a v0.3.2 ou a web devem editar produtos.
- Stock de filamento, passo 2 (publicado na API e na web a 2026-11-27; cópia da base antes: `~/backups-db/cubicodesign-manual-20261127-antes-015.sql.gz`): ecrã Stock (lista, histórico, registar compra, acertar pesando com o carretel), migração 015 (`filament_movements`; stock = soma dos movimentos, que nunca se editam) e a tara "Carretel vazio" em Custos e preços → Filamentos (`empty_spool_g`; oferece copiar para a mesma marca). GET (stock, histórico): qualquer sessão, sem preços para o colaborador; POST (compras, acertos): só administrador. O preço da compra é por rolo. Provas, dentro de `api/`: `php tests/stock-check.php` (contas; numa transação com rollback, a base fica igual) e `php tests/stock-http-check.php` (rotas; precisa da API a correr com `php -S localhost:8080 -t public`; cria e apaga um utilizador temporário). Ambas imprimem PASS/FAIL e saem com o número de falhas (0 = bem). Ainda sem consumo automático pela produção.
- Avisos de encomendas novas (Web Push, migração 013, 2026-11-24): só administradores, só na web; no iPhone/iPad só com o site no ecrã principal. Chaves VAPID no `.env`, criadas uma vez pelo `api/bin/vapid-setup.php` (nunca as mostra). A web tem um `web/flutter_bootstrap.js` próprio, sem o service worker do Flutter (apagava o `push_sw.js`). No PC, a API arranca com `OPENSSL_CONF=C:\php\extras\ssl\openssl.cnf` (chaves EC) e `php -d curl.cainfo="C:\Program Files\Git\mingw64\etc\ssl\certs\ca-bundle.crt"` (senão o envio dá cURL error 60). Provado no Chrome do PC e no iPhone do Rui (servidor) a 2026-11-24.
