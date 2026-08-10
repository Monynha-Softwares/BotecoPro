import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'odoo_cart.dart';

class OdooCartStore {
  const OdooCartStore();

  static const _cartKey = 'odoo.operational.local_cart.v1';

  Future<void> save(OdooLocalCart cart) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cartKey, jsonEncode(cart.toJson()));
  }

  Future<OdooLocalCart?> read({
    required String instanceKey,
    required int userId,
    required int companyId,
    required int posConfigId,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_cartKey);
    if (raw == null) return null;
    try {
      final cart = OdooLocalCart.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      final matches = cart.matchesContext(
        instanceKey: instanceKey,
        userId: userId,
        companyId: companyId,
        posConfigId: posConfigId,
      );
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
