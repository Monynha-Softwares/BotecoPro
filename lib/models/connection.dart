class ConnectionConfig {
  const ConnectionConfig({
    required this.baseUrl,
    required this.username,
    this.database,
  });

  final String baseUrl;
  final String username;
  final String? database;

  /// Stable identity for data that must never cross Odoo database boundaries.
  ///
  /// Odoo.sh and self-hosted installations may expose multiple databases from
  /// the same HTTPS origin. Keeping the optional database in this opaque key
  /// prevents snapshots and local drafts from being restored into another
  /// tenant whose numeric record IDs happen to overlap.
  String get instanceKey {
    final databaseName = database;
    if (databaseName == null) return baseUrl;
    return '$baseUrl?database=${Uri.encodeComponent(databaseName)}';
  }

  factory ConnectionConfig.fromInput({
    required String baseUrl,
    required String username,
    String? database,
  }) {
    final normalized = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('Use uma URL HTTPS válida do Odoo.');
    }
    if (username.trim().isEmpty) {
      throw const FormatException('Informe o utilizador do Odoo.');
    }

    return ConnectionConfig(
      baseUrl: normalized,
      username: username.trim(),
      database: database?.trim().isEmpty == true ? null : database?.trim(),
    );
  }

  Uri get versionUri => Uri.parse('$baseUrl/web/version');

  Uri json2Uri(String model, String method) {
    final encodedModel = Uri.encodeComponent(model);
    final encodedMethod = Uri.encodeComponent(method);
    return Uri.parse('$baseUrl/json/2/$encodedModel/$encodedMethod');
  }
}
