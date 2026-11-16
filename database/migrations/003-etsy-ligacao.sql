-- 003 — Ligação à Etsy (OAuth 2 com PKCE).
--
-- A loja liga-se uma vez, nas Definições: o administrador autoriza na Etsy e a Etsy devolve
-- dois tokens. O de acesso dura 1 hora; o de renovação, 90 dias (renova-se a cada sincronização).
-- Os tokens ficam CIFRADOS (AES-256-GCM, chave tirada do JWT_SECRET): quem vir só a base de
-- dados não consegue usá-los.
--
-- A chave da app (keystring e shared secret) NÃO está aqui: vive no .env.

-- Só há uma linha (id = 1): a loja ligada.
CREATE TABLE etsy_connection (
  id                 TINYINT UNSIGNED PRIMARY KEY,
  etsy_user_id       BIGINT UNSIGNED NOT NULL,
  shop_id            BIGINT UNSIGNED NOT NULL,
  shop_name          VARCHAR(100) NOT NULL,
  access_token       TEXT NOT NULL,       -- cifrado
  refresh_token      TEXT NOT NULL,       -- cifrado
  access_expires_at  DATETIME NOT NULL,
  refresh_expires_at DATETIME NOT NULL,   -- depois disto é preciso ligar outra vez
  connected_by       INT UNSIGNED,
  connected_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (connected_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Os pedidos de ligação a meio: o "state" (contra CSRF) e o segredo do PKCE.
-- Cada um só serve uma vez e só durante 10 minutos.
CREATE TABLE etsy_oauth_states (
  state         CHAR(43) PRIMARY KEY,
  code_verifier VARCHAR(128) NOT NULL,
  user_id       INT UNSIGNED NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
