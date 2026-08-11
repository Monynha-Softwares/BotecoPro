import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/sync_snapshot.dart';

class SnapshotStorageService {
  const SnapshotStorageService({this.namespace = ''});

  static const _snapshotKey = 'odoo.operational.snapshot.v1';
  static Future<void> _operationTail = Future<void>.value();
  final String namespace;

  String get _key =>
      namespace.isEmpty ? _snapshotKey : '$namespace.$_snapshotKey';

  Future<void> save(SyncSnapshot snapshot) => _serialized(() async {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(
          _key,
          jsonEncode(snapshot.toJson()),
        );
      });

  Future<SyncSnapshot?> read(OperationalContext context) =>
      _serialized(() async {
        final preferences = await SharedPreferences.getInstance();
        final raw = preferences.getString(_key);
        if (raw == null) return null;
        try {
          final snapshot = SyncSnapshot.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          );
          if (snapshot.matches(context)) return snapshot;
          await preferences.remove(_key);
          return null;
        } on Object {
          await preferences.remove(_key);
          return null;
        }
      });

  Future<void> clear() => _serialized(() async {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_key);
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
