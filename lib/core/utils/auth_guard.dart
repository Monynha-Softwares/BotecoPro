// lib/core/utils/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../presentation/pages/login_page.dart';

/// AuthGuard - Proteção de rotas que requerem autenticação
///
/// Verifica se o usuário está autenticado antes de permitir
/// navegação para telas protegidas. Redireciona para login se necessário.
///
/// EXEMPLO DE USO:
/// ```dart
/// Navigator.push(
///   context,
///   AuthGuard.route(
///     builder: (_) => HomePage(),
///   ),
/// );
/// ```

class AuthGuard {
  /// Cria uma rota protegida que verifica autenticação
  static MaterialPageRoute<T> route<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (context) {
        final authProvider = context.watch<AuthProvider>();
        
        // Se não estiver autenticado, redireciona para login
        if (!authProvider.isSignedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          });
          // Retorna widget vazio temporariamente
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Usuário autenticado, renderiza o widget
        return builder(context);
      },
    );
  }

  /// Verifica se usuário está autenticado e executa callback apropriado
  static void check(
    BuildContext context, {
    required VoidCallback onAuthenticated,
    VoidCallback? onUnauthenticated,
  }) {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isSignedIn) {
      onAuthenticated();
    } else {
      if (onUnauthenticated != null) {
        onUnauthenticated();
      } else {
        // Comportamento padrão: navegar para login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  /// Wrapper de widget que só renderiza se autenticado
  static Widget builder({
    required BuildContext context,
    required Widget child,
    Widget? fallback,
  }) {
    final authProvider = context.watch<AuthProvider>();
    
    if (!authProvider.isSignedIn) {
      return fallback ?? 
        const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
    
    return child;
  }
}

/// Mixin para adicionar proteção de autenticação em StatefulWidgets
///
/// EXEMPLO DE USO:
/// ```dart
/// class MyProtectedPage extends StatefulWidget {
///   const MyProtectedPage({Key? key}) : super(key: key);
///
///   @override
///   State<MyProtectedPage> createState() => _MyProtectedPageState();
/// }
///
/// class _MyProtectedPageState extends State<MyProtectedPage>
///     with RequiresAuth {
///   @override
///   void initState() {
///     super.initState();
///     checkAuthOnInit(context); // Verifica auth na inicialização
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(/*...*/);
///   }
/// }
/// ```
mixin RequiresAuth<T extends StatefulWidget> on State<T> {
  /// Verifica autenticação e redireciona se necessário
  void checkAuthOnInit(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isSignedIn) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    });
  }

  /// Verifica autenticação antes de executar ação
  Future<void> requireAuth(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isSignedIn) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }
    
    await action();
  }
}
