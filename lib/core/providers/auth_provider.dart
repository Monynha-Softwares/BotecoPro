import 'package:flutter/foundation.dart';

import '../../data/repositories/local_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository<AuthUser>? repository})
      : _repository = repository ?? LocalAuthRepository();

  final AuthRepository<AuthUser> _repository;

  AuthUser? _user;
  bool _initialized = false;
  bool _isLoading = false;
  String? _lastError;

  AuthUser? get user => _user;
  bool get initialized => _initialized;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  String? get lastError => _lastError;
  String get displayName => _user?.name?.trim().isNotEmpty == true
      ? _user!.name!
      : (_user?.email ?? 'Equipe Monynha');

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _setLoading(true);
    try {
      _user = await _repository.getCurrentUser();
      _lastError = null;
    } catch (error) {
      _lastError = 'Falha ao restaurar a sessão local: $error';
    } finally {
      _initialized = true;
      _setLoading(false, notify: true);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    return _performAuthAction(() {
      return _repository.signIn(email: email, password: password);
    });
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    return _performAuthAction(() {
      return _repository.signUp(name: name, email: email, password: password);
    });
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _repository.sendPasswordReset(email);
      _lastError = null;
    } catch (error) {
      _lastError = 'Não foi possível solicitar a redefinição: $error';
    } finally {
      _setLoading(false, notify: true);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _repository.signOut();
      _user = null;
      _lastError = null;
    } catch (error) {
      _lastError = 'Falha ao encerrar a sessão: $error';
    } finally {
      _setLoading(false, notify: true);
    }
  }

  Future<bool> _performAuthAction(Future<AuthUser> Function() action) async {
    _setLoading(true);
    try {
      _user = await action();
      _lastError = null;
      return true;
    } catch (error) {
      _lastError = 'Falha na autenticação: $error';
      return false;
    } finally {
      _setLoading(false, notify: true);
    }
  }

  void clearError() {
    if (_lastError == null) {
      return;
    }
    _lastError = null;
    notifyListeners();
  }

  void _setLoading(bool value, {bool notify = false}) {
    _isLoading = value;
    if (notify) {
      notifyListeners();
    }
  }
}
