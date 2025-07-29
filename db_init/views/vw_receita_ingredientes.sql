CREATE OR REPLACE VIEW vw_receita_ingredientes AS
SELECT ri.*, p.nome AS produto_nome
FROM receita_ingredientes ri
JOIN produtos p ON ri.id_produto = p.id_produto;
