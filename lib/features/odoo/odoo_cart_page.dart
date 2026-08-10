import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/odoo/odoo_cart.dart';
import '../../core/odoo/odoo_provider.dart';

class OdooCartPage extends StatelessWidget {
  const OdooCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final items = provider.cartItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comanda local'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: provider.clearCart,
              child: const Text('Limpar'),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Adicione produtos Odoo para montar uma prévia local. Nada será enviado ao Odoo nesta etapa.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                if (provider.restaurantTables.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: DropdownButtonFormField<int>(
                      value: provider.selectedTable?.id ?? 0,
                      decoration: const InputDecoration(
                        labelText: 'Mesa (opcional)',
                        prefixIcon: Icon(Icons.table_restaurant_outlined),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: 0, child: Text('Sem mesa')),
                        for (final table in provider.restaurantTables)
                          DropdownMenuItem(
                              value: table.id, child: Text(table.label)),
                      ],
                      onChanged: (tableId) => provider.selectTable(
                        tableId == null || tableId == 0
                            ? null
                            : provider.restaurantTables.firstWhere(
                                (table) => table.id == tableId,
                              ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _CartItemCard(item: items[index]),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Prévia local · ${provider.selectedPosConfig?.name ?? 'POS'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text(
                              currency.format(provider.cartSubtotal),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sem pedido, pagamento, stock ou lançamento fiscal no Odoo.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final OdooCartItem item;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OdooProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(item.productName,
                        style: Theme.of(context).textTheme.titleMedium)),
                IconButton(
                  tooltip: 'Remover',
                  onPressed: () => provider.removeCartItem(item.productId),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Text('${currency.format(item.unitPrice)} por unidade'),
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Nota: ${item.note}'),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Diminuir',
                  onPressed: () => provider.updateCartItemQuantity(
                      item.productId, item.quantity - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${item.quantity}',
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  tooltip: 'Aumentar',
                  onPressed: () => provider.updateCartItemQuantity(
                      item.productId, item.quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                Text(currency.format(item.subtotal),
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _editNote(context, item),
                icon: const Icon(Icons.note_alt_outlined),
                label:
                    Text(item.note.isEmpty ? 'Adicionar nota' : 'Editar nota'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNote(BuildContext context, OdooCartItem item) async {
    final controller = TextEditingController(text: item.note);
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nota do item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 250,
          decoration: const InputDecoration(hintText: 'Ex.: sem gelo'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar')),
        ],
      ),
    );
    controller.dispose();
    if (note != null && context.mounted) {
      context.read<OdooProvider>().updateCartItemNote(item.productId, note);
    }
  }
}
