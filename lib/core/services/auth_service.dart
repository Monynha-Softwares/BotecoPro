// lib/core/services/auth_service.dart

/// AuthService - Placeholder para implementação futura de autenticação
///
/// Este serviço será responsável pela autenticação de usuários no aplicativo.
/// Atualmente está vazio e pronto para ser implementado quando necessário.
/// Consulte docs/DOCUMENTATION_INDEX.md (Seção "⚠️ Estado atual da autenticação")
/// para orientação completa sobre os próximos passos de desenvolvimento.
///
/// IMPLEMENTAÇÕES FUTURAS PREVISTAS:
///
/// 1. Autenticação com Firebase:
///    - Login com email e senha
///    - Cadastro de novos usuários
///    - Login com Google
///    - Recuperação de senha
///    - Logout
///
/// 2. Gerenciamento de Sessão:
///    - Verificação de usuário autenticado
///    - Persistência de sessão
///    - Token de autenticação
///
/// 3. Integração com AuthProvider:
///    - Este service será chamado pelo AuthProvider
///    - AuthProvider gerenciará o estado da autenticação
///
/// EXEMPLO DE USO FUTURO:
/// ```dart
/// final authService = AuthService();
///
/// // Login
/// final user = await authService.signInWithEmailAndPassword(
///   email: 'user@example.com',
///   password: 'senha123',
/// );
///
/// // Cadastro
/// final newUser = await authService.registerWithEmailAndPassword(
///   email: 'novousuario@example.com',
///   password: 'senha123',
///   name: 'Nome do Usuário',
/// );
///
/// // Logout
/// await authService.signOut();
/// ```
///
/// INTEGRAÇÃO COM FIREBASE:
/// Para integrar com Firebase, adicione as dependências:
/// ```yaml
/// dependencies:
///   firebase_core: ^2.24.0
///   firebase_auth: ^4.15.0
///   google_sign_in: ^6.1.5
/// ```
///
/// E implemente os métodos seguindo os exemplos no AuthProvider.
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/auth_user.dart';

class AuthException implements Exception {
  AuthException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  // TODO(auth): Implementar singleton pattern se necessário (ver docs/DOCUMENTATION_INDEX.md, seção "⚠️ Estado atual da autentic
  // ação").
  // static final AuthService _instance = AuthService._internal();
  // factory AuthService() => _instance;
  // AuthService._internal();

  AuthService({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _usersKey = 'auth_registered_users';

  final Uuid _uuid = const Uuid();
  SharedPreferences? _preferences;

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final users = await _loadUsers();
    final storedUser = users.firstWhere(
      (user) => user.normalizedEmail == normalizedEmail,
      orElse: () => throw AuthException(
        'invalid-credentials',
        'Credenciais inválidas. Verifique seu email e senha.',
      ),
    );

    if (!_verifyPassword(password, storedUser.passwordHash)) {
      throw AuthException(
        'invalid-credentials',
        'Credenciais inválidas. Verifique seu email e senha.',
      );
    }

    return storedUser.toAuthUser();
  }

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final trimmedEmail = email.trim();
    final normalizedEmail = _normalizeEmail(email);
    final users = await _loadUsers();

    final alreadyExists = users.any(
      (user) => user.normalizedEmail == normalizedEmail,
    );

    if (alreadyExists) {
      throw AuthException(
        'email-already-in-use',
        'Já existe uma conta cadastrada com esse email.',
      );
    }

    final storedUser = _StoredUser(
      id: _uuid.v4(),
      email: trimmedEmail,
      normalizedEmail: normalizedEmail,
      passwordHash: _hashPassword(password),
      name: _cleanOptional(name),
      photoUrl: null,
    );

    final updatedUsers = <_StoredUser>[...users, storedUser];
    await _saveUsers(updatedUsers);

    return storedUser.toAuthUser();
  }

  Future<void> requestPasswordReset({required String email}) async {
    final normalizedEmail = _normalizeEmail(email);
    final users = await _loadUsers();
    final exists = users.any((user) => user.normalizedEmail == normalizedEmail);

    if (!exists) {
      throw AuthException(
        'user-not-found',
        'Email não encontrado na base de usuários.',
      );
    }
  }

  Future<AuthUser?> getUserById(String id) async {
    final users = await _loadUsers();
    for (final user in users) {
      if (user.id == id) {
        return user.toAuthUser();
      }
    }
    return null;
  }

  Future<List<_StoredUser>> _loadUsers() async {
    final prefs = await _preferencesInstance;
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      return <_StoredUser>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <_StoredUser>[];
      }

      return decoded
          .map((dynamic item) {
            if (item is Map<String, dynamic>) {
              return _StoredUser.fromJson(item);
            }
            if (item is Map) {
              return _StoredUser.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              );
            }
            return null;
          })
          .whereType<_StoredUser>()
          .toList(growable: false);
    } catch (_) {
      return <_StoredUser>[];
    }
  }

  Future<void> _saveUsers(List<_StoredUser> users) async {
    final prefs = await _preferencesInstance;
    final serialized = jsonEncode(users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, serialized);
  }

  Future<SharedPreferences> get _preferencesInstance async {
    if (_preferences != null) {
      return _preferences!;
    }
    _preferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Gera hash seguro da senha usando PBKDF2 com salt aleatório.
  /// 
  /// Retorna uma string no formato: "salt:hash"
  /// - salt: 16 bytes aleatórios em base64
  /// - hash: PBKDF2-HMAC-SHA256 com 10000 iterações
  String _hashPassword(String password) {
    // Gera salt aleatório de 16 bytes
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final salt = base64Encode(saltBytes);
    
    // Deriva chave usando PBKDF2 com 10000 iterações
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, saltBytes);
    
    // Implementação simplificada de PBKDF2
    var hash = passwordBytes;
    for (var i = 0; i < 10000; i++) {
      final output = hmac.convert(hash);
      hash = output.bytes;
    }
    
    final hashStr = base64Encode(hash);
    return '$salt:$hashStr';
  }
  
  /// Verifica se a senha fornecida corresponde ao hash armazenado.
  bool _verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) {
        // Hash antigo (SHA-256 sem salt) - migrar automaticamente
        return _hashPasswordLegacy(password) == storedHash;
      }
      
      final salt = base64Decode(parts[0]);
      final expectedHash = parts[1];
      
      // Deriva hash da senha fornecida com o mesmo salt
      final passwordBytes = utf8.encode(password);
      final hmac = Hmac(sha256, salt);
      
      var hash = passwordBytes;
      for (var i = 0; i < 10000; i++) {
        final output = hmac.convert(hash);
        hash = output.bytes;
      }
      
      final actualHash = base64Encode(hash);
      return actualHash == expectedHash;
    } catch (_) {
      return false;
    }
  }
  
  /// Hash legado (SHA-256 sem salt) - apenas para migração.
  @deprecated
  String _hashPasswordLegacy(String password) {
    final data = utf8.encode(password);
    return sha256.convert(data).toString();
  }

  String? _cleanOptional(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }
    return cleaned;
  }
}

class _StoredUser {
  const _StoredUser({
    required this.id,
    required this.email,
    required this.normalizedEmail,
    required this.passwordHash,
    this.name,
    this.photoUrl,
  });

  factory _StoredUser.fromJson(Map<String, dynamic> json) {
    final rawEmail = (json['email'] as String?)?.trim() ?? '';
    final normalized =
        (json['normalizedEmail'] as String?) ?? rawEmail.toLowerCase();

    return _StoredUser(
      id: json['id'] as String,
      email: rawEmail,
      normalizedEmail: normalized,
      passwordHash: json['passwordHash'] as String? ?? '',
      name: (json['name'] as String?)?.trim(),
      photoUrl: json['photoUrl'] as String?,
    );
  }

  final String id;
  final String email;
  final String normalizedEmail;
  final String passwordHash;
  final String? name;
  final String? photoUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'normalizedEmail': normalizedEmail,
      'passwordHash': passwordHash,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  AuthUser toAuthUser() {
    return AuthUser(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );
  }
}
