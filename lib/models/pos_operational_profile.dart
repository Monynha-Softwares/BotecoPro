import 'currency.dart';

class PricelistInfo {
  const PricelistInfo({
    required this.id,
    required this.name,
    required this.currencyId,
    required this.active,
    this.companyId,
  });

  final int id;
  final String name;
  final int currencyId;
  final bool active;
  final int? companyId;
}

class PosSessionSummary {
  const PosSessionSummary({
    required this.id,
    required this.name,
    required this.state,
    required this.configId,
    required this.userId,
    required this.userName,
    required this.currencyId,
    required this.paymentMethodIds,
    this.startedAt,
    this.stoppedAt,
  });

  final int id;
  final String name;
  final String state;
  final int configId;
  final int userId;
  final String userName;
  final int currencyId;
  final List<int> paymentMethodIds;
  final DateTime? startedAt;
  final DateTime? stoppedAt;
}

class PaymentMethodSummary {
  const PaymentMethodSummary({
    required this.id,
    required this.name,
    required this.active,
    required this.isCashCount,
    required this.splitTransactions,
    required this.sequence,
    this.type,
    this.paymentMethodType,
  });

  final int id;
  final String name;
  final bool active;
  final bool isCashCount;
  final bool splitTransactions;
  final int sequence;
  final String? type;
  final String? paymentMethodType;
}

/// Read-only metadata required to describe the selected Odoo POS accurately.
///
/// This profile is not an open session and grants no authority to create an
/// order, calculate a transactional price or register a payment.
class PosOperationalProfile {
  const PosOperationalProfile({
    required this.posConfigId,
    required this.currency,
    required this.pricelist,
    required this.nonClosedSessions,
    required this.pricelistReadable,
    required this.sessionsReadable,
    required this.paymentMethods,
    required this.paymentMethodsReadable,
  });

  final int posConfigId;
  final CurrencyInfo currency;
  final PricelistInfo? pricelist;
  final bool pricelistReadable;
  final List<PosSessionSummary> nonClosedSessions;
  final bool sessionsReadable;
  final List<PaymentMethodSummary> paymentMethods;
  final bool paymentMethodsReadable;

  bool get hasOpenedSession =>
      nonClosedSessions.any((session) => session.state == 'opened');

  PosOperationalProfile withoutDynamicState() => PosOperationalProfile(
        posConfigId: posConfigId,
        currency: currency,
        pricelist: pricelist,
        pricelistReadable: pricelistReadable,
        nonClosedSessions: const [],
        sessionsReadable: false,
        paymentMethods: const [],
        paymentMethodsReadable: false,
      );
}
