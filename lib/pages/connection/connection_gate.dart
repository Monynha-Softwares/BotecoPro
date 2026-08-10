import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/odoo_session_provider.dart';
import '../legacy/main_navigation_screen.dart';
import '../odoo/main_screen.dart';
import 'connection_page.dart';

/// Selects the application shell from the explicit Odoo session state.
class ConnectionGate extends StatelessWidget {
  const ConnectionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OdooSessionProvider>(
      builder: (context, session, _) {
        switch (session.state) {
          case OdooSessionState.loading:
          case OdooSessionState.connecting:
            return const _ConnectionLoadingPage();
          case OdooSessionState.connected:
            return session.isDemoMode
                ? const MainNavigationScreen()
                : const OdooMainScreen();
          case OdooSessionState.needsConnection:
          case OdooSessionState.error:
            return const ConnectionPage();
        }
      },
    );
  }
}

class _ConnectionLoadingPage extends StatelessWidget {
  const _ConnectionLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
