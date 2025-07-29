import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/supabase_auth_service.dart';
import '../services/user_provider.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();
  AuthStatus _status = AuthStatus.initial;
  AuthUser? _user;
  String? _error;
  bool _isLoading = false;

  // Constructor
  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication and listen to state changes
  void _initializeAuth() {
    // Check if user is already signed in
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  // Getters
  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is Exception ? _authService.getMessageFromErrorCode(e) : 'Ocorreu um erro. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Ocorreu um erro. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signUpWithEmail(email, password, displayName);
      if (user != null) {
        // Update user profile info in UserProvider
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Falha ao criar conta. Tente novamente.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e is Exception ? _authService.getMessageFromErrorCode(e) : 'Ocorreu um erro. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Ocorreu um erro. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        // Google sign in successful
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // User canceled Google sign in
        _error = 'Login com Google cancelado.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Falha no login com Google. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
    } catch (e) {
      _error = 'Falha ao sair. Tente novamente mais tarde.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is Exception ? _authService.getMessageFromErrorCode(e) : 'Ocorreu um erro. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Ocorreu um erro ao resetar a senha. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user profile in Firebase and sync with UserProvider
  Future<bool> updateProfile({String? displayName, String? photoURL, required UserProvider userProvider}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      // Update user profile in UserProvider
      if (user != null && displayName != null) {
        // Only update the profile if the displayName was changed
        final currentProfile = userProvider.userProfile;
        await userProvider.updateUserProfile(currentProfile.copyWith(
          name: displayName,
        ));
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Falha ao atualizar o perfil. Tente novamente mais tarde.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}