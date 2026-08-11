import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/catalog.dart';
import '../../models/currency.dart';
import '../../models/pos_config.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/odoo_session_provider.dart';
import '../../widgets/catalog_money_formatter.dart';
import '../../widgets/odoo_sync_banner.dart';
import 'cart_page.dart';

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
    final catalog = context.watch<CatalogProvider>();
    final cartCount =
        context.select<CartProvider, int>((cart) => cart.itemCount);
    final posConfig = context.select<OdooSessionProvider, PosConfig?>(
        (value) => value.selectedPosConfig);
    final currency = context.select<OdooSessionProvider, CurrencyInfo?>(
      (session) => session.posOperationalProfile?.currency,
    );
    final selectedCategoryId =
        catalog.categories.any((category) => category.id == _categoryId)
            ? _categoryId
            : null;
    final products = catalog.products
        .where((product) => _matches(product, selectedCategoryId))
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos POS'),
        actions: [
          _CartButton(count: cartCount),
          IconButton(
            key: const Key('catalog.refresh'),
            tooltip: 'Atualizar',
            onPressed: catalog.isLoading ? null : catalog.refresh,
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
              key: const Key('catalog.search'),
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'Procurar no catálogo Odoo',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          _CategoryFilter(
            categories: catalog.categories,
            selectedCategoryId: selectedCategoryId,
            onSelected: (id) => setState(() => _categoryId = id),
          ),
          Expanded(
            child: _CatalogList(
              catalog: catalog,
              catalogProductCount: posConfig?.catalogProductCount,
              products: products,
              hasFilter: _query.isNotEmpty || _categoryId != null,
              currency: currency,
            ),
          ),
        ],
      ),
    );
  }

  bool _matches(CatalogProduct product, int? selectedCategoryId) {
    final normalizedQuery = _query.toLowerCase();
    final matchesQuery = normalizedQuery.isEmpty ||
        product.name.toLowerCase().contains(normalizedQuery) ||
        (product.defaultCode?.toLowerCase().contains(normalizedQuery) ??
            false) ||
        (product.barcode?.contains(_query) ?? false);
    final matchesCategory = selectedCategoryId == null ||
        product.categoryIds.contains(selectedCategoryId);
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
            key: const Key('cart.open'),
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

  final List<CatalogCategory> categories;
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
                key: const Key('catalog.category.all'),
                label: const Text('Todos'),
                selected: selectedCategoryId == null,
                onSelected: (_) => onSelected(null),
              ),
            ),
            for (final category in categories)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  key: Key('catalog.category.${category.id}'),
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
    required this.catalog,
    required this.catalogProductCount,
    required this.products,
    required this.hasFilter,
    required this.currency,
  });

  final CatalogProvider catalog;
  final int? catalogProductCount;
  final List<CatalogProduct> products;
  final bool hasFilter;
  final CurrencyInfo? currency;

  @override
  Widget build(BuildContext context) {
    if (catalog.products.isEmpty && catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.products.isEmpty && catalog.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${catalog.error!.message}\nNenhum snapshot compatível está disponível.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (products.isEmpty) {
      final message = catalog.products.isEmpty && catalogProductCount == 0
          ? 'A configuração POS selecionada não autoriza produtos. Verifique as categorias disponíveis no Odoo.'
          : hasFilter
              ? 'Nenhum produto Odoo corresponde ao filtro.'
              : 'Nenhum produto disponível no POS.';
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            key: Key('catalog.product.${product.id}'),
            onTap: () => _showProductDetails(context, product, currency),
            title: Text(product.name),
            subtitle: Text([
              if (product.defaultCode?.isNotEmpty == true) product.defaultCode!,
              if (product.barcode?.isNotEmpty == true) product.barcode!,
            ].join(' · ')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formatCatalogAmount(
                  product.catalogPrice,
                  currency: currency,
                  amountCurrencyId: product.currencyId,
                )),
                IconButton(
                  key: Key('catalog.product.add.${product.id}'),
                  tooltip: 'Adicionar à comanda local',
                  onPressed: () => context.read<CartProvider>().add(product),
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductDetails(
    BuildContext context,
    CatalogProduct product,
    CurrencyInfo? currency,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        key: Key('catalog.product.detail.${product.id}'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: Theme.of(sheetContext).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Valor de catálogo Odoo: ${formatCatalogAmount(
                product.catalogPrice,
                currency: currency,
                amountCurrencyId: product.currencyId,
              )}',
            ),
            if (product.defaultCode?.isNotEmpty == true)
              Text('Referência: ${product.defaultCode}'),
            if (product.barcode?.isNotEmpty == true)
              Text('Código de barras: ${product.barcode}'),
            const SizedBox(height: 8),
            const Text(
                'O preço apresentado é informativo; regras transacionais de pricelist e fiscalidade serão tratadas antes de qualquer write.'),
            if (currency == null || product.currencyId != currency.id)
              const Text(
                'A moeda deste valor ainda não foi validada contra o perfil da POS.',
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: Key('catalog.product.detail.add.${product.id}'),
              onPressed: () {
                context.read<CartProvider>().add(product);
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
