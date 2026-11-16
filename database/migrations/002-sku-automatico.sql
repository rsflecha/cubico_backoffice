-- ============================================================
-- Migração 002 — SKU automático e variantes por nome (decisão de 2026-11-16)
--
--   Categoria "Suportes"            → código SUP (3 letras do nome, sem acentos)
--   Produto                         → CD3-SUP-01, CD3-SUP-02… (recomeça em cada categoria)
--   Produto sem categoria           → CD3-GER-01…  (GER fica reservado)
--   Variante "Hamilton" do produto  → CD3-SUP-01-HAMILTON
--   Variante sem nome               → CD3-SUP-01 (o produto não tem variantes)
--
-- Para bases de dados criadas ANTES desta data (a do teu PC e a do cPanel).
-- Uma base de dados nova, criada com o schema.sql e o seed.sql atuais, já está assim.
-- Correr UMA vez, com a base de dados escolhida. Exige MariaDB 10.2+ ou MySQL 8
-- (ROW_NUMBER e REGEXP_REPLACE). O servidor e o PC têm MariaDB 10.6.
--
-- Os produtos são renumerados pela ordem em que foram criados (id).
-- As variantes ficam com o nome que têm; o SKU passa a vir do nome.
-- As encomendas não mudam: as linhas apontam para a variante pelo id, não pelo SKU.
-- ============================================================

SET NAMES utf8mb4;

-- ───── 1. Código das categorias ─────
ALTER TABLE categories ADD COLUMN code VARCHAR(5) NULL AFTER name;

-- o nome em maiúsculas e sem acentos (MariaDB não tem uma função para isto)
CREATE TEMPORARY TABLE tmp_plain (
  kind  CHAR(1) NOT NULL,            -- c = categoria, v = variante
  id    INT UNSIGNED NOT NULL,
  plain VARCHAR(120) NOT NULL,
  PRIMARY KEY (kind, id)
);

INSERT INTO tmp_plain (kind, id, plain)
SELECT 'c', id, UPPER(name) FROM categories
UNION ALL
SELECT 'v', id, UPPER(name) FROM variants;

UPDATE tmp_plain SET plain =
  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
  REPLACE(REPLACE(REPLACE(REPLACE(plain,
    'Á','A'),'À','A'),'Â','A'),'Ã','A'),'Ä','A'),
    'É','E'),'È','E'),'Ê','E'),'Ë','E'),
    'Í','I'),'Ì','I'),'Î','I'),'Ï','I'),
    'Ó','O'),'Ò','O'),'Ô','O'),'Õ','O'),'Ö','O'),
    'Ú','U'),'Ù','U'),'Û','U'),'Ü','U'),
    'Ç','C'),'Ñ','N');

-- as 3 primeiras letras/algarismos; se já houver, a 2.ª fica XX2, a 3.ª XX3…
CREATE TEMPORARY TABLE tmp_cat AS
SELECT id, base,
       ROW_NUMBER() OVER (PARTITION BY base ORDER BY id) AS rn
FROM (
  SELECT id, COALESCE(NULLIF(LEFT(REGEXP_REPLACE(plain, '[^A-Z0-9]', ''), 3), ''), 'CAT') AS base
  FROM tmp_plain WHERE kind = 'c'
) AS b;

UPDATE categories c JOIN tmp_cat t ON t.id = c.id
SET c.code = IF(t.rn = 1 AND t.base <> 'GER',
                t.base,
                CONCAT(LEFT(t.base, 2), t.rn + IF(t.base = 'GER', 1, 0)));

ALTER TABLE categories
  MODIFY code VARCHAR(5) NOT NULL,
  ADD UNIQUE KEY uq_category_code (code);

-- ───── 2. SKU dos produtos ─────
CREATE TEMPORARY TABLE tmp_prod AS
SELECT p.id,
       CONCAT('CD3-', COALESCE(c.code, 'GER'), '-',
              IF(n < 100, LPAD(n, 2, '0'), n)) AS sku
FROM (
  SELECT id, category_id,
         ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY id) AS n
  FROM products
) AS p
LEFT JOIN categories c ON c.id = p.category_id;

-- primeiro um valor provisório, para não chocar com um SKU antigo igual a um novo
UPDATE products SET base_sku = CONCAT('TMP-', id);
UPDATE products p JOIN tmp_prod t ON t.id = p.id SET p.base_sku = t.sku;

-- ───── 3. SKU das variantes ─────
-- "Hamilton" → HAMILTON; "PLA Basic Black" → PLA-BASIC-BLACK (até 30 caracteres)
CREATE TEMPORARY TABLE tmp_var AS
SELECT id, sku, ROW_NUMBER() OVER (PARTITION BY sku ORDER BY id) AS rn
FROM (
  SELECT v.id,
         IF(TRIM(v.name) = '',
            p.base_sku,                      -- variante sem nome = o próprio produto
            CONCAT(p.base_sku, '-',
                   COALESCE(NULLIF(TRIM(BOTH '-' FROM LEFT(
                     TRIM(BOTH '-' FROM REGEXP_REPLACE(t.plain, '[^A-Z0-9]+', '-')), 30)), ''), 'V'))) AS sku
  FROM variants v
  JOIN products p ON p.id = v.product_id
  JOIN tmp_plain t ON t.kind = 'v' AND t.id = v.id
) AS s;

UPDATE variants SET sku = CONCAT('TMP-', id);
-- dois nomes iguais no mesmo produto: o segundo fica -2, o terceiro -3…
UPDATE variants v JOIN tmp_var t ON t.id = v.id
SET v.sku = IF(t.rn = 1, t.sku, CONCAT(t.sku, '-', t.rn));

DROP TEMPORARY TABLE tmp_plain;
DROP TEMPORARY TABLE tmp_cat;
DROP TEMPORARY TABLE tmp_prod;
DROP TEMPORARY TABLE tmp_var;

-- ───── 4. Confirmar ─────
SELECT c.code, c.name FROM categories c ORDER BY c.code;
SELECT p.base_sku, p.name, v.sku, v.name AS variante
FROM products p LEFT JOIN variants v ON v.product_id = p.id
ORDER BY p.base_sku, v.sku;
