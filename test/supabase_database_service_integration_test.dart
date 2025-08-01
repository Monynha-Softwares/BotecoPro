import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:boteco_pro/services/supabase_auth_service.dart';
import 'package:boteco_pro/services/supabase_database_service.dart';
import 'package:boteco_pro/models/data_models.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _map = {};
  @override
  Future<String?> getItem({required String key}) async => _map[key];
  @override
  Future<void> removeItem({required String key}) async {
    _map.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _map[key] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseAuthService authService;
  late SupabaseDatabaseService dbService;

  setUpAll(() async {
    final url = Platform.environment['SUPABASE_URL'];
    final anonKey = Platform.environment['SUPABASE_ANON_KEY'];
    if (url == null || anonKey == null) {
      throw Exception('Missing Supabase environment variables');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: false,
        localStorage: const EmptyLocalStorage(),
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
    );
    authService = SupabaseAuthService();
    dbService = SupabaseDatabaseService();
  });

  test('login, inserir produto e registrar venda', () async {
    final email = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    const password = 'pass1234';

    final user = await authService.signUpWithEmail(email, password, 'Test');
    expect(user, isNotNull);

    final categorias = await dbService.getCategorias();
    if (categorias.isEmpty) {
      await dbService.initializeData(createSampleData: true);
    }
    final categoriaId = (await dbService.getCategorias()).first.id_categoria!;

    final produto = Produto(
      nome: 'Produto Teste',
      unidade_base: 'unidade',
      tipo_produto: 'compra',
      controla_estoque: true,
      id_categoria: categoriaId,
    );
    await dbService.addProduto(produto);

    final produtos = await dbService.getProdutos();
    expect(produtos.any((p) => p.nome == 'Produto Teste'), isTrue);

    final mesa = (await dbService.getMesas()).first;
    final venda = Venda(id_mesa: mesa.id_mesa!, data_venda: DateTime.now());
    await dbService.addVenda(venda);

    final vendas = await dbService.getVendas();
    expect(vendas.isNotEmpty, isTrue);
  });
}
