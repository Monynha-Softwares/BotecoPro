import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/draft_cart.dart';
import '../../models/sync_snapshot.dart';

class CartStorageService {
  const CartStorageService();

  static const _cartKey = 'odoo.operational.local_cart.v1';
  static Future<void> _operationTail = Future<void>.value();

  Future<void> save(DraftCart cart) => _serialized(() async {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(_cartKey, jsonEncode(cart.toJson()));
      });

  Future<DraftCart?> read(OperationalContext context) => _serialized(() async {
        final preferences = await SharedPreferences.getInstance();
        final raw = preferences.getString(_cartKey);
        if (raw == null) return null;
        try {
          final cart = DraftCart.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          );
          if (cart.matchesContext(context)) return cart;
          await preferences.remove(_cartKey);
          return null;
        } on Object {
          await preferences.remove(_cartKey);
          return null;
        }
      });

  Future<void> clear() => _serialized(() async {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_cartKey);
      });

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    final ready = _operationTail.then<void>(
      (_) {},
      onError: (_, __) {},
    );
    _operationTail = ready.then<void>((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
