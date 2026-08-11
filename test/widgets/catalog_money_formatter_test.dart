import 'package:boteco_pro/models/currency.dart';
import 'package:boteco_pro/widgets/catalog_money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats the synchronized currency position and decimal places', () {
    const before = CurrencyInfo(
      id: 1,
      name: 'BRL',
      symbol: r'R$',
      position: CurrencySymbolPosition.before,
      decimalPlaces: 2,
      rounding: 0.01,
    );
    const after = CurrencyInfo(
      id: 2,
      name: 'TND',
      symbol: 'د.ت',
      position: CurrencySymbolPosition.after,
      decimalPlaces: 3,
      rounding: 0.001,
    );

    expect(
      formatCatalogAmount(12.5, currency: before, amountCurrencyId: 1),
      r'R$ 12,50',
    );
    expect(
      formatCatalogAmount(12.5, currency: after, amountCurrencyId: 2),
      '12,500 د.ت',
    );
  });

  test('never applies a POS symbol to an unverified product currency', () {
    const currency = CurrencyInfo(
      id: 1,
      name: 'BRL',
      symbol: r'R$',
      position: CurrencySymbolPosition.before,
      decimalPlaces: 2,
      rounding: 0.01,
    );

    expect(
      formatCatalogAmount(12.5, currency: currency, amountCurrencyId: null),
      '12,50',
    );
    expect(
      formatCatalogAmount(12.5, currency: currency, amountCurrencyId: 99),
      '12,50',
    );
  });
}
