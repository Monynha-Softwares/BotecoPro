import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/odoo/odoo_provider.dart';

class OdooProductsPage extends StatelessWidget {
  const OdooProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final products = provider.products;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos POS'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: provider.isLoadingProducts ? null : provider.loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: products.isEmpty && provider.isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('Nenhum produto disponível no POS.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length + 1,
                  itemBuilder: (context, index) {
                    if (index == products.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: OutlinedButton(
                          onPressed: provider.isLoadingProducts
                              ? null
                              : () => provider.loadProducts(append: true),
                          child: Text(provider.isLoadingProducts ? 'A carregar…' : 'Carregar mais'),
                        ),
                      );
                    }
                    final product = products[index];
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text([
                          if (product.defaultCode?.isNotEmpty == true) product.defaultCode!,
                          if (product.barcode?.isNotEmpty == true) product.barcode!,
                        ].join(' · ')),
                        trailing: Text(currency.format(product.price)),
                      ),
                    );
                  },
                ),
    );
  }
}
