enum OdooErrorKind {
  invalidConfiguration,
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unexpected,
}

class OdooException implements Exception {
  const OdooException({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  final OdooErrorKind kind;
  final String message;
  final int? statusCode;

  factory OdooException.fromHttp({
    required int statusCode,
    required dynamic body,
    Iterable<String> sensitiveValues = const [],
  }) {
    final rawMessage =
        body is Map<String, dynamic> ? body['message']?.toString() : null;
    final message = _safeMessage(rawMessage, sensitiveValues) ??
        _messageForStatus(statusCode);
    final kind = switch (statusCode) {
      401 => OdooErrorKind.unauthorized,
      403 => OdooErrorKind.forbidden,
      404 => OdooErrorKind.notFound,
      >= 400 && < 500 => OdooErrorKind.validation,
      >= 500 => OdooErrorKind.server,
      _ => OdooErrorKind.unexpected,
    };
    return OdooException(kind: kind, message: message, statusCode: statusCode);
  }

  static String? _safeMessage(String? value, Iterable<String> sensitiveValues) {
    if (value == null || value.trim().isEmpty) return null;
    var normalized = value.replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
    for (final sensitiveValue in sensitiveValues) {
      if (sensitiveValue.isNotEmpty) {
        normalized = normalized.replaceAll(sensitiveValue, '[redacted]');
      }
    }
    if (normalized.length > 240) return normalized.substring(0, 240);
    return normalized;
  }

  static String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      401 => 'API key inválida ou expirada.',
      403 => 'O utilizador não tem permissão para esta operação.',
      404 => 'Modelo ou método Odoo não encontrado.',
      >= 500 => 'O Odoo devolveu um erro temporário.',
      _ => 'O Odoo rejeitou o pedido.',
    };
  }

  @override
  String toString() => message;
}
