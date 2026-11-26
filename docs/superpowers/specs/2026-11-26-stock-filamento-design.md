# Stock de filamento — desenho

> Estado: **aprovado pelo Rui a 2026-11-26.** Escrito nesse dia, a partir da conversa.
> As decisões marcadas *(decisão do Rui)* foram tomadas por ele; as marcadas *(proposta do Claude, aprovada pelo Rui)*
> eram escolhas minhas, e o Rui aprovou-as todas a 2026-11-26.

## 1. Porquê

Hoje a única forma de saber quanto filamento resta é olhar para os rolos. O Rui quer que o backoffice
saiba, a qualquer momento, quanto tem de cada filamento e o avise antes de acabar.

Serve os dois objetivos do projeto *(decisão do Rui: "o melhor dos 2 mundos")*:
- **Loja:** usar a app no dia a dia, sem contas de cabeça.
- **Portfólio:** um entrevistador explora a demo e vê um stock com histórico a sério.

## 2. Objetivos, não-objetivos, anti-objetivos

**Objetivos**
- Stock de cada filamento em gramas, sempre explicável movimento a movimento.
- Desconto automático quando uma tarefa de produção fica feita, e quando se regista uma falha.
- Registar compras com o número real de rolos e o preço *(decisão do Rui)*.
- Acertar o stock pesando o rolo.
- Aviso quando um filamento chega a 1 rolo ou menos.
- Gramas com 2 casas decimais em todo o lado onde hoje se arredondam.

**Não-objetivos (agora)**
- Stock por rolo individual (saber que rolo está na impressora).
- Componentes e embalagens (ímanes, caixas). Ficam para depois, com o mesmo modelo.
- Ligação à impressora Bambu para ler o consumo real.
- Relatórios de consumo por período (v2, "Relatórios").

**Anti-objetivos (falha mesmo que funcione)**
- Um stock que deriva da realidade sem dar sinal: o número tem de ter sempre a origem à vista.
- Mexer em encomendas antigas: custos e preços já vendidos não mudam.
- Partir o modo demo: tem de continuar a funcionar sem servidor.

## 3. Restrições

- Alojamento cPanel, PHP 8.3, sem terminal: migrações aplicadas à mão no phpMyAdmin; a API vai pelo File Manager.
- As contas oficiais ficam na API (`api/src/costs.php`); a app só mostra.
- O colaborador nunca recebe preços nem custos (regra do projeto).
- Base de dados verdadeira em `app.fazendasubmersa.pt`: testar sempre contra a API do PC.

## 4. Abordagens consideradas

| | Como guarda o stock | Prós | Contras |
|---|---|---|---|
| **A. Livro de movimentos** ✅ | Uma linha por compra, consumo, falha e acerto; stock = soma | Histórico completo; cada número explicável; acertos apontam receitas mal medidas | Um pouco mais de trabalho |
| B. Número no filamento | Coluna `stock_g` que sobe e desce | Mais rápido | Sem histórico: erro mudo garantido |
| C. Calcular na hora | Soma das tarefas × receita atual | Nada a guardar | Corrigir uma receita muda o consumo passado sem ninguém mexer |

**Escolhida: A** *(decisão do Rui)*. É a única que responde sempre a "porque é que a app diz que tenho 400 g?".

## 5. O desenho

### 5.1 Gramas com decimais (fazer primeiro)

Hoje `86,4 g` grava-se como `86 g` sem aviso, em três sítios:
- `app/lib/features/products/presentation/widgets/cost_card.dart:120` e `:127` — `.round()`;
- `api/routes/products.php:345` (e a leitura em `:325`) — `(int)`;
- `variant_filaments.grams INT`, `variants.grams_color_2 SMALLINT`, `print_failures.wasted_grams INT`.

Passam a `DECIMAL(8,2)` *(proposta do Claude, aprovada pelo Rui)*, e o modelo Dart `VariantFilament.grams` e
`Variant.gramsColor2` a `double`. As contas em `costs.php` e `cost_calculator.dart` deixam de converter
para inteiro. `variants.weight_g` (peso para os portes) fica inteiro: os escalões dos CTT são em gramas redondos.

Vem antes do stock porque o stock desconta os gramas da receita: se a receita perde meio grama por peça,
o stock deriva com ela.

### 5.2 Tabela `filament_movements`

```sql
CREATE TABLE filament_movements (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  filament_id      SMALLINT UNSIGNED NOT NULL,
  movement_type    ENUM('purchase','consumption','failure','adjustment','reversal') NOT NULL,
  grams            DECIMAL(10,2) NOT NULL,        -- positivo entra, negativo sai
  -- só nas compras: a "fotografia" do que foi pago
  spools           SMALLINT UNSIGNED,
  paid_price       DECIMAL(10,2),                 -- por rolo
  shipping_cost    DECIMAL(10,2),                 -- total da compra
  -- de onde veio
  print_job_id     INT UNSIGNED,
  print_failure_id INT UNSIGNED,
  reverses_id      INT UNSIGNED,                  -- o movimento que este anula
  note             VARCHAR(255),
  user_id          INT UNSIGNED,                  -- quem fez (NULL = automático)
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX (filament_id, created_at),
  FOREIGN KEY (filament_id)      REFERENCES filaments(id),
  FOREIGN KEY (print_job_id)     REFERENCES print_jobs(id) ON DELETE SET NULL,
  FOREIGN KEY (print_failure_id) REFERENCES print_failures(id) ON DELETE SET NULL,
  FOREIGN KEY (reverses_id)      REFERENCES filament_movements(id),
  FOREIGN KEY (user_id)          REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Regra:** os movimentos **nunca se editam nem se apagam**. Um engano corrige-se com um movimento novo
(`reversal` ou `adjustment`), como num extrato bancário *(proposta do Claude, aprovada pelo Rui)*.

**Stock de um filamento** = `SUM(grams)`. Em rolos = stock ÷ `spool_weight_g`, com uma casa decimal.

As tabelas `spools` e `stock_movements` do `schema.sql` (stock por rolo, preparadas e nunca usadas)
saem na mesma migração, depois de confirmar que estão vazias no servidor.

### 5.3 Os quatro movimentos

**Compra** (só administrador). O Rui diz o filamento, o número de rolos, o preço pago por rolo e os
portes da compra. Grava `+rolos × spool_weight_g` e atualiza `filaments.paid_price`, `shipping_cost` e
`spools_in_order`: o preço da **última compra** passa a ser o do filamento *(decisão do Rui)*. A calculadora
de custo fica igual. As encomendas antigas não mudam, porque cada linha guarda a "fotografia" do custo.

**Consumo** (automático). Quando uma tarefa de produção passa a `done`, a API grava um movimento negativo
por filamento, com os gramas da receita × quantidade **desse momento** (fotografia). As cores resolvem-se
**com a mesma função que o custo usa** em `costs.php`, para custo e consumo nunca divergirem:
- `colors_per_piece` 1 ou 2: a cor escolhida na linha da encomenda (`filament_id`, `filament_id_2`) e os
  `grams_color_2` passados para a 2.ª cor;
- `colors_per_piece` 0: a receita da variante, cor a cor;
- tarefa manual (teste, protótipo, sem encomenda): a receita da variante *(proposta do Claude, aprovada pelo Rui)*.

Se a tarefa **sair** de `done` (arrastada para trás no quadro), grava-se um `reversal` de cada consumo dela.
Se voltar a `done`, consome de novo. Assim, arrastar para trás e para a frente nunca desconta duas vezes
*(proposta do Claude, aprovada pelo Rui)*.

**Falha.** Hoje a tabela `print_failures` existe, mas **nada a usa**: nem ecrã, nem rota da API (procurado
a 2026-11-26). Este trabalho acrescenta um botão **"Registar falha"** no cartão da tarefa, no quadro de
Produção: filamento (por omissão o principal da tarefa), gramas desperdiçados, minutos perdidos e motivo
*(proposta do Claude, aprovada pelo Rui)*. Ao gravar, a API escreve a falha e o movimento `−wasted_grams`, na mesma transação.

**Acerto** (só administrador). O Rui pesa o que tem e escreve o total real. A app grava a diferença
(`real − stock atual`), com uma nota opcional. O **stock inicial** de cada filamento entra assim: no
primeiro dia, um acerto por filamento com o que está na prateleira.

### 5.4 Aviso de "1 rolo ou menos"

- O limite é `filaments.min_stock_g`. Uma migração muda-o para `spool_weight_g` em todos os filamentos
  (hoje vale 250 por omissão e não é usado), e passa a vir com o peso do rolo nos filamentos novos.
  Pode mudar-se por filamento *(decisão do Rui)*.
- Nova coluna `filaments.low_stock_notified BOOLEAN`. Quando um movimento deixa o stock `≤` limite e a
  coluna está a falso, envia o aviso e põe-na a verdadeiro. Quando o stock volta a subir acima do limite
  (uma compra, um acerto), volta a falso. Assim avisa **uma vez por cada descida** *(decisão do Rui)*.
- **Web Push** com o `pushNotify()` de `api/src/push.php`, só para administradores, como nas encomendas:
  "PLA preto: resta 1 rolo (980 g)". O aviso abre o ecrã do Stock.
- **Cartão "Filamento a acabar" no Dashboard**, para quem usa a APK ou o Windows (sem push).

### 5.5 Ecrãs

Nova secção **Stock** no menu (o plano já a previa para a v2), entre Produtos e Clientes.

```
Stock                                          [ Registar compra ]
────────────────────────────────────────────────────────────────
● PLA preto · Bambu        ████████░░  2,4 rolos · 2 380 g
● PLA branco · Bambu       ██░░░░░░░░  0,6 rolos ·   590 g   ⚠
● PETG azul · Sunlu        ██████████  5,0 rolos · 5 000 g
```

Tocar num filamento abre o **histórico**:

```
PLA preto · Bambu                     2 380 g        [ Acertar ]
────────────────────────────────────────────────────────────────
02/12  Acerto (pesado)               −120,00 g    Rui
27/11  Falha · tarefa #43             −30,00 g    automático
27/11  Consumo · #1042 MARE ×1        −86,40 g    automático
26/11  Compra · 5 rolos                +5 000 g   Rui · 15,00 €/rolo
```

- O colaborador vê o stock e o histórico, mas **sem preços**, e não regista compras nem acertos
  *(proposta do Claude, aprovada pelo Rui)*: precisa de saber se há filamento para imprimir, não quanto custou.
- O stock também aparece no cartão da tarefa no quadro de Produção, ao lado dos gramas que ela vai gastar
  *(proposta do Claude, aprovada pelo Rui)*.

### 5.6 API

- `GET /api/filaments/stock` — stock, rolos e limite de cada filamento (sem preços para o colaborador).
- `GET /api/filaments/{id}/movements` — o histórico (sem preços para o colaborador).
- `POST /api/filaments/{id}/purchases` — admin.
- `POST /api/filaments/{id}/adjustments` — admin; recebe o total pesado.
- O consumo e a falha gravam-se **dentro da mesma transação** que muda a tarefa ou grava a falha
  (`api/routes/production.php`): ou fica tudo, ou nada.

### 5.7 Modo demo

`DemoFilamentStockRepository` com movimentos de exemplo: compras, consumos ligados às encomendas de
demonstração, uma falha, um acerto, e um filamento abaixo do limite para o cartão do Dashboard aparecer.

### 5.8 Testes

- API: stock = soma; consumo ao passar a `done`; `reversal` ao sair de `done`; ida e volta não desconta
  duas vezes; aviso uma vez por descida; colaborador sem preços.
- App: os ecrãs no varrimento de tamanhos (`responsive_scan_test.dart`); a resolução de cores igual ao custo.
- **Provar com números reais:** num filamento, comparar o stock da app com o rolo pesado ao fim de uma
  semana de uso. É o teste que apanha o erro mudo.

## 6. Ordem do trabalho

1. Gramas com decimais (migração 014, API, app, testes). Útil já, mesmo sem stock.
2. Tabela de movimentos, compras e acertos, ecrã de Stock (migração 015).
3. Consumo automático na produção, e o botão "Registar falha" (rota `POST /api/print-jobs/{id}/failures`).
4. Aviso (push e cartão do Dashboard).
5. Modo demo, documentação (`docs/architecture.md`, `CLAUDE.md`), e acerto inicial na loja a sério.

Cada passo é testado e commitado antes do seguinte.

## 7. Fica para quem constrói

- Nomes exatos dos ficheiros Dart e dos providers, seguindo as convenções do `CLAUDE.md`.
- O desenho visual dos ecrãs, dentro do tema (`AppColors`, `AppTextStyles`).
- Arredondamentos na apresentação (gramas sem decimais na lista; decimais no histórico).
