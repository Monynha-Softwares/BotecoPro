import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:boteco_pro/providers/auth_provider.dart';
import 'package:boteco_pro/services/supabase_auth_service.dart';
import 'package:boteco_pro/models/auth_user.dart';

class MockAuthService extends Mock implements SupabaseAuthService {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(Exception('error'));
  });

  group('AuthProvider', () {
    late MockAuthService authService;
    late AuthProvider provider;
    late BuildContext ctx;

    setUp(() async {
      authService = MockAuthService();
      when(() => authService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(() => authService.currentUser).thenReturn(null);
      provider = AuthProvider(authService: authService);
    });

    Future<void> _setupContext(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          }),
        ),
      );
    }

    testWidgets('signInWithEmail returns true on success', (tester) async {
      final user = AuthUser(uid: '1', email: 'test@test.com');
      when(() => authService.signInWithEmail('test@test.com', 'pass'))
          .thenAnswer((_) async => user);

      await _setupContext(tester);

      final result =
          await provider.signInWithEmail(ctx, 'test@test.com', 'pass');

      expect(result, isTrue);
      verify(() => authService.signInWithEmail('test@test.com', 'pass'))
          .called(1);
    });

    testWidgets('signUpWithEmail returns true on success', (tester) async {
      final user = AuthUser(uid: '2', email: 'new@test.com');
      when(() => authService.signUpWithEmail('new@test.com', 'pass', 'Name'))
          .thenAnswer((_) async => user);

      await _setupContext(tester);

      final result =
          await provider.signUpWithEmail(ctx, 'new@test.com', 'pass', 'Name');

      expect(result, isTrue);
      verify(() => authService.signUpWithEmail('new@test.com', 'pass', 'Name'))
          .called(1);
    });

    testWidgets('signInWithEmail handles error', (tester) async {
      when(() => authService.signInWithEmail('bad@test.com', 'pass'))
          .thenThrow(Exception('user-not-found'));
      when(() => authService.getMessageFromErrorCode(any(), any()))
          .thenReturn('User not found');

      await _setupContext(tester);

      final result =
          await provider.signInWithEmail(ctx, 'bad@test.com', 'pass');

      expect(result, isFalse);
      expect(provider.error, 'User not found');
    });
  });
}
