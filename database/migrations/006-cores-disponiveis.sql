-- 006 — Cores disponíveis de cada produto.
--
-- A bola pode sair em Gold, White ou Red: são os filamentos marcados aqui.
-- Na encomenda, o menu "Cor" de cada artigo mostra só estas (mais a cor da receita).
-- Sem nenhuma marcada, o menu mostra todos os filamentos ativos (como antes).
--
-- Só junta uma tabela nova; não mexe nos dados que já existem.
-- Apagar um produto ou um filamento tira-o daqui sozinho (ON DELETE CASCADE).

CREATE TABLE product_colors (
  product_id  INT UNSIGNED      NOT NULL,
  filament_id SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, filament_id),
  FOREIGN KEY (product_id)  REFERENCES products(id)  ON DELETE CASCADE,
  FOREIGN KEY (filament_id) REFERENCES filaments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
