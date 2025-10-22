import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boteco_pro/pages/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('LoginPage displays all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Verify logo icon
      expect(find.byIcon(Icons.sports_bar), findsOneWidget);
      
      // Verify title
      expect(find.text('Boteco PRO'), findsOneWidget);
      
      // Verify subtitle
      expect(find.text('Gestão completa para seu bar'), findsOneWidget);
      
      // Verify email field
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      
      // Verify password field
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
      
      // Verify login button
      expect(find.text('Entrar'), findsOneWidget);
      
      // Verify demo info
      expect(find.text('Demo MVP'), findsOneWidget);
    });

    testWidgets('Email field shows validation error when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Tap login button without entering email
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, insira seu email'), findsOneWidget);
    });

    testWidgets('Email field shows validation error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalidemail',
      );
      
      // Tap login button
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, insira um email válido'), findsOneWidget);
    });

    testWidgets('Password field shows validation error when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter valid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      // Tap login button without entering password
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('Password field shows validation error for short password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter valid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      // Enter short password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123',
      );

      // Tap login button
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Senha deve ter no mínimo 4 caracteres'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Senha');
      expect(passwordField, findsOneWidget);

      // Initial state - password should be obscured
      TextFormField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, true);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Password should now be visible
      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, false);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Password should be obscured again
      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, true);
    });

    testWidgets('Form fields can accept input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'password123',
      );

      // Verify input is displayed
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
