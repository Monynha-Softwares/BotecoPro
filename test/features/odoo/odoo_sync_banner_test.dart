import 'package:boteco_pro/features/odoo/odoo_sync_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows explicit offline state and synchronization timestamp',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OdooSyncStatus(
          isOffline: true,
          synchronizedAt: DateTime.utc(2026, 8, 10, 12, 30),
        ),
      ),
    ));

    expect(find.text('Offline · Dados locais'), findsOneWidget);
    expect(find.textContaining('Última sincronização:'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('hides status before the first successful synchronization',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: OdooSyncStatus(isOffline: false, synchronizedAt: null),
      ),
    ));

    expect(find.text('Online'), findsNothing);
    expect(find.byType(ListTile), findsNothing);
  });
}
