// Used for generating temporary IDs in offline mode
// const uuid = Uuid();

// Table: Fornecedor (Supplier)
class Fornecedor {
  final int? id_fornecedor; // Using nullable to handle new entries
  String nome; // NVARCHAR(100)
  String? telefone; // NVARCHAR(20)
  String? email; // NVARCHAR(100)
  String? contato; // NVARCHAR(100)
  String? detalhes; // NVARCHAR(255)

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
  final int? id_categoria; // Using nullable to handle new entries
  String nome; // NVARCHAR(100)
  String? descricao; // NVARCHAR(255)

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
  final int? id_produto; // Using nullable to handle new entries
  String nome; // NVARCHAR(100)
  String unidade_base; // NVARCHAR(20)
  String
      tipo_produto; // NVARCHAR(20) - 'compra', 'producao', 'ingrediente', 'ambos'
  bool controla_estoque; // BIT - represents boolean value
  int? id_categoria; // FK Categoria

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
      'controla_estoque': controla_estoque ? 1 : 0, // Convert bool to BIT (1/0)
      'id_categoria': id_categoria,
    };
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id_produto: json['id_produto'],
      nome: json['nome'] ?? '',
      unidade_base: json['unidade_base'] ?? 'unidade',
      tipo_produto: json['tipo_produto'] ?? 'compra',
      controla_estoque:
          json['controla_estoque'] == true || json['controla_estoque'] == 1,
      id_categoria: json['id_categoria'],
    );
  }
}

// Table: Produto_Venda (Product_Sale)
class ProdutoVenda {
  final int? id_venda; // Using nullable to handle new entries
  int id_produto; // FK Produto
  String descricao_venda; // NVARCHAR(100)
  double quantidade_base; // DECIMAL(10,2)
  double preco_venda; // DECIMAL(10,2)

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
  final int? id_receita; // Using nullable to handle new entries
  String nome; // NVARCHAR(100)
  String tipo_receita; // NVARCHAR(20) - 'cocktail', 'dose', 'porcao'
  double preco_venda; // DECIMAL(10,2)
  int? tempo_preparo_minutos; // INT
  int? id_categoria; // FK Categoria

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
      tempo_preparo_minutos:
          tempo_preparo_minutos ?? this.tempo_preparo_minutos,
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
  final int? id; // Using nullable to handle new entries
  int id_receita; // FK Receita
  int id_produto; // FK Produto
  double quantidade_utilizada; // DECIMAL(10,2)

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
  final int? id_producao; // Using nullable to handle new entries
  String nome; // NVARCHAR(100)
  double quantidade_gerada; // DECIMAL(10,2)
  String unidade_gerada; // NVARCHAR(20)
  int? tempo_preparo; // INT
  DateTime? data_inicio_producao; // DATE in DB
  DateTime? data_fim_disponivel; // DATE in DB

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
      // Format as yyyy-MM-dd for DATE fields
      'data_inicio_producao': data_inicio_producao != null
          ? '${data_inicio_producao!.year}-${data_inicio_producao!.month.toString().padLeft(2, '0')}-${data_inicio_producao!.day.toString().padLeft(2, '0')}'
          : null,
      'data_fim_disponivel': data_fim_disponivel != null
          ? '${data_fim_disponivel!.year}-${data_fim_disponivel!.month.toString().padLeft(2, '0')}-${data_fim_disponivel!.day.toString().padLeft(2, '0')}'
          : null,
    };
  }

  factory ProducaoCaseira.fromJson(Map<String, dynamic> json) {
    return ProducaoCaseira(
      id_producao: json['id_producao'],
      nome: json['nome'] ?? '',
      quantidade_gerada: (json['quantidade_gerada'] ?? 0).toDouble(),
      unidade_gerada: json['unidade_gerada'] ?? 'unidade',
      tempo_preparo: json['tempo_preparo'],
      // Parse DATE fields as DateTime
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
  final int? id; // Using nullable to handle new entries
  int id_producao; // FK Producao_Caseira
  int id_produto; // FK Produto
  double quantidade_utilizada; // DECIMAL(10,2)

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
  final int? id_estoque; // Using nullable to handle new entries
  int id_produto; // FK Produto
  double quantidade_disponivel; // DECIMAL(10,2)
  DateTime data_atualizacao; // DATETIME

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
  final int? id_entrada; // Using nullable to handle new entries
  int id_produto; // FK Produto
  double quantidade_entrada; // DECIMAL(10,2)
  DateTime data_entrada; // DATETIME
  String? observacao; // NVARCHAR(255)

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
  final int? id_ajuste; // Using nullable to handle new entries
  int id_produto; // FK Produto
  double quantidade_anterior; // DECIMAL(10,2)
  double quantidade_nova; // DECIMAL(10,2)
  DateTime data_ajuste; // DATETIME
  String? motivo; // NVARCHAR(255)

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
  final int? id_consumo; // Using nullable to handle new entries
  int id_produto; // FK Produto
  double quantidade_consumida; // DECIMAL(10,2)
  DateTime data_hora; // DATETIME
  String? motivo; // NVARCHAR(255)

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
  final int? id_mesa; // Using nullable to handle new entries
  int numero_mesa; // INT
  bool status_ocupada; // BIT - represents boolean value
  String? nome_cliente; // NVARCHAR(100)
  int quantidade_lugares; // INT

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
      'status_ocupada': status_ocupada ? 1 : 0, // Convert bool to BIT (1/0)
      'nome_cliente': nome_cliente,
      'quantidade_lugares': quantidade_lugares,
    };
  }

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id_mesa: json['id_mesa'],
      numero_mesa: json['numero_mesa'] ?? 0,
      status_ocupada:
          json['status_ocupada'] == true || json['status_ocupada'] == 1,
      nome_cliente: json['nome_cliente'],
      quantidade_lugares: json['quantidade_lugares'] ?? 4,
    );
  }
}

// Table: Venda (Sale)
class Venda {
  final int? id_venda; // Using nullable to handle new entries
  int id_mesa; // FK Mesa
  DateTime data_venda; // DATETIME
  bool status_aberta; // BIT - represents boolean value
  bool cancelada; // BIT - represents boolean value

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
      'status_aberta': status_aberta ? 1 : 0, // Convert bool to BIT (1/0)
      'cancelada': cancelada ? 1 : 0, // Convert bool to BIT (1/0)
    };
  }

  factory Venda.fromJson(Map<String, dynamic> json) {
    return Venda(
      id_venda: json['id_venda'],
      id_mesa: json['id_mesa'] ?? 0,
      data_venda: json['data_venda'] != null
          ? DateTime.parse(json['data_venda'])
          : DateTime.now(),
      status_aberta:
          json['status_aberta'] == true || json['status_aberta'] == 1,
      cancelada: json['cancelada'] == true || json['cancelada'] == 1,
    );
  }
}

// Table: Pedido (Order)
class Pedido {
  final int? id_pedido; // Using nullable to handle new entries
  int id_venda; // FK Venda
  int id_mesa; // FK Mesa
  String? nome_funcionario; // NVARCHAR(100)
  DateTime data_pedido; // DATETIME
  String
      status_pedido; // NVARCHAR(20) - 'pendente', 'preparando', 'pronto', 'entregue', 'cancelado'

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
  final int? id_pedido_item; // Using nullable to handle new entries
  int id_pedido; // FK Pedido
  String tipo_item; // NVARCHAR(20) - 'produto' or 'receita'
  int id_item; // ID of Product or Recipe
  double quantidade; // DECIMAL(10,2)
  double preco_unitario; // DECIMAL(10,2)
  String? observacao; // NVARCHAR(255)

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
