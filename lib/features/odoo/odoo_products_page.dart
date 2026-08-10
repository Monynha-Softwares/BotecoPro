import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/odoo/odoo_connection.dart';
import '../../core/odoo/odoo_provider.dart';
import 'odoo_cart_page.dart';
import 'odoo_sync_banner.dart';

class OdooProductsPage extends StatefulWidget {
  const OdooProductsPage({super.key});

  @override
  State<OdooProductsPage> createState() => _OdooProductsPageState();
}

class _OdooProductsPageState extends State<OdooProductsPage> {
  String _query = '';
  int? _categoryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();
    final products = provider.products.where(_matches).toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos POS'),
        actions: [
          _CartButton(count: provider.cartItemCount),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: provider.isLoadingProducts
                ? null
                : provider.isOffline
                    ? provider.reconnect
                    : provider.loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          const OdooSyncBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'Procurar no catálogo Odoo',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          _CategoryFilter(
            categories: provider.categories,
            selectedCategoryId: _categoryId,
            onSelected: (id) => setState(() => _categoryId = id),
          ),
          Expanded(
            child: _CatalogList(
              provider: provider,
              products: products,
              hasFilter: _query.isNotEmpty || _categoryId != null,
            ),
          ),
        ],
      ),
    );
  }

  bool _matches(OdooProduct product) {
    final normalizedQuery = _query.toLowerCase();
    final matchesQuery = normalizedQuery.isEmpty ||
        product.name.toLowerCase().contains(normalizedQuery) ||
        (product.defaultCode?.toLowerCase().contains(normalizedQuery) ??
            false) ||
        (product.barcode?.contains(_query) ?? false);
    final matchesCategory =
        _categoryId == null || product.categoryIds.contains(_categoryId);
    return matchesQuery && matchesCategory;
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Comanda local',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OdooCartPage()),
            ),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: CircleAvatar(
                radius: 9,
                child: Text('$count', style: const TextStyle(fontSize: 11)),
              ),
            ),
        ],
      );
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<OdooCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: const Text('Todos'),
                selected: selectedCategoryId == null,
                onSelected: (_) => onSelected(null),
              ),
            ),
            for (final category in categories)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: selectedCategoryId == category.id,
                  onSelected: (_) => onSelected(category.id),
                ),
              ),
          ],
        ),
      );
}

class _CatalogList extends StatelessWidget {
  const _CatalogList({
    required this.provider,
    required this.products,
    required this.hasFilter,
  });

  final OdooProvider provider;
  final List<OdooProduct> products;
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    if (provider.products.isEmpty && provider.isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.products.isEmpty && provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${provider.error!.message}\nNenhum snapshot compatível está disponível.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (products.isEmpty) {
      final message = provider.products.isEmpty &&
              provider.selectedPosConfig?.catalogProductCount == 0
          ? 'A configuração POS selecionada não autoriza produtos. Verifique as categorias disponíveis no Odoo.'
          : hasFilter
              ? 'Nenhum produto Odoo corresponde ao filtro.'
              : 'Nenhum produto disponível no POS.';
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center)));
    }
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length + (provider.hasMoreProducts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton(
              onPressed: provider.isLoadingProducts
                  ? null
                  : () => provider.loadProducts(append: true),
              child: Text(
                  provider.isLoadingProducts ? 'A carregar…' : 'Carregar mais'),
            ),
          );
        }
        final product = products[index];
        return Card(
          child: ListTile(
            onTap: () => _showProductDetails(context, product),
            title: Text(product.name),
            subtitle: Text([
              if (product.defaultCode?.isNotEmpty == true) product.defaultCode!,
              if (product.barcode?.isNotEmpty == true) product.barcode!,
            ].join(' · ')),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currency.format(product.price)),
                IconButton(
                  tooltip: 'Adicionar à comanda local',
                  onPressed: () => provider.addToCart(product),
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, OdooProduct product) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: Theme.of(sheetContext).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Preço de catálogo Odoo: ${currency.format(product.price)}'),
            if (product.defaultCode?.isNotEmpty == true)
              Text('Referência: ${product.defaultCode}'),
            if (product.barcode?.isNotEmpty == true)
              Text('Código de barras: ${product.barcode}'),
            const SizedBox(height: 8),
            const Text(
                'O preço apresentado é informativo; regras transacionais de pricelist e fiscalidade serão tratadas antes de qualquer write.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.read<OdooProvider>().addToCart(product);
                Navigator.pop(sheetContext);
              },
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text('Adicionar à comanda local'),
            ),
          ],
        ),
      ),
    );
  }
}
