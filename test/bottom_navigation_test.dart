import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boteco_pro/widgets/bottom_navigation.dart';

void main() {
  testWidgets('BottomNavigation has five items', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavigation(
            currentTab: NavigationTab.home,
            onTabSelected: (_) {},
          ),
        ),
      ),
    );

    final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNav.items.length, 5);
  });
}
