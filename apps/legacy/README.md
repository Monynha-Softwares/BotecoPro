# Boteco PRO

## Overview
Boteco PRO is a comprehensive management system for bars and restaurants, allowing owners and staff to manage tables, products, recipes, inventory, and more.

## Usage

To use the corrected models:

```dart
// Import corrected models
import 'package:botecopro/models/corrected_import.dart';

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