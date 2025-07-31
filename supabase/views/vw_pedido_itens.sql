CREATE OR REPLACE VIEW vw_pedido_itens AS
SELECT pi.*, p.nome AS produto_nome
FROM pedido_itens pi
LEFT JOIN produtos p ON pi.id_item = p.id_produto;
