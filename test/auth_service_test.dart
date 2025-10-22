import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boteco_pro/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      // Clear all preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('isLoggedIn returns false when user is not logged in', () async {
      final result = await authService.isLoggedIn();
      expect(result, false);
    });

    test('login with valid credentials succeeds', () async {
      final result = await authService.login('test@example.com', 'password123');
      expect(result, true);
      
      final isLoggedIn = await authService.isLoggedIn();
      expect(isLoggedIn, true);
    });

    test('login with empty email fails', () async {
      final result = await authService.login('', 'password123');
      expect(result, false);
    });

    test('login with empty password fails', () async {
      final result = await authService.login('test@example.com', '');
      expect(result, false);
    });

    test('getUserName returns correct name after login', () async {
      await authService.login('john@example.com', 'password123');
      
      final userName = await authService.getUserName();
      expect(userName, 'john');
    });

    test('getUserEmail returns correct email after login', () async {
      await authService.login('test@example.com', 'password123');
      
      final userEmail = await authService.getUserEmail();
      expect(userEmail, 'test@example.com');
    });

    test('logout clears user session', () async {
      // First login
      await authService.login('test@example.com', 'password123');
      expect(await authService.isLoggedIn(), true);
      
      // Then logout
      await authService.logout();
      
      // Verify user is logged out
      expect(await authService.isLoggedIn(), false);
      expect(await authService.getUserName(), null);
      expect(await authService.getUserEmail(), null);
    });

    test('session persists between instances', () async {
      // Login with one instance
      final authService1 = AuthService();
      await authService1.login('test@example.com', 'password123');
      
      // Create new instance and verify session
      final authService2 = AuthService();
      expect(await authService2.isLoggedIn(), true);
      expect(await authService2.getUserEmail(), 'test@example.com');
    });

    test('getUserName extracts name from email correctly', () async {
      await authService.login('maria.silva@company.com', 'pass');
      final userName = await authService.getUserName();
      expect(userName, 'maria.silva');
    });
  });
}
