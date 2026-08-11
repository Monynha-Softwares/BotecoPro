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
            return const _ConnectionLoadingPage();
          case OdooSessionState.connecting:
            // Keep the active shell during an offline retry and keep the form
            // mounted during a first connection attempt. This preserves the
            // local cart and non-secret form fields across transient failures.
            return session.operationalContext != null
                ? const OdooMainScreen()
                : const ConnectionPage();
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
