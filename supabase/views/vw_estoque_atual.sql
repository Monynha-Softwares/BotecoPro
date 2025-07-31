CREATE OR REPLACE VIEW vw_estoque_atual AS
SELECT e.*, p.nome AS produto_nome
FROM estoque e
JOIN produtos p ON e.id_produto = p.id_produto;
