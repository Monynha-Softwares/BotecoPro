import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/data_models.dart';

class SupabaseDatabaseService {
  static final SupabaseDatabaseService _instance = SupabaseDatabaseService._internal();
  factory SupabaseDatabaseService() => _instance;
  SupabaseDatabaseService._internal();

  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // Current user ID for row-level security
  String? get _userId => _supabase.auth.currentUser?.id;

  // Initialize data - create sample data if needed
  Future<void> initializeData() async {
    try {
      // Check if user has any data
      final fornecedores = await getFornecedores();
      if (fornecedores.isEmpty) {
        await _createSampleData();
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  // Create sample data for new users
  Future<void> _createSampleData() async {
    if (_userId == null) return;

    try {
      // Create sample categories
      await _supabase.from('categorias').insert([
        {'nome': 'Bebidas', 'descricao': 'Bebidas em geral', 'user_id': _userId},
        {'nome': 'Comidas', 'descricao': 'Alimentos em geral', 'user_id': _userId},
        {'nome': 'Outros', 'descricao': 'Produtos diversos', 'user_id': _userId},
      ]);

      // Create sample tables
      List<Map<String, dynamic>> mesasData = [];
      for (int i = 1; i <= 10; i++) {
        mesasData.add({
          'numero_mesa': i,
          'quantidade_lugares': (i % 3) + 2,
          'status_ocupada': false,
          'user_id': _userId,
        });
      }
      await _supabase.from('mesas').insert(mesasData);

      // Get categories to link products
      final categoriasResponse = await _supabase
          .from('categorias')
          .select('id_categoria, nome')
          .eq('user_id', _userId!);
      
      if (categoriasResponse.isNotEmpty) {
        final bebidas = categoriasResponse.firstWhere((c) => c['nome'] == 'Bebidas');
        final comidas = categoriasResponse.firstWhere((c) => c['nome'] == 'Comidas');

        // Create sample products
        await _supabase.from('produtos').insert([
          {
            'nome': 'Chopp',
            'unidade_base': 'ml',
            'tipo_produto': 'compra',
            'controla_estoque': true,
            'id_categoria': bebidas['id_categoria'],
            'user_id': _userId,
          },
          {
            'nome': 'Caipirinha',
            'unidade_base': 'unidade',
            'tipo_produto': 'producao',
            'controla_estoque': true,
            'id_categoria': bebidas['id_categoria'],
            'user_id': _userId,
          },
          {
            'nome': 'Batata Frita',
            'unidade_base': 'porção',
            'tipo_produto': 'producao',
            'controla_estoque': true,
            'id_categoria': comidas['id_categoria'],
            'user_id': _userId,
          },
          {
            'nome': 'Refrigerante Lata',
            'unidade_base': 'unidade',
            'tipo_produto': 'compra',
            'controla_estoque': true,
            'id_categoria': bebidas['id_categoria'],
            'user_id': _userId,
          },
        ]);

        // Create sample suppliers
        await _supabase.from('fornecedores').insert([
          {
            'nome': 'Distribuidora de Bebidas ABC',
            'telefone': '(11) 99999-8888',
            'email': 'contato@distribuidoraabc.com',
            'contato': 'João Silva',
            'detalhes': 'Entrega toda segunda-feira',
            'user_id': _userId,
          },
          {
            'nome': 'Alimentos Frescos Ltda',
            'telefone': '(11) 97777-6666',
            'email': 'vendas@alimentosfrescos.com',
            'contato': 'Maria Oliveira',
            'detalhes': 'Fornecedor de alimentos frescos',
            'user_id': _userId,
          },
        ]);
      }
    } catch (e) {
      debugPrint('Error creating sample data: $e');
    }
  }

  // FORNECEDORES (Suppliers)
  Future<List<Fornecedor>> getFornecedores() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('fornecedores')
          .select()
          .eq('user_id', _userId!)
          .order('nome');

      return response.map<Fornecedor>((data) => Fornecedor.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting fornecedores: $e');
      return [];
    }
  }

  Future<void> addFornecedor(Fornecedor fornecedor) async {
    if (_userId == null) return;

    try {
      final data = fornecedor.toJson();
      data['user_id'] = _userId;
      data.remove('id_fornecedor'); // Let database generate ID

      await _supabase.from('fornecedores').insert(data);
    } catch (e) {
      debugPrint('Error adding fornecedor: $e');
      throw Exception('Erro ao adicionar fornecedor');
    }
  }

  Future<void> updateFornecedor(Fornecedor fornecedor) async {
    if (_userId == null || fornecedor.id_fornecedor == null) return;

    try {
      final data = fornecedor.toJson();
      data['user_id'] = _userId;
      data.remove('id_fornecedor');

      await _supabase
          .from('fornecedores')
          .update(data)
          .eq('id_fornecedor', fornecedor.id_fornecedor!)
          .eq('user_id', _userId!);
    } catch (e) {
      debugPrint('Error updating fornecedor: $e');
      throw Exception('Erro ao atualizar fornecedor');
    }
  }

  Future<void> deleteFornecedor(int id) async {
    if (_userId == null) return;

    try {
      await _supabase
          .from('fornecedores')
          .delete()
          .eq('id_fornecedor', id)
          .eq('user_id', _userId!);
    } catch (e) {
      debugPrint('Error deleting fornecedor: $e');
      throw Exception('Erro ao excluir fornecedor');
    }
  }

  // CATEGORIAS
  Future<List<Categoria>> getCategorias() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('categorias')
          .select()
          .eq('user_id', _userId!)
          .order('nome');

      return response.map<Categoria>((data) => Categoria.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting categorias: $e');
      return [];
    }
  }

  // PRODUTOS
  Future<List<Produto>> getProdutos() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('produtos')
          .select()
          .eq('user_id', _userId!)
          .order('nome');

      return response.map<Produto>((data) => Produto.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting produtos: $e');
      return [];
    }
  }

  Future<void> addProduto(Produto produto) async {
    if (_userId == null) return;

    try {
      final data = produto.toJson();
      data['user_id'] = _userId;
      data.remove('id_produto');

      await _supabase.from('produtos').insert(data);
    } catch (e) {
      debugPrint('Error adding produto: $e');
      throw Exception('Erro ao adicionar produto');
    }
  }

  // PRODUTOS VENDA
  Future<List<ProdutoVenda>> getProdutosVenda() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('produtos_venda')
          .select()
          .eq('user_id', _userId!)
          .order('id_produto');

      return response.map<ProdutoVenda>((data) => ProdutoVenda.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting produtos venda: $e');
      return [];
    }
  }

  Future<void> addProdutoVenda(ProdutoVenda produtoVenda) async {
    if (_userId == null) return;

    try {
      final data = produtoVenda.toJson();
      data['user_id'] = _userId;
      data.remove('id_venda');

      await _supabase.from('produtos_venda').insert(data);
    } catch (e) {
      debugPrint('Error adding produto venda: $e');
      throw Exception('Erro ao adicionar produto venda');
    }
  }

  // MESAS
  Future<List<Mesa>> getMesas() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('mesas')
          .select()
          .eq('user_id', _userId!)
          .order('numero_mesa');

      return response.map<Mesa>((data) => Mesa.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting mesas: $e');
      return [];
    }
  }

  Future<void> updateMesa(Mesa mesa) async {
    if (_userId == null || mesa.id_mesa == null) return;

    try {
      final data = mesa.toJson();
      data['user_id'] = _userId;
      data.remove('id_mesa');

      await _supabase
          .from('mesas')
          .update(data)
          .eq('id_mesa', mesa.id_mesa!)
          .eq('user_id', _userId!);
    } catch (e) {
      debugPrint('Error updating mesa: $e');
      throw Exception('Erro ao atualizar mesa');
    }
  }

  // VENDAS
  Future<List<Venda>> getVendas() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('vendas')
          .select()
          .eq('user_id', _userId!)
          .order('data_venda', ascending: false);

      return response.map<Venda>((data) => Venda.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting vendas: $e');
      return [];
    }
  }

  Future<void> addVenda(Venda venda) async {
    if (_userId == null) return;

    try {
      final data = venda.toJson();
      data['user_id'] = _userId;
      data.remove('id_venda');

      await _supabase.from('vendas').insert(data);

      // Update mesa status
      if (venda.id_mesa != null) {
        await _supabase
            .from('mesas')
            .update({'status_ocupada': true})
            .eq('id_mesa', venda.id_mesa!)
            .eq('user_id', _userId!);
      }
    } catch (e) {
      debugPrint('Error adding venda: $e');
      throw Exception('Erro ao adicionar venda');
    }
  }

  Future<void> closeVenda(int idVenda) async {
    if (_userId == null) return;

    try {
      // Update venda status
      await _supabase
          .from('vendas')
          .update({'status_aberta': false})
          .eq('id_venda', idVenda)
          .eq('user_id', _userId!);

      // Get the venda to find the mesa
      final vendaResponse = await _supabase
          .from('vendas')
          .select('id_mesa')
          .eq('id_venda', idVenda)
          .eq('user_id', _userId!)
          .single();

      final idMesa = vendaResponse['id_mesa'] as int?;
      if (idMesa != null) {
        // Free the mesa
        await _supabase
            .from('mesas')
            .update({'status_ocupada': false, 'nome_cliente': null})
            .eq('id_mesa', idMesa)
            .eq('user_id', _userId!);
      }
    } catch (e) {
      debugPrint('Error closing venda: $e');
      throw Exception('Erro ao fechar venda');
    }
  }

  // PEDIDOS
  Future<List<Pedido>> getPedidos() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('pedidos')
          .select()
          .eq('user_id', _userId!)
          .order('data_pedido', ascending: false);

      return response.map<Pedido>((data) => Pedido.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting pedidos: $e');
      return [];
    }
  }

  Future<void> addPedido(Pedido pedido) async {
    if (_userId == null) return;

    try {
      final data = pedido.toJson();
      data['user_id'] = _userId;
      data.remove('id_pedido');

      await _supabase.from('pedidos').insert(data);
    } catch (e) {
      debugPrint('Error adding pedido: $e');
      throw Exception('Erro ao adicionar pedido');
    }
  }

  Future<void> updatePedidoStatus(int idPedido, String status) async {
    if (_userId == null) return;

    try {
      await _supabase
          .from('pedidos')
          .update({'status_pedido': status})
          .eq('id_pedido', idPedido)
          .eq('user_id', _userId!);
    } catch (e) {
      debugPrint('Error updating pedido status: $e');
      throw Exception('Erro ao atualizar status do pedido');
    }
  }

  // PEDIDO ITENS
  Future<List<PedidoItem>> getPedidoItens() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('pedido_itens')
          .select()
          .eq('user_id', _userId!);

      return response.map<PedidoItem>((data) => PedidoItem.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting pedido itens: $e');
      return [];
    }
  }

  Future<List<PedidoItem>> getPedidoItensByPedido(int idPedido) async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('pedido_itens')
          .select()
          .eq('id_pedido', idPedido)
          .eq('user_id', _userId!);

      return response.map<PedidoItem>((data) => PedidoItem.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting pedido itens by pedido: $e');
      return [];
    }
  }

  Future<void> addPedidoItem(PedidoItem item) async {
    if (_userId == null) return;

    try {
      final data = item.toJson();
      data['user_id'] = _userId;
      data.remove('id_pedido_item');

      await _supabase.from('pedido_itens').insert(data);
    } catch (e) {
      debugPrint('Error adding pedido item: $e');
      throw Exception('Erro ao adicionar item ao pedido');
    }
  }

  // ESTOQUE
  Future<List<Estoque>> getEstoque() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('estoque')
          .select()
          .eq('user_id', _userId!);

      return response.map<Estoque>((data) => Estoque.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting estoque: $e');
      return [];
    }
  }

  Future<void> updateEstoqueProduto(int idProduto, double novaQuantidade) async {
    if (_userId == null) return;

    try {
      // Check if product exists in estoque
      final existing = await _supabase
          .from('estoque')
          .select()
          .eq('id_produto', idProduto)
          .eq('user_id', _userId!)
          .limit(1);

      if (existing.isNotEmpty) {
        // Update existing
        await _supabase
            .from('estoque')
            .update({
              'quantidade_disponivel': novaQuantidade,
              'data_atualizacao': DateTime.now().toIso8601String(),
            })
            .eq('id_produto', idProduto)
            .eq('user_id', _userId!);
      } else {
        // Insert new
        await _supabase.from('estoque').insert({
          'id_produto': idProduto,
          'quantidade_disponivel': novaQuantidade,
          'data_atualizacao': DateTime.now().toIso8601String(),
          'user_id': _userId,
        });
      }
    } catch (e) {
      debugPrint('Error updating estoque: $e');
      throw Exception('Erro ao atualizar estoque');
    }
  }

  // RECEITAS
  Future<List<Receita>> getReceitas() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('receitas')
          .select()
          .eq('user_id', _userId!)
          .order('nome');

      return response.map<Receita>((data) => Receita.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting receitas: $e');
      return [];
    }
  }

  Future<void> addReceita(Receita receita) async {
    if (_userId == null) return;

    try {
      final data = receita.toJson();
      data['user_id'] = _userId;
      data.remove('id_receita');

      await _supabase.from('receitas').insert(data);
    } catch (e) {
      debugPrint('Error adding receita: $e');
      throw Exception('Erro ao adicionar receita');
    }
  }

  // RECEITA INGREDIENTES
  Future<List<ReceitaIngrediente>> getReceitaIngredientes() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('receita_ingredientes')
          .select()
          .eq('user_id', _userId!);

      return response
          .map<ReceitaIngrediente>((data) => ReceitaIngrediente.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error getting receita ingredientes: $e');
      return [];
    }
  }

  Future<List<ReceitaIngrediente>> getReceitaIngredientesByReceita(int idReceita) async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('receita_ingredientes')
          .select()
          .eq('id_receita', idReceita)
          .eq('user_id', _userId!);

      return response
          .map<ReceitaIngrediente>((data) => ReceitaIngrediente.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error getting receita ingredientes by receita: $e');
      return [];
    }
  }

  Future<void> addReceitaIngrediente(ReceitaIngrediente ingrediente) async {
    if (_userId == null) return;

    try {
      final data = ingrediente.toJson();
      data['user_id'] = _userId;
      data.remove('id');

      await _supabase.from('receita_ingredientes').insert(data);
    } catch (e) {
      debugPrint('Error adding receita ingrediente: $e');
      throw Exception('Erro ao adicionar ingrediente da receita');
    }
  }

  // REAL-TIME STREAMS
  Stream<List<Pedido>> streamPedidos() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('pedidos')
        .stream(primaryKey: ['id_pedido'])
        .eq('user_id', _userId!)
        .map((data) => data.map<Pedido>((item) => Pedido.fromJson(item)).toList());
  }

  Stream<List<Mesa>> streamMesas() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('mesas')
        .stream(primaryKey: ['id_mesa'])
        .eq('user_id', _userId!)
        .map((data) => data.map<Mesa>((item) => Mesa.fromJson(item)).toList());
  }

  Stream<List<Estoque>> streamEstoque() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('estoque')
        .stream(primaryKey: ['id_estoque'])
        .eq('user_id', _userId!)
        .map((data) => data.map<Estoque>((item) => Estoque.fromJson(item)).toList());
  }

  // UTILITY METHODS
  Future<Venda?> getVendaAtivaMesa(int idMesa) async {
    if (_userId == null) return null;

    try {
      final response = await _supabase
          .from('vendas')
          .select()
          .eq('id_mesa', idMesa)
          .eq('status_aberta', true)
          .eq('user_id', _userId!)
          .limit(1);

      if (response.isNotEmpty) {
        return Venda.fromJson(response.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting venda ativa: $e');
      return null;
    }
  }

  Future<List<Venda>> getVendasAtivas() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('vendas')
          .select()
          .eq('status_aberta', true)
          .eq('user_id', _userId!);

      return response.map<Venda>((data) => Venda.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting vendas ativas: $e');
      return [];
    }
  }

  Future<double> getVendasDiarias() async {
    if (_userId == null) return 0.0;

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('vendas')
          .select('id_venda')
          .eq('user_id', _userId!)
          .eq('status_aberta', false)
          .eq('cancelada', false)
          .gte('data_venda', startOfDay.toIso8601String())
          .lt('data_venda', endOfDay.toIso8601String());

      // For now, return a mock value since we'd need to join with pedidos and items
      return response.length * 50.0; // Mock average per sale
    } catch (e) {
      debugPrint('Error getting vendas diarias: $e');
      return 0.0;
    }
  }

  // Legacy compatibility methods for existing code
  Future<void> saveFornecedores(List<Fornecedor> fornecedores) async {
    // This method is not needed with Supabase, but kept for compatibility
    debugPrint('saveFornecedores called - using individual operations instead');
  }

  Future<void> saveMesas(List<Mesa> mesas) async {
    // This method is not needed with Supabase, but kept for compatibility
    debugPrint('saveMesas called - using individual operations instead');
  }

  // More legacy methods can be added as needed
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

  // Cleanup method
  void dispose() {
    // Supabase handles cleanup automatically
  }
}