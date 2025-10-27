// lib/core/services/auth_service.dart

/// AuthService - Serviço de Autenticação com Firebase
///
/// Este serviço é responsável pela autenticação de usuários no aplicativo.
/// Implementa todas as funcionalidades de autenticação usando Firebase Auth.
///
/// FUNCIONALIDADES IMPLEMENTADAS:
///
/// 1. Autenticação com Firebase:
///    - Login com email e senha ✅
///    - Cadastro de novos usuários ✅
///    - Login com Google ✅
///    - Recuperação de senha ✅
///    - Logout ✅
///
/// 2. Gerenciamento de Sessão:
///    - Verificação de usuário autenticado ✅
///    - Persistência de sessão ✅
///    - Stream de mudanças de autenticação ✅
///
/// 3. Integração com AuthProvider:
///    - Este service é chamado pelo AuthProvider ✅
///    - AuthProvider gerencia o estado da autenticação ✅
///
/// EXEMPLO DE USO:
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
/// DEPENDÊNCIAS NECESSÁRIAS:
/// ```yaml
/// dependencies:
///   firebase_core: ^2.24.0
///   firebase_auth: ^4.15.0
///   google_sign_in: ^6.1.5
/// ```
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

  /// Faz login com email e senha usando Firebase Auth.
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

  /// Registra novo usuário com email e senha no Firebase Auth.
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

  /// Faz login com conta Google (suporta Web e Mobile).
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

  /// Faz logout do usuário atual.
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

  /// Envia email de recuperação de senha.
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

  /// Retorna o usuário atualmente autenticado.
  @override
  Future<AuthUser?> getCurrentUser() async {
    return _authUserFromFirebase(_firebaseAuth.currentUser);
  }

  /// Stream de mudanças no estado de autenticação.
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
