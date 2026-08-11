import 'package:intl/intl.dart';

import '../models/currency.dart';

String formatCatalogAmount(
  double amount, {
  required CurrencyInfo? currency,
  required int? amountCurrencyId,
  String locale = 'pt-BR',
}) {
  final number = NumberFormat.currency(
    locale: locale,
    symbol: '',
    decimalDigits: currency?.decimalPlaces ?? 2,
  ).format(amount).trim();
  if (currency == null || amountCurrencyId != currency.id) return number;
  return switch (currency.position) {
    CurrencySymbolPosition.before => '${currency.symbol} $number',
    CurrencySymbolPosition.after => '$number ${currency.symbol}',
  };
}
