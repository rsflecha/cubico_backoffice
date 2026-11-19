-- 007 — Cores por peça.
--
-- A árvore de Natal de família sai sempre a 2 cores, e é o cliente que as escolhe.
-- 1 = uma cor (todos os produtos até hoje); 2 = na encomenda pede-se "Cor 1" e "Cor 2".
--
-- Só junta uma coluna, a 1 em todos os produtos; não muda nem apaga nada do que existe.

ALTER TABLE products
  ADD COLUMN colors_per_piece TINYINT UNSIGNED NOT NULL DEFAULT 1 AFTER is_pack;
