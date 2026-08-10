import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/draft_cart.dart';
import '../../models/sync_snapshot.dart';

class CartStorageService {
  const CartStorageService();

  static const _cartKey = 'odoo.operational.local_cart.v1';

  Future<void> save(DraftCart cart) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cartKey, jsonEncode(cart.toJson()));
  }

  Future<DraftCart?> read(OperationalContext context) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_cartKey);
    if (raw == null) return null;
    try {
      final cart = DraftCart.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      final matches = cart.matchesContext(context);
      if (!matches) {
        await preferences.remove(_cartKey);
        return null;
      }
      return cart;
    } on Object {
      await preferences.remove(_cartKey);
      return null;
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_cartKey);
  }
}
