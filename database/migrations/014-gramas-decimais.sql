-- 014 — Gramas com 2 casas decimais.
--
-- Até aqui, 86,4 g gravava-se como 86 g, sem aviso: as colunas eram inteiras. O custo e,
-- a seguir, o stock de filamento descontam estas gramas, por isso o meio grama perdido em
-- cada peça somava-se. Passam a DECIMAL(8,2): até 999 999,99 g, com 2 casas.
-- variants.weight_g (o peso para os portes) fica inteiro: os escalões dos CTT são em gramas redondos.
--
-- Os valores que já existem ficam iguais (120 passa a 120.00). Não apaga nada.

ALTER TABLE variant_filaments MODIFY COLUMN grams DECIMAL(8,2) NOT NULL;
ALTER TABLE variants MODIFY COLUMN grams_color_2 DECIMAL(8,2) NOT NULL DEFAULT 0;
ALTER TABLE print_failures MODIFY COLUMN wasted_grams DECIMAL(8,2) NOT NULL;
