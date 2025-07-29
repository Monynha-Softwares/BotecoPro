import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pages/auth/login_page.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  final Future<void>? init;

  const AuthWrapper({Key? key, required this.child, this.init})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.status == AuthStatus.initial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If authenticated, show the main app content
              if (authProvider.isAuthenticated) {
                return child;
              }

              // If not authenticated, show login screen
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}
