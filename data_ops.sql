-- Inserções adicionais
INSERT INTO clientes (nome, email) VALUES ('Diego Alves','diego@example.com');
INSERT INTO produtos (titulo, autor, preco, estoque) VALUES ('SQL Avançado','Vários', 150.00, 12);

-- Atualizações
-- 1) Corrigir estoque
UPDATE produtos SET estoque = estoque + 5 WHERE titulo = 'Clean Code';

-- 2) Marcar produto como inativo
UPDATE produtos SET ativo = FALSE WHERE titulo = 'Domain-Driven Design';

-- 3) Atualizar status do pedido
UPDATE pedidos SET status = 'PAGO' WHERE id = 2;

-- Remoções (com cuidado e critério)
-- 1) Remover um item específico do pedido 1
DELETE FROM itens_pedido
WHERE pedido_id = 1 AND produto_id = 3 AND quantidade = 2;

-- 2) Remover cliente sem pedidos
DELETE FROM clientes c
WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id)
  AND c.email = 'diego@example.com';

-- Consultas (demonstração)
-- A) Pedidos com totais
SELECT * FROM vw_pedido_totais ORDER BY pedido_id;

-- B) Detalhar itens de um pedido
SELECT p.id AS pedido, c.nome AS cliente, pr.titulo, i.quantidade, i.preco_unitario,
       (i.quantidade * i.preco_unitario) AS subtotal
FROM itens_pedido i
JOIN pedidos  p  ON p.id = i.pedido_id
JOIN clientes c  ON c.id = p.cliente_id
JOIN produtos pr ON pr.id = i.produto_id
WHERE p.id = 1
ORDER BY pr.titulo;

-- C) Top produtos por faturamento
SELECT pr.titulo,
       SUM(i.quantidade) AS qtd,
       ROUND(SUM(i.quantidade * i.preco_unitario)::NUMERIC, 2) AS faturado
FROM itens_pedido i
JOIN produtos pr ON pr.id = i.produto_id
GROUP BY pr.id, pr.titulo
ORDER BY faturado DESC;

-- D) Pedidos por status
SELECT status, COUNT(*) AS qtd
FROM pedidos
GROUP BY status
ORDER BY status;
