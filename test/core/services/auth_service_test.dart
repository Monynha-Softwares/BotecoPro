import 'package:boteco_pro/core/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    authService = AuthService();
  });

  test('signUpWithEmail cadastra usuário com email normalizado e nome opcional',
      () async {
    final user = await authService.signUpWithEmail(
      email: 'User@example.com ',
      password: 'SenhaSegura123',
      name: '  Usuário  ',
    );

    expect(user.email, 'User@example.com');
    expect(user.name, 'Usuário');

    final persisted = await authService.getUserById(user.id);
    expect(persisted?.email, 'User@example.com');
    expect(persisted?.name, 'Usuário');
  });

  test('signInWithEmail aceita email case-insensitive e valida senha',
      () async {
    final registered = await authService.signUpWithEmail(
      email: 'user@example.com',
      password: 'SenhaSegura123',
    );

    final logged = await authService.signInWithEmail(
      email: 'USER@example.com',
      password: 'SenhaSegura123',
    );

    expect(logged.id, registered.id);
    expect(logged.email, registered.email);
  });

  test('signInWithEmail dispara AuthException com senha incorreta', () async {
    await authService.signUpWithEmail(
      email: 'user@example.com',
      password: 'SenhaSegura123',
    );

    await expectLater(
      authService.signInWithEmail(
        email: 'user@example.com',
        password: 'senha-errada',
      ),
      throwsA(isA<AuthException>()
          .having((e) => e.code, 'code', 'invalid-credentials')),
    );
  });

  test('signUpWithEmail impede cadastro duplicado independente de caixa',
      () async {
    await authService.signUpWithEmail(
      email: 'user@example.com',
      password: 'SenhaSegura123',
    );

    await expectLater(
      authService.signUpWithEmail(
        email: 'USER@example.com',
        password: 'OutraSenha456',
      ),
      throwsA(isA<AuthException>()
          .having((e) => e.code, 'code', 'email-already-in-use')),
    );
  });

  test('requestPasswordReset valida existência do email cadastrado', () async {
    await authService.signUpWithEmail(
      email: 'user@example.com',
      password: 'SenhaSegura123',
    );

    await authService.requestPasswordReset(email: 'USER@example.com');

    await expectLater(
      authService.requestPasswordReset(email: 'desconhecido@example.com'),
      throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'user-not-found')),
    );
  });
}
