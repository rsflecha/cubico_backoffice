-- 011 — Limite de tentativas de login (contra robôs que experimentam palavras-passe).
--
-- login_attempts: uma linha por cada tentativa FALHADA, guardada durante um dia.
--   key_hash é o sha256 de "email:<email>" ou "ip:<endereço>": não se guarda o email
--   nem o IP em claro, só o suficiente para os contar.
--   A API conta as falhas dos últimos 15 minutos (ver api/src/login_limit.php).
--
-- Só cria uma tabela nova; não mexe nas que existem.

CREATE TABLE login_attempts (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  key_hash   CHAR(64) CHARACTER SET ascii NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX (key_hash, created_at),
  INDEX (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
