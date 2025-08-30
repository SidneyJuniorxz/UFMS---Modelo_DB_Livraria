-- Database: livraria

-- DROP DATABASE IF EXISTS livraria;

CREATE DATABASE livraria
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Portuguese_Brazil.1252'
    LC_CTYPE = 'Portuguese_Brazil.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

	CREATE TABLE clientes (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome       TEXT NOT NULL,
  email      TEXT NOT NULL UNIQUE,
  criado_em  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE produtos (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  titulo     TEXT NOT NULL,
  autor      TEXT,
  preco      NUMERIC(10,2) NOT NULL CHECK (preco >= 0),
  estoque    INTEGER NOT NULL DEFAULT 0 CHECK (estoque >= 0),
  ativo      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE pedidos (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cliente_id   BIGINT NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  data_pedido  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  status       TEXT NOT NULL DEFAULT 'ABERTO' CHECK (status IN ('ABERTO','PAGO','CANCELADO'))
);

CREATE TABLE itens_pedido (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  pedido_id      BIGINT NOT NULL REFERENCES pedidos(id)  ON DELETE CASCADE  ON UPDATE CASCADE,
  produto_id     BIGINT NOT NULL REFERENCES produtos(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantidade     INTEGER NOT NULL CHECK (quantidade > 0),
  preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario >= 0)
);

-- Índices úteis (melhoram JOINs/consultas)
CREATE INDEX idx_pedidos_cliente   ON pedidos(cliente_id);
CREATE INDEX idx_itens_pedido_pid  ON itens_pedido(pedido_id);
CREATE INDEX idx_itens_pedido_prid ON itens_pedido(produto_id);

INSERT INTO clientes (nome, email) VALUES
  ('Ana Souza',      'ana@example.com'),
  ('Bruno Lima',     'bruno@example.com'),
  ('Carla Ribeiro',  'carla@example.com');

  select * from clientes
  where nome = 'Ana Souza'

  INSERT INTO produtos (titulo, autor, preco, estoque, ativo) VALUES
  ('Clean Code',              'Robert C. Martin', 180.00, 10, TRUE),
  ('Domain-Driven Design',    'Eric Evans',       220.00,  5, TRUE),
  ('Introdução ao SQL',       'Vários',            95.50, 20, TRUE);

-- pedidos
INSERT INTO pedidos (cliente_id, status) VALUES
  (1, 'ABERTO'),
  (2, 'ABERTO'),
  (3, 'PAGO');

-- itens_pedido
-- Pedido 1 (Ana): 1x Clean Code, 2x Intro SQL
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
  (1, 1, 1, 180.00),
  (1, 3, 2, 95.50);

-- Pedido 2 (Bruno): 1x DDD
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
  (2, 2, 1, 220.00);

-- Pedido 3 (Carla): 1x Clean Code, 1x DDD (pago)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
  (3, 1, 1, 180.00),
  (3, 2, 1, 220.00);

CREATE VIEW vw_pedido_totais AS
SELECT
  p.id             AS pedido_id,
  p.cliente_id,
  p.status,
  p.data_pedido,
  ROUND(SUM(i.quantidade * i.preco_unitario)::NUMERIC, 2) AS total
FROM pedidos p
JOIN itens_pedido i ON i.pedido_id = p.id
GROUP BY p.id, p.cliente_id, p.status, p.data_pedido;

COMMIT;

SELECT * FROM produtos;


SELECT p.id AS pedido, pr.titulo, i.quantidade, i.preco_unitario
FROM itens_pedido i
JOIN pedidos p  ON p.id = i.pedido_id
JOIN produtos pr ON pr.id = i.produto_id
ORDER BY p.id;


select * from vw_pedido_totais