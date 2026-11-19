-- 010 — Entrar com Face ID / impressão digital (passkeys, WebAuthn).
--
-- passkeys: as chaves de cada utilizador, uma por aparelho (iPhone, iPad…).
--   Guarda-se só a chave PÚBLICA: a cara ou o dedo nunca saem do aparelho.
--   credential_id é base64url, que distingue maiúsculas de minúsculas: por isso ascii_bin.
-- passkey_challenges: o desafio de cada tentativa (vale 5 minutos e só uma vez).
--   A API não guarda sessões, por isso o desafio fica aqui entre os dois pedidos.
--
-- Só cria tabelas novas; não mexe nas que existem.

CREATE TABLE passkeys (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       INT UNSIGNED NOT NULL,
  credential_id VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
  public_key    TEXT NOT NULL,                     -- PEM
  sign_count    INT UNSIGNED NOT NULL DEFAULT 0,
  rp_id         VARCHAR(100) NOT NULL,             -- o site onde foi criada (app.fazendasubmersa.pt)
  label         VARCHAR(80) NOT NULL,              -- "iPhone", "iPad", "Android"…
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_used_at  DATETIME,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE passkey_challenges (
  id         CHAR(32) CHARACTER SET ascii NOT NULL PRIMARY KEY, -- o número da tentativa (aleatório)
  challenge  CHAR(64) CHARACTER SET ascii NOT NULL,             -- 32 bytes aleatórios, em hex
  purpose    ENUM('register','login') NOT NULL,
  user_id    INT UNSIGNED,                                      -- só no "register"
  rp_id      VARCHAR(100) NOT NULL,
  expires_at DATETIME NOT NULL,
  INDEX (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
