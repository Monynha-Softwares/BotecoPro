import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'odoo_snapshot.dart';

class OdooSnapshotStore {
  const OdooSnapshotStore();

  static const _snapshotKey = 'odoo.operational.snapshot.v1';

  Future<void> save(OdooSnapshotEnvelope snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  Future<OdooSnapshotEnvelope?> read(OdooSnapshotContext context) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_snapshotKey);
    if (raw == null) return null;
    try {
      final snapshot = OdooSnapshotEnvelope.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      if (!snapshot.matches(context)) {
        await preferences.remove(_snapshotKey);
        return null;
      }
      return snapshot;
    } on Object {
      await preferences.remove(_snapshotKey);
      return null;
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_snapshotKey);
  }
}
