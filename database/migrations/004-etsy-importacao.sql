-- 004 — Importação das encomendas da Etsy.
--
-- 1. Os clientes da Etsy reconhecem-se pelo id de comprador da Etsy (o email quase nunca vem).
-- 2. Cada sincronização guarda as notas: as encomendas que ficaram "por associar"
--    (um SKU que não existe no backoffice) e porquê.

ALTER TABLE customers
  ADD COLUMN etsy_buyer_user_id BIGINT UNSIGNED NULL AFTER instagram,
  ADD UNIQUE KEY uq_customer_etsy (etsy_buyer_user_id);

ALTER TABLE sync_runs
  ADD COLUMN skipped_count SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER updated_count,
  ADD COLUMN notes TEXT AFTER error_message;
