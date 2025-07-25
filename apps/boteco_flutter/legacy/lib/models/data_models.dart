import 'dart:convert';
import 'package:uuid/uuid.dart';

// Used for generating temporary IDs in offline mode
const uuid = Uuid();

// Table: Fornecedor (Supplier)
class Fornecedor {
  final int? id_fornecedor; // Using nullable to handle new entries
  String nome;
  String? telefone;
  String? email;
  String? contato;
  String? detalhes;

  Fornecedor({
    this.id_fornecedor,
    required this.nome,
    this.telefone,
    this.email,
    this.contato,
    this.detalhes,
  });

  Fornecedor copyWith({
    String? nome,
    String? telefone,
    String? email,
    String? contato,
    String? detalhes,
  }) {
    return Fornecedor(
      id_fornecedor: id_fornecedor,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      contato: contato ?? this.contato,
      detalhes: detalhes ?? this.detalhes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_fornecedor': id_fornecedor,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'contato': contato,
      'detalhes': detalhes,
    };
  }

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      id_fornecedor: json['id_fornecedor'],
      nome: json['nome'] ?? '',
      telefone: json['telefone'],
      email: json['email'],
      contato: json['contato'],
      detalhes: json['detalhes'],
    );
  }
}

// Table: Categoria (Category)
class Categoria {
  final int? id_categoria;
  String nome;
  String? descricao;

  Categoria({
    this.id_categoria,
    required this.nome,
    this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_categoria': id_categoria,
      'nome': nome,
      'descricao': descricao,
    };
  }

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id_categoria: json['id_categoria'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
    );
  }
}

// Table: Produto (Product)
class Produto {
  final int? id_produto;
  String nome;
  String unidade_base;
  String tipo_produto; // 'compra', 'producao', 'ingrediente', 'ambos'
  bool controla_estoque;
  int? id_categoria;

  Produto({
    this.id_produto,
    required this.nome,
    required this.unidade_base,
    required this.tipo_produto,
    this.controla_estoque = true,
    this.id_categoria,
  });

  Produto copyWith({
    String? nome,
    String? unidade_base,
    String? tipo_produto,
    bool? controla_estoque,
    int? id_categoria,
  }) {
    return Produto(
      id_produto: id_produto,
      nome: nome ?? this.nome,
      unidade_base: unidade_base ?? this.unidade_base,
      tipo_produto: tipo_produto ?? this.tipo_produto,
      controla_estoque: controla_estoque ?? this.controla_estoque,
      id_categoria: id_categoria ?? this.id_categoria,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produto': id_produto,
      'nome': nome,
      'unidade_base': unidade_base,
      'tipo_produto': tipo_produto,
      'controla_estoque': controla_estoque,
      'id_categoria': id_categoria,
    };
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id_produto: json['id_produto'],
      nome: json['nome'] ?? '',
      unidade_base: json['unidade_base'] ?? 'unidade',
      tipo_produto: json['tipo_produto'] ?? 'compra',
      controla_estoque: json['controla_estoque'] == true || json['controla_estoque'] == 1,
      id_categoria: json['id_categoria'],
    );
  }
}

// Table: Produto_Venda (Product_Sale)
class ProdutoVenda {
  final int? id_venda;
  int id_produto;
  String descricao_venda;
  double quantidade_base;
  double preco_venda;

  ProdutoVenda({
    this.id_venda,
    required this.id_produto,
    required this.descricao_venda,
    required this.quantidade_base,
    required this.preco_venda,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_venda': id_venda,
      'id_produto': id_produto,
      'descricao_venda': descricao_venda,
      'quantidade_base': quantidade_base,
      'preco_venda': preco_venda,
    };
  }

  factory ProdutoVenda.fromJson(Map<String, dynamic> json) {
    return ProdutoVenda(
      id_venda: json['id_venda'],
      id_produto: json['id_produto'] ?? 0,
      descricao_venda: json['descricao_venda'] ?? '',
      quantidade_base: (json['quantidade_base'] ?? 0).toDouble(),
      preco_venda: (json['preco_venda'] ?? 0).toDouble(),
    );
  }
}

// Table: Receita (Recipe)
class Receita {
  final int? id_receita;
  String nome;
  String tipo_receita; // 'cocktail', 'dose', 'porcao'
  double preco_venda;
  int? tempo_preparo_minutos;
  int? id_categoria;

  Receita({
    this.id_receita,
    required this.nome,
    required this.tipo_receita,
    required this.preco_venda,
    this.tempo_preparo_minutos,
    this.id_categoria,
  });

  Receita copyWith({
    String? nome,
    String? tipo_receita,
    double? preco_venda,
    int? tempo_preparo_minutos,
    int? id_categoria,
  }) {
    return Receita(
      id_receita: id_receita,
      nome: nome ?? this.nome,
      tipo_receita: tipo_receita ?? this.tipo_receita,
      preco_venda: preco_venda ?? this.preco_venda,
      tempo_preparo_minutos: tempo_preparo_minutos ?? this.tempo_preparo_minutos,
      id_categoria: id_categoria ?? this.id_categoria,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_receita': id_receita,
      'nome': nome,
      'tipo_receita': tipo_receita,
      'preco_venda': preco_venda,
      'tempo_preparo_minutos': tempo_preparo_minutos,
      'id_categoria': id_categoria,
    };
  }

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id_receita: json['id_receita'],
      nome: json['nome'] ?? '',
      tipo_receita: json['tipo_receita'] ?? 'porcao',
      preco_venda: (json['preco_venda'] ?? 0).toDouble(),
      tempo_preparo_minutos: json['tempo_preparo_minutos'],
      id_categoria: json['id_categoria'],
    );
  }
}

// Table: Receita_Ingrediente (Recipe_Ingredient)
class ReceitaIngrediente {
  final int? id;
  int id_receita;
  int id_produto;
  double quantidade_utilizada;

  ReceitaIngrediente({
    this.id,
    required this.id_receita,
    required this.id_produto,
    required this.quantidade_utilizada,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_receita': id_receita,
      'id_produto': id_produto,
      'quantidade_utilizada': quantidade_utilizada,
    };
  }

  factory ReceitaIngrediente.fromJson(Map<String, dynamic> json) {
    return ReceitaIngrediente(
      id: json['id'],
      id_receita: json['id_receita'] ?? 0,
      id_produto: json['id_produto'] ?? 0,
      quantidade_utilizada: (json['quantidade_utilizada'] ?? 0).toDouble(),
    );
  }
}

// Table: Producao_Caseira (In-house Production)
class ProducaoCaseira {
  final int? id_producao;
  String nome;
  double quantidade_gerada;
  String unidade_gerada;
  int? tempo_preparo;
  DateTime? data_inicio_producao;
  DateTime? data_fim_disponivel;

  ProducaoCaseira({
    this.id_producao,
    required this.nome,
    required this.quantidade_gerada,
    required this.unidade_gerada,
    this.tempo_preparo,
    this.data_inicio_producao,
    this.data_fim_disponivel,
  });

  ProducaoCaseira copyWith({
    String? nome,
    double? quantidade_gerada,
    String? unidade_gerada,
    int? tempo_preparo,
    DateTime? data_inicio_producao,
    DateTime? data_fim_disponivel,
  }) {
    return ProducaoCaseira(
      id_producao: id_producao,
      nome: nome ?? this.nome,
      quantidade_gerada: quantidade_gerada ?? this.quantidade_gerada,
      unidade_gerada: unidade_gerada ?? this.unidade_gerada,
      tempo_preparo: tempo_preparo ?? this.tempo_preparo,
      data_inicio_producao: data_inicio_producao ?? this.data_inicio_producao,
      data_fim_disponivel: data_fim_disponivel ?? this.data_fim_disponivel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producao': id_producao,
      'nome': nome,
      'quantidade_gerada': quantidade_gerada,
      'unidade_gerada': unidade_gerada,
      'tempo_preparo': tempo_preparo,
      'data_inicio_producao': data_inicio_producao?.toIso8601String(),
      'data_fim_disponivel': data_fim_disponivel?.toIso8601String(),
    };
  }

  factory ProducaoCaseira.fromJson(Map<String, dynamic> json) {
    return ProducaoCaseira(
      id_producao: json['id_producao'],
      nome: json['nome'] ?? '',
      quantidade_gerada: (json['quantidade_gerada'] ?? 0).toDouble(),
      unidade_gerada: json['unidade_gerada'] ?? 'unidade',
      tempo_preparo: json['tempo_preparo'],
      data_inicio_producao: json['data_inicio_producao'] != null 
          ? DateTime.parse(json['data_inicio_producao']) 
          : null,
      data_fim_disponivel: json['data_fim_disponivel'] != null 
          ? DateTime.parse(json['data_fim_disponivel']) 
          : null,
    );
  }
}

// Table: Producao_Ingrediente (Production_Ingredient)
class ProducaoIngrediente {
  final int? id;
  int id_producao;
  int id_produto;
  double quantidade_utilizada;

  ProducaoIngrediente({
    this.id,
    required this.id_producao,
    required this.id_produto,
    required this.quantidade_utilizada,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_producao': id_producao,
      'id_produto': id_produto,
      'quantidade_utilizada': quantidade_utilizada,
    };
  }

  factory ProducaoIngrediente.fromJson(Map<String, dynamic> json) {
    return ProducaoIngrediente(
      id: json['id'],
      id_producao: json['id_producao'] ?? 0,
      id_produto: json['id_produto'] ?? 0,
      quantidade_utilizada: (json['quantidade_utilizada'] ?? 0).toDouble(),
    );
  }
}

// Table: Estoque (Stock)
class Estoque {
  final int? id_estoque;
  int id_produto;
  double quantidade_disponivel;
  DateTime data_atualizacao;

  Estoque({
    this.id_estoque,
    required this.id_produto,
    required this.quantidade_disponivel,
    required this.data_atualizacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_estoque': id_estoque,
      'id_produto': id_produto,
      'quantidade_disponivel': quantidade_disponivel,
      'data_atualizacao': data_atualizacao.toIso8601String(),
    };
  }

  factory Estoque.fromJson(Map<String, dynamic> json) {
    return Estoque(
      id_estoque: json['id_estoque'],
      id_produto: json['id_produto'] ?? 0,
      quantidade_disponivel: (json['quantidade_disponivel'] ?? 0).toDouble(),
      data_atualizacao: json['data_atualizacao'] != null 
          ? DateTime.parse(json['data_atualizacao']) 
          : DateTime.now(),
    );
  }
}

// Table: Entrada_Estoque (Stock_Entry)
class EntradaEstoque {
  final int? id_entrada;
  int id_produto;
  double quantidade_entrada;
  DateTime data_entrada;
  String? observacao;

  EntradaEstoque({
    this.id_entrada,
    required this.id_produto,
    required this.quantidade_entrada,
    required this.data_entrada,
    this.observacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_entrada': id_entrada,
      'id_produto': id_produto,
      'quantidade_entrada': quantidade_entrada,
      'data_entrada': data_entrada.toIso8601String(),
      'observacao': observacao,
    };
  }

  factory EntradaEstoque.fromJson(Map<String, dynamic> json) {
    return EntradaEstoque(
      id_entrada: json['id_entrada'],
      id_produto: json['id_produto'] ?? 0,
      quantidade_entrada: (json['quantidade_entrada'] ?? 0).toDouble(),
      data_entrada: json['data_entrada'] != null 
          ? DateTime.parse(json['data_entrada']) 
          : DateTime.now(),
      observacao: json['observacao'],
    );
  }
}

// Table: Ajuste_Estoque (Stock_Adjustment)
class AjusteEstoque {
  final int? id_ajuste;
  int id_produto;
  double quantidade_anterior;
  double quantidade_nova;
  DateTime data_ajuste;
  String? motivo;

  AjusteEstoque({
    this.id_ajuste,
    required this.id_produto,
    required this.quantidade_anterior,
    required this.quantidade_nova,
    required this.data_ajuste,
    this.motivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_ajuste': id_ajuste,
      'id_produto': id_produto,
      'quantidade_anterior': quantidade_anterior,
      'quantidade_nova': quantidade_nova,
      'data_ajuste': data_ajuste.toIso8601String(),
      'motivo': motivo,
    };
  }

  factory AjusteEstoque.fromJson(Map<String, dynamic> json) {
    return AjusteEstoque(
      id_ajuste: json['id_ajuste'],
      id_produto: json['id_produto'] ?? 0,
      quantidade_anterior: (json['quantidade_anterior'] ?? 0).toDouble(),
      quantidade_nova: (json['quantidade_nova'] ?? 0).toDouble(),
      data_ajuste: json['data_ajuste'] != null 
          ? DateTime.parse(json['data_ajuste']) 
          : DateTime.now(),
      motivo: json['motivo'],
    );
  }
}

// Table: Consumo_Interno (Internal_Consumption)
class ConsumoInterno {
  final int? id_consumo;
  int id_produto;
  double quantidade_consumida;
  DateTime data_hora;
  String? motivo;

  ConsumoInterno({
    this.id_consumo,
    required this.id_produto,
    required this.quantidade_consumida,
    required this.data_hora,
    this.motivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_consumo': id_consumo,
      'id_produto': id_produto,
      'quantidade_consumida': quantidade_consumida,
      'data_hora': data_hora.toIso8601String(),
      'motivo': motivo,
    };
  }

  factory ConsumoInterno.fromJson(Map<String, dynamic> json) {
    return ConsumoInterno(
      id_consumo: json['id_consumo'],
      id_produto: json['id_produto'] ?? 0,
      quantidade_consumida: (json['quantidade_consumida'] ?? 0).toDouble(),
      data_hora: json['data_hora'] != null 
          ? DateTime.parse(json['data_hora']) 
          : DateTime.now(),
      motivo: json['motivo'],
    );
  }
}

// Table: Mesa (Table)
class Mesa {
  final int? id_mesa;
  int numero_mesa;
  bool status_ocupada;
  String? nome_cliente;
  int quantidade_lugares;

  Mesa({
    this.id_mesa,
    required this.numero_mesa,
    this.status_ocupada = false,
    this.nome_cliente,
    required this.quantidade_lugares,
  });

  Mesa copyWith({
    int? numero_mesa,
    bool? status_ocupada,
    String? nome_cliente,
    int? quantidade_lugares,
  }) {
    return Mesa(
      id_mesa: id_mesa,
      numero_mesa: numero_mesa ?? this.numero_mesa,
      status_ocupada: status_ocupada ?? this.status_ocupada,
      nome_cliente: nome_cliente ?? this.nome_cliente,
      quantidade_lugares: quantidade_lugares ?? this.quantidade_lugares,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mesa': id_mesa,
      'numero_mesa': numero_mesa,
      'status_ocupada': status_ocupada,
      'nome_cliente': nome_cliente,
      'quantidade_lugares': quantidade_lugares,
    };
  }

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id_mesa: json['id_mesa'],
      numero_mesa: json['numero_mesa'] ?? 0,
      status_ocupada: json['status_ocupada'] == true || json['status_ocupada'] == 1,
      nome_cliente: json['nome_cliente'],
      quantidade_lugares: json['quantidade_lugares'] ?? 4,
    );
  }
}

// Table: Venda (Sale)
class Venda {
  final int? id_venda;
  int id_mesa;
  DateTime data_venda;
  bool status_aberta;
  bool cancelada;

  Venda({
    this.id_venda,
    required this.id_mesa,
    required this.data_venda,
    this.status_aberta = true,
    this.cancelada = false,
  });

  Venda copyWith({
    int? id_mesa,
    DateTime? data_venda,
    bool? status_aberta,
    bool? cancelada,
  }) {
    return Venda(
      id_venda: id_venda,
      id_mesa: id_mesa ?? this.id_mesa,
      data_venda: data_venda ?? this.data_venda,
      status_aberta: status_aberta ?? this.status_aberta,
      cancelada: cancelada ?? this.cancelada,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_venda': id_venda,
      'id_mesa': id_mesa,
      'data_venda': data_venda.toIso8601String(),
      'status_aberta': status_aberta,
      'cancelada': cancelada,
    };
  }

  factory Venda.fromJson(Map<String, dynamic> json) {
    return Venda(
      id_venda: json['id_venda'],
      id_mesa: json['id_mesa'] ?? 0,
      data_venda: json['data_venda'] != null 
          ? DateTime.parse(json['data_venda']) 
          : DateTime.now(),
      status_aberta: json['status_aberta'] == true || json['status_aberta'] == 1,
      cancelada: json['cancelada'] == true || json['cancelada'] == 1,
    );
  }
}

// Table: Pedido (Order)
class Pedido {
  final int? id_pedido;
  int id_venda;
  int id_mesa;
  String? nome_funcionario;
  DateTime data_pedido;
  String status_pedido; // 'pendente', 'preparando', 'pronto', 'entregue', 'cancelado'

  Pedido({
    this.id_pedido,
    required this.id_venda,
    required this.id_mesa,
    this.nome_funcionario,
    required this.data_pedido,
    this.status_pedido = 'pendente',
  });

  Pedido copyWith({
    int? id_venda,
    int? id_mesa,
    String? nome_funcionario,
    DateTime? data_pedido,
    String? status_pedido,
  }) {
    return Pedido(
      id_pedido: id_pedido,
      id_venda: id_venda ?? this.id_venda,
      id_mesa: id_mesa ?? this.id_mesa,
      nome_funcionario: nome_funcionario ?? this.nome_funcionario,
      data_pedido: data_pedido ?? this.data_pedido,
      status_pedido: status_pedido ?? this.status_pedido,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pedido': id_pedido,
      'id_venda': id_venda,
      'id_mesa': id_mesa,
      'nome_funcionario': nome_funcionario,
      'data_pedido': data_pedido.toIso8601String(),
      'status_pedido': status_pedido,
    };
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id_pedido: json['id_pedido'],
      id_venda: json['id_venda'] ?? 0,
      id_mesa: json['id_mesa'] ?? 0,
      nome_funcionario: json['nome_funcionario'],
      data_pedido: json['data_pedido'] != null 
          ? DateTime.parse(json['data_pedido']) 
          : DateTime.now(),
      status_pedido: json['status_pedido'] ?? 'pendente',
    );
  }
}

// Table: Pedido_Item (Order_Item)
class PedidoItem {
  final int? id_pedido_item;
  int id_pedido;
  String tipo_item; // 'produto' or 'receita'
  int id_item;  // ID of Product or Recipe
  double quantidade;
  double preco_unitario;
  String? observacao;

  PedidoItem({
    this.id_pedido_item,
    required this.id_pedido,
    required this.tipo_item,
    required this.id_item,
    required this.quantidade,
    required this.preco_unitario,
    this.observacao,
  });

  double get total => quantidade * preco_unitario;

  Map<String, dynamic> toJson() {
    return {
      'id_pedido_item': id_pedido_item,
      'id_pedido': id_pedido,
      'tipo_item': tipo_item,
      'id_item': id_item,
      'quantidade': quantidade,
      'preco_unitario': preco_unitario,
      'observacao': observacao,
    };
  }

  factory PedidoItem.fromJson(Map<String, dynamic> json) {
    return PedidoItem(
      id_pedido_item: json['id_pedido_item'],
      id_pedido: json['id_pedido'] ?? 0,
      tipo_item: json['tipo_item'] ?? 'produto',
      id_item: json['id_item'] ?? 0,
      quantidade: (json['quantidade'] ?? 0).toDouble(),
      preco_unitario: (json['preco_unitario'] ?? 0).toDouble(),
      observacao: json['observacao'],
    );
  }
}

// Extension methods for converting between old and new models
extension SupplierConverter on Fornecedor {
  Supplier toSupplier() {
    return Supplier(
      id: id_fornecedor?.toString() ?? uuid.v4(),
      name: nome,
      contact: contato ?? '',
      address: '',  // Not in DB model but needed for UI
      notes: detalhes ?? '',
    );
  }
}

extension TableConverter on Mesa {
  TableModel toTableModel() {
    return TableModel(
      id: id_mesa?.toString() ?? uuid.v4(),
      number: numero_mesa,
      status: status_ocupada ? TableStatus.occupied : TableStatus.free,
      capacity: quantidade_lugares,
    );
  }
}

// Legacy models for backward compatibility
// These will need to be gradually phased out

enum TableStatus { free, occupied }

enum OrderStatus { pending, preparing, ready, delivered, canceled }

enum PaymentMethod { cash, credit, debit, pix }

enum ProductCategory { drink, food, other }

enum RecipeType { food, drink }

enum ProductionStatus { inProgress, finalized }

// Legacy model: Supplier
class Supplier {
  final String id;
  String name;
  String contact;
  String address;
  String notes;

  Supplier({
    String? id,
    required this.name,
    required this.contact,
    this.address = '',
    this.notes = '',
  }) : id = id ?? uuid.v4();

  Supplier copyWith({
    String? name,
    String? contact,
    String? address,
    String? notes,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'notes': notes,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contact: json['contact'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Fornecedor toFornecedor() {
    return Fornecedor(
      id_fornecedor: int.tryParse(id),
      nome: name,
      contato: contact,
      telefone: '',
      email: '',
      detalhes: notes,
    );
  }
}

// Legacy model: Product
class Product {
  final String id;
  String name;
  ProductCategory category;
  double price;
  int stockQuantity;
  String? supplierId;
  String description;
  String unit;

  Product({
    String? id,
    required this.name,
    required this.category,
    required this.price,
    this.stockQuantity = 0,
    this.supplierId,
    this.description = '',
    this.unit = 'unidade',
  }) : id = id ?? uuid.v4();

  Product copyWith({
    String? name,
    ProductCategory? category,
    double? price,
    int? stockQuantity,
    String? supplierId,
    String? description,
    String? unit,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      supplierId: supplierId ?? this.supplierId,
      description: description ?? this.description,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'price': price,
      'stockQuantity': stockQuantity,
      'supplierId': supplierId,
      'description': description,
      'unit': unit,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: ProductCategory.values[json['category']],
      price: json['price'].toDouble(),
      stockQuantity: json['stockQuantity'],
      supplierId: json['supplierId'],
      description: json['description'] ?? '',
      unit: json['unit'] ?? 'unidade',
    );
  }
}

// Legacy model: TableModel
class TableModel {
  final String id;
  int number;
  TableStatus status;
  int capacity;
  String? currentOrderId;

  TableModel({
    String? id,
    required this.number,
    this.status = TableStatus.free,
    this.capacity = 4,
    this.currentOrderId,
  }) : id = id ?? uuid.v4();

  TableModel copyWith({
    int? number,
    TableStatus? status,
    int? capacity,
    String? currentOrderId,
  }) {
    return TableModel(
      id: id,
      number: number ?? this.number,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      currentOrderId: currentOrderId ?? this.currentOrderId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status.index,
      'capacity': capacity,
      'currentOrderId': currentOrderId,
    };
  }

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      number: json['number'],
      status: TableStatus.values[json['status']],
      capacity: json['capacity'],
      currentOrderId: json['currentOrderId'],
    );
  }
}

// Legacy model: OrderItem
class OrderItem {
  final String id;
  String productId;
  String productName;
  int quantity;
  double price;
  String notes;
  OrderStatus status;

  OrderItem({
    String? id,
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
    this.notes = '',
    this.status = OrderStatus.pending,
  }) : id = id ?? uuid.v4();

  double get total => price * quantity;

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    String? notes,
    OrderStatus? status,
  }) {
    return OrderItem(
      id: id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'notes': notes,
      'status': status.index,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      notes: json['notes'] ?? '',
      status: OrderStatus.values[json['status']],
    );
  }
}

// Legacy model: Order
class Order {
  final String id;
  String tableId;
  int tableNumber;
  DateTime createdAt;
  List<OrderItem> items;
  OrderStatus status;
  bool isClosed;

  Order({
    String? id,
    required this.tableId,
    required this.tableNumber,
    DateTime? createdAt,
    List<OrderItem>? items,
    this.status = OrderStatus.pending,
    this.isClosed = false,
  })
      : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];

  double get total => items.fold(
      0, (previousValue, element) => previousValue + element.total);

  Order copyWith({
    String? tableId,
    int? tableNumber,
    DateTime? createdAt,
    List<OrderItem>? items,
    OrderStatus? status,
    bool? isClosed,
  }) {
    return Order(
      id: id,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      status: status ?? this.status,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.index,
      'isClosed': isClosed,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['tableId'],
      tableNumber: json['tableNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      status: OrderStatus.values[json['status']],
      isClosed: json['isClosed'],
    );
  }
}

// Legacy model: Sale
class Sale {
  final String id;
  String orderId;
  DateTime timestamp;
  PaymentMethod paymentMethod;
  double total;

  Sale({
    String? id,
    required this.orderId,
    required this.total,
    DateTime? timestamp,
    this.paymentMethod = PaymentMethod.cash,
  })
      : id = id ?? uuid.v4(),
        timestamp = timestamp ?? DateTime.now();

  Sale copyWith({
    String? orderId,
    DateTime? timestamp,
    PaymentMethod? paymentMethod,
    double? total,
  }) {
    return Sale(
      id: id,
      orderId: orderId ?? this.orderId,
      timestamp: timestamp ?? this.timestamp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'timestamp': timestamp.toIso8601String(),
      'paymentMethod': paymentMethod.index,
      'total': total,
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      orderId: json['orderId'],
      timestamp: DateTime.parse(json['timestamp']),
      paymentMethod: PaymentMethod.values[json['paymentMethod']],
      total: json['total'].toDouble(),
    );
  }
}

// Legacy model: RecipeIngredient
class RecipeIngredient {
  final String id;
  String productId;
  String productName;
  int quantity;
  String unit;

  RecipeIngredient({
    String? id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  }) : id = id ?? uuid.v4();

  RecipeIngredient copyWith({
    String? productId,
    String? productName,
    int? quantity,
    String? unit,
  }) {
    return RecipeIngredient(
      id: id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }
}

// Legacy model: Recipe
class Recipe {
  final String id;
  String name;
  RecipeType type;
  double price;
  String instructions;
  List<RecipeIngredient> ingredients;

  Recipe({
    String? id,
    required this.name,
    required this.type,
    required this.price,
    this.instructions = '',
    List<RecipeIngredient>? ingredients,
  })
      : id = id ?? uuid.v4(),
        ingredients = ingredients ?? [];

  Recipe copyWith({
    String? name,
    RecipeType? type,
    double? price,
    String? instructions,
    List<RecipeIngredient>? ingredients,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      instructions: instructions ?? this.instructions,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'price': price,
      'instructions': instructions,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      type: RecipeType.values[json['type']],
      price: json['price'].toDouble(),
      instructions: json['instructions'] ?? '',
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => RecipeIngredient.fromJson(i))
          .toList() ?? [],
    );
  }
}

// Legacy model: ProductionIngredient
class ProductionIngredient {
  final String id;
  String productId;
  String productName;
  int quantity;
  String unit;

  ProductionIngredient({
    String? id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  }) : id = id ?? uuid.v4();

  ProductionIngredient copyWith({
    String? productId,
    String? productName,
    int? quantity,
    String? unit,
  }) {
    return ProductionIngredient(
      id: id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory ProductionIngredient.fromJson(Map<String, dynamic> json) {
    return ProductionIngredient(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }
}

// Legacy model: InternalProduction
class InternalProduction {
  final String id;
  String name;
  int quantity;
  String unit;
  String? recipeId;
  String notes;
  DateTime createdAt;
  DateTime? finalizedAt;
  ProductionStatus status;
  List<ProductionIngredient> ingredients;

  InternalProduction({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.recipeId,
    this.notes = '',
    DateTime? createdAt,
    this.finalizedAt,
    this.status = ProductionStatus.inProgress,
    List<ProductionIngredient>? ingredients,
  })
      : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        ingredients = ingredients ?? [];

  InternalProduction copyWith({
    String? name,
    int? quantity,
    String? unit,
    String? recipeId,
    String? notes,
    DateTime? createdAt,
    DateTime? finalizedAt,
    ProductionStatus? status,
    List<ProductionIngredient>? ingredients,
  }) {
    return InternalProduction(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      recipeId: recipeId ?? this.recipeId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      status: status ?? this.status,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'recipeId': recipeId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'finalizedAt': finalizedAt?.toIso8601String(),
      'status': status.index,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }

  factory InternalProduction.fromJson(Map<String, dynamic> json) {
    return InternalProduction(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      recipeId: json['recipeId'],
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      finalizedAt: json['finalizedAt'] != null 
          ? DateTime.parse(json['finalizedAt']) 
          : null,
      status: ProductionStatus.values[json['status']],
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => ProductionIngredient.fromJson(i))
          .toList() ?? [],
    );
  }
}