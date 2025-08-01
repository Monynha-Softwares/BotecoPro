import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_user.dart';
import '../l10n/app_localizations.dart';

class SupabaseAuthService {
  // Singleton pattern
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user getter
  AuthUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return AuthUser.fromSupabase(user);
    }
    return null;
  }

  // Auth state changes stream
  Stream<AuthUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user != null) {
        return AuthUser.fromSupabase(user);
      }
      return null;
    });
  }

  // Sign up with email and password
  Future<AuthUser?> signUpWithEmail(String email, String password, String? displayName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user != null) {
        return AuthUser.fromSupabase(response.user!);
      }
      return null;
    } on supabase.AuthException catch (e) {
      debugPrint('Supabase auth error: ${e.message}');
      throw Exception(_getErrorCode(e.message));
    } catch (e) {
      debugPrint('Auth error: $e');
      throw Exception('unknown-error');
    }
  }

  // Sign in with email and password
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthUser.fromSupabase(response.user!);
      }
      return null;
    } on supabase.AuthException catch (e) {
      debugPrint('Supabase auth error: ${e.message}');
      throw Exception(_getErrorCode(e.message));
    } catch (e) {
      debugPrint('Auth error: $e');
      throw Exception('unknown-error');
    }
  }

  // Sign in with Google
  Future<AuthUser?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('google-auth-failed');
      }

      // Sign in to Supabase with Google credentials
      final response = await _supabase.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        return AuthUser.fromSupabase(response.user!);
      }
      return null;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      throw Exception('google-auth-failed');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e) {
      debugPrint('Password reset error: ${e.message}');
      throw Exception(_getErrorCode(e.message));
    } catch (e) {
      debugPrint('Password reset error: $e');
      throw Exception('unknown-error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('sign-out-failed');
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (photoURL != null) updates['avatar_url'] = photoURL;

      if (updates.isNotEmpty) {
        await _supabase.auth.updateUser(supabase.UserAttributes(data: updates));
      }
    } on supabase.AuthException catch (e) {
      debugPrint('Profile update error: ${e.message}');
      throw Exception(_getErrorCode(e.message));
    } catch (e) {
      debugPrint('Profile update error: $e');
      throw Exception('update-failed');
    }
  }

  // Convert Supabase error messages to app error codes
  String _getErrorCode(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('invalid email')) {
      return 'invalid-email';
    } else if (lowerMessage.contains('user not found') || lowerMessage.contains('invalid login credentials')) {
      return 'user-not-found';
    } else if (lowerMessage.contains('password') && lowerMessage.contains('weak')) {
      return 'weak-password';
    } else if (lowerMessage.contains('email already registered') || lowerMessage.contains('already exists')) {
      return 'email-already-in-use';
    } else if (lowerMessage.contains('too many requests')) {
      return 'too-many-requests';
    }
    
    return 'unknown-error';
  }

  // Get error message from Exception
  String getMessageFromErrorCode(BuildContext context, Exception e) {
    final l10n = AppLocalizations.of(context)!;
    final String errorCode = e.toString().replaceAll('Exception: ', '');
    
    switch (errorCode) {
      case 'invalid-email':
        return l10n.invalidEmailError;
      case 'user-not-found':
        return l10n.userNotFoundError;
      case 'wrong-password':
        return l10n.wrongPasswordError;
      case 'weak-password':
        return l10n.weakPasswordError;
      case 'email-already-in-use':
        return l10n.emailInUseError;
      case 'operation-not-allowed':
        return l10n.operationNotAllowedError;
      case 'user-disabled':
        return l10n.userDisabledError;
      case 'too-many-requests':
        return l10n.tooManyRequestsError;
      case 'google-auth-failed':
        return l10n.googleAuthFailedError;
      case 'sign-out-failed':
        return l10n.signOutFailedError;
      case 'update-failed':
        return l10n.updateFailedError;
      default:
        return l10n.unknownError;
    }
  }

  // Mock persist user token - Not needed with Supabase as it handles sessions automatically
  Future<void> persistUserToken() async {
    // Supabase handles session persistence automatically
    return;
  }
}