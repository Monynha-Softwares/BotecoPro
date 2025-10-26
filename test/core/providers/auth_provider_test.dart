import 'dart:async';

import 'package:boteco_pro/core/models/auth_user.dart';
import 'package:boteco_pro/core/providers/auth_provider.dart';
import 'package:boteco_pro/core/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthService implements AuthService {
  FakeAuthService() : _controller = StreamController<AuthUser?>.broadcast();

  final StreamController<AuthUser?> _controller;
  AuthUser? _currentUser;

  void seedUser(AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<AuthUser?> getCurrentUser() async => _currentUser;

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final AuthUser user = AuthUser(id: 'uid-$email', email: email, name: null, photoUrl: null);
    seedUser(user);
    return user;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final AuthUser user = AuthUser(id: 'google-uid', email: 'google@example.com', name: 'Google User', photoUrl: null);
    seedUser(user);
    return user;
  }

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password, {String? name}) async {
    final AuthUser user = AuthUser(
      id: 'uid-$email',
      email: email,
      name: name,
      photoUrl: null,
    );
    seedUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    seedUser(null);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  late FakeAuthService fakeAuthService;
  late AuthProvider provider;

  setUp(() {
    fakeAuthService = FakeAuthService();
    provider = AuthProvider(authService: fakeAuthService);
  });

  tearDown(() async {
    await fakeAuthService.dispose();
  });

  test('initialize loads current user and listens for changes', () async {
    final AuthUser seededUser = AuthUser(
      id: 'seeded',
      email: 'seeded@example.com',
      name: 'Seeded',
      photoUrl: null,
    );
    fakeAuthService.seedUser(seededUser);

    await provider.initialize();

    expect(provider.initialized, isTrue);
    expect(provider.user, equals(seededUser));
    expect(provider.isSignedIn, isTrue);

    final AuthUser updatedUser = seededUser.copyWith(name: 'Updated');
    fakeAuthService.seedUser(updatedUser);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(provider.user, equals(updatedUser));
  });

  test('signInWithEmail updates state and notifies listeners', () async {
    bool notified = false;
    provider.addListener(() {
      notified = true;
    });

    final AuthUser? user = await provider.signInWithEmail('user@example.com', 'secret');

    expect(user, isNotNull);
    expect(provider.user, equals(user));
    expect(provider.isSignedIn, isTrue);
    expect(notified, isTrue);
  });

  test('signOut clears user and notifies listeners', () async {
    await provider.signInWithEmail('user@example.com', 'secret');

    bool notified = false;
    provider.addListener(() {
      notified = true;
    });

    await provider.signOut();

    expect(provider.user, isNull);
    expect(provider.isSignedIn, isFalse);
    expect(notified, isTrue);
  });
}
