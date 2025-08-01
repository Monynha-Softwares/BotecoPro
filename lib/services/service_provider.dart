import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'supabase_database_service.dart';
import '../models/data_models.dart';
import '../adapters/model_adapters.dart';

const uuid = Uuid();

/// ServiceProvider é responsável por gerenciar qual serviço de dados será usado.
/// Agora usa o SupabaseDatabaseService para persistência e real-time.
class ServiceProvider with ChangeNotifier {
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();

  final bool _isOnline = true; // Supabase is always "online"
  final bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Initialize the database
  Future<void> initializeData() async {
    await _supabaseService.initializeData();
  }

  // Método para alternar entre online e offline - não necessário com Supabase
  Future<void> toggleOnlineMode(bool online) async {
    debugPrint('toggleOnlineMode called - Supabase is always online');
  }

  // Sincronizar dados - não necessário com Supabase (real-time)
  Future<void> syncData() async {
    debugPrint('syncData called - Supabase handles this automatically');
  }

  // FORNECEDORES (Suppliers)
  Future<List<Fornecedor>> getFornecedores() async {
    return await _supabaseService.getFornecedores();
  }

  Future<void> addFornecedor(Fornecedor fornecedor) async {
    await _supabaseService.addFornecedor(fornecedor);
  }

  Future<void> updateFornecedor(Fornecedor fornecedor) async {
    await _supabaseService.updateFornecedor(fornecedor);
  }

  Future<void> deleteFornecedor(int idFornecedor) async {
    await _supabaseService.deleteFornecedor(idFornecedor);
  }

  // CATEGORIAS (Categories)
  Future<List<Categoria>> getCategorias() async {
    return await _supabaseService.getCategorias();
  }

  // PRODUTOS (Products)
  Future<List<Produto>> getProdutos() async {
    return await _supabaseService.getProdutos();
  }

  Future<List<ProdutoVenda>> getProdutosVenda() async {
    return await _supabaseService.getProdutosVenda();
  }

  Future<void> addProduto(Produto produto) async {
    await _supabaseService.addProduto(produto);
  }

  Future<void> addProdutoVenda(ProdutoVenda produtoVenda) async {
    await _supabaseService.addProdutoVenda(produtoVenda);
  }

  Future<void> updateEstoqueProduto(
    int idProduto,
    double novaQuantidade,
  ) async {
    await _supabaseService.updateEstoqueProduto(idProduto, novaQuantidade);
  }

  // ESTOQUE (Stock)
  Future<List<Estoque>> getEstoque() async {
    return await _supabaseService.getEstoque();
  }

  // MESAS (Tables)
  Future<List<Mesa>> getMesas() async {
    return await _supabaseService.getMesas();
  }

  Future<void> saveMesas(List<Mesa> mesas) async {
    // Supabase service handles this automatically - compatibility method
    debugPrint('saveMesas called - using individual operations instead');
  }

  // VENDAS (Sales)
  Future<List<Venda>> getVendas() async {
    return await _supabaseService.getVendas();
  }

  Stream<List<Venda>> streamVendas() {
    return _supabaseService.streamVendas();
  }

  Future<List<Sale>> getSales() async {
    final vendas = await getVendas();
    return vendas.map((venda) {
      // Simplified conversion to legacy Sale format
      return Sale(
        id: venda.id_venda?.toString() ?? uuid.v4(),
        orderId: venda.id_venda?.toString() ?? '',
        timestamp: venda.data_venda,
        total: 0, // Would need to calculate from PedidoItems
      );
    }).toList();
  }

  Future<List<Venda>> getVendasAtivas() async {
    return await _supabaseService.getVendasAtivas();
  }

  Future<Venda?> getVendaAtivaMesa(int idMesa) async {
    return await _supabaseService.getVendaAtivaMesa(idMesa);
  }

  Future<void> addVenda(Venda venda) async {
    await _supabaseService.addVenda(venda);
  }

  Future<void> closeVenda(int idVenda) async {
    await _supabaseService.closeVenda(idVenda);
  }

  Future<void> cancelVenda(int idVenda) async {
    // For now, use close - implement cancel later if needed
    await _supabaseService.closeVenda(idVenda);
  }

  // PEDIDOS (Orders)
  Future<List<Pedido>> getPedidos() async {
    return await _supabaseService.getPedidos();
  }

  Stream<List<Pedido>> streamPedidos() {
    return _supabaseService.streamPedidos();
  }

  Future<List<Order>> getOrders() async {
    final pedidos = await getPedidos();
    final produtos = await getProdutos();
    final produtoMap = <int, Produto>{
      for (var p in produtos)
        if (p.id_produto != null) p.id_produto!: p,
    };

    List<Order> orders = [];

    for (var pedido in pedidos) {
      if (pedido.id_pedido != null) {
        final itemsDb = await getPedidoItensByPedido(pedido.id_pedido!);
        final items = itemsDb
            .map((i) => OrderItemAdapter.fromPedidoItem(
                  i,
                  productName: produtoMap[i.id_item]?.nome ?? 'Produto',
                ))
            .toList();
        orders.add(OrderAdapter.fromPedido(pedido, items));
      }
    }

    return orders;
  }

  Stream<List<Order>> streamOrders() {
    return streamPedidos().asyncMap((pedidos) async {
      final produtos = await getProdutos();
      final produtoMap = <int, Produto>{
        for (var p in produtos)
          if (p.id_produto != null) p.id_produto!: p,
      };

      List<Order> orders = [];
      for (var pedido in pedidos) {
        if (pedido.id_pedido != null) {
          final itemsDb = await getPedidoItensByPedido(pedido.id_pedido!);
          final items = itemsDb
              .map((i) => OrderItemAdapter.fromPedidoItem(
                    i,
                    productName: produtoMap[i.id_item]?.nome ?? 'Produto',
                  ))
              .toList();
          orders.add(OrderAdapter.fromPedido(pedido, items));
        }
      }
      return orders;
    });
  }

  Future<void> addPedido(Pedido pedido) async {
    await _supabaseService.addPedido(pedido);
  }

  Future<void> updatePedidoStatus(int idPedido, String status) async {
    await _supabaseService.updatePedidoStatus(idPedido, status);
  }

  Future<List<PedidoItem>> getPedidoItens() async {
    return await _supabaseService.getPedidoItens();
  }

  Future<List<PedidoItem>> getPedidoItensByPedido(int idPedido) async {
    return await _supabaseService.getPedidoItensByPedido(idPedido);
  }

  Future<void> addPedidoItem(PedidoItem item) async {
    await _supabaseService.addPedidoItem(item);
  }

  // RECEITAS (Recipes)
  Future<List<Receita>> getReceitas() async {
    return await _supabaseService.getReceitas();
  }

  Future<void> addReceita(Receita receita) async {
    await _supabaseService.addReceita(receita);
  }

  Future<List<ReceitaIngrediente>> getReceitaIngredientes() async {
    return await _supabaseService.getReceitaIngredientes();
  }

  Future<List<ReceitaIngrediente>> getReceitaIngredientesByReceita(int idReceita) async {
    return await _supabaseService.getReceitaIngredientesByReceita(idReceita);
  }

  Future<void> addReceitaIngrediente(ReceitaIngrediente ingrediente) async {
    await _supabaseService.addReceitaIngrediente(ingrediente);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final receitaId = int.tryParse(recipe.id);
    if (receitaId == null) return;

    // Get current recipe
    final receitas = await getReceitas();
    final index = receitas.indexWhere((r) => r.id_receita == receitaId);
    if (index == -1) return;

    // Update recipe
    receitas[index] = Receita(
      id_receita: receitaId,
      nome: recipe.name,
      tipo_receita: recipe.type == RecipeType.food ? 'porcao' : 'cocktail',
      preco_venda: recipe.price,
      tempo_preparo_minutos:
          recipe.preparationMinutes ?? receitas[index].tempo_preparo_minutos,
      id_categoria: receitas[index].id_categoria,
    );

    await _supabaseService.updateReceita(receitas[index]);

    // Update ingredients (simplified approach)
    // This would need more robust logic for a real migration
    final existingIngredients = await getReceitaIngredientesByReceita(
      receitaId,
    );

    // Add any new ingredients
    for (var ingredient in recipe.ingredients) {
      bool exists = false;
      for (var existing in existingIngredients) {
        if (existing.id?.toString() == ingredient.id) {
          exists = true;
          break;
        }
      }

      if (!exists) {
        await addRecipeIngredient(recipe.id, ingredient);
      }
    }
  }

  // PRODUÇÕES CASEIRAS (In-house Productions)
  // TODO: implementar usando Supabase
  Future<List<ProducaoCaseira>> getProducoes() async {
    return await _supabaseService.getProducoes();
  }

  Future<void> addProducao(ProducaoCaseira producao) async {
    await _supabaseService.addProducao(producao);
  }

  Future<List<ProducaoIngrediente>> getProducaoIngredientes() async {
    return await _supabaseService.getProducaoIngredientes();
  }

  Future<List<ProducaoIngrediente>> getProducaoIngredientesByProducao(
    int idProducao,
  ) async {
    return await _supabaseService.getProducaoIngredientesByProducao(idProducao);
  }

  Future<void> addProducaoIngrediente(ProducaoIngrediente ingrediente) async {
    await _supabaseService.addProducaoIngrediente(ingrediente);
  }

  // ESTATÍSTICAS (Statistics)
  Future<double> getVendasDiarias() async {
    return await _supabaseService.getVendasDiarias();
  }

  Stream<double> streamVendasDiarias() {
    return streamVendas().map((vendas) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final vendasHoje = vendas.where((v) {
        return v.data_venda.isAfter(startOfDay) &&
            v.data_venda.isBefore(endOfDay) &&
            !v.status_aberta &&
            !v.cancelada;
      }).length;

      // Reuse mock calculation from getVendasDiarias
      return vendasHoje * 50.0;
    });
  }

  Future<List<Produto>> getProdutosEstoqueBaixo(int threshold) async {
    // For now, return empty list - implement when needed
    return [];
  }

  // Legacy compatibility methods for the transition phase

  Future<List<Supplier>> getSuppliers() async {
    return await _supabaseService.getSuppliers();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _supabaseService.addSupplier(supplier);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _supabaseService.updateSupplier(supplier);
  }

  Future<void> deleteSupplier(String id) async {
    await _supabaseService.deleteSupplier(id);
  }

  Future<List<TableModel>> getTables() async {
    return await _supabaseService.getTables();
  }

  Future<void> saveTables(List<TableModel> tables) async {
    // Supabase service handles this automatically - compatibility method
    debugPrint('saveTables called - using individual operations instead');
  }

  Future<Order?> getActiveOrderForTable(String tableId) async {
    final intId = int.tryParse(tableId);
    if (intId != null) {
      // Get active sale for this table
      final venda = await getVendaAtivaMesa(intId);
      if (venda != null) {
        final produtos = await getProdutos();
        final produtoMap = <int, Produto>{
          for (var p in produtos)
            if (p.id_produto != null) p.id_produto!: p,
        };
        // Get all pedidos for this sale
        final pedidos = await getPedidos();
        final pedidosVenda = pedidos
            .where((p) => p.id_venda == venda.id_venda)
            .toList();

        if (pedidosVenda.isNotEmpty) {
          // Get items for each pedido
          List<PedidoItem> allItems = [];
          for (var pedido in pedidosVenda) {
            if (pedido.id_pedido != null) {
              final items = await getPedidoItensByPedido(pedido.id_pedido!);
              allItems.addAll(items);
            }
          }

          // Create an Order with the first pedido
          final orderItems = allItems
              .map((item) => OrderItemAdapter.fromPedidoItem(
                    item,
                    productName: produtoMap[item.id_item]?.nome ?? 'Produto',
                  ))
              .toList();

          return Order(
            id: venda.id_venda?.toString() ?? uuid.v4(),
            tableId: tableId,
            tableNumber: intId,
            createdAt: venda.data_venda,
            items: orderItems,
            status: OrderStatus.pending,
          );
        }
      }
    }
    return null;
  }

  Future<List<Order>> getActiveOrders() async {
    // Get all active vendas
    final vendasAtivas = await getVendasAtivas();
    final produtos = await getProdutos();
    final produtoMap = <int, Produto>{
      for (var p in produtos)
        if (p.id_produto != null) p.id_produto!: p,
    };

    List<Order> orders = [];

    for (var venda in vendasAtivas) {
      // Get all pedidos for this venda
      final pedidos = await getPedidos();
      final pedidosVenda = pedidos
          .where((p) => p.id_venda == venda.id_venda)
          .toList();

      if (pedidosVenda.isNotEmpty) {
        // Get items for each pedido
        List<PedidoItem> allItems = [];
        for (var pedido in pedidosVenda) {
          if (pedido.id_pedido != null) {
            final items = await getPedidoItensByPedido(pedido.id_pedido!);
            allItems.addAll(items);
          }
        }

        final orderItems = allItems
            .map((item) => OrderItemAdapter.fromPedidoItem(
                  item,
                  productName: produtoMap[item.id_item]?.nome ?? 'Produto',
                ))
            .toList();

        final order = Order(
          id: venda.id_venda?.toString() ?? uuid.v4(),
          tableId: venda.id_mesa.toString(),
          tableNumber: venda.id_mesa,
          createdAt: venda.data_venda,
          items: orderItems,
          status: OrderStatus.pending,
        );

        orders.add(order);
      }
    }

    return orders;
  }

  Future<void> updateOrder(Order order) async {
    // Extract ID information
    final vendaId = int.tryParse(order.id);
    if (vendaId == null) return;

    // Get all pedidos for this venda
    final pedidos = await getPedidos();
    final pedidosVenda = pedidos.where((p) => p.id_venda == vendaId).toList();

    if (pedidosVenda.isEmpty) {
      // Create a new pedido for this order
      final pedido = Pedido(
        id_venda: vendaId,
        id_mesa: order.tableNumber,
        data_pedido: order.createdAt,
        status_pedido: 'pendente',
      );
      await addPedido(pedido);

      // Get the created pedido ID
      final updatedPedidos = await getPedidos();
      final createdPedido = updatedPedidos.lastWhere(
        (p) => p.id_venda == vendaId,
      );

      // Add all items in the order to this pedido
      for (var item in order.items) {
        final pedidoItem = OrderItemAdapter.toPedidoItem(
          item,
          createdPedido.id_pedido!,
        );
        await addPedidoItem(pedidoItem);
      }
    } else {
      // Update existing pedido items
      // This is a simplified approach - in a real migration you'd need more robust logic
      final pedido = pedidosVenda.first;

      // Get existing items
      final existingItems = await getPedidoItensByPedido(pedido.id_pedido!);

      // For simplicity, we're removing all items and adding new ones
      // In a real implementation, you'd match and update existing items

      // Add all items in the updated order
      for (var item in order.items) {
        // Check if item exists
        bool exists = false;
        for (var existingItem in existingItems) {
          if (existingItem.id_pedido_item?.toString() == item.id) {
            exists = true;
            break;
          }
        }

        if (!exists) {
          // Add new item
          final pedidoItem = OrderItemAdapter.toPedidoItem(
            item,
            pedido.id_pedido!,
          );
          await addPedidoItem(pedidoItem);
        }
        // For now, we're not updating existing items or removing ones not in the new order
        // This would need more complex logic in a real migration
      }
    }
  }

  Future<void> addOrder(Order order) async {
    // Create a venda (sale) for this order
    final tableId = int.tryParse(order.tableId);
    if (tableId == null) return;

    final venda = Venda(
      id_mesa: tableId,
      data_venda: order.createdAt,
      status_aberta: true,
      cancelada: false,
    );

    await addVenda(venda);

    // Get the created venda ID
    final vendas = await getVendas();
    final createdVenda = vendas.lastWhere(
      (v) => v.id_mesa == tableId && v.status_aberta,
    );

    // Create a pedido (order) for this venda
    final pedido = Pedido(
      id_venda: createdVenda.id_venda!,
      id_mesa: tableId,
      data_pedido: order.createdAt,
      status_pedido: 'pendente',
    );

    await addPedido(pedido);

    // Get the created pedido ID
    final pedidos = await getPedidos();
    final createdPedido = pedidos.lastWhere(
      (p) => p.id_venda == createdVenda.id_venda,
    );

    // Add all items in the order to this pedido
    for (var item in order.items) {
      final pedidoItem = OrderItemAdapter.toPedidoItem(
        item,
        createdPedido.id_pedido!,
      );
      await addPedidoItem(pedidoItem);
    }
  }

  Future<void> closeOrder(String orderId) async {
    final vendaId = int.tryParse(orderId);
    if (vendaId != null) {
      await closeVenda(vendaId);
    }
  }

  // Recipe methods
  Future<List<Recipe>> getRecipes() async {
    final receitas = await getReceitas();
    final produtos = await getProdutos();
    final produtoMap = <int, Produto>{
      for (var p in produtos)
        if (p.id_produto != null) p.id_produto!: p,
    };

    List<Recipe> recipes = [];

    for (var receita in receitas) {
      if (receita.id_receita != null) {
        final ingredientesDb = await getReceitaIngredientesByReceita(
          receita.id_receita!,
        );

        final ingredientes = ingredientesDb
            .map((i) => RecipeIngredientAdapter.fromReceitaIngrediente(
                  i,
                  productName: produtoMap[i.id_produto]?.nome ?? 'Produto',
                  unit: produtoMap[i.id_produto]?.unidade_base ?? 'unidade',
                ))
            .toList();

        recipes.add(RecipeAdapter.fromReceita(receita, ingredientes));
      }
    }

    return recipes;
  }

  Future<void> addRecipe(Recipe recipe) async {
    final receita = RecipeAdapter.toReceita(recipe);
    await addReceita(receita);

    // Get the created recipe ID
    final receitas = await getReceitas();
    final createdReceita = receitas.lastWhere((r) => r.nome == recipe.name);

    // Add ingredients
    for (var ingredient in recipe.ingredients) {
      final receitaIngrediente = RecipeIngredientAdapter.toReceitaIngrediente(
        ingredient,
        createdReceita.id_receita!,
      );
      await addReceitaIngrediente(receitaIngrediente);
    }
  }

  Future<void> addRecipeIngredient(
    String recipeId,
    RecipeIngredient ingredient,
  ) async {
    final receitaId = int.tryParse(recipeId);
    if (receitaId != null) {
      final receitaIngrediente = RecipeIngredientAdapter.toReceitaIngrediente(
        ingredient,
        receitaId,
      );
      await addReceitaIngrediente(receitaIngrediente);
    }
  }

  // Production methods
  Future<List<InternalProduction>> getInternalProductions() async {
    final producoes = await getProducoes();
    final produtos = await getProdutos();
    final produtoMap = <int, Produto>{
      for (var p in produtos)
        if (p.id_produto != null) p.id_produto!: p,
    };
    List<InternalProduction> productions = [];

    for (var producao in producoes) {
      if (producao.id_producao != null) {
        final ingredientes = await getProducaoIngredientesByProducao(
          producao.id_producao!,
        );
        productions.add(
          ProductionAdapter.fromProducaoCaseira(
            producao,
            ingredientes,
            produtoMap,
          ),
        );
      }
    }

    return productions;
  }

  Future<void> addInternalProduction(InternalProduction production) async {
    final producao = ProductionAdapter.toProducaoCaseira(production);
    await addProducao(producao);

    // Get the created production ID
    final producoes = await getProducoes();
    final createdProducao = producoes.lastWhere(
      (p) => p.nome == production.name,
    );

    // Add ingredients
    for (var ingredient in production.ingredients) {
      final producaoIngrediente =
          ProductionIngredientAdapter.toProducaoIngrediente(
            ingredient,
            createdProducao.id_producao!,
          );
      await addProducaoIngrediente(producaoIngrediente);
    }
  }

  Future<void> addProductionIngredient(
    String productionId,
    ProductionIngredient ingredient,
  ) async {
    final producaoId = int.tryParse(productionId);
    if (producaoId != null) {
      final producaoIngrediente =
          ProductionIngredientAdapter.toProducaoIngrediente(
            ingredient,
            producaoId,
          );
      await addProducaoIngrediente(producaoIngrediente);
    }
  }

  Future<void> updateInternalProduction(InternalProduction production) async {
    // This would need a more complex implementation to properly update
    // For now, we'll just add production ingredients if there are any new ones
    final producaoId = int.tryParse(production.id);
    if (producaoId != null) {
      // Get existing ingredients
      final existingIngredients = await getProducaoIngredientesByProducao(
        producaoId,
      );

      // Add any new ingredients
      for (var ingredient in production.ingredients) {
        bool exists = false;
        for (var existingIngredient in existingIngredients) {
          if (existingIngredient.id?.toString() == ingredient.id) {
            exists = true;
            break;
          }
        }

        if (!exists) {
          await addProductionIngredient(production.id, ingredient);
        }
      }
    }
  }

  // Product methods
  Future<List<Product>> getProducts() async {
    final produtos = await getProdutos();
    final produtosVenda = await getProdutosVenda();
    final estoque = await getEstoque();

    return produtos.map((produto) {
      // Find corresponding produtoVenda
      final pv = produtosVenda.firstWhere(
        (pv) => pv.id_produto == produto.id_produto,
        orElse: () => ProdutoVenda(
          id_produto: produto.id_produto ?? 0,
          descricao_venda: produto.nome,
          quantidade_base: 1,
          preco_venda: 0,
        ),
      );

      // Find current stock
      final estoqueItem = estoque.firstWhere(
        (e) => e.id_produto == produto.id_produto,
        orElse: () => Estoque(
          id_produto: produto.id_produto ?? 0,
          quantidade_disponivel: 0,
          data_atualizacao: DateTime.now(),
        ),
      );

      // Create a legacy Product
      return Product(
        id: produto.id_produto?.toString() ?? uuid.v4(),
        name: produto.nome,
        category: _mapCategoria(produto.id_categoria),
        price: pv.preco_venda,
        stockQuantity: estoqueItem.quantidade_disponivel.toInt(),
        unit: produto.unidade_base,
        description: '',
      );
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    // Create Produto
    final produto = Produto(
      nome: product.name,
      unidade_base: product.unit,
      tipo_produto: 'compra', // Default
      controla_estoque: true,
      id_categoria: _getCategoriaId(product.category),
    );

    await addProduto(produto);

    // Get created product ID
    final produtos = await getProdutos();
    final createdProduto = produtos.lastWhere((p) => p.nome == product.name);

    // Create ProdutoVenda
    final produtoVenda = ProdutoVenda(
      id_produto: createdProduto.id_produto!,
      descricao_venda: '${product.name} (Padrão)',
      quantidade_base: 1,
      preco_venda: product.price,
    );

    await addProdutoVenda(produtoVenda);

    // Set initial stock if needed
    if (product.stockQuantity > 0) {
      await updateEstoqueProduto(
        createdProduto.id_produto!,
        product.stockQuantity.toDouble(),
      );
    }
  }

  Future<void> updateProduct(Product product) async {
    final produtoId = int.tryParse(product.id);
    if (produtoId == null) return;

    // Get current product
    final produtos = await getProdutos();
    final index = produtos.indexWhere((p) => p.id_produto == produtoId);
    if (index == -1) return;

    // Update produto
    produtos[index] = Produto(
      id_produto: produtoId,
      nome: product.name,
      unidade_base: product.unit,
      tipo_produto: produtos[index].tipo_produto,
      controla_estoque: produtos[index].controla_estoque,
      id_categoria: _getCategoriaId(product.category),
    );

    // Update produto venda information
    final produtosVenda = await getProdutosVenda();
    final pvIndex = produtosVenda.indexWhere(
      (pv) => pv.id_produto == produtoId,
    );

    ProdutoVenda? pv;
    if (pvIndex != -1) {
      pv = ProdutoVenda(
        id_venda: produtosVenda[pvIndex].id_venda,
        id_produto: produtoId,
        descricao_venda: '${product.name} (Padrão)',
        quantidade_base: produtosVenda[pvIndex].quantidade_base,
        preco_venda: product.price,
      );
    } else {
      pv = ProdutoVenda(
        id_produto: produtoId,
        descricao_venda: '${product.name} (Padrão)',
        quantidade_base: 1,
        preco_venda: product.price,
      );
    }

    await _supabaseService.updateProduto(produtos[index], pv);
    }

  Future<void> updateProductStock(String productId, int newQuantity) async {
    final produtoId = int.tryParse(productId);
    if (produtoId != null) {
      await updateEstoqueProduto(produtoId, newQuantity.toDouble());
    }
  }

  int _getCategoriaId(ProductCategory category) {
    switch (category) {
      case ProductCategory.drink:
        return 1;
      case ProductCategory.food:
        return 2;
      case ProductCategory.other:
        return 3;
      default:
        return 1;
    }
  }

  ProductCategory _mapCategoria(int? idCategoria) {
    // Simple mapping based on ID
    if (idCategoria == 1) return ProductCategory.drink;
    if (idCategoria == 2) return ProductCategory.food;
    return ProductCategory.other;
  }

  Future<double> getTodaySales() async {
    return await getVendasDiarias();
  }

  Future<List<Product>> getLowStockProducts(int threshold) async {
    final produtos = await getProdutosEstoqueBaixo(threshold);
    return getProducts().then((allProducts) {
      return allProducts.where((p) {
        return produtos.any(
          (lowStock) => lowStock.id_produto.toString() == p.id,
        );
      }).toList();
    });
  }
}
