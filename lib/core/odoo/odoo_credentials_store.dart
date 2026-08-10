import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'odoo_connection.dart';

class OdooCredentialsStore {
  const OdooCredentialsStore({
    this.secureStorage = const FlutterSecureStorage(),
  });

  static const _baseUrlKey = 'odoo.connection.base_url';
  static const _usernameKey = 'odoo.connection.username';
  static const _databaseKey = 'odoo.connection.database';
  static const _apiKey = 'odoo.secret.api_key';
  static const _companyKey = 'odoo.selection.company_id';
  static const _posConfigKey = 'odoo.selection.pos_config_id';

  final FlutterSecureStorage secureStorage;

  Future<OdooConnection?> readConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_baseUrlKey);
    final username = prefs.getString(_usernameKey);
    if (baseUrl == null || username == null) return null;
    return OdooConnection(
      baseUrl: baseUrl,
      username: username,
      database: prefs.getString(_databaseKey),
    );
  }

  Future<String?> readApiKey() => secureStorage.read(key: _apiKey);

  Future<int?> readCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_companyKey);
  }

  Future<int?> readPosConfigId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_posConfigKey);
  }

  Future<void> saveConnection({
    required OdooConnection connection,
    required String apiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, connection.baseUrl);
    await prefs.setString(_usernameKey, connection.username);
    if (connection.database == null) {
      await prefs.remove(_databaseKey);
    } else {
      await prefs.setString(_databaseKey, connection.database!);
    }
    await secureStorage.write(key: _apiKey, value: apiKey);
  }

  Future<void> saveSelections({int? companyId, int? posConfigId}) async {
    final prefs = await SharedPreferences.getInstance();
    if (companyId == null) {
      await prefs.remove(_companyKey);
    } else {
      await prefs.setInt(_companyKey, companyId);
    }
    if (posConfigId == null) {
      await prefs.remove(_posConfigKey);
    } else {
      await prefs.setInt(_posConfigKey, posConfigId);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in <String>[
      _baseUrlKey,
      _usernameKey,
      _databaseKey,
      _companyKey,
      _posConfigKey,
    ]) {
      await prefs.remove(key);
    }
    await secureStorage.delete(key: _apiKey);
  }
}
