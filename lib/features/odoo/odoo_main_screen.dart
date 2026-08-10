import 'package:flutter/material.dart';

import 'odoo_home_page.dart';
import 'odoo_pos_page.dart';
import 'odoo_products_page.dart';

class OdooMainScreen extends StatefulWidget {
  const OdooMainScreen({super.key});

  @override
  State<OdooMainScreen> createState() => _OdooMainScreenState();
}

class _OdooMainScreenState extends State<OdooMainScreen> {
  int _index = 0;

  static const _pages = <Widget>[
    OdooHomePage(),
    OdooProductsPage(),
    OdooPosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Resumo'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Produtos'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'POS'),
        ],
      ),
    );
  }
}
