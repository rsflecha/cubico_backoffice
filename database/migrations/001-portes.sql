-- ============================================================
-- Migração 001 — portes por zona (decisão de 2026-11-06)
-- Para bases de dados criadas ANTES desta data (a do teu PC e a do cPanel).
-- Uma base de dados nova, criada com o schema.sql e o seed.sql atuais, já está assim.
-- Correr UMA vez, com a base de dados escolhida.
-- ============================================================

SET NAMES utf8mb4;

-- 1. os escalões passam a ter um id próprio (a app muda cada escalão pelo id)
DROP TABLE IF EXISTS shipping_rates;

-- 2. as zonas e as transportadoras da decisão: Registado em Portugal, Azul Internacional lá fora
DELETE FROM shipping_zones;
INSERT INTO shipping_zones (id, name, countries) VALUES
  (1, 'Portugal',       'PT'),
  (2, 'Europa',         'ES,FR,DE,IT,NL,BE,LU,AT,IE,DK,SE,FI,PL,CZ,GR,GB,CH,NO'),
  (3, 'Estados Unidos', 'US'),
  (4, 'Resto do mundo', NULL);

UPDATE carriers SET name = 'CTT · Correio Registado'          WHERE id = 1;
UPDATE carriers SET name = 'CTT · Correio Azul Internacional' WHERE id = 2;

CREATE TABLE shipping_rates (
  id           SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  carrier_id   TINYINT UNSIGNED NOT NULL,
  zone_id      TINYINT UNSIGNED NOT NULL,
  max_weight_g INT UNSIGNED NOT NULL,           -- escalao: ate 100 g, 500 g…
  price        DECIMAL(10,2) NOT NULL,
  UNIQUE KEY uq_rate (carrier_id, zone_id, max_weight_g),
  FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE,
  FOREIGN KEY (zone_id)    REFERENCES shipping_zones(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. os preços base dos CTT de 2026 (pacote postal)
INSERT INTO shipping_rates (carrier_id, zone_id, max_weight_g, price) VALUES
  (1, 1,  100,  4.60), (1, 1,  500,  5.40), (1, 1, 2000,  8.93),
  (2, 2,  100,  5.80), (2, 2,  250,  7.55), (2, 2,  500,  9.80), (2, 2, 1000, 13.20), (2, 2, 2000, 21.20),
  (2, 3,  100,  6.95), (2, 3,  250, 10.10), (2, 3,  500, 15.70), (2, 3, 1000, 26.75), (2, 3, 2000, 39.25),
  (2, 4,  100,  6.55), (2, 4,  250,  9.30), (2, 4,  500, 14.15), (2, 4, 1000, 23.95), (2, 4, 2000, 36.15);
