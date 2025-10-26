import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:boteco_pro/core/models/auth_user.dart';
import 'package:boteco_pro/core/providers/auth_provider.dart';
import 'package:boteco_pro/core/services/auth_service.dart';

class FakeAuthService implements BaseAuthService {
  FakeAuthService({AuthUser? initialUser})
      : _controller = StreamController<AuthUser?>.broadcast(),
        _currentUser = initialUser;

  final StreamController<AuthUser?> _controller;
  AuthUser? _currentUser;
  AuthUser? signInResponse;
  AuthUser? registerResponse;
  AuthUser? googleResponse;
  AuthServiceException? signInException;
  AuthServiceException? registerException;
  AuthServiceException? googleException;
  AuthServiceException? signOutException;
  AuthServiceException? resetException;
  bool signOutCalled = false;
  String? lastEmail;
  String? lastPassword;
  String? lastRegisterName;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  void emit(AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<AuthUser?> getCurrentUser() async => _currentUser;

  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    if (registerException != null) {
      throw registerException!;
    }
    lastEmail = email;
    lastPassword = password;
    lastRegisterName = name;
    _currentUser = registerResponse;
    emit(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (signInException != null) {
      throw signInException!;
    }
    lastEmail = email;
    lastPassword = password;
    _currentUser = signInResponse;
    emit(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    if (googleException != null) {
      throw googleException!;
    }
    _currentUser = googleResponse;
    emit(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (resetException != null) {
      throw resetException!;
    }
  }

  @override
  Future<void> signOut() async {
    if (signOutException != null) {
      throw signOutException!;
    }
    signOutCalled = true;
    _currentUser = null;
    emit(null);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider (Firebase mode)', () {
    late FakeAuthService fakeService;
    late AuthProvider provider;

    setUp(() {
      fakeService = FakeAuthService();
      provider = AuthProvider(
        authService: fakeService,
        useFirebase: true,
      );
    });

    test('initialize loads current user and listens for changes', () async {
      final initialUser = AuthUser(id: '1', email: 'user@test.com');
      fakeService.emit(initialUser);

      await provider.initialize();

      expect(provider.initialized, isTrue);
      expect(provider.user, equals(initialUser));

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      final updatedUser = initialUser.copyWith(name: 'Tester');
      fakeService.emit(updatedUser);
      await Future<void>.delayed(Duration.zero);

      expect(provider.user, equals(updatedUser));
      expect(notified, isTrue);
    });

    test('signInWithEmail delegates to auth service', () async {
      final authUser = AuthUser(id: 'abc', email: 'demo@test.com');
      fakeService.signInResponse = authUser;

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      final result = await provider.signInWithEmail('demo@test.com', 'secret');

      expect(result, equals(authUser));
      expect(provider.user, equals(authUser));
      expect(fakeService.lastEmail, 'demo@test.com');
      expect(fakeService.lastPassword, 'secret');
      expect(notified, isTrue);
    });

    test('signOut clears user and propagates to auth service', () async {
      final authUser = AuthUser(id: 'abc', email: 'demo@test.com');
      fakeService.signInResponse = authUser;
      await provider.signInWithEmail('demo@test.com', 'secret');

      await provider.signOut();

      expect(fakeService.signOutCalled, isTrue);
      expect(provider.user, isNull);
    });

    test('errors from auth service are wrapped in AuthProviderException', () {
      fakeService.signInException =
          AuthServiceException('Erro de autenticação');

      expect(
        () => provider.signInWithEmail('demo@test.com', 'secret'),
        throwsA(isA<AuthProviderException>()),
      );
    });
  });

  group('AuthProvider (local fallback)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('signInWithEmail persists local user', () async {
      final provider = AuthProvider(useFirebase: false);

      final user = await provider.signInWithEmail('local@test.com', '123456');

      expect(user, isNotNull);
      expect(provider.user?.email, 'local@test.com');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_user'), isNotEmpty);
    });
  });
}
