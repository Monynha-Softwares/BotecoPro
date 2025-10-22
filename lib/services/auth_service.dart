import 'package:shared_preferences/shared_preferences.dart';

/// Simple authentication service for BotecoPro MVP
/// Uses SharedPreferences for session management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get current user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Get current user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Login user (simple demonstration - no real authentication)
  Future<bool> login(String email, String password) async {
    // For MVP, accept any non-empty credentials
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, email.split('@').first);

    return true;
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }
}
