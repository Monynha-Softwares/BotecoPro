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
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user.dart';

abstract class BaseAuthService {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  });

  Future<AuthUser?> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<AuthUser?> getCurrentUser();

  void dispose();
}

class AuthServiceException implements Exception {
  AuthServiceException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AuthService implements BaseAuthService {
  // TODO(auth): Implementar singleton pattern se necessário (ver docs/DOCUMENTATION_INDEX.md, seção "⚠️ Estado atual da autenticação").
  // static final AuthService _instance = AuthService._internal();
  // factory AuthService() => _instance;
  // AuthService._internal();

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn,
        _authStateController = StreamController<AuthUser?>.broadcast();

  final FirebaseAuth _firebaseAuth;
  GoogleSignIn? _googleSignIn;
  final StreamController<AuthUser?> _authStateController;

  @override
  Stream<AuthUser?> get authStateChanges {
    _ensureAuthStateSubscription();
    return _authStateController.stream;
  }

  StreamSubscription<User?>? _authStateSubscription;

  void _ensureAuthStateSubscription() {
    _authStateSubscription ??=
        _firebaseAuth.authStateChanges().listen((User? firebaseUser) {
      _authStateController.add(_authUserFromFirebase(firebaseUser));
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateController.close();
  }

  /// TODO(auth): Implementar login com email e senha.
  @override
  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _authUserFromFirebase(credential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapFirebaseException(e), code: e.code);
    } catch (e) {
      throw AuthServiceException(
        'Não foi possível entrar / Unable to sign in: $e',
      );
    }
  }

  /// TODO(auth): Implementar cadastro de novo usuário.
  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null && name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      return _authUserFromFirebase(_firebaseAuth.currentUser);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapFirebaseException(e), code: e.code);
    } catch (e) {
      throw AuthServiceException(
        'Não foi possível concluir o cadastro / Unable to sign up: $e',
      );
    }
  }

  /// TODO(auth): Implementar login com Google.
  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final credential = await _firebaseAuth.signInWithPopup(provider);
        return _authUserFromFirebase(credential.user);
      }

      _googleSignIn ??= GoogleSignIn(scopes: const ['email']);
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return null;
      }
      final googleAuth = await googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final credential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      return _authUserFromFirebase(credential.user);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapFirebaseException(e), code: e.code);
    } catch (e) {
      throw AuthServiceException(
        'Não foi possível entrar com Google / Unable to sign in with Google: $e',
      );
    }
  }

  /// TODO(auth): Implementar logout.
  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (!kIsWeb) {
        _googleSignIn ??= GoogleSignIn(scopes: const ['email']);
        await _googleSignIn!.signOut();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapFirebaseException(e), code: e.code);
    } catch (e) {
      throw AuthServiceException(
        'Não foi possível finalizar a sessão / Unable to sign out: $e',
      );
    }
  }

  /// TODO(auth): Implementar recuperação de senha.
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapFirebaseException(e), code: e.code);
    } catch (e) {
      throw AuthServiceException(
        'Não foi possível enviar o email de recuperação / Unable to send reset email: $e',
      );
    }
  }

  /// TODO(auth): Implementar verificação de usuário autenticado.
  @override
  Future<AuthUser?> getCurrentUser() async {
    return _authUserFromFirebase(_firebaseAuth.currentUser);
  }

  /// TODO(auth): Implementar stream de mudanças de autenticação.
  Stream<AuthUser?> observeAuthState() => authStateChanges;

  AuthUser? _authUserFromFirebase(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      id: user.uid,
      email: user.email,
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  String _mapFirebaseException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'Usuário não encontrado / User not found';
      case 'wrong-password':
        return 'Senha inválida / Wrong password';
      case 'invalid-email':
        return 'Email inválido / Invalid email';
      case 'user-disabled':
        return 'Usuário desativado / User disabled';
      case 'email-already-in-use':
        return 'Email já cadastrado / Email already in use';
      case 'weak-password':
        return 'Senha fraca / Weak password';
      case 'operation-not-allowed':
        return 'Operação não permitida / Operation not allowed';
      case 'network-request-failed':
        return 'Falha de rede / Network request failed';
      default:
        return exception.message ??
            'Erro inesperado na autenticação / Unexpected authentication error';
    }
  }
}
