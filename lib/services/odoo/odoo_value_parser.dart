int? odooInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? odooNullableDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? odooString(Object? value) {
  if (value == null || value == false) return null;
  return value.toString();
}

DateTime? odooDateTimeUtc(Object? value) {
  final raw = odooString(value);
  if (raw == null) return null;
  var normalized = raw.replaceFirst(' ', 'T');
  if (!RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(normalized)) {
    normalized = '${normalized}Z';
  }
  return DateTime.tryParse(normalized)?.toUtc();
}

int? odooRelationId(Object? value) {
  if (value is List && value.isNotEmpty) return odooInt(value.first);
  return odooInt(value);
}

List<int> odooRelationIds(Object? value) {
  if (value is! List) return const <int>[];
  return value
      .map(odooRelationId)
      .whereType<int>()
      .where((id) => id > 0)
      .toList(growable: false);
}
