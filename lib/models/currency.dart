enum CurrencySymbolPosition { before, after }

class CurrencyInfo {
  const CurrencyInfo({
    required this.id,
    required this.name,
    required this.symbol,
    required this.position,
    required this.decimalPlaces,
    required this.rounding,
  });

  final int id;
  final String name;
  final String symbol;
  final CurrencySymbolPosition position;
  final int decimalPlaces;
  final double rounding;
}
