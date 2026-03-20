import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final Map<String, String> _webFallback = <String, String>{};

  bool get _supportsSecureStorage => !kIsWeb;

  Future<String?> read(String key) async {
    if (_supportsSecureStorage) {
      return _storage.read(key: key);
    }
    return _webFallback[key];
  }

  Future<void> write(String key, String value) async {
    if (_supportsSecureStorage) {
      await _storage.write(key: key, value: value);
      return;
    }
    _webFallback[key] = value;
  }

  Future<void> delete(String key) async {
    if (_supportsSecureStorage) {
      await _storage.delete(key: key);
      return;
    }
    _webFallback.remove(key);
  }
}
