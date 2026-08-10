int? odooInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double odooDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String? odooString(Object? value) {
  if (value == null || value == false) return null;
  return value.toString();
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
