-- 015 — Stock de filamento: o livro de movimentos.
--
-- O stock de um filamento é a soma dos seus movimentos (compras, consumos, falhas, acertos,
-- anulações). Os movimentos nunca se editam nem se apagam: um engano corrige-se com um movimento novo.
-- Também entra a tara de cada filamento (filaments.empty_spool_g, o peso do carretel vazio, em gramas;
-- 0 = por saber), precisa para o acerto por pesagem.
-- As tabelas antigas spools e stock_movements (stock por rolo, preparadas e nunca usadas) saem.
--
-- Antes de correr no servidor: confirmar que `spools` e `stock_movements` estão vazias
-- (SELECT COUNT(*) FROM spools; SELECT COUNT(*) FROM stock_movements; têm de dar 0 e 0).

ALTER TABLE filaments ADD COLUMN empty_spool_g SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER spool_weight_g;

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

-- A que tem a chave estrangeira (stock_movements → spools) sai primeiro.
DROP TABLE stock_movements;
DROP TABLE spools;
