-- 009 — Produtos a 2 cores: quantas gramas leva a Cor 2.
--
-- A receita (variant_filaments) continua a guardar o TOTAL de gramas, e o custo faz-se como
-- antes (o total ao preço da cor mais cara). Esta coluna só diz quanto desse total é da Cor 2;
-- a Cor 1 é o resto. 0 = produto de 1 cor.
-- Não apaga nada.

ALTER TABLE variants ADD COLUMN grams_color_2 SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER weight_g;
