import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/data_models.dart';

class LocalCacheService {
  static bool _initialized = false;

  static Future<void> init({String? path}) async {
    if (_initialized) return;
    if (path != null) {
      Hive.init(path);
    } else {
      try {
        await Hive.initFlutter();
      } catch (_) {
        Hive.init(Directory.current.path);
      }
    }
    await Hive.openBox<Map>('fornecedores');
    await Hive.openBox<Map>('mesas');
    await Hive.openBox<Map>('pending_ops');
    _initialized = true;
  }

  Box<Map> get _fornecedoresBox => Hive.box<Map>('fornecedores');
  Box<Map> get _mesasBox => Hive.box<Map>('mesas');
  Box<Map> get _pendingBox => Hive.box<Map>('pending_ops');

  Future<List<Fornecedor>> getFornecedores() async {
    return _fornecedoresBox.values
        .map((e) => Fornecedor.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveFornecedores(List<Fornecedor> fornecedores) async {
    await _fornecedoresBox.clear();
    for (final f in fornecedores) {
      final key = f.id_fornecedor?.toString() ?? uuid.v4();
      await _fornecedoresBox.put(key, f.toJson());
    }
  }

  Future<void> upsertFornecedor(Fornecedor fornecedor) async {
    final key = fornecedor.id_fornecedor?.toString() ?? uuid.v4();
    await _fornecedoresBox.put(key, fornecedor.toJson());
  }

  Future<void> removeFornecedor(int id) async {
    final key = _fornecedoresBox.keys.firstWhere(
      (k) => _fornecedoresBox.get(k)?['id_fornecedor'] == id,
      orElse: () => null,
    );
    if (key != null) {
      await _fornecedoresBox.delete(key);
    }
  }

  Future<List<Mesa>> getMesas() async {
    return _mesasBox.values
        .map((e) => Mesa.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveMesas(List<Mesa> mesas) async {
    await _mesasBox.clear();
    for (final m in mesas) {
      final key = m.id_mesa?.toString() ?? uuid.v4();
      await _mesasBox.put(key, m.toJson());
    }
  }

  Future<void> upsertMesa(Mesa mesa) async {
    final key = mesa.id_mesa?.toString() ?? uuid.v4();
    await _mesasBox.put(key, mesa.toJson());
  }

  Future<void> removeMesa(int id) async {
    final key = _mesasBox.keys.firstWhere(
      (k) => _mesasBox.get(k)?['id_mesa'] == id,
      orElse: () => null,
    );
    if (key != null) {
      await _mesasBox.delete(key);
    }
  }

  Future<void> addPending(Map<String, dynamic> op) async {
    await _pendingBox.add(op);
  }

  Future<List<Map<String, dynamic>>> pendingOperations() async {
    return _pendingBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> clearPending() async {
    await _pendingBox.clear();
  }
}
