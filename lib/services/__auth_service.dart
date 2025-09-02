import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

import '../models/__auth_models.dart';

class AuthService {
  static const String baseUrl =
      'https://gw.apiflow.online/api/1358f420ae2e4df794a4b4b49f53d042';
  static const String authToken =
      'ODAxMDdlMTQ1YTJlYmFhNjZjOGZiMjQ1MDRmNmY0MGQ6YTE3NjFiOTRjODM3NmE3ODNiZjVhNWU4NDlhZjlmZmQ=';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        '431701294282-dcv6qh9mrfp8jrbi7so1dssfic6lie5v.apps.googleusercontent.com',
  );
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keys for secure storage
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _googleSubKey = 'google_sub';

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Check if user is already signed in
  Future<bool> isSignedIn() async {
    final userId = await _secureStorage.read(key: _userIdKey);
    return userId != null;
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      late final GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        googleUser = await _signInWithGoogleWeb();
      } else {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        // User cancelled the sign-in flow
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Decode the JWT token to extract data
      final Map<String, dynamic> decodedToken = Jwt.parseJwt(idToken);
      final String googleSub = decodedToken['sub'] as String;
      final String email = googleUser.email;
      final String name = googleUser.displayName ?? email.split('@')[0];

      // Register or update user in backend
      final user = await _registerOrUpdateUser(googleSub, name, email);

      // Store user info in secure storage
      await _secureStorage.write(key: _userIdKey, value: user.id.toString());
      await _secureStorage.write(key: _userEmailKey, value: user.email);
      await _secureStorage.write(key: _userNameKey, value: user.name);
      await _secureStorage.write(key: _googleSubKey, value: googleSub);

      _currentUser = user;
      return user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<GoogleSignInAccount?> _signInWithGoogleWeb() async {
    try {
      await _googleSignIn.signOut();
      return await _googleSignIn.signIn();
    } catch (error) {
      debugPrint('Error signing in with Google on web: $error');
      return null;
    }
  }

  // Register or update user in the backend
  Future<User> _registerOrUpdateUser(
      String googleSub, String name, String email) async {
    final url = Uri.parse('$baseUrl/sp/dbo.sp_register_or_update_user');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'google_sub': googleSub,
        'nome': name,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      final int userId = responseData['id_usuario'] ?? 0;

      if (userId == 0) {
        throw Exception('Failed to register/update user: Invalid user ID');
      }

      return User(
        id: userId,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Failed to register/update user: ${response.statusCode}');
    }
  }

  // Fetch user profile from backend
  Future<User> fetchUserProfile(int userId) async {
    final url = Uri.parse(
        '$baseUrl/view/dbo.vw_usuario_detalhes?filter=(id_usuario=$userId)');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);

      if (responseData.isEmpty) {
        throw Exception('User not found');
      }

      final user = User.fromJson(responseData.first);
      _currentUser = user;
      return user;
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode}');
    }
  }

  // Load current user from secure storage
  Future<User?> loadCurrentUser() async {
    final userIdStr = await _secureStorage.read(key: _userIdKey);
    final email = await _secureStorage.read(key: _userEmailKey);
    final name = await _secureStorage.read(key: _userNameKey);

    if (userIdStr != null && email != null && name != null) {
      final userId = int.parse(userIdStr);
      try {
        // Try to fetch fresh data from API
        return await fetchUserProfile(userId);
      } catch (e) {
        // Fallback to stored data if API fails
        debugPrint('Error fetching user profile: $e');
        return User(
          id: userId,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _secureStorage.deleteAll();
    _currentUser = null;
  }

  // Get stored user ID
  Future<int?> getUserId() async {
    final userIdStr = await _secureStorage.read(key: _userIdKey);
    if (userIdStr != null) {
      return int.parse(userIdStr);
    }
    return null;
  }
}
