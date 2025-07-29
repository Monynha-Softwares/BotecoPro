CREATE OR REPLACE VIEW vw_producao_ingredientes AS
SELECT pi.*, p.nome AS produto_nome
FROM producao_ingredientes pi
JOIN produtos p ON pi.id_produto = p.id_produto;
