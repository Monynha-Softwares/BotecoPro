import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/fixed_models.dart';

class FixedApiService {
  static const String baseUrl = 'https://gw.apiflow.online/api/1358f420ae2e4df794a4b4b49f53d042';
  static const String authToken = 'ODAxMDdlMTQ1YTJlYmFhNjZjOGZiMjQ1MDRmNmY0MGQ6YTE3NjFiOTRjODM3NmE3ODNiZjVhNWU4NDlhZjlmZmQ=';
  
  final Dio _dio = Dio();
  
  FixedApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer $authToken';
    _dio.options.headers['Content-Type'] = 'application/json';
    
    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // FORNECEDORES (Suppliers)
  Future<List<Fornecedor>> getSuppliers() async {
    try {
      final response = await _dio.get('/view/dbo.vw_fornecedor_detalhes');
      final List<dynamic> data = response.data;
      return data.map((json) => Fornecedor.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching suppliers: $e');
      return [];
    }
  }

  Future<bool> createSupplier(Fornecedor supplier) async {
    try {
      await _dio.post('/sp/dbo.sp_cadastrar_fornecedor', data: {
        'nome': supplier.nome,
        'telefone': supplier.telefone,
        'email': supplier.email,
        'contato': supplier.contato,
        'detalhes': supplier.detalhes,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating supplier: $e');
      return false;
    }
  }

  Future<bool> updateSupplier(Fornecedor supplier) async {
    try {
      await _dio.post('/sp/dbo.sp_atualizar_fornecedor', data: {
        'id_fornecedor': supplier.id_fornecedor,
        'nome': supplier.nome,
        'telefone': supplier.telefone,
        'email': supplier.email,
        'contato': supplier.contato,
        'detalhes': supplier.detalhes,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating supplier: $e');
      return false;
    }
  }

  // CATEGORIAS (Categories)
  Future<List<Categoria>> getCategories() async {
    try {
      final response = await _dio.get('/view/dbo.vw_categorias');
      final List<dynamic> data = response.data;
      return data.map((json) => Categoria.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // PRODUTOS (Products)
  Future<List<Produto>> getProducts() async {
    try {
      final response = await _dio.get('/view/dbo.vw_produto_detalhes');
      final List<dynamic> data = response.data;
      return data.map((json) => Produto.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  Future<List<ProdutoVenda>> getProductSales() async {
    try {
      final response = await _dio.get('/view/dbo.vw_produto_venda_detalhes');
      final List<dynamic> data = response.data;
      return data.map((json) => ProdutoVenda.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching product sales: $e');
      return [];
    }
  }

  Future<bool> createProduct(Produto product) async {
    try {
      // Criar o produto
      final productResponse = await _dio.post('/sp/dbo.sp_cadastrar_produto', data: {
        'nome': product.nome,
        'unidade_base': product.unidade_base,
        'tipo_produto': product.tipo_produto,
        'controla_estoque': product.controla_estoque ? 1 : 0, // Convert bool to BIT (1/0)
        'id_categoria': product.id_categoria,
      });
      
      final productId = productResponse.data['id_produto'];
      return productId != null;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    }
  }

  Future<bool> createProductSale(ProdutoVenda productSale) async {
    try {
      await _dio.post('/sp/dbo.sp_cadastrar_produto_venda', data: {
        'id_produto': productSale.id_produto,
        'descricao_venda': productSale.descricao_venda,
        'quantidade_base': productSale.quantidade_base,
        'preco_venda': productSale.preco_venda,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating product sale: $e');
      return false;
    }
  }

  // ESTOQUE (Stock)
  Future<List<Estoque>> getStock() async {
    try {
      final response = await _dio.get('/view/dbo.vw_estoque_atual');
      final List<dynamic> data = response.data;
      return data.map((json) => Estoque.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching stock: $e');
      return [];
    }
  }

  Future<bool> createStockEntry(EntradaEstoque entry) async {
    try {
      await _dio.post('/sp/dbo.sp_entrada_estoque', data: {
        'id_produto': entry.id_produto,
        'quantidade_entrada': entry.quantidade_entrada,
        'data_entrada': entry.data_entrada.toIso8601String(),
        'observacao': entry.observacao,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating stock entry: $e');
      return false;
    }
  }

  Future<bool> createStockAdjustment(AjusteEstoque adjustment) async {
    try {
      await _dio.post('/sp/dbo.sp_ajustar_estoque', data: {
        'id_produto': adjustment.id_produto,
        'quantidade_anterior': adjustment.quantidade_anterior,
        'quantidade_nova': adjustment.quantidade_nova,
        'data_ajuste': adjustment.data_ajuste.toIso8601String(),
        'motivo': adjustment.motivo,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating stock adjustment: $e');
      return false;
    }
  }

  // RECEITAS (Recipes)
  Future<List<Receita>> getRecipes() async {
    try {
      final response = await _dio.get('/view/dbo.vw_receita_detalhes');
      final List<dynamic> data = response.data;
      return data.map((json) => Receita.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      return [];
    }
  }

  Future<List<ReceitaIngrediente>> getRecipeIngredients() async {
    try {
      final response = await _dio.get('/view/dbo.vw_receita_ingredientes');
      final List<dynamic> data = response.data;
      return data.map((json) => ReceitaIngrediente.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching recipe ingredients: $e');
      return [];
    }
  }

  Future<bool> createRecipe(Receita recipe) async {
    try {
      // Criar a receita
      final recipeResponse = await _dio.post('/sp/dbo.sp_cadastrar_receita', data: {
        'nome': recipe.nome,
        'tipo_receita': recipe.tipo_receita,
        'preco_venda': recipe.preco_venda,
        'tempo_preparo_minutos': recipe.tempo_preparo_minutos,
        'id_categoria': recipe.id_categoria,
      });
      
      return recipeResponse.data['id_receita'] != null;
    } catch (e) {
      debugPrint('Error creating recipe: $e');
      return false;
    }
  }

  Future<bool> addRecipeIngredient(ReceitaIngrediente ingredient) async {
    try {
      await _dio.post('/sp/dbo.sp_adicionar_ingrediente_receita', data: {
        'id_receita': ingredient.id_receita,
        'id_produto': ingredient.id_produto,
        'quantidade_utilizada': ingredient.quantidade_utilizada,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding recipe ingredient: $e');
      return false;
    }
  }

  // PRODUÇÕES CASEIRAS (In-house Productions)
  Future<List<ProducaoCaseira>> getInternalProductions() async {
    try {
      final response = await _dio.get('/view/dbo.vw_producao_caseira_detalhes');
      final List<dynamic> data = response.data;
      return data.map((json) => ProducaoCaseira.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching internal productions: $e');
      return [];
    }
  }

  Future<List<ProducaoIngrediente>> getProductionIngredients() async {
    try {
      final response = await _dio.get('/view/dbo.vw_producao_ingredientes');
      final List<dynamic> data = response.data;
      return data.map((json) => ProducaoIngrediente.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching production ingredients: $e');
      return [];
    }
  }

  Future<bool> createInternalProduction(ProducaoCaseira production) async {
    try {
      final productionResponse = await _dio.post('/sp/dbo.sp_cadastrar_producao_caseira', data: {
        'nome': production.nome,
        'quantidade_gerada': production.quantidade_gerada,
        'unidade_gerada': production.unidade_gerada,
        'tempo_preparo': production.tempo_preparo,
        // Format as yyyy-MM-dd for DATE fields
        'data_inicio_producao': production.data_inicio_producao != null
            ? '${production.data_inicio_producao!.year}-${production.data_inicio_producao!.month.toString().padLeft(2, '0')}-${production.data_inicio_producao!.day.toString().padLeft(2, '0')}'
            : null,
        'data_fim_disponivel': production.data_fim_disponivel != null
            ? '${production.data_fim_disponivel!.year}-${production.data_fim_disponivel!.month.toString().padLeft(2, '0')}-${production.data_fim_disponivel!.day.toString().padLeft(2, '0')}'
            : null,
      });
      
      return productionResponse.data['id_producao'] != null;
    } catch (e) {
      debugPrint('Error creating internal production: $e');
      return false;
    }
  }

  Future<bool> addProductionIngredient(ProducaoIngrediente ingredient) async {
    try {
      await _dio.post('/sp/dbo.sp_adicionar_ingrediente_producao', data: {
        'id_producao': ingredient.id_producao,
        'id_produto': ingredient.id_produto,
        'quantidade_utilizada': ingredient.quantidade_utilizada,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding production ingredient: $e');
      return false;
    }
  }

  // MESAS (Tables)
  Future<List<Mesa>> getTables() async {
    try {
      final response = await _dio.get('/view/dbo.vw_mesas_detalhes');
      final List<dynamic> data = response.data;
      return data.map((json) => Mesa.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching tables: $e');
      return [];
    }
  }

  Future<bool> createTable(Mesa table) async {
    try {
      await _dio.post('/sp/dbo.sp_registrar_mesa', data: {
        'numero_mesa': table.numero_mesa,
        'quantidade_lugares': table.quantidade_lugares,
        'status_ocupada': table.status_ocupada ? 1 : 0, // Convert bool to BIT (1/0)
        'nome_cliente': table.nome_cliente,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating table: $e');
      return false;
    }
  }

  // VENDAS (Sales)
  Future<List<Venda>> getSales() async {
    try {
      final response = await _dio.get('/view/dbo.vw_vendas');
      final List<dynamic> data = response.data;
      return data.map((json) => Venda.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching sales: $e');
      return [];
    }
  }

  Future<bool> createSale(Venda sale) async {
    try {
      final saleResponse = await _dio.post('/sp/dbo.sp_abrir_venda_mesa', data: {
        'id_mesa': sale.id_mesa,
        'data_venda': sale.data_venda.toIso8601String(),
      });
      
      return saleResponse.data['id_venda'] != null;
    } catch (e) {
      debugPrint('Error creating sale: $e');
      return false;
    }
  }

  Future<bool> closeSale(int id_venda) async {
    try {
      await _dio.post('/sp/dbo.sp_fechar_venda', data: {
        'id_venda': id_venda,
        'data_fechamento': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error closing sale: $e');
      return false;
    }
  }

  Future<bool> cancelSale(int id_venda) async {
    try {
      await _dio.post('/sp/dbo.sp_cancelar_venda', data: {
        'id_venda': id_venda,
      });
      return true;
    } catch (e) {
      debugPrint('Error canceling sale: $e');
      return false;
    }
  }

  // PEDIDOS (Orders)
  Future<List<Pedido>> getOrders() async {
    try {
      final response = await _dio.get('/view/dbo.vw_pedidos');
      final List<dynamic> data = response.data;
      return data.map((json) => Pedido.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  Future<List<PedidoItem>> getOrderItems() async {
    try {
      final response = await _dio.get('/view/dbo.vw_pedido_itens');
      final List<dynamic> data = response.data;
      return data.map((json) => PedidoItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching order items: $e');
      return [];
    }
  }

  Future<bool> createOrder(Pedido order) async {
    try {
      final orderResponse = await _dio.post('/sp/dbo.sp_criar_pedido', data: {
        'id_venda': order.id_venda,
        'id_mesa': order.id_mesa,
        'nome_funcionario': order.nome_funcionario,
        'data_pedido': order.data_pedido.toIso8601String(),
        'status_pedido': order.status_pedido,
      });
      
      return orderResponse.data['id_pedido'] != null;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  Future<bool> addOrderItem(PedidoItem item) async {
    try {
      await _dio.post('/sp/dbo.sp_adicionar_item_pedido', data: {
        'id_pedido': item.id_pedido,
        'tipo_item': item.tipo_item,
        'id_item': item.id_item,
        'quantidade': item.quantidade,
        'preco_unitario': item.preco_unitario,
        'observacao': item.observacao,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding order item: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(int id_pedido, String status_pedido) async {
    try {
      await _dio.post('/sp/dbo.sp_atualizar_status_pedido', data: {
        'id_pedido': id_pedido,
        'status_pedido': status_pedido,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  // RELATÓRIOS E ESTATÍSTICAS
  Future<double> getTodaySales() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final salesResponse = await _dio.get('/view/dbo.vw_vendas');
      final List<dynamic> salesData = salesResponse.data;
      
      // Filtrar vendas de hoje que não estejam canceladas nem abertas
      final todaySales = salesData.where((sale) {
        final saleDate = sale['data_venda']?.toString().split('T')[0];
        return saleDate == today && 
              sale['cancelada'] != true && 
              sale['cancelada'] != 1 && 
              sale['status_aberta'] != true &&
              sale['status_aberta'] != 1;
      }).toList();
      
      // Obter os itens de pedido para calcular o valor total
      final orderItemsResponse = await _dio.get('/view/dbo.vw_pedido_itens');
      final List<dynamic> orderItemsData = orderItemsResponse.data;
      
      double total = 0.0;
      for (var sale in todaySales) {
        // Obter pedidos desta venda
        final ordersResponse = await _dio.get('/view/dbo.vw_pedidos', 
            queryParameters: {'id_venda': sale['id_venda']});
        final List<dynamic> ordersData = ordersResponse.data;
        
        for (var order in ordersData) {
          // Obter itens deste pedido
          final orderItems = orderItemsData.where(
            (item) => item['id_pedido'] == order['id_pedido']
          ).toList();
          
          // Somar os valores dos itens
          for (var item in orderItems) {
            total += (item['quantidade'] ?? 0).toDouble() * (item['preco_unitario'] ?? 0).toDouble();
          }
        }
      }
      
      return total;
    } catch (e) {
      debugPrint('Error getting today sales: $e');
      return 0.0;
    }
  }

  Future<List<Produto>> getLowStockProducts(int threshold) async {
    try {
      final stockResponse = await _dio.get('/view/dbo.vw_estoque_atual');
      final List<dynamic> stockData = stockResponse.data;
      
      // Filtrar produtos com estoque baixo
      final lowStockData = stockData.where(
        (item) => (item['quantidade_disponivel'] ?? 0).toDouble() <= threshold
      ).toList();
      
      // Obter detalhes dos produtos
      final productsResponse = await _dio.get('/view/dbo.vw_produto_detalhes');
      final List<dynamic> productsData = productsResponse.data;
      
      // Mapear para objetos Produto
      List<Produto> lowStockProducts = [];
      for (var stockItem in lowStockData) {
        final productData = productsData.firstWhere(
          (p) => p['id_produto'] == stockItem['id_produto'],
          orElse: () => {}
        );
        
        if (productData.isNotEmpty) {
          lowStockProducts.add(Produto.fromJson(productData));
        }
      }
      
      return lowStockProducts;
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }
}