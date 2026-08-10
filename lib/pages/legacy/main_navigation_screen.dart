import 'package:flutter/material.dart';

import '../../widgets/bottom_navigation.dart';
import '../home_page.dart';
import '../production_page.dart';
import '../products_page.dart';
import '../recipes_page.dart';
import '../tables_page.dart';

/// Navigation shell for the explicitly selected debug/demo experience.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  NavigationTab _currentTab = NavigationTab.home;

  final Map<NavigationTab, Widget> _screens = {
    NavigationTab.home: const HomePage(),
    NavigationTab.tables: const TablesPage(),
    NavigationTab.products: const ProductsPage(),
    NavigationTab.recipes: const RecipesPage(),
    NavigationTab.production: const ProductionPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentTab],
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
