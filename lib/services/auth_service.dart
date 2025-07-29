// In a real implementation, these would be actual Firebase imports
// import 'package:firebase_auth/firebase_auth.dart' as firebase;
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/auth_user.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Load stored user data when service is initialized
    _loadStoredUser();
  }

  // Mock Firebase Auth (in a real implementation, these would be actual Firebase instances)
  // final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Current user simulation
  AuthUser? _currentUser;

  // Mock stream for auth state changes
  Stream<AuthUser?> get authStateChanges {
    // Create a stream controller to simulate auth state changes
    return Stream.value(_currentUser);
  }

  // Get current user
  AuthUser? get currentUser => _currentUser;

  // Load stored user from SharedPreferences
  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('auth_user');
      if (userJson != null) {
        // Simulate an authenticated user from stored preferences
        _currentUser = AuthUser.fromFirebase({
          'uid': prefs.getString('user_uid') ?? '123456',
          'displayName': prefs.getString('user_displayName') ?? 'Test User',
          'email': prefs.getString('user_email') ?? 'admin@boteco.pro',
          'photoURL': prefs.getString('user_photoURL'),
          'emailVerified': true,
          'providerId': 'password'
        });
      }
    } catch (e) {
      debugPrint('Error loading stored user: $e');
    }
  }

  // Mock sign in with email and password
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Test accounts for easy login
      if ((email == 'test@example.com' && password == 'password123') ||
          (email == 'admin@boteco.pro' && password == 'admin123')) {
        
        _currentUser = AuthUser.fromFirebase({
          'uid': '123456',
          'displayName': email == 'admin@boteco.pro' ? 'Administrador' : 'Test User',
          'email': email,
          'photoURL': null,
          'emailVerified': true,
          'providerId': 'password'
        });
        
        // Save to SharedPreferences for persistence
        await persistUserToken();
        
        return _currentUser;
      } else if (email.isEmpty || !email.contains('@')) {
        throw Exception('invalid-email');
      } else if (password.length < 6) {
        throw Exception('weak-password');
      } else {
        throw Exception('user-not-found');
      }
    } catch (e) {
      debugPrint('Email sign in error: $e');
      rethrow;
    }
  }

  // Mock sign up with email and password
  Future<AuthUser?> signUpWithEmail(String email, String password, String? displayName) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock validation (in a real app, this would be handled by Firebase)
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('invalid-email');
      } else if (password.length < 6) {
        throw Exception('weak-password');
      }
      
      // Create new user
      _currentUser = AuthUser.fromFirebase({
        'uid': DateTime.now().millisecondsSinceEpoch.toString(),
        'displayName': displayName ?? email.split('@')[0],
        'email': email,
        'photoURL': null,
        'emailVerified': false,
        'providerId': 'password'
      });
      
      // Save to SharedPreferences for persistence
      await persistUserToken();
      
      return _currentUser;
    } catch (e) {
      debugPrint('Email sign up error: $e');
      rethrow;
    }
  }

  // Mock sign in with Google
  Future<AuthUser?> signInWithGoogle() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful Google sign in
      _currentUser = AuthUser.fromFirebase({
        'uid': 'google-${DateTime.now().millisecondsSinceEpoch}',
        'displayName': 'Google User',
        'email': 'google@example.com',
        'photoURL': null,
        'emailVerified': true,
        'providerId': 'google.com'
      });
      
      // Save to SharedPreferences for persistence
      await persistUserToken();
      
      return _currentUser;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  // Mock sign out
  Future<void> signOut() async {
    // Clear stored user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
    await prefs.remove('user_uid');
    await prefs.remove('user_displayName');
    await prefs.remove('user_email');
    await prefs.remove('user_photoURL');
    
    _currentUser = null;
  }

  // Mock reset password
  Future<void> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('invalid-email');
    }
    
    // In a real app, this would trigger a password reset email
    // For this mock implementation, we'll just consider it successful
    return;
  }

  // Mock update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Update current user
    if (_currentUser != null) {
      _currentUser = AuthUser.fromFirebase({
        'uid': _currentUser!.uid,
        'displayName': displayName ?? _currentUser!.displayName,
        'email': _currentUser!.email,
        'photoURL': photoURL ?? _currentUser!.photoUrl,
        'emailVerified': _currentUser!.emailVerified,
        'providerId': _currentUser!.isGoogleProvider ? 'google.com' : 'password'
      });
      
      // Update stored user data
      await persistUserToken();
    }
  }

  // Mock persist user token
  Future<void> persistUserToken() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', 'user-data-stored');
      await prefs.setString('user_uid', _currentUser!.uid);
      await prefs.setString('user_displayName', _currentUser!.displayName ?? '');
      await prefs.setString('user_email', _currentUser!.email ?? '');
      if (_currentUser!.photoUrl != null) {
        await prefs.setString('user_photoURL', _currentUser!.photoUrl!);
      }
    }
  }

  // Get error message from Exception
  String getMessageFromErrorCode(Exception e) {
    final String errorCode = e.toString().replaceAll('Exception: ', '');
    
    switch (errorCode) {
      case 'invalid-email':
        return 'O e-mail informado é inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique seu e-mail e senha.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outro usuário.';
      case 'operation-not-allowed':
        return 'Operação não permitida. Contate o suporte.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Contate o suporte.';
      default:
        return 'Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.';
    }
  }
}