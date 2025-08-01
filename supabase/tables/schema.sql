CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE IF NOT EXISTS auth.users (
    id UUID PRIMARY KEY,
    email TEXT
);

-- Suppliers
CREATE TABLE IF NOT EXISTS fornecedores (
    id_fornecedor SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    telefone TEXT,
    email TEXT,
    contato TEXT,
    detalhes TEXT,
    user_id UUID REFERENCES auth.users(id)
);

-- Categories
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    user_id UUID REFERENCES auth.users(id)
);

-- Products
CREATE TABLE IF NOT EXISTS produtos (
    id_produto SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    unidade_base TEXT NOT NULL,
    tipo_produto TEXT NOT NULL,
    controla_estoque BOOLEAN DEFAULT TRUE,
    id_categoria INTEGER REFERENCES categorias(id_categoria),
    user_id UUID REFERENCES auth.users(id)
);

-- Products available for sale
CREATE TABLE IF NOT EXISTS produtos_venda (
    id_venda SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES produtos(id_produto) ON DELETE CASCADE,
    descricao_venda TEXT,
    quantidade_base NUMERIC(10,2),
    preco_venda NUMERIC(10,2),
    user_id UUID REFERENCES auth.users(id)
);

-- Recipes
CREATE TABLE IF NOT EXISTS receitas (
    id_receita SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    tipo_receita TEXT NOT NULL,
    preco_venda NUMERIC(10,2) NOT NULL,
    tempo_preparo_minutos INTEGER,
    id_categoria INTEGER REFERENCES categorias(id_categoria),
    user_id UUID REFERENCES auth.users(id)
);

-- Recipe ingredients
CREATE TABLE IF NOT EXISTS receita_ingredientes (
    id SERIAL PRIMARY KEY,
    id_receita INTEGER REFERENCES receitas(id_receita) ON DELETE CASCADE,
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade_utilizada NUMERIC(10,2),
    user_id UUID REFERENCES auth.users(id)
);

-- Homemade production
CREATE TABLE IF NOT EXISTS producao_caseira (
    id_producao SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    quantidade_gerada NUMERIC(10,2) NOT NULL,
    unidade_gerada TEXT NOT NULL,
    tempo_preparo INTEGER,
    data_inicio_producao TIMESTAMP,
    data_fim_disponivel TIMESTAMP,
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS producao_ingredientes (
    id SERIAL PRIMARY KEY,
    id_producao INTEGER REFERENCES producao_caseira(id_producao) ON DELETE CASCADE,
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade_utilizada NUMERIC(10,2),
    user_id UUID REFERENCES auth.users(id)
);

-- Stock
CREATE TABLE IF NOT EXISTS estoque (
    id_estoque SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade_disponivel NUMERIC(10,2),
    data_atualizacao TIMESTAMP NOT NULL,
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS entrada_estoque (
    id_entrada SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade_entrada NUMERIC(10,2),
    data_entrada TIMESTAMP NOT NULL,
    observacao TEXT,
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS ajuste_estoque (
    id_ajuste SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade_anterior NUMERIC(10,2),
    quantidade_nova NUMERIC(10,2),
    data_ajuste TIMESTAMP NOT NULL,
    motivo TEXT,
    user_id UUID REFERENCES auth.users(id)
);

CREATE TABLE IF NOT EXISTS consumo_interno (
    id_consumo SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade_consumida NUMERIC(10,2),
    data_hora TIMESTAMP NOT NULL,
    motivo TEXT,
    user_id UUID REFERENCES auth.users(id)
);

-- Tables in the bar
CREATE TABLE IF NOT EXISTS mesas (
    id_mesa SERIAL PRIMARY KEY,
    numero_mesa INTEGER NOT NULL,
    status_ocupada BOOLEAN DEFAULT FALSE,
    nome_cliente TEXT,
    quantidade_lugares INTEGER NOT NULL,
    user_id UUID REFERENCES auth.users(id)
);

-- Sales
CREATE TABLE IF NOT EXISTS vendas (
    id_venda SERIAL PRIMARY KEY,
    id_mesa INTEGER REFERENCES mesas(id_mesa),
    data_venda TIMESTAMP NOT NULL,
    status_aberta BOOLEAN DEFAULT TRUE,
    cancelada BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES auth.users(id)
);

-- Orders
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_venda INTEGER REFERENCES vendas(id_venda),
    id_mesa INTEGER REFERENCES mesas(id_mesa),
    nome_funcionario TEXT,
    data_pedido TIMESTAMP,
    status_pedido TEXT,
    user_id UUID REFERENCES auth.users(id)
);

-- Items within an order
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
