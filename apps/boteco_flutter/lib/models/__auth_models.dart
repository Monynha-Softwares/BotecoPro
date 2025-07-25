import 'package:intl/intl.dart';

/// User model from 'vw_usuario_detalhes'
class User {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'] ?? 0,
      name: json['nome'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id,
      'nome': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}

/// Sales Detail model from 'vw_total_venda_detalhada'
class SalesDetail {
  final int saleId;
  final DateTime saleDate;
  final int tableNumber;
  final double totalAmount;
  final int itemCount;
  final bool isOpen;
  final bool isCancelled;

  SalesDetail({
    required this.saleId,
    required this.saleDate,
    required this.tableNumber,
    required this.totalAmount,
    required this.itemCount,
    required this.isOpen,
    required this.isCancelled,
  });

  factory SalesDetail.fromJson(Map<String, dynamic> json) {
    return SalesDetail(
      saleId: json['id_venda'] ?? 0,
      saleDate: json['data_venda'] != null
          ? DateTime.parse(json['data_venda'])
          : DateTime.now(),
      tableNumber: json['numero_mesa'] ?? 0,
      totalAmount: (json['total_venda'] ?? 0.0).toDouble(),
      itemCount: json['total_itens'] ?? 0,
      isOpen: json['status_aberta'] == 1 || json['status_aberta'] == true,
      isCancelled: json['cancelada'] == 1 || json['cancelada'] == true,
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(saleDate);
  
  String get formattedAmount => NumberFormat.currency(
    locale: 'pt_BR', 
    symbol: 'R\$',
  ).format(totalAmount);
}

/// Stock Movement model from 'vw_movimentacao_estoque_geral'
class StockMovement {
  final DateTime movementDate;
  final String productName;
  final double quantity;
  final String movementType;
  final String source;
  final String? notes;

  StockMovement({
    required this.movementDate,
    required this.productName,
    required this.quantity,
    required this.movementType,
    required this.source,
    this.notes,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      movementDate: json['data_movimentacao'] != null
          ? DateTime.parse(json['data_movimentacao'])
          : DateTime.now(),
      productName: json['nome_produto'] ?? '',
      quantity: (json['quantidade'] ?? 0.0).toDouble(),
      movementType: json['tipo_movimentacao'] ?? '',
      source: json['origem'] ?? '',
      notes: json['observacao'],
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(movementDate);
  
  bool get isPositive => 
      movementType.toLowerCase().contains('entrada') ||
      (movementType.toLowerCase().contains('ajuste') && quantity > 0);
}