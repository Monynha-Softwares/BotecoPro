import 'package:flutter/material.dart';
import '../theme.dart';

enum NavigationTab {
  home,
  tables,
  products,
  reports,  // This is the 'Pedidos' tab
  settings  // This is the 'Config' tab
}

class BottomNavigation extends StatelessWidget {
  final NavigationTab currentTab;
  final Function(NavigationTab) onTabSelected;

  const BottomNavigation({
    Key? key,
    required this.currentTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTab.index,
      onTap: (index) => onTabSelected(NavigationTab.values[index]),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Theme.of(context).colorScheme.primary,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_bar_outlined),
          activeIcon: Icon(Icons.table_bar),
          label: 'Mesas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Produtos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined),
          activeIcon: Icon(Icons.receipt),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Config',
        ),
      ],
    );
  }
}