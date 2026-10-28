-- ============================================================
-- CubicoDesign3D Backoffice — dados de arranque
-- Importar DEPOIS do schema.sql, uma vez só.
--
-- Tudo o que esta aqui pode ser mudado depois no ecra Definicoes.
-- Os valores marcados com (confirmar) sao os que ainda nao vieram
-- de uma fonte oficial do Rui.
-- ============================================================

SET NAMES utf8mb4;   -- o servidor tem latin1 por omissao; sem isto os acentos entram trocados

-- ───────────── Definicoes ─────────────
-- Tabela chave/valor: estas chaves sao as unicas strings que o codigo
-- escreve a mao, por isso vao dar constantes no Dart.
INSERT INTO settings (setting_key, setting_value) VALUES
  ('kwh_price',          '0.21'),   -- contrato do Rui, com IVA
  ('target_margin',      '60'),     -- % de margem alvo para o preco sugerido (confirmar)
  ('min_margin',         '35'),     -- % abaixo da qual a app avisa (confirmar)
  ('rounding',           '0.50'),   -- precos sugeridos arredondados a 0,50 € (confirmar)
  ('hourly_rate',        '0'),      -- valor da hora do Rui; 0 = nao entra no custo
  ('include_fixed_costs','0');      -- 0 = custos fixos nao sao repartidos pelas encomendas

-- ───────────── Canais ─────────────
-- Taxas da Etsy: confirmar no painel da conta, mudam de tempos a tempos.
-- Os outros canais nao tem taxa nenhuma.
INSERT INTO channels (code, name, transaction_fee, processing_fee, flat_fee, listing_fee, is_automatic) VALUES
  ('etsy',      'Etsy',         6.50, 4.00, 0.30, 0.20, TRUE),   -- (confirmar) 6,5% + 4% + 0,30 € + 0,20 € de listagem
  ('instagram', 'Instagram',    0.00, 0.00, 0.00, 0.00, FALSE),
  ('facebook',  'Facebook',     0.00, 0.00, 0.00, 0.00, FALSE),
  ('in_person', 'Pessoalmente', 0.00, 0.00, 0.00, 0.00, FALSE);

-- ───────────── Categorias ─────────────
INSERT INTO categories (name, color, sort_order) VALUES
  ('Secretária', '#C2410C', 1),
  ('Chaveiros',  '#0D7698', 2),
  ('Flexi',      '#7C3AED', 3),
  ('Packs',      '#15803D', 4);

-- ───────────── Impressora ─────────────
-- custo/h = 95/1000 × 0,21 + 381,40/5000 + 40/1500 ≈ 0,123 €/h
-- (vida util e manutencao sao estimativas; o preco de compra e real)
INSERT INTO printers (name, power_w, purchase_price, lifespan_hours, yearly_maintenance, yearly_hours, is_default) VALUES
  ('Bambu Lab A1', 95, 381.40, 5000, 40.00, 1500, TRUE);

-- ───────────── Metodos de pagamento ─────────────
INSERT INTO payment_methods (name, percent_fee, flat_fee) VALUES
  ('Etsy Payments', 0.00, 0.00),   -- a taxa ja esta no canal, nao contar duas vezes
  ('MB WAY',        0.00, 0.00),
  ('Transferência', 0.00, 0.00),
  ('Dinheiro',      0.00, 0.00);

-- ───────────── Envios ─────────────
INSERT INTO carriers (name) VALUES
  ('CTT · Correio Registado'),
  ('CTT Expresso');

INSERT INTO shipping_zones (name, countries) VALUES
  ('Portugal Continental', 'PT'),
  ('Ilhas',                'PT'),
  ('Europa',               'ES,FR,DE,IT,NL,BE,LU,AT,IE,DK,SE,FI,PL,CZ,GR');

-- As tarifas ficam por preencher: dependem dos escaloes de peso do contrato
-- dos CTT. Sem elas, os portes entram a mao em cada encomenda.
-- Exemplo do formato, quando houver os precos:
-- INSERT INTO shipping_rates (carrier_id, zone_id, max_weight_g, price) VALUES (1, 1, 20, 2.95);

-- ───────────── Utilizador administrador ─────────────
-- Fica por criar de proposito: a password tem de ser guardada como hash
-- bcrypt, gerado pelo PHP (password_hash). Inserir aqui um hash escrito a
-- mao e caminho certo para ninguem conseguir entrar.
-- Criado na fase 3, pelo instalador da API.
