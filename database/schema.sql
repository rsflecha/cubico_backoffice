-- ============================================================
-- CubicoDesign3D Backoffice — esquema da base de dados
-- MySQL 8 / MariaDB 10.4+ · InnoDB · utf8mb4
--
-- Nomes de tabelas e colunas em INGLES, snake_case, para baterem
-- certo com os modelos em Dart sem precisar de @JsonKey.
-- Comentarios em portugues: explicam o porque, nao o que.
--
-- Dinheiro em DECIMAL(10,2) — nunca FLOAT, que arredonda mal.
-- Pesos em gramas (INT), tempos em minutos (INT).
-- ============================================================

SET NAMES utf8mb4;

-- ───────────── Acesso ─────────────

CREATE TABLE users (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  email         VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role          ENUM('admin','staff') NOT NULL DEFAULT 'staff',
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,   -- desativar sem apagar: o historico fica
  last_login_at DATETIME,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Configuracao ─────────────

CREATE TABLE settings (
  setting_key   VARCHAR(60) PRIMARY KEY,   -- kwh_price, target_margin, min_margin, rounding, hourly_rate, include_fixed_costs
  setting_value VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE channels (
  id              TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code            VARCHAR(20) NOT NULL UNIQUE,  -- etsy, instagram, facebook, in_person (+ shop na v3)
  name            VARCHAR(60) NOT NULL,
  transaction_fee DECIMAL(5,2) NOT NULL DEFAULT 0,   -- %
  processing_fee  DECIMAL(5,2) NOT NULL DEFAULT 0,   -- %
  flat_fee        DECIMAL(10,2) NOT NULL DEFAULT 0,  -- € por venda
  listing_fee     DECIMAL(10,2) NOT NULL DEFAULT 0,  -- € por artigo vendido
  is_automatic    BOOLEAN NOT NULL DEFAULT FALSE     -- TRUE = encomendas entram sozinhas (Etsy)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categories (
  id         SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(60) NOT NULL UNIQUE,          -- Secretaria, Chaveiros, Flexi, Packs…
  color      CHAR(7) NOT NULL DEFAULT '#A1A1AA',   -- cor da etiqueta na app
  sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 0  -- ordem na lista (arrastar para ordenar)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Materiais ─────────────

CREATE TABLE filaments (
  id             SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  material       VARCHAR(20) NOT NULL,            -- PLA, PLA Silk, PETG, TPU…
  brand          VARCHAR(60),
  color_name     VARCHAR(60) NOT NULL,
  color_hex      CHAR(7),
  spool_weight_g INT UNSIGNED NOT NULL DEFAULT 1000,
  list_price     DECIMAL(10,2) NOT NULL,          -- preco de tabela, so para referencia
  paid_price     DECIMAL(10,2) NOT NULL,          -- o que foi mesmo pago, com desconto
  shipping_cost  DECIMAL(10,2) NOT NULL DEFAULT 0,   -- portes totais dessa compra
  spools_in_order TINYINT UNSIGNED NOT NULL DEFAULT 1, -- portes repartidos por estes rolos
  -- €/kg = (paid_price + shipping_cost / spools_in_order) / spool_weight_g × 1000  (calculado pela API)
  min_stock_g    INT UNSIGNED NOT NULL DEFAULT 250,
  is_active      BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE components (
  id             SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(100) NOT NULL,                      -- saco zip, caixa, argola, iman…
  kind           ENUM('component','packaging') NOT NULL,
  size_label     VARCHAR(40),                                -- 8 × 12 cm, S, A5…
  weight_g       SMALLINT UNSIGNED NOT NULL DEFAULT 0,       -- conta para o escalao dos portes
  pack_price     DECIMAL(10,2) NOT NULL,
  units_per_pack INT UNSIGNED NOT NULL DEFAULT 1,
  -- custo/unidade = pack_price / units_per_pack  (calculado pela API)
  stock_qty      INT NOT NULL DEFAULT 0,
  min_stock_qty  INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE printers (
  id                TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(60) NOT NULL,       -- Bambu Lab A1
  power_w           SMALLINT UNSIGNED NOT NULL, -- consumo medio a imprimir
  purchase_price    DECIMAL(10,2) NOT NULL,
  lifespan_hours    INT UNSIGNED NOT NULL,
  yearly_maintenance DECIMAL(10,2) NOT NULL DEFAULT 0,
  yearly_hours      INT UNSIGNED NOT NULL DEFAULT 1000,
  is_default        BOOLEAN NOT NULL DEFAULT FALSE
  -- €/h = power_w/1000 × kwh_price + purchase_price/lifespan_hours + yearly_maintenance/yearly_hours
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Envios ─────────────

CREATE TABLE carriers (
  id   TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(60) NOT NULL                     -- CTT · Correio Registado, CTT Expresso…
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE shipping_zones (
  id        TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name      VARCHAR(60) NOT NULL,               -- Portugal Continental, Europa · Zona 1…
  countries VARCHAR(500)                        -- codigos ISO, ex.: 'ES,FR,DE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE shipping_rates (
  carrier_id   TINYINT UNSIGNED NOT NULL,
  zone_id      TINYINT UNSIGNED NOT NULL,
  max_weight_g INT UNSIGNED NOT NULL,           -- escalao: ate 20 g, 100 g, 500 g…
  price        DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (carrier_id, zone_id, max_weight_g),
  FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE,
  FOREIGN KEY (zone_id)    REFERENCES shipping_zones(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payment_methods (
  id           TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(40) NOT NULL,            -- MB WAY, Transferencia, Dinheiro
  percent_fee  DECIMAL(5,2) NOT NULL DEFAULT 0,
  flat_fee     DECIMAL(10,2) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fixed_costs (
  id            SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(80) NOT NULL,           -- Alojamento cPanel, Etsy Plus…
  monthly_value DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Catalogo ─────────────

CREATE TABLE products (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(120) NOT NULL,
  base_sku        VARCHAR(40) NOT NULL UNIQUE,
  description     TEXT,
  category_id     SMALLINT UNSIGNED,
  status          ENUM('active','draft','archived') NOT NULL DEFAULT 'draft',
  is_customizable BOOLEAN NOT NULL DEFAULT FALSE,
  is_pack         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_photos (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id INT UNSIGNED NOT NULL,
  url        VARCHAR(255) NOT NULL,
  sort_order TINYINT UNSIGNED NOT NULL DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE variants (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id      INT UNSIGNED NOT NULL,
  name            VARCHAR(80) NOT NULL,         -- Preto mate, Laranja…
  sku             VARCHAR(50) NOT NULL UNIQUE,
  sale_price      DECIMAL(10,2) NOT NULL,
  print_time_min  INT UNSIGNED NOT NULL DEFAULT 0,
  plate_count     TINYINT UNSIGNED NOT NULL DEFAULT 1,
  weight_g        SMALLINT UNSIGNED NOT NULL DEFAULT 0, -- peso da peca, para os portes
  printer_id      TINYINT UNSIGNED,                     -- NULL = impressora principal
  model_file      VARCHAR(255),                         -- caminho do .3mf
  etsy_listing_id VARCHAR(30),                          -- liga a encomenda Etsy a esta variante
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (printer_id) REFERENCES printers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE variant_filaments (
  variant_id  INT UNSIGNED NOT NULL,
  filament_id SMALLINT UNSIGNED NOT NULL,
  grams       INT UNSIGNED NOT NULL,
  PRIMARY KEY (variant_id, filament_id),
  FOREIGN KEY (variant_id)  REFERENCES variants(id) ON DELETE CASCADE,
  FOREIGN KEY (filament_id) REFERENCES filaments(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE variant_components (
  variant_id   INT UNSIGNED NOT NULL,
  component_id SMALLINT UNSIGNED NOT NULL,
  quantity     SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (variant_id, component_id),
  FOREIGN KEY (variant_id)   REFERENCES variants(id) ON DELETE CASCADE,
  FOREIGN KEY (component_id) REFERENCES components(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pack_items (                       -- v2
  pack_variant_id INT UNSIGNED NOT NULL,
  variant_id      INT UNSIGNED NOT NULL,
  quantity        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (pack_variant_id, variant_id),
  FOREIGN KEY (pack_variant_id) REFERENCES variants(id) ON DELETE CASCADE,
  FOREIGN KEY (variant_id)      REFERENCES variants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Clientes ─────────────

CREATE TABLE customers (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  email      VARCHAR(190),
  phone      VARCHAR(30),
  instagram  VARCHAR(60),
  notes      TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE addresses (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  line1       VARCHAR(150) NOT NULL,
  line2       VARCHAR(150),
  postal_code VARCHAR(12) NOT NULL,
  city        VARCHAR(80) NOT NULL,
  country     CHAR(2) NOT NULL DEFAULT 'PT',
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Encomendas ─────────────

CREATE TABLE orders (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_number     INT UNSIGNED NOT NULL UNIQUE,   -- #1042
  channel_id       TINYINT UNSIGNED NOT NULL,
  external_ref     VARCHAR(40),                    -- n.o da encomenda na Etsy
  customer_id      INT UNSIGNED,                   -- NULL = encomenda "de boca", sem ficha
  customer_name    VARCHAR(120) NOT NULL,          -- nome ou referencia ("D. Lurdes — vizinha")
  customer_contact VARCHAR(60),                    -- telemovel ou @instagram, opcional
  address_id       INT UNSIGNED,
  status           ENUM('pending','in_production','ready','shipped','delivered','cancelled')
                   NOT NULL DEFAULT 'pending',
  payment_status   ENUM('unpaid','paid','refunded') NOT NULL DEFAULT 'unpaid',
  payment_method   VARCHAR(30),                    -- Etsy Payments, MB WAY, dinheiro…
  delivery_method  ENUM('carrier','hand','pickup','other') NOT NULL DEFAULT 'carrier',
  carrier_name     VARCHAR(40),
  tracking_code    VARCHAR(40),
  shipping_charged DECIMAL(10,2) NOT NULL DEFAULT 0,  -- o que o cliente pagou
  shipping_paid    DECIMAL(10,2) NOT NULL DEFAULT 0,  -- o que custou mesmo
  ship_by_date     DATE,
  notes            TEXT,
  created_manually BOOLEAN NOT NULL DEFAULT FALSE,
  created_by       INT UNSIGNED,                   -- NULL = entrou pela sincronizacao
  is_seen          BOOLEAN NOT NULL DEFAULT FALSE, -- "2 novas por ver"
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_source (channel_id, external_ref), -- a sincronizacao nunca cria duplicados
  INDEX (status),
  INDEX (created_at),
  FOREIGN KEY (channel_id)  REFERENCES channels(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  FOREIGN KEY (address_id)  REFERENCES addresses(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by)  REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_lines (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id      INT UNSIGNED NOT NULL,
  variant_id    INT UNSIGNED NOT NULL,
  quantity      SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  unit_price    DECIMAL(10,2) NOT NULL,
  discount      DECIMAL(10,2) NOT NULL DEFAULT 0,
  customization VARCHAR(255),
  unit_cost     DECIMAL(10,2) NOT NULL,            -- fotografia do custo no momento da venda
  channel_fee   DECIMAL(10,2) NOT NULL DEFAULT 0,  -- fotografia da taxa desta linha
  FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (variant_id) REFERENCES variants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_events (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id    INT UNSIGNED NOT NULL,
  description VARCHAR(150) NOT NULL,   -- "Pagamento confirmado", "Enviada por CTT"…
  new_status  VARCHAR(20),
  source      ENUM('system','user','sync') NOT NULL,
  user_id     INT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id)  REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sync_runs (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  channel_id   TINYINT UNSIGNED NOT NULL,
  started_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_at  DATETIME,
  status       ENUM('running','ok','error') NOT NULL DEFAULT 'running',
  created_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  updated_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  error_message TEXT,
  FOREIGN KEY (channel_id) REFERENCES channels(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Producao ─────────────

CREATE TABLE print_jobs (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_line_id   INT UNSIGNED,            -- NULL = tarefa manual (stock, prototipo)
  variant_id      INT UNSIGNED NOT NULL,
  quantity        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  status          ENUM('queued','printing','post_processing','done')
                  NOT NULL DEFAULT 'queued',
  estimated_min   INT UNSIGNED NOT NULL,
  current_plate   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  started_at      DATETIME,                -- da o progresso na v1, sem ligacao a impressora
  finished_at     DATETIME,
  board_position  INT NOT NULL DEFAULT 0,  -- posicao no quadro de producao
  notes           VARCHAR(255),
  INDEX (status),
  FOREIGN KEY (order_line_id) REFERENCES order_lines(id) ON DELETE CASCADE,
  FOREIGN KEY (variant_id)    REFERENCES variants(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE print_failures (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  print_job_id  INT UNSIGNED NOT NULL,
  filament_id   SMALLINT UNSIGNED NOT NULL,
  wasted_grams  INT UNSIGNED NOT NULL,
  wasted_min    INT UNSIGNED NOT NULL,
  reason        VARCHAR(150),
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (print_job_id) REFERENCES print_jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (filament_id)  REFERENCES filaments(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────────── Stock (v2, ja preparado) ─────────────

CREATE TABLE spools (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  filament_id      SMALLINT UNSIGNED NOT NULL,
  initial_weight_g INT UNSIGNED NOT NULL DEFAULT 1000,
  remaining_g      INT NOT NULL,
  status           ENUM('sealed','in_use','empty') NOT NULL DEFAULT 'sealed',
  purchased_on     DATE,
  FOREIGN KEY (filament_id) REFERENCES filaments(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE stock_movements (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  spool_id     INT UNSIGNED NOT NULL,
  grams        INT NOT NULL,                        -- negativo = consumo, positivo = acerto
  movement_type ENUM('production','failure','adjustment') NOT NULL,
  print_job_id INT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (spool_id)     REFERENCES spools(id) ON DELETE CASCADE,
  FOREIGN KEY (print_job_id) REFERENCES print_jobs(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
