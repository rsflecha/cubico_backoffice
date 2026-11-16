-- 005 — Códigos postais de Portugal (base dos CTT), para a localidade aparecer
-- sozinha na morada do cliente.
--
-- Só cria a tabela, vazia. Os dados (cerca de 197 mil códigos) não vão para o Git
-- (o repositório é público e a base é dos CTT): geram-se com
--   php -d extension=pdo_sqlite api/bin/postal-codes.php <cp.db> database/postal-codes.sql
-- e importam-se à parte (phpMyAdmin → Importar, ou o mesmo script com --load no PC).

CREATE TABLE postal_codes (
  code         CHAR(8)     NOT NULL PRIMARY KEY,  -- "3700-008"
  locality     VARCHAR(80) NOT NULL,              -- a localidade postal (vai para a morada)
  municipality VARCHAR(80) NOT NULL,              -- concelho
  district     VARCHAR(80) NOT NULL               -- distrito (ou ilha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
