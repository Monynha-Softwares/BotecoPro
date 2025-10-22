import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling Supabase authentication
/// 
/// This service provides methods for user authentication including:
/// - Sign in with email/password
/// - Sign up
/// - Sign out
/// - Password reset
/// - Session management
class SupabaseAuthService {
  // Singleton pattern
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  /// Get the Supabase client instance
  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Supabase not initialized. Please configure .env file with SUPABASE_URL and SUPABASE_ANON_KEY');
    }
  }

  /// Get the current user (returns null if Supabase not initialized)
  User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Get the current session (returns null if Supabase not initialized)
  Session? get currentSession {
    try {
      return client.auth.currentSession;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated (returns false if Supabase not initialized)
  bool get isAuthenticated {
    try {
      return currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password - sends reset email
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await client.auth.updateUser(
        UserAttributes(data: metadata),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sign in with OAuth provider (Google, Apple, etc.)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      final result = await client.auth.signInWithOAuth(provider);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
