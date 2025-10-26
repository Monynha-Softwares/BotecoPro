// lib/core/services/auth_service.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user.dart';

abstract class AuthService {
  Future<AuthUser?> signInWithEmail(String email, String password);

  Future<AuthUser?> signUpWithEmail(String email, String password, {String? name});

  Future<AuthUser?> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  Future<AuthUser?> getCurrentUser();

  Stream<AuthUser?> authStateChanges();
}

class AuthFailure implements Exception {
  AuthFailure({required this.code, required this.message, this.cause});

  final String code;
  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebase(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    } catch (error) {
      throw AuthFailure(
        code: 'unknown',
        message: 'Não foi possível fazer login. Tente novamente.',
        cause: error,
      );
    }
  }

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password,
      {String? name}) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = credential.user;
      if (user != null && name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
        return _userFromFirebase(_firebaseAuth.currentUser);
      }
      return _userFromFirebase(user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    } catch (error) {
      throw AuthFailure(
        code: 'unknown',
        message: 'Não foi possível concluir o cadastro.',
        cause: error,
      );
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure(
          code: 'aborted',
          message: 'Login com Google cancelado pelo usuário.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return _userFromFirebase(userCredential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    } catch (error) {
      throw AuthFailure(
        code: 'unknown',
        message: 'Não foi possível fazer login com o Google.',
        cause: error,
      );
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    } catch (error) {
      throw AuthFailure(
        code: 'unknown',
        message: 'Não foi possível enviar o email de recuperação.',
        cause: error,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait(<Future<void>>[
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (error) {
      throw AuthFailure(
        code: 'unknown',
        message: 'Não foi possível encerrar a sessão.',
        cause: error,
      );
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return _userFromFirebase(_firebaseAuth.currentUser);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  AuthUser? _userFromFirebase(User? user) {
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

  AuthFailure _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return AuthFailure(
          code: error.code,
          message: 'O endereço de email é inválido.',
          cause: error,
        );
      case 'user-disabled':
        return AuthFailure(
          code: error.code,
          message: 'Esta conta foi desativada.',
          cause: error,
        );
      case 'user-not-found':
        return AuthFailure(
          code: error.code,
          message: 'Não encontramos uma conta com este email.',
          cause: error,
        );
      case 'wrong-password':
        return AuthFailure(
          code: error.code,
          message: 'Senha incorreta. Verifique e tente novamente.',
          cause: error,
        );
      case 'email-already-in-use':
        return AuthFailure(
          code: error.code,
          message: 'Este email já está em uso.',
          cause: error,
        );
      case 'weak-password':
        return AuthFailure(
          code: error.code,
          message: 'A senha precisa ser mais forte.',
          cause: error,
        );
      case 'operation-not-allowed':
        return AuthFailure(
          code: error.code,
          message: 'Operação não permitida. Verifique as configurações do Firebase.',
          cause: error,
        );
      default:
        return AuthFailure(
          code: error.code,
          message: error.message ?? 'Ocorreu um erro de autenticação.',
          cause: error,
        );
    }
  }
}
