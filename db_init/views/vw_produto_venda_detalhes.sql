CREATE OR REPLACE VIEW vw_produto_venda_detalhes AS
SELECT pv.*, p.nome AS produto_nome
FROM produtos_venda pv
JOIN produtos p ON pv.id_produto = p.id_produto;
