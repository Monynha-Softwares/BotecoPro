import 'dart:async';

import 'package:boteco_pro/models/catalog.dart';
import 'package:boteco_pro/models/draft_cart.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/providers/cart_provider.dart';
import 'package:boteco_pro/providers/catalog_provider.dart';
import 'package:boteco_pro/providers/odoo_session_provider.dart';
import 'package:boteco_pro/services/storage/cart_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _context = OperationalContext(
  instanceKey: 'https://odoo.example.com?database=tenant',
  userId: 2,
  companyId: 1,
  posConfigId: 3,
);

class _SessionHarness extends OdooSessionProvider {
  @override
  bool get isDemoMode => false;

  @override
  OperationalContext get operationalContext => _context;
}

class _DelayedCartStorage extends CartStorageService {
  _DelayedCartStorage(this.stored);

  final DraftCart stored;
  final readStarted = Completer<void>();
  final releaseRead = Completer<void>();
  DraftCart? saved;

  @override
  Future<DraftCart?> read(OperationalContext context) async {
    readStarted.complete();
    await releaseRead.future;
    return stored;
  }

  @override
  Future<void> save(DraftCart cart) async => saved = cart;

  @override
  Future<void> clear() async => saved = null;
}

Future<void> _settle() async {
  for (var index = 0; index < 6; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('a delayed restore never overwrites a cart edited by the user',
      () async {
    final storage = _DelayedCartStorage(
      DraftCart(context: _context).add(
        const CatalogProduct(
          id: 10,
          name: 'Produto armazenado',
          catalogPrice: 5,
        ),
      ),
    );
    final session = _SessionHarness();
    final catalog = CatalogProvider();
    final cart = CartProvider(storage: storage);

    cart.bind(session, catalog);
    await storage.readStarted.future;
    cart.add(
      const CatalogProduct(
        id: 20,
        name: 'Produto escolhido agora',
        catalogPrice: 7,
      ),
    );
    storage.releaseRead.complete();
    await _settle();

    expect(cart.items.map((item) => item.productId), [20]);
    expect(storage.saved?.items.map((item) => item.productId), [20]);

    session.dispose();
    catalog.dispose();
    cart.dispose();
  });
}
