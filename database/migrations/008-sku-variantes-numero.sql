-- 008 — SKU das variantes por número, em vez do nome.
--
-- Antes: CD3-SUP-01-HAMILTON (o nome da variante no SKU).
-- Agora: CD3-SUP-01-01, CD3-SUP-01-02… pela ordem em que as variantes foram criadas (id).
-- A variante sem nome (modelo único) fica com o SKU do produto: CD3-SUP-01.
--
-- ATENÇÃO: a Etsy liga as encomendas pelo SKU. Depois de correr isto, os anúncios da Etsy
-- têm de passar a ter os SKU novos (ver "Anúncios da Etsy" na app), senão as encomendas não entram.
--
-- Muda só a coluna sku das variantes com nome; não apaga nada.
-- Precisa de ROW_NUMBER() (MySQL 8 ou MariaDB 10.2 em diante).

UPDATE variants v
JOIN products p ON p.id = v.product_id
JOIN (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY id) AS n
  FROM variants
  WHERE TRIM(name) <> ''
) r ON r.id = v.id
SET v.sku = CONCAT(p.base_sku, '-', LPAD(r.n, 2, '0'));
