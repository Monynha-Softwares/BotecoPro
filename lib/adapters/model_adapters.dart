import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

const uuid = Uuid();

// Adapter classes to help with model transitions

class OrderAdapter {
  static Pedido toPedido(Order order) {
    return Pedido(
      id_pedido: int.tryParse(order.id),
      id_venda: int.tryParse(order.tableId) ?? 0,
      id_mesa: order.tableNumber,
      data_pedido: order.createdAt,
      status_pedido: _mapOrderStatus(order.status),
    );
  }

  static Order fromPedido(
    Pedido pedido,
    List<OrderItem> items,
  ) {
    return Order(
      id: pedido.id_pedido?.toString() ?? uuid.v4(),
      tableId: pedido.id_mesa.toString(),
      tableNumber: pedido.id_mesa,
      createdAt: pedido.data_pedido,
      status: _mapPedidoStatus(pedido.status_pedido),
      items: items,
      isClosed:
          pedido.status_pedido == 'entregue' || pedido.status_pedido == 'cancelado',
    );
  }

  static String _mapOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pendente';
      case OrderStatus.preparing:
        return 'preparando';
      case OrderStatus.ready:
        return 'pronto';
      case OrderStatus.delivered:
        return 'entregue';
      case OrderStatus.canceled:
        return 'cancelado';
    }
  }

  static OrderStatus _mapPedidoStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return OrderStatus.pending;
      case 'preparando':
        return OrderStatus.preparing;
      case 'pronto':
        return OrderStatus.ready;
      case 'entregue':
        return OrderStatus.delivered;
      case 'cancelado':
        return OrderStatus.canceled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItemAdapter {
  static PedidoItem toPedidoItem(OrderItem item, int pedidoId) {
    return PedidoItem(
      id_pedido_item: int.tryParse(item.id),
      id_pedido: pedidoId,
      tipo_item: 'produto', // Default to product
      id_item: int.tryParse(item.productId) ?? 0,
      quantidade: item.quantity.toDouble(),
      preco_unitario: item.price,
      observacao: item.notes,
    );
  }

  static OrderItem fromPedidoItem(
    PedidoItem item, {
    required String productName,
  }) {
    return OrderItem(
      id: item.id_pedido_item?.toString() ?? uuid.v4(),
      productId: item.id_item.toString(),
      productName: productName,
      quantity: item.quantidade.toInt(),
      price: item.preco_unitario,
      notes: item.observacao ?? '',
      status: _mapItemStatus(item),
    );
  }

  static OrderStatus _mapItemStatus(PedidoItem item) {
    // Determine item status based on the pedido status or other factors
    // You might need more context to accurately determine this
    return OrderStatus.pending;
  }
}

class RecipeAdapter {
  static Receita toReceita(Recipe recipe) {
    return Receita(
      id_receita: int.tryParse(recipe.id),
      nome: recipe.name,
      tipo_receita: recipe.type == RecipeType.food ? 'porcao' : 'cocktail',
      preco_venda: recipe.price,
      tempo_preparo_minutos: recipe.preparationMinutes,
    );
  }

  static Recipe fromReceita(
    Receita receita,
    List<RecipeIngredient> ingredientes,
  ) {
    return Recipe(
      id: receita.id_receita?.toString() ?? uuid.v4(),
      name: receita.nome,
      type: receita.tipo_receita == 'cocktail' ? RecipeType.drink : RecipeType.food,
      price: receita.preco_venda,
      preparationMinutes: receita.tempo_preparo_minutos,
      instructions: '', // Not in DB model
      ingredients: ingredientes,
    );
  }
}

class RecipeIngredientAdapter {
  static ReceitaIngrediente toReceitaIngrediente(RecipeIngredient ingredient, int receitaId) {
    return ReceitaIngrediente(
      id_receita: receitaId,
      id_produto: int.tryParse(ingredient.productId) ?? 0,
      quantidade_utilizada: ingredient.quantity.toDouble(),
    );
  }

  static RecipeIngredient fromReceitaIngrediente(
    ReceitaIngrediente ingredient, {
    required String productName,
    required String unit,
  }) {
    return RecipeIngredient(
      id: ingredient.id?.toString() ?? uuid.v4(),
      productId: ingredient.id_produto.toString(),
      productName: productName,
      quantity: ingredient.quantidade_utilizada.toInt(),
      unit: unit,
    );
  }
}

class ProductionAdapter {
  static ProducaoCaseira toProducaoCaseira(InternalProduction production) {
    return ProducaoCaseira(
      id_producao: int.tryParse(production.id),
      nome: production.name,
      quantidade_gerada: production.quantity.toDouble(),
      unidade_gerada: production.unit,
      data_inicio_producao: production.createdAt,
      data_fim_disponivel: production.finalizedAt,
    );
  }

  static InternalProduction fromProducaoCaseira(
    ProducaoCaseira producao,
    List<ProducaoIngrediente> ingredientes,
    Map<int, Produto> produtos,
  ) {
    return InternalProduction(
      id: producao.id_producao?.toString() ?? uuid.v4(),
      name: producao.nome,
      quantity: producao.quantidade_gerada.toInt(),
      unit: producao.unidade_gerada,
      createdAt: producao.data_inicio_producao,
      finalizedAt: producao.data_fim_disponivel,
      status: producao.data_fim_disponivel != null ? ProductionStatus.finalized : ProductionStatus.inProgress,
      ingredients: ingredientes
          .map((i) => ProductionIngredientAdapter.fromProducaoIngrediente(
                i,
                productName: produtos[i.id_produto]?.nome ?? 'Produto',
                unit: produtos[i.id_produto]?.unidade_base ?? 'unidade',
              ))
          .toList(),
    );
  }
}

class ProductionIngredientAdapter {
  static ProducaoIngrediente toProducaoIngrediente(ProductionIngredient ingredient, int producaoId) {
    return ProducaoIngrediente(
      id_producao: producaoId,
      id_produto: int.tryParse(ingredient.productId) ?? 0,
      quantidade_utilizada: ingredient.quantity.toDouble(),
    );
  }

  static ProductionIngredient fromProducaoIngrediente(
    ProducaoIngrediente ingredient, {
    required String productName,
    required String unit,
  }) {
    return ProductionIngredient(
      id: ingredient.id?.toString() ?? uuid.v4(),
      productId: ingredient.id_produto.toString(),
      productName: productName,
      quantity: ingredient.quantidade_utilizada.toInt(),
      unit: unit,
    );
  }
}

class ProductAdapter {
  static Produto toProduto(Product product) {
    return Produto(
      id_produto: int.tryParse(product.id),
      nome: product.name,
      unidade_base: product.unit,
      tipo_produto: 'compra', // Default value
      controla_estoque: true,
      id_categoria: 1, // Default category
    );
  }

  static Product fromProduto(Produto produto, ProdutoVenda? produtoVenda) {
    return Product(
      id: produto.id_produto?.toString() ?? uuid.v4(),
      name: produto.nome,
      category: _mapCategoria(produto.id_categoria),
      price: produtoVenda?.preco_venda ?? 0.0,
      stockQuantity: 0, // Would need to fetch from Estoque
      unit: produto.unidade_base,
      description: '',
    );
  }

  static ProductCategory _mapCategoria(int? idCategoria) {
    // Simple mapping based on ID
    if (idCategoria == 1) return ProductCategory.drink;
    if (idCategoria == 2) return ProductCategory.food;
    return ProductCategory.other;
  }
}