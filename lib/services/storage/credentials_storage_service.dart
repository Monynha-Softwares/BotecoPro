import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/connection.dart';

class CredentialsStorageService {
  const CredentialsStorageService({
    this.secureStorage = const FlutterSecureStorage(),
    this.namespace = '',
  });

  static const _baseUrlKey = 'odoo.connection.base_url';
  static const _usernameKey = 'odoo.connection.username';
  static const _databaseKey = 'odoo.connection.database';
  static const _apiKey = 'odoo.secret.api_key';
  static const _companyKey = 'odoo.selection.company_id';
  static const _posConfigKey = 'odoo.selection.pos_config_id';
  static const _userIdKey = 'odoo.identity.user_id';

  final FlutterSecureStorage secureStorage;
  final String namespace;

  String _key(String key) => namespace.isEmpty ? key : '$namespace.$key';

  Future<ConnectionConfig?> readConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_key(_baseUrlKey));
    final username = prefs.getString(_key(_usernameKey));
    if (baseUrl == null || username == null) return null;
    return ConnectionConfig(
      baseUrl: baseUrl,
      username: username,
      database: prefs.getString(_key(_databaseKey)),
    );
  }

  Future<String?> readApiKey() => secureStorage.read(key: _key(_apiKey));

  Future<int?> readCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(_companyKey));
  }

  Future<int?> readPosConfigId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(_posConfigKey));
  }

  Future<int?> readUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(_userIdKey));
  }

  Future<void> saveConnection({
    required ConnectionConfig connection,
    required String apiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(_baseUrlKey), connection.baseUrl);
    await prefs.setString(_key(_usernameKey), connection.username);
    if (connection.database == null) {
      await prefs.remove(_key(_databaseKey));
    } else {
      await prefs.setString(_key(_databaseKey), connection.database!);
    }
    await secureStorage.write(key: _key(_apiKey), value: apiKey);
  }

  Future<void> saveSelections({int? companyId, int? posConfigId}) async {
    final prefs = await SharedPreferences.getInstance();
    if (companyId == null) {
      await prefs.remove(_key(_companyKey));
    } else {
      await prefs.setInt(_key(_companyKey), companyId);
    }
    if (posConfigId == null) {
      await prefs.remove(_key(_posConfigKey));
    } else {
      await prefs.setInt(_key(_posConfigKey), posConfigId);
    }
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(_userIdKey), userId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in <String>[
      _baseUrlKey,
      _usernameKey,
      _databaseKey,
      _companyKey,
      _posConfigKey,
      _userIdKey,
    ]) {
      await prefs.remove(_key(key));
    }
    await secureStorage.delete(key: _key(_apiKey));
  }
}
