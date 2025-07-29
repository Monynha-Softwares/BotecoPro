# Boteco PRO - Sistema de Gestão para Bares

Sistema completo de gestão para bares e restaurantes com autenticação Supabase, banco de dados em tempo real e interface Flutter moderna.

## 🚀 Funcionalidades

- ✅ **Autenticação completa** - Login com email/senha e Google Sign-In
- ✅ **Gestão de mesas** - Controle de ocupação em tempo real
- ✅ **Controle de estoque** - Monitoramento automático de produtos
- ✅ **Pedidos e vendas** - Sistema completo de comandas
- ✅ **Fornecedores** - Cadastro e gestão de fornecedores
- ✅ **Receitas** - Cadastro de receitas e produções caseiras
- ✅ **Relatórios** - Dashboard com vendas diárias
- ✅ **Tempo real** - Atualizações automáticas via Supabase

## 🛠️ Tecnologias

- **Frontend:** Flutter (Dart)
- **Backend:** Supabase (PostgreSQL + Real-time)
- **Autenticação:** Supabase Auth + Google Sign-In
- **Estado:** Provider Pattern
- **UI:** Material Design 3

## ⚙️ Configuração do Supabase

### 1. Criar o projeto no Supabase
1. Acesse [supabase.com](https://supabase.com)
2. Crie um novo projeto
3. Anote a URL e a Anon Key

### 2. Configurar o banco de dados
Execute este SQL no SQL Editor do Supabase para criar as tabelas:

```sql
-- Criar tabela de categorias
CREATE TABLE IF NOT EXISTS public.categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar tabela de fornecedores
CREATE TABLE IF NOT EXISTS public.fornecedores (
    id_fornecedor SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(150),
    contato VARCHAR(100),
    detalhes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar tabela de produtos
CREATE TABLE IF NOT EXISTS public.produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    unidade_base VARCHAR(20) NOT NULL,
    tipo_produto VARCHAR(20) NOT NULL CHECK (tipo_produto IN ('compra', 'producao', 'ingrediente', 'ambos')),
    controla_estoque BOOLEAN DEFAULT TRUE,
    id_categoria INTEGER REFERENCES public.categorias(id_categoria),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar tabela de mesas
CREATE TABLE IF NOT EXISTS public.mesas (
    id_mesa SERIAL PRIMARY KEY,
    numero_mesa INTEGER NOT NULL,
    quantidade_lugares INTEGER NOT NULL,
    status_ocupada BOOLEAN DEFAULT FALSE,
    nome_cliente VARCHAR(100),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar tabela de vendas
CREATE TABLE IF NOT EXISTS public.vendas (
    id_venda SERIAL PRIMARY KEY,
    id_mesa INTEGER REFERENCES public.mesas(id_mesa),
    data_venda TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status_aberta BOOLEAN DEFAULT TRUE,
    cancelada BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Criar tabela de pedidos
CREATE TABLE IF NOT EXISTS public.pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_venda INTEGER REFERENCES public.vendas(id_venda),
    id_mesa INTEGER REFERENCES public.mesas(id_mesa),
    nome_funcionario VARCHAR(100),
    data_pedido TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status_pedido VARCHAR(20) DEFAULT 'pendente',
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Criar tabela de estoque
CREATE TABLE IF NOT EXISTS public.estoque (
    id_estoque SERIAL PRIMARY KEY,
    id_produto INTEGER REFERENCES public.produtos(id_produto),
    quantidade_disponivel DECIMAL(10,3) NOT NULL DEFAULT 0,
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Criar tabela de receitas
CREATE TABLE IF NOT EXISTS public.receitas (
    id_receita SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    tipo_receita VARCHAR(50),
    preco_venda DECIMAL(10,2),
    tempo_preparo_minutos INTEGER,
    id_categoria INTEGER REFERENCES public.categorias(id_categoria),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar Row Level Security
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receitas ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS (cada usuário só vê seus dados)
CREATE POLICY "Users can manage their own categorias" ON public.categorias USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own fornecedores" ON public.fornecedores USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own produtos" ON public.produtos USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own mesas" ON public.mesas USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own vendas" ON public.vendas USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own pedidos" ON public.pedidos USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own estoque" ON public.estoque USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own receitas" ON public.receitas USING (auth.uid() = user_id);

-- Habilitar Real-time para tabelas importantes
ALTER PUBLICATION supabase_realtime ADD TABLE public.mesas;
ALTER PUBLICATION supabase_realtime ADD TABLE public.pedidos;
ALTER PUBLICATION supabase_realtime ADD TABLE public.vendas;
ALTER PUBLICATION supabase_realtime ADD TABLE public.estoque;
```

### 3. Configurar Authentication
1. Vá em Authentication > Settings
2. Habilite "Enable email confirmations" se desejar
3. Configure Google OAuth (opcional)

## 🔒 Segurança

- **Row Level Security (RLS):** Cada usuário só acessa seus próprios dados
- **Autenticação JWT:** Tokens seguros gerenciados pelo Supabase
- **Validação server-side:** Políticas de segurança no banco de dados
- **HTTPS:** Todas as comunicações são criptografadas

## 📱 Como Usar

### Primeiro Acesso
1. Cadastre-se com email/senha ou Google
2. O sistema criará dados de exemplo automaticamente
3. Explore as funcionalidades do dashboard

### Funcionalidades Principais
- **Dashboard:** Visão geral das vendas e mesas
- **Mesas:** Controle de ocupação em tempo real
- **Produtos:** Cadastro e controle de estoque  
- **Pedidos:** Sistema de comandas
- **Fornecedores:** Gestão de fornecedores
- **Receitas:** Cadastro de receitas próprias

---

**Desenvolvido com ❤️ para a gestão de bares e restaurantes**

## Important Changes

This repository contains corrected data models to match the SQL Server database structure. The key fixes include:

1. **Fixed Data Types**:
   - Corrected decimal representations for DECIMAL(10,2) fields
   - Proper handling of DATE vs DATETIME fields
   - Correct BIT field handling (boolean in Dart, 1/0 in SQL Server)
   
2. **Standardized Model Properties**:
   - All model properties now match exact database field names
   - All nullability handled correctly based on DB constraints
   - All NVARCHAR fields properly modeled as String types

3. **API Integration**:
   - Fixed API request/response mapping
   - Ensured proper date formatting for SQL Server DATE fields
   - Correct handling of boolean to BIT conversions

## Usage

To use the corrected models:

```dart
// Import corrected models
import 'package:dreamflow/models/corrected_import.dart';

// Use fixed models directly
final product = Produto(
  nome: 'Test Product',
  unidade_base: 'un',
  tipo_produto: 'compra',
  controla_estoque: true,
);
```

## Data Models

All models now directly correspond to the SQL Server tables:

- `Fornecedor` - Supplier data
- `Produto` - Product information
- `ProdutoVenda` - Product sale information
- `Receita` - Recipe details
- `ReceitaIngrediente` - Recipe ingredients
- `Categoria` - Categories
- `ProducaoCaseira` - In-house production records
- `ProducaoIngrediente` - Production ingredients
- `Estoque` - Inventory records
- `EntradaEstoque` - Stock entries
- `AjusteEstoque` - Stock adjustments
- `ConsumoInterno` - Internal consumption
- `Mesa` - Tables
- `Venda` - Sales
- `Pedido` - Orders
- `PedidoItem` - Order items

## Database Structure Reference

All models accurately reflect the SQL Server database structure with proper field types:

- INT fields → int in Dart
- DECIMAL(10,2) → double in Dart
- BIT → bool in Dart (converted to 1/0 when sending to server)
- DATE/DATETIME → DateTime in Dart (with proper formatting)
- NVARCHAR → String in Dart