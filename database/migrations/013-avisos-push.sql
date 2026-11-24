-- 013 — Avisos de encomendas novas (Web Push).
--
-- Cada aparelho que ligou os avisos (o iPhone do Rui, o iPad…) fica aqui: o endereço que o
-- serviço de push do browser lhe deu (endpoint) e as duas chaves para cifrar o aviso.
-- O endpoint é longo demais para um índice único, por isso o índice é no seu SHA-256.
-- Só administradores recebem avisos (a API confirma).
--
-- Só cria uma tabela nova; não mexe nas que existem.

CREATE TABLE push_subscriptions (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       INT UNSIGNED NOT NULL,
  endpoint      TEXT NOT NULL,
  endpoint_hash CHAR(64) CHARACTER SET ascii NOT NULL UNIQUE,
  p256dh        VARCHAR(255) CHARACTER SET ascii NOT NULL,
  auth          VARCHAR(64) CHARACTER SET ascii NOT NULL,
  user_agent    VARCHAR(255),
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_used_at  DATETIME,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
