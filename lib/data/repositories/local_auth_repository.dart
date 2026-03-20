import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/auth_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../local/secure_storage_service.dart';

class LocalAuthRepository implements AuthRepository<AuthUser> {
  LocalAuthRepository({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService();

  static const _authUserKey = 'auth_user';
  static const _authModeKey = 'auth_mode';
  static const _sessionUserIdKey = 'session_user_id';
  final SecureStorageService _secureStorage;

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<AuthUser?> getCurrentUser() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_authUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_authUserKey);
      await _secureStorage.delete(_sessionUserIdKey);
      return null;
    }
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = AuthUser(
      id: 'local_${normalizedEmail.hashCode}',
      email: normalizedEmail,
      name: _guessDisplayName(normalizedEmail),
      photoUrl: null,
    );
    await _persistUser(user);
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = AuthUser(
      id: 'local_${normalizedEmail.hashCode}',
      email: normalizedEmail,
      name: name.trim(),
      photoUrl: null,
    );
    await _persistUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _secureStorage.write(_authModeKey, 'password_reset_requested');
  }

  @override
  Future<void> signOut() async {
    final prefs = await _prefs;
    await prefs.remove(_authUserKey);
    await _secureStorage.delete(_sessionUserIdKey);
    await _secureStorage.delete(_authModeKey);
  }

  Future<void> _persistUser(AuthUser user) async {
    final prefs = await _prefs;
    await prefs.setString(_authUserKey, jsonEncode(user.toJson()));
    await _secureStorage.write(_sessionUserIdKey, user.id);
    await _secureStorage.write(_authModeKey, 'local');
  }

  String _guessDisplayName(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return 'Operador BotecoPro';
    }

    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
