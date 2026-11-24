# Avisos de encomendas novas (Web Push) — desenho

Data: 2026-11-24 · Pedido do Rui: «A, avança e publica».

## Para quê

O Rui quer saber logo quando entra uma encomenda nova — da Etsy (sincronização a cada 15 min)
ou criada à mão por outra pessoa (a Sara) — sem ter a app aberta. Recebe no **iPhone e no iPad**,
com o site `app.fazendasubmersa.pt` adicionado ao ecrã principal.

## Objetivos e o que fica de fora

- Sim: aviso no iPhone/iPad (iOS/iPadOS 16.4+, site no ecrã principal), e em qualquer browser
  de computador que o suporte (Chrome, Edge, Safari do Mac). Tocar no aviso abre a encomenda.
- Sim: cada aparelho liga e desliga os avisos nas Definições; há um «Enviar aviso de teste».
- Só administradores recebem. Quem criou a encomenda não recebe o aviso dela.
- Fora: APK Android (Firebase), app de Windows, avisos para a colaboradora, outros tipos de aviso.
- Anti-objetivo: o aviso nunca leva dinheiro (preço, custo, lucro) — só número, canal, cliente e
  quantos artigos. E um erro no envio do aviso nunca pode impedir a encomenda de ficar gravada.

## Abordagens (escolhida: A)

- **A. Web Push próprio** (escolhida pelo Rui): a API assina com chaves VAPID e envia ao serviço
  de push do browser (Apple, Google, Mozilla). Sem contas nem terceiros com os dados da loja.
  Custa: biblioteca `minishlink/web-push` 10.1 + `guzzlehttp/guzzle` 7 (12 pacotes, 8 MB no
  `vendor`, que vai à mão para o servidor), migração 013 e um service worker.
- B. Serviço de terceiros (OneSignal…): menos código, mas mais uma conta e o nome da cliente
  passa por eles; o iPhone continua a precisar do ecrã principal.
- C. Robô do Telegram: o mais simples e fiável, mas o aviso não vive na app.

## Como

**Base (migração 013):** tabela `push_subscriptions` — `user_id`, `endpoint` (o endereço do
aparelho no serviço de push), `endpoint_hash` (SHA-256, único: o endereço é longo demais para
índice), as chaves `p256dh` e `auth` do aparelho, `user_agent`, `created_at`, `last_used_at`.
Apaga-se em cascata com o utilizador. Cópia da base antes de correr no servidor.

**Chaves VAPID:** `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT` no `api/.env`.
`api/bin/vapid-setup.php` gera-as e acrescenta-as ao `.env` se lá não estiverem, sem as mostrar
(no servidor corre uma vez por cron). Nunca no Git nem no chat.

**API:**
- `GET /api/push/key` (admin) → a chave pública.
- `POST /api/push/subscriptions` (admin) → guarda o aparelho (o mesmo endpoint atualiza).
- `DELETE /api/push/subscriptions` (admin, endpoint no corpo) → esquece o aparelho.
- `POST /api/push/test` (admin) → aviso de teste aos aparelhos de quem pede; diz quantos chegaram.
- `src/push.php`: `notifyNewOrders(array $orderIds, ?int $exceptUserId)`. Envia aos aparelhos dos
  administradores ativos; apaga os aparelhos que o serviço diz que já não existem (404/410);
  regista os outros erros no log e nunca lança exceção para fora.
- Chamado depois do `commit` em `POST /api/orders` (exceto quem a criou) e no fim da
  sincronização da Etsy (cron e «Sincronizar agora») para as encomendas criadas. Mais de 3 de uma
  vez → um só aviso: «5 encomendas novas da Etsy».
- Texto: título «Encomenda nova #1043»; corpo «Etsy · Ana Silva · 2 artigos». Ao tocar:
  `/#/orders/<id>` (ou `/#/orders` no resumo).

**Web:**
- `web/flutter_bootstrap.js` próprio: arranca o Flutter **sem** o service worker do Flutter
  (ele apaga-se a si próprio e levaria o nosso com ele: há só um por âmbito).
- `web/push_sw.js`: recebe o `push` e mostra o aviso; `notificationclick` foca a app aberta ou
  abre-a no endereço do aviso.
- `web/push.js`: regista o service worker e dá à app `cubicoPushState()`, `cubicoPushEnable(key)`
  e `cubicoPushDisable()` (como o `passkeys.js`). `tool/cache_bust.dart` passa a pôr `?v=` também
  no `push.js`.

**App (Definições, só administrador, só na web):** cartão «Avisos de encomendas novas»:
- iPhone/iPad fora do ecrã principal → «Para receber avisos, abre o site no Safari → Partilhar →
  Adicionar ao ecrã principal, e abre a app por esse ícone.»
- Desligado → botão «Ligar avisos neste aparelho» (o browser pede autorização).
- Ligado → «Ligados neste aparelho» + «Enviar aviso de teste» + «Desligar».
- Bloqueado no browser → explica onde se volta a autorizar.
- Fora da web (Windows, APK) → o cartão não aparece.

## Provas antes de dar por feito

- Testes PHP do envio com um serviço de push falso (o que se envia e a limpeza dos 410).
- Testes Flutter do cartão nos vários estados (ponte falsa, como as passkeys).
- No PC: API local + Chrome verdadeiro → ligar avisos, criar encomenda noutro utilizador, o aviso
  aparece.
- No servidor: aviso de teste no iPhone do Rui, e depois uma encomenda verdadeira.

## Deixado ao construtor

Nomes internos, estrutura dos ficheiros, mensagens de erro em português.
