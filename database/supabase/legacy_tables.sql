-- Legacy tables used by the Flutter app

CREATE TABLE IF NOT EXISTS produtos (
    id_produto SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    unidade_base TEXT NOT NULL,
    tipo_produto TEXT NOT NULL,
    controla_estoque BOOLEAN DEFAULT TRUE,
    id_categoria INTEGER REFERENCES category(category_id),
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS produtos_venda (
    id_venda SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES produtos(id_produto) ON DELETE CASCADE,
    descricao_venda TEXT,
    quantidade_base NUMERIC(10,2),
    preco_venda NUMERIC(10,2),
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_venda INTEGER REFERENCES vendas(id_venda),
    id_mesa INTEGER REFERENCES mesas(id_mesa),
    nome_funcionario TEXT,
    data_pedido TIMESTAMP,
    status_pedido TEXT,
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS pedido_itens (
    id_pedido_item SERIAL PRIMARY KEY,
    id_pedido INTEGER REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    tipo_item TEXT,
    id_item INTEGER,
    quantidade NUMERIC(10,2),
    preco_unitario NUMERIC(10,2),
    observacao TEXT,
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS receita_ingredientes (
    id SERIAL PRIMARY KEY,
    id_receita INTEGER REFERENCES receitas(id_receita) ON DELETE CASCADE,
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade_utilizada NUMERIC(10,2),
    user_id UUID REFERENCES auth.users(id)
);
