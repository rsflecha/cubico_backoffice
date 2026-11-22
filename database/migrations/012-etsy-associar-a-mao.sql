-- 012 — Associar à mão um artigo da Etsy a uma variante.
--
-- Uma venda da Etsy só entra se cada artigo ligar a uma variante: pelo SKU, ou, sem SKU,
-- pela listagem. Quando nenhum dos dois serve (SKU diferente na Etsy, ou sem SKU num anúncio
-- com várias variações), o administrador escolhe a variante à mão no "Conferir os SKU".
--
-- etsy_product_id é o produto do anúncio na Etsy (uma combinação de variações, ex.: "Piloto: Hamilton").
-- É o que vem em cada artigo vendido (transaction.product_id), por isso serve para ligar.
-- Se o anúncio for editado na Etsy e o produto mudar de número, volta a aparecer por ligar.
--
-- Só cria uma tabela nova; não mexe nas que existem.

CREATE TABLE etsy_links (
  etsy_product_id VARCHAR(20) CHARACTER SET ascii NOT NULL PRIMARY KEY,
  listing_id      VARCHAR(20) CHARACTER SET ascii NOT NULL,
  variant_id      INT UNSIGNED NOT NULL,
  user_id         INT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (variant_id) REFERENCES variants(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
