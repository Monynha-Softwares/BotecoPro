import '../../models/draft_cart.dart';
import '../../models/pos_config.dart';
import '../../models/pos_operational_profile.dart';
import '../../models/sync_snapshot.dart';

enum PosWriteBlocker {
  offline,
  contextMismatch,
  posInactive,
  emptyCart,
  unstableSubmissionIdentity,
  changedCatalogItem,
  unavailableCatalogItem,
  unverifiedCurrency,
  operationalProfileUnavailable,
  sessionDataUnavailable,
  noOpenedSession,
  ambiguousOpenedSession,
  sessionContextMismatch,
  sessionOwnerMismatch,
  tableContextMismatch,
  targetContractUnverified,
  authoritativePricingUnavailable,
  sessionOwnershipPolicyUnverified,
  restaurantCollisionPolicyUnverified,
  idempotencyReadbackUnverified,
  disposableRehearsalPending,
  fiscalIdentityUnverified,
}

/// Explicit product and operational gates that cannot be inferred locally.
///
/// The default is fail-closed. Advancing a gate requires external evidence;
/// constructing this object does not authorize a write by itself.
class PosWriteContractGates {
  const PosWriteContractGates({
    this.targetContractVerified = false,
    this.authoritativePricingVerified = false,
    this.sessionOwnershipPolicyVerified = false,
    this.restaurantCollisionPolicyVerified = false,
    this.idempotencyReadbackVerified = false,
    this.disposableRehearsalPassed = false,
    this.fiscalIdentityVerified = false,
  });

  final bool targetContractVerified;
  final bool authoritativePricingVerified;
  final bool sessionOwnershipPolicyVerified;
  final bool restaurantCollisionPolicyVerified;
  final bool idempotencyReadbackVerified;
  final bool disposableRehearsalPassed;
  final bool fiscalIdentityVerified;
}

class PosWritePreflightResult {
  const PosWritePreflightResult(this.blockers);

  final Set<PosWriteBlocker> blockers;

  bool get isReadyForDraftRehearsal => blockers.isEmpty;
}

/// Pure, fail-closed validation for the future M8a draft-order rehearsal.
///
/// There is intentionally no JSON-2 write method in this service. Its only
/// output is a set of blockers that must be empty before a separate transport
/// implementation can even be considered.
class PosWritePreflightService {
  const PosWritePreflightService();

  PosWritePreflightResult evaluate({
    required bool online,
    required OperationalContext currentContext,
    required DraftCart cart,
    required PosConfig posConfig,
    required PosOperationalProfile? operationalProfile,
    PosWriteContractGates gates = const PosWriteContractGates(),
  }) {
    final blockers = <PosWriteBlocker>{};

    if (!online) blockers.add(PosWriteBlocker.offline);
    if (!cart.matchesContext(currentContext) ||
        posConfig.id != currentContext.posConfigId ||
        posConfig.companyId != currentContext.companyId) {
      blockers.add(PosWriteBlocker.contextMismatch);
    }
    if (!posConfig.active) blockers.add(PosWriteBlocker.posInactive);
    if (cart.items.isEmpty) blockers.add(PosWriteBlocker.emptyCart);
    if (!cart.hasStableSubmissionIdentity) {
      blockers.add(PosWriteBlocker.unstableSubmissionIdentity);
    }
    if (cart.items.any(
      (item) => item.state == DraftCartItemState.changed,
    )) {
      blockers.add(PosWriteBlocker.changedCatalogItem);
    }
    if (cart.items.any(
      (item) => item.state == DraftCartItemState.unavailable,
    )) {
      blockers.add(PosWriteBlocker.unavailableCatalogItem);
    }
    if (cart.table != null && !posConfig.restaurant) {
      blockers.add(PosWriteBlocker.tableContextMismatch);
    }

    final profile = operationalProfile;
    if (profile == null) {
      blockers.add(PosWriteBlocker.operationalProfileUnavailable);
      blockers.add(PosWriteBlocker.unverifiedCurrency);
      blockers.add(PosWriteBlocker.sessionDataUnavailable);
    } else {
      if (profile.posConfigId != currentContext.posConfigId) {
        blockers.add(PosWriteBlocker.contextMismatch);
      }
      final capturedCurrencyId = cart.capturedCurrencyId;
      if (capturedCurrencyId == null ||
          capturedCurrencyId != profile.currency.id ||
          posConfig.currencyId != profile.currency.id) {
        blockers.add(PosWriteBlocker.unverifiedCurrency);
      }
      if (!profile.sessionsReadable) {
        blockers.add(PosWriteBlocker.sessionDataUnavailable);
      } else {
        final opened = profile.nonClosedSessions
            .where((session) => session.state == 'opened')
            .toList(growable: false);
        if (opened.isEmpty) blockers.add(PosWriteBlocker.noOpenedSession);
        if (opened.length > 1) {
          blockers.add(PosWriteBlocker.ambiguousOpenedSession);
        }
        if (opened.length == 1) {
          final session = opened.single;
          if (session.configId != currentContext.posConfigId ||
              session.currencyId != profile.currency.id) {
            blockers.add(PosWriteBlocker.sessionContextMismatch);
          }
          if (session.userId != currentContext.userId) {
            blockers.add(PosWriteBlocker.sessionOwnerMismatch);
          }
        }
      }
    }

    if (!gates.targetContractVerified) {
      blockers.add(PosWriteBlocker.targetContractUnverified);
    }
    if (!gates.authoritativePricingVerified) {
      blockers.add(PosWriteBlocker.authoritativePricingUnavailable);
    }
    if (!gates.sessionOwnershipPolicyVerified) {
      blockers.add(PosWriteBlocker.sessionOwnershipPolicyUnverified);
    }
    if (posConfig.restaurant && !gates.restaurantCollisionPolicyVerified) {
      blockers.add(PosWriteBlocker.restaurantCollisionPolicyUnverified);
    }
    if (!gates.idempotencyReadbackVerified) {
      blockers.add(PosWriteBlocker.idempotencyReadbackUnverified);
    }
    if (!gates.disposableRehearsalPassed) {
      blockers.add(PosWriteBlocker.disposableRehearsalPending);
    }
    if (!gates.fiscalIdentityVerified) {
      blockers.add(PosWriteBlocker.fiscalIdentityUnverified);
    }

    return PosWritePreflightResult(Set.unmodifiable(blockers));
  }
}
