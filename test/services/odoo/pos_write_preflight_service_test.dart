import 'package:flutter_test/flutter_test.dart';

import 'package:boteco_pro/models/catalog.dart';
import 'package:boteco_pro/models/currency.dart';
import 'package:boteco_pro/models/draft_cart.dart';
import 'package:boteco_pro/models/pos_config.dart';
import 'package:boteco_pro/models/pos_operational_profile.dart';
import 'package:boteco_pro/models/sync_snapshot.dart';
import 'package:boteco_pro/services/odoo/pos_write_preflight_service.dart';

const context = OperationalContext(
  instanceKey: 'https://example.odoo.com',
  userId: 7,
  companyId: 3,
  posConfigId: 11,
);

const posConfig = PosConfig(
  id: 11,
  name: 'POS de teste',
  companyId: 3,
  active: true,
  limitCategories: false,
  categoryIds: [],
  restaurant: true,
  currencyId: 6,
);

const openedSession = PosSessionSummary(
  id: 31,
  name: 'Sessão de teste',
  state: 'opened',
  configId: 11,
  userId: 7,
  userName: 'Operador de teste',
  currencyId: 6,
  paymentMethodIds: [],
);

const profile = PosOperationalProfile(
  posConfigId: 11,
  currency: CurrencyInfo(
    id: 6,
    name: 'BRL',
    symbol: r'R$',
    position: CurrencySymbolPosition.before,
    decimalPlaces: 2,
    rounding: 0.01,
  ),
  pricelist: null,
  nonClosedSessions: [openedSession],
  pricelistReadable: true,
  sessionsReadable: true,
  paymentMethods: [],
  paymentMethodsReadable: true,
);

DraftCart preparedCart(
    {DraftCartItemState state = DraftCartItemState.available}) {
  var sequence = 0;
  final cart = DraftCart(context: context).add(const CatalogProduct(
    id: 42,
    name: 'Produto sintético',
    catalogPrice: 12.5,
    currencyId: 6,
  ));
  final prepared = cart.prepareSubmissionIdentity(
    () => '00000000-0000-4000-8000-${(++sequence).toString().padLeft(12, '0')}',
  );
  if (state == DraftCartItemState.available) return prepared;
  return prepared.copyWith(
    items: [prepared.items.single.copyWith(state: state)],
  );
}

void main() {
  const service = PosWritePreflightService();

  test('fails closed while external M8 gates remain unverified', () {
    final result = service.evaluate(
      online: true,
      currentContext: context,
      cart: preparedCart(),
      posConfig: posConfig,
      operationalProfile: profile,
    );

    expect(result.isReadyForDraftRehearsal, isFalse);
    expect(
      result.blockers,
      containsAll({
        PosWriteBlocker.targetContractUnverified,
        PosWriteBlocker.authoritativePricingUnavailable,
        PosWriteBlocker.sessionOwnershipPolicyUnverified,
        PosWriteBlocker.restaurantCollisionPolicyUnverified,
        PosWriteBlocker.idempotencyReadbackUnverified,
        PosWriteBlocker.disposableRehearsalPending,
        PosWriteBlocker.fiscalIdentityUnverified,
      }),
    );
    expect(result.blockers, isNot(contains(PosWriteBlocker.noOpenedSession)));
  });

  test('requires stable identity and rejects changed or unavailable lines', () {
    final withoutIdentity =
        DraftCart(context: context).add(const CatalogProduct(
      id: 42,
      name: 'Produto sintético',
      catalogPrice: 12.5,
      currencyId: 6,
    ));
    final missingIdentity = service.evaluate(
      online: true,
      currentContext: context,
      cart: withoutIdentity,
      posConfig: posConfig,
      operationalProfile: profile,
    );
    final changed = service.evaluate(
      online: true,
      currentContext: context,
      cart: preparedCart(state: DraftCartItemState.changed),
      posConfig: posConfig,
      operationalProfile: profile,
    );
    final unavailable = service.evaluate(
      online: true,
      currentContext: context,
      cart: preparedCart(state: DraftCartItemState.unavailable),
      posConfig: posConfig,
      operationalProfile: profile,
    );

    expect(
      missingIdentity.blockers,
      contains(PosWriteBlocker.unstableSubmissionIdentity),
    );
    expect(changed.blockers, contains(PosWriteBlocker.changedCatalogItem));
    expect(
      unavailable.blockers,
      contains(PosWriteBlocker.unavailableCatalogItem),
    );
  });

  test('blocks offline, foreign context and unavailable live session data', () {
    final result = service.evaluate(
      online: false,
      currentContext: const OperationalContext(
        instanceKey: 'https://example.odoo.com',
        userId: 7,
        companyId: 9,
        posConfigId: 11,
      ),
      cart: preparedCart(),
      posConfig: posConfig,
      operationalProfile: profile.withoutDynamicState(),
    );

    expect(result.blockers, contains(PosWriteBlocker.offline));
    expect(result.blockers, contains(PosWriteBlocker.contextMismatch));
    expect(
      result.blockers,
      contains(PosWriteBlocker.sessionDataUnavailable),
    );
  });

  test('becomes ready only when every local and external gate is proven', () {
    final result = service.evaluate(
      online: true,
      currentContext: context,
      cart: preparedCart(),
      posConfig: posConfig,
      operationalProfile: profile,
      gates: const PosWriteContractGates(
        targetContractVerified: true,
        authoritativePricingVerified: true,
        sessionOwnershipPolicyVerified: true,
        restaurantCollisionPolicyVerified: true,
        idempotencyReadbackVerified: true,
        disposableRehearsalPassed: true,
        fiscalIdentityVerified: true,
      ),
    );

    expect(result.blockers, isEmpty);
    expect(result.isReadyForDraftRehearsal, isTrue);
  });
}
