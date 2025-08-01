import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:boteco_pro/services/local_cache_service.dart';
import 'package:boteco_pro/models/data_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalCacheService cache;

  setUpAll(() async {
    final path = Directory.current.path;
    await LocalCacheService.init(path: path);
    cache = LocalCacheService();
  });

  test('save and get fornecedores from cache', () async {
    final fornecedor = Fornecedor(nome: 'Fornecedor X');
    await cache.saveFornecedores([fornecedor]);

    final result = await cache.getFornecedores();
    expect(result.length, 1);
    expect(result.first.nome, 'Fornecedor X');
  });
}
