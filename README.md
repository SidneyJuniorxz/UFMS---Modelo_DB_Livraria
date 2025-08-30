# Livraria – Banco de Dados (PostgreSQL)

Modelo simples com **clientes**, **produtos**, **pedidos** e **itens_pedido**, incluindo dados de exemplo e uma `VIEW` de totais por pedido.

## Como executar

```bash
psql -U postgres -c "CREATE DATABASE livraria;"
psql -U postgres -d livraria -f schema_db.sql


Depois Consulte
psql -U postgres -d livraria -c "SELECT * FROM vw_pedido_totais ORDER BY pedido_id;"
