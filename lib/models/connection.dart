class ConnectionConfig {
  const ConnectionConfig({
    required this.baseUrl,
    required this.username,
    this.database,
  });

  final String baseUrl;
  final String username;
  final String? database;

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
