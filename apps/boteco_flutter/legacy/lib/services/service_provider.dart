import 'package:flutter/material.dart';

import '../adapters/model_adapters.dart';
import '../models/data_models.dart';
import 'api_service.dart';
import 'database_service.dart';

/// ServiceProvider é responsável por gerenciar qual serviço de dados será usado.
/// No modo offline, usa o DatabaseService local com SharedPreferences.
/// No modo online, usa o ApiService para conectar com o backend.
class ServiceProvider with ChangeNotifier {
  final DatabaseService _localService = DatabaseService();
  final ApiService _apiService = ApiService();

  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Initialize the database
  Future<void> initializeData() async {
    await _localService.initializeData();
  }

  // Método para alternar entre online e offline
  Future<void> toggleOnlineMode(bool online) async {
    if (online == _isOnline) return;

    _isOnline = online;

    if (online) {
      // Se está entrando no modo online, sincronizar dados
      await syncData();
    }

    notifyListeners();
  }

  // Sincronizar dados entre local e API
  Future<void> syncData() async {
    if (!_isOnline || _isSyncing) return;

    try {
      _isSyncing = true;
      notifyListeners();

      // Obter dados da API
      await _syncFornecedores();
      await _syncCategorias();
      await _syncProdutos();
      await _syncProdutosVenda();
      await _syncMesas();
      await _syncReceitas();
      await _syncProducoes();
      await _syncEstoque();

      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Error syncing data: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // FORNECEDORES (Suppliers)
  Future<List<Fornecedor>> getFornecedores() async {
    if (_isOnline) {
      return await _apiService.getSuppliers();
    } else {
      return await _localService.getFornecedores();
    }
  }

  Future<void> addFornecedor(Fornecedor fornecedor) async {
    if (_isOnline) {
      final success = await _apiService.createSupplier(fornecedor);
      if (success) {
        // Atualizar cache local
        await _syncFornecedores();
      }
    } else {
      await _localService.addFornecedor(fornecedor);
    }
  }

  Future<void> updateFornecedor(Fornecedor fornecedor) async {
    if (_isOnline) {
      final success = await _apiService.updateSupplier(fornecedor);
      if (success) {
        await _syncFornecedores();
      }
    } else {
      await _localService.updateFornecedor(fornecedor);
    }
  }

  Future<void> deleteFornecedor(int id_fornecedor) async {
    // API não tem endpoint de delete, então só mexemos no cache local
    await _localService.deleteFornecedor(id_fornecedor);
  }

  Future<void> _syncFornecedores() async {
    final apiFornecedores = await _apiService.getSuppliers();
    await _localService.saveFornecedores(apiFornecedores);
  }

  // CATEGORIAS (Categories)
  Future<List<Categoria>> getCategorias() async {
    if (_isOnline) {
      return await _apiService.getCategories();
    } else {
      return await _localService.getCategorias();
    }
  }

  Future<void> _syncCategorias() async {
    final apiCategorias = await _apiService.getCategories();
    await _localService.saveCategorias(apiCategorias);
  }

  // PRODUTOS (Products)
  Future<List<Produto>> getProdutos() async {
    if (_isOnline) {
      return await _apiService.getProducts();
    } else {
      return await _localService.getProdutos();
    }
  }

  Future<List<ProdutoVenda>> getProdutosVenda() async {
    if (_isOnline) {
      return await _apiService.getProductSales();
    } else {
      return await _localService.getProdutosVenda();
    }
  }

  Future<void> addProduto(Produto produto) async {
    if (_isOnline) {
      final success = await _apiService.createProduct(produto);
      if (success) {
        await _syncProdutos();
      }
    } else {
      await _localService.addProduto(produto);
    }
  }

  Future<void> addProdutoVenda(ProdutoVenda produtoVenda) async {
    if (_isOnline) {
      final success = await _apiService.createProductSale(produtoVenda);
      if (success) {
        await _syncProdutosVenda();
      }
    } else {
      final produtos = await _localService.getProdutosVenda();
      // Set next available ID if null
      if (produtoVenda.id_venda == null) {
        int nextId = 1;
        if (produtos.isNotEmpty) {
          nextId = produtos
                  .map((p) => p.id_venda ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;
        }
        produtoVenda = ProdutoVenda(
          id_venda: nextId,
          id_produto: produtoVenda.id_produto,
          descricao_venda: produtoVenda.descricao_venda,
          quantidade_base: produtoVenda.quantidade_base,
          preco_venda: produtoVenda.preco_venda,
        );
      }
      produtos.add(produtoVenda);
      await _localService.saveProdutosVenda(produtos);
    }
  }

  Future<void> updateEstoqueProduto(
      int id_produto, double novaQuantidade) async {
    if (_isOnline) {
      final estoque = await getEstoque();
      final currentStock = estoque
          .firstWhere(
            (e) => e.id_produto == id_produto,
            orElse: () => Estoque(
              id_produto: id_produto,
              quantidade_disponivel: 0,
              data_atualizacao: DateTime.now(),
            ),
          )
          .quantidade_disponivel;

      // For API, we need to create either an entry or adjustment
      if (currentStock == 0) {
        // Create a stock entry for new products
        await _apiService.createStockEntry(
          EntradaEstoque(
            id_produto: id_produto,
            quantidade_entrada: novaQuantidade,
            data_entrada: DateTime.now(),
            observacao: 'Ajuste inicial de estoque',
          ),
        );
      } else {
        // Create a stock adjustment for existing products
        await _apiService.createStockAdjustment(
          AjusteEstoque(
            id_produto: id_produto,
            quantidade_anterior: currentStock,
            quantidade_nova: novaQuantidade,
            data_ajuste: DateTime.now(),
            motivo: 'Ajuste manual de estoque',
          ),
        );
      }

      // Sync stock data
      await _syncEstoque();
    } else {
      await _localService.updateEstoqueProduto(id_produto, novaQuantidade);
    }
  }

  Future<void> _syncProdutos() async {
    final apiProdutos = await _apiService.getProducts();
    await _localService.saveProdutos(apiProdutos);
  }

  Future<void> _syncProdutosVenda() async {
    final apiProdutosVenda = await _apiService.getProductSales();
    await _localService.saveProdutosVenda(apiProdutosVenda);
  }

  // ESTOQUE (Stock)
  Future<List<Estoque>> getEstoque() async {
    if (_isOnline) {
      return await _apiService.getStock();
    } else {
      return await _localService.getEstoque();
    }
  }

  Future<void> _syncEstoque() async {
    final apiEstoque = await _apiService.getStock();
    await _localService.saveEstoque(apiEstoque);
  }

  // MESAS (Tables)
  Future<List<Mesa>> getMesas() async {
    if (_isOnline) {
      return await _apiService.getTables();
    } else {
      return await _localService.getMesas();
    }
  }

  Future<void> saveMesas(List<Mesa> mesas) async {
    // No modo online, cada mesa nova precisa ser criada individualmente
    if (_isOnline) {
      final existingMesas = await _apiService.getTables();

      for (var mesa in mesas) {
        // Verificar se a mesa já existe na API
        final existingMesa =
            existingMesas.any((t) => t.id_mesa == mesa.id_mesa);

        if (!existingMesa) {
          await _apiService.createTable(mesa);
        }
      }

      await _syncMesas();
    } else {
      await _localService.saveMesas(mesas);
    }
  }

  Future<void> _syncMesas() async {
    final apiMesas = await _apiService.getTables();
    await _localService.saveMesas(apiMesas);
  }

  // VENDAS (Sales)
  Future<List<Venda>> getVendas() async {
    if (_isOnline) {
      return await _apiService.getSales();
    } else {
      return await _localService.getVendas();
    }
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
    if (_isOnline) {
      final vendas = await _apiService.getSales();
      return vendas.where((v) => v.status_aberta).toList();
    } else {
      return await _localService.getVendasAtivas();
    }
  }

  Future<Venda?> getVendaAtivaMesa(int id_mesa) async {
    if (_isOnline) {
      final vendas = await _apiService.getSales();
      try {
        return vendas.firstWhere(
          (v) => v.id_mesa == id_mesa && v.status_aberta,
        );
      } catch (e) {
        return null;
      }
    } else {
      return await _localService.getVendaAtivaMesa(id_mesa);
    }
  }

  Future<void> addVenda(Venda venda) async {
    if (_isOnline) {
      final success = await _apiService.createSale(venda);
      if (success) {
        await _syncMesas(); // Mesas are affected by sales
        await _syncVendas();
      }
    } else {
      await _localService.addVenda(venda);
    }
  }

  Future<void> closeVenda(int id_venda) async {
    if (_isOnline) {
      await _apiService.closeSale(id_venda);
      await _syncMesas(); // Mesas are affected by closed sales
      await _syncVendas();
    } else {
      await _localService.closeVenda(id_venda);
    }
  }

  Future<void> cancelVenda(int id_venda) async {
    if (_isOnline) {
      await _apiService.cancelSale(id_venda);
      await _syncMesas(); // Mesas are affected by canceled sales
      await _syncVendas();
    } else {
      await _localService.cancelVenda(id_venda);
    }
  }

  Future<void> _syncVendas() async {
    final apiVendas = await _apiService.getSales();
    await _localService.saveVendas(apiVendas);
  }

  // PEDIDOS (Orders)
  Future<List<Pedido>> getPedidos() async {
    if (_isOnline) {
      return await _apiService.getOrders();
    } else {
      return await _localService.getPedidos();
    }
  }

  Future<List<Order>> getOrders() async {
    final pedidos = await getPedidos();
    List<Order> orders = [];

    for (var pedido in pedidos) {
      if (pedido.id_pedido != null) {
        final items = await getPedidoItensByPedido(pedido.id_pedido!);
        orders.add(OrderAdapter.fromPedido(pedido, items));
      }
    }

    return orders;
  }

  Future<void> addPedido(Pedido pedido) async {
    if (_isOnline) {
      final success = await _apiService.createOrder(pedido);
      if (success) {
        await _syncPedidos();
      }
    } else {
      await _localService.addPedido(pedido);
    }
  }

  Future<void> updatePedidoStatus(int id_pedido, String status) async {
    if (_isOnline) {
      await _apiService.updateOrderStatus(id_pedido, status);
      await _syncPedidos();
    } else {
      await _localService.updatePedidoStatus(id_pedido, status);
    }
  }

  Future<List<PedidoItem>> getPedidoItens() async {
    if (_isOnline) {
      return await _apiService.getOrderItems();
    } else {
      return await _localService.getPedidoItens();
    }
  }

  Future<List<PedidoItem>> getPedidoItensByPedido(int id_pedido) async {
    if (_isOnline) {
      final allItems = await _apiService.getOrderItems();
      return allItems.where((i) => i.id_pedido == id_pedido).toList();
    } else {
      return await _localService.getPedidoItensByPedido(id_pedido);
    }
  }

  Future<void> addPedidoItem(PedidoItem item) async {
    if (_isOnline) {
      await _apiService.addOrderItem(item);
      await _syncPedidoItens();
    } else {
      await _localService.addPedidoItem(item);
    }
  }

  Future<void> _syncPedidos() async {
    final apiPedidos = await _apiService.getOrders();
    await _localService.savePedidos(apiPedidos);
  }

  Future<void> _syncPedidoItens() async {
    final apiPedidoItens = await _apiService.getOrderItems();
    await _localService.savePedidoItens(apiPedidoItens);
  }

  // RECEITAS (Recipes)
  Future<List<Receita>> getReceitas() async {
    if (_isOnline) {
      return await _apiService.getRecipes();
    } else {
      return await _localService.getReceitas();
    }
  }

  Future<void> addReceita(Receita receita) async {
    if (_isOnline) {
      final success = await _apiService.createRecipe(receita);
      if (success) {
        await _syncReceitas();
      }
    } else {
      await _localService.addReceita(receita);
    }
  }

  Future<List<ReceitaIngrediente>> getReceitaIngredientes() async {
    if (_isOnline) {
      return await _apiService.getRecipeIngredients();
    } else {
      return await _localService.getReceitaIngredientes();
    }
  }

  Future<List<ReceitaIngrediente>> getReceitaIngredientesByReceita(
      int id_receita) async {
    if (_isOnline) {
      final allIngredients = await _apiService.getRecipeIngredients();
      return allIngredients.where((i) => i.id_receita == id_receita).toList();
    } else {
      return await _localService.getReceitaIngredientesByReceita(id_receita);
    }
  }

  Future<void> addReceitaIngrediente(ReceitaIngrediente ingrediente) async {
    if (_isOnline) {
      final success = await _apiService.addRecipeIngredient(ingrediente);
      if (success) {
        await _syncReceitaIngredientes();
      }
    } else {
      await _localService.addReceitaIngrediente(ingrediente);
    }
  }

  Future<void> _syncReceitas() async {
    final apiReceitas = await _apiService.getRecipes();
    await _localService.saveReceitas(apiReceitas);
  }

  Future<void> _syncReceitaIngredientes() async {
    final apiIngredientes = await _apiService.getRecipeIngredients();
    await _localService.saveReceitaIngredientes(apiIngredientes);
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
      tempo_preparo_minutos: receitas[index].tempo_preparo_minutos,
      id_categoria: receitas[index].id_categoria,
    );

    await _localService.saveReceitas(receitas);

    // Update ingredients (simplified approach)
    // This would need more robust logic for a real migration
    final existingIngredients =
        await getReceitaIngredientesByReceita(receitaId);

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
  Future<List<ProducaoCaseira>> getProducoes() async {
    if (_isOnline) {
      return await _apiService.getInternalProductions();
    } else {
      return await _localService.getProducoes();
    }
  }

  Future<void> addProducao(ProducaoCaseira producao) async {
    if (_isOnline) {
      final success = await _apiService.createInternalProduction(producao);
      if (success) {
        await _syncProducoes();
      }
    } else {
      await _localService.addProducao(producao);
    }
  }

  Future<List<ProducaoIngrediente>> getProducaoIngredientes() async {
    if (_isOnline) {
      return await _apiService.getProductionIngredients();
    } else {
      return await _localService.getProducaoIngredientes();
    }
  }

  Future<List<ProducaoIngrediente>> getProducaoIngredientesByProducao(
      int id_producao) async {
    if (_isOnline) {
      final allIngredients = await _apiService.getProductionIngredients();
      return allIngredients.where((i) => i.id_producao == id_producao).toList();
    } else {
      return await _localService.getProducaoIngredientesByProducao(id_producao);
    }
  }

  Future<void> addProducaoIngrediente(ProducaoIngrediente ingrediente) async {
    if (_isOnline) {
      final success = await _apiService.addProductionIngredient(ingrediente);
      if (success) {
        await _syncProducaoIngredientes();
        // Also update stock (ingredients are consumed from stock)
        await _syncEstoque();
      }
    } else {
      await _localService.addProducaoIngrediente(ingrediente);
    }
  }

  Future<void> _syncProducoes() async {
    final apiProducoes = await _apiService.getInternalProductions();
    await _localService.saveProducoes(apiProducoes);
  }

  Future<void> _syncProducaoIngredientes() async {
    final apiIngredientes = await _apiService.getProductionIngredients();
    await _localService.saveProducaoIngredientes(apiIngredientes);
  }

  // ESTATÍSTICAS (Statistics)
  Future<double> getVendasDiarias() async {
    if (_isOnline) {
      return await _apiService.getTodaySales();
    } else {
      return await _localService.getVendasDiarias();
    }
  }

  Future<List<Produto>> getProdutosEstoqueBaixo(int threshold) async {
    if (_isOnline) {
      return await _apiService.getLowStockProducts(threshold);
    } else {
      return await _localService.getProdutosEstoqueBaixo(threshold);
    }
  }

  // Legacy compatibility methods for the transition phase

  Future<List<Supplier>> getSuppliers() async {
    final fornecedores = await getFornecedores();
    return fornecedores.map((f) => f.toSupplier()).toList();
  }

  Future<void> addSupplier(Supplier supplier) async {
    final fornecedor = supplier.toFornecedor();
    await addFornecedor(fornecedor);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final fornecedor = supplier.toFornecedor();
    await updateFornecedor(fornecedor);
  }

  Future<void> deleteSupplier(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      await deleteFornecedor(intId);
    }
  }

  Future<List<TableModel>> getTables() async {
    final mesas = await getMesas();
    return mesas.map((m) => m.toTableModel()).toList();
  }

  Future<void> saveTables(List<TableModel> tables) async {
    // Convert legacy tables to new Mesa format
    final List<Mesa> mesas = [];
    for (var table in tables) {
      final intId = int.tryParse(table.id);
      mesas.add(Mesa(
        id_mesa: intId,
        numero_mesa: table.number,
        quantidade_lugares: table.capacity,
        status_ocupada: table.status == TableStatus.occupied,
      ));
    }
    await _localService.saveMesas(mesas);
  }

  Future<Order?> getActiveOrderForTable(String tableId) async {
    final intId = int.tryParse(tableId);
    if (intId != null) {
      // Get active sale for this table
      final venda = await getVendaAtivaMesa(intId);
      if (venda != null) {
        // Get all pedidos for this sale
        final pedidos = await getPedidos();
        final pedidosVenda =
            pedidos.where((p) => p.id_venda == venda.id_venda).toList();

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
          return Order(
            id: venda.id_venda?.toString() ?? uuid.v4(),
            tableId: tableId,
            tableNumber: intId,
            createdAt: venda.data_venda,
            items: allItems
                .map((item) => OrderItemAdapter.fromPedidoItem(item))
                .toList(),
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
    List<Order> orders = [];

    for (var venda in vendasAtivas) {
      // Get all pedidos for this venda
      final pedidos = await getPedidos();
      final pedidosVenda =
          pedidos.where((p) => p.id_venda == venda.id_venda).toList();

      if (pedidosVenda.isNotEmpty) {
        // Get items for each pedido
        List<PedidoItem> allItems = [];
        for (var pedido in pedidosVenda) {
          if (pedido.id_pedido != null) {
            final items = await getPedidoItensByPedido(pedido.id_pedido!);
            allItems.addAll(items);
          }
        }

        // Create an Order with the venda
        final order = Order(
          id: venda.id_venda?.toString() ?? uuid.v4(),
          tableId: venda.id_mesa.toString(),
          tableNumber: venda.id_mesa,
          createdAt: venda.data_venda,
          items: allItems
              .map((item) => OrderItemAdapter.fromPedidoItem(item))
              .toList(),
          status: OrderStatus.pending, // Would need proper mapping
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
      final createdPedido =
          updatedPedidos.lastWhere((p) => p.id_venda == vendaId);

      // Add all items in the order to this pedido
      for (var item in order.items) {
        final pedidoItem =
            OrderItemAdapter.toPedidoItem(item, createdPedido.id_pedido!);
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
          final pedidoItem =
              OrderItemAdapter.toPedidoItem(item, pedido.id_pedido!);
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
    final createdVenda =
        vendas.lastWhere((v) => v.id_mesa == tableId && v.status_aberta);

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
    final createdPedido =
        pedidos.lastWhere((p) => p.id_venda == createdVenda.id_venda);

    // Add all items in the order to this pedido
    for (var item in order.items) {
      final pedidoItem =
          OrderItemAdapter.toPedidoItem(item, createdPedido.id_pedido!);
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
    List<Recipe> recipes = [];

    for (var receita in receitas) {
      if (receita.id_receita != null) {
        final ingredientes =
            await getReceitaIngredientesByReceita(receita.id_receita!);
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
      String recipeId, RecipeIngredient ingredient) async {
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
    List<InternalProduction> productions = [];

    for (var producao in producoes) {
      if (producao.id_producao != null) {
        final ingredientes =
            await getProducaoIngredientesByProducao(producao.id_producao!);
        productions
            .add(ProductionAdapter.fromProducaoCaseira(producao, ingredientes));
      }
    }

    return productions;
  }

  Future<void> addInternalProduction(InternalProduction production) async {
    final producao = ProductionAdapter.toProducaoCaseira(production);
    await addProducao(producao);

    // Get the created production ID
    final producoes = await getProducoes();
    final createdProducao =
        producoes.lastWhere((p) => p.nome == production.name);

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
      String productionId, ProductionIngredient ingredient) async {
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
      final existingIngredients =
          await getProducaoIngredientesByProducao(producaoId);

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
          createdProduto.id_produto!, product.stockQuantity.toDouble());
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

    await _localService.saveProdutos(produtos);

    // Update produto venda
    final produtosVenda = await getProdutosVenda();
    final pvIndex =
        produtosVenda.indexWhere((pv) => pv.id_produto == produtoId);

    if (pvIndex != -1) {
      produtosVenda[pvIndex] = ProdutoVenda(
        id_venda: produtosVenda[pvIndex].id_venda,
        id_produto: produtoId,
        descricao_venda: '${product.name} (Padrão)',
        quantidade_base: produtosVenda[pvIndex].quantidade_base,
        preco_venda: product.price,
      );

      await _localService.saveProdutosVenda(produtosVenda);
    }
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
        return produtos
            .any((lowStock) => lowStock.id_produto.toString() == p.id);
      }).toList();
    });
  }
}
