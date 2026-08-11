import 'catalog.dart';
import 'restaurant.dart';
import 'sync_snapshot.dart';

enum DraftCartItemState { available, changed, unavailable }

class DraftCartItem {
  const DraftCartItem({
    required this.productId,
    required this.productName,
    required this.capturedUnitPrice,
    this.capturedCurrencyId,
    this.quantity = 1,
    this.note = '',
    this.state = DraftCartItemState.available,
    this.currentProductName,
    this.currentCatalogPrice,
    this.currentCurrencyId,
    this.submissionLineUuid,
  });

  final int productId;
  final String productName;

  /// Informational catalog value captured when the item entered the draft.
  /// It is not an authoritative Odoo transactional price.
  final double capturedUnitPrice;
  final int? capturedCurrencyId;
  final int quantity;
  final String note;
  final DraftCartItemState state;
  final String? currentProductName;
  final double? currentCatalogPrice;
  final int? currentCurrencyId;

  /// Stable local identity reserved for a future controlled POS submission.
  ///
  /// It is deliberately not an Odoo write queue and is never sent anywhere by
  /// the M8 preparation milestone.
  final String? submissionLineUuid;

  double get subtotal => capturedUnitPrice * quantity;

  DraftCartItem copyWith({
    int? quantity,
    String? note,
    DraftCartItemState? state,
    String? currentProductName,
    double? currentCatalogPrice,
    int? currentCurrencyId,
    String? submissionLineUuid,
    bool clearCurrentValues = false,
  }) =>
      DraftCartItem(
        productId: productId,
        productName: productName,
        capturedUnitPrice: capturedUnitPrice,
        capturedCurrencyId: capturedCurrencyId,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
        state: state ?? this.state,
        currentProductName: clearCurrentValues
            ? null
            : currentProductName ?? this.currentProductName,
        currentCatalogPrice: clearCurrentValues
            ? null
            : currentCatalogPrice ?? this.currentCatalogPrice,
        currentCurrencyId: clearCurrentValues
            ? null
            : currentCurrencyId ?? this.currentCurrencyId,
        submissionLineUuid: submissionLineUuid ?? this.submissionLineUuid,
      );

  Map<String, Object?> toJson() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': capturedUnitPrice,
        'currencyId': capturedCurrencyId,
        'quantity': quantity,
        'note': note,
        'submissionLineUuid': submissionLineUuid,
      };

  factory DraftCartItem.fromJson(Map<String, dynamic> json) => DraftCartItem(
        productId: json['productId'] as int,
        productName: json['productName'] as String,
        capturedUnitPrice: (json['unitPrice'] as num).toDouble(),
        capturedCurrencyId: json['currencyId'] as int?,
        quantity: json['quantity'] as int,
        note: json['note'] as String? ?? '',
        submissionLineUuid: json['submissionLineUuid'] as String?,
      );
}

class DraftCart {
  DraftCart({
    required this.context,
    this.table,
    this.items = const [],
    this.submissionOrderUuid,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  static const currentSchemaVersion = 1;
  static final _uuidV4Pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  final OperationalContext context;
  final RestaurantTable? table;
  final List<DraftCartItem> items;
  final String? submissionOrderUuid;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
  double get subtotal => items.fold(0, (total, item) => total + item.subtotal);
  int? get capturedCurrencyId {
    if (items.isEmpty) return null;
    final candidate = items.first.capturedCurrencyId;
    if (candidate == null ||
        items.any((item) => item.capturedCurrencyId != candidate)) {
      return null;
    }
    return candidate;
  }

  bool get hasUnavailableItems =>
      items.any((item) => item.state == DraftCartItemState.unavailable);

  bool get hasStableSubmissionIdentity =>
      _isUuidV4(submissionOrderUuid) &&
      items.isNotEmpty &&
      items.every((item) => _isUuidV4(item.submissionLineUuid));

  static bool _isUuidV4(String? value) =>
      value != null && _uuidV4Pattern.hasMatch(value);

  bool matchesContext(OperationalContext candidate) =>
      context.matches(candidate);

  DraftCart add(CatalogProduct product) {
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index < 0) {
      return copyWith(items: [
        ...items,
        DraftCartItem(
          productId: product.id,
          productName: product.name,
          capturedUnitPrice: product.catalogPrice,
          capturedCurrencyId: product.currencyId,
        )
      ]);
    }
    return updateQuantity(product.id, items[index].quantity + 1);
  }

  DraftCart updateQuantity(int productId, int quantity) {
    if (quantity <= 0) return remove(productId);
    return copyWith(items: [
      for (final item in items)
        if (item.productId == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ]);
  }

  DraftCart updateNote(int productId, String note) => copyWith(items: [
        for (final item in items)
          if (item.productId == productId)
            item.copyWith(note: note.trim())
          else
            item,
      ]);

  DraftCart remove(int productId) => copyWith(
        items: items
            .where((item) => item.productId != productId)
            .toList(growable: false),
      );

  DraftCart clear() => copyWith(items: const [], clearSubmissionIdentity: true);

  /// Allocates stable retry identities without performing an Odoo write.
  ///
  /// Repeated calls preserve every previously allocated UUID. New lines get a
  /// new identity, while a removed and re-added product is intentionally a new
  /// line. The caller persists the returned draft before any future request.
  DraftCart prepareSubmissionIdentity(String Function() generateUuid) =>
      copyWith(
        submissionOrderUuid: submissionOrderUuid ?? generateUuid(),
        items: [
          for (final item in items)
            item.copyWith(
              submissionLineUuid: item.submissionLineUuid ?? generateUuid(),
            ),
        ],
      );

  DraftCart reconcile(
    List<CatalogProduct> products, {
    List<RestaurantTable>? restaurantTables,
  }) {
    final catalog = {for (final product in products) product.id: product};
    final tableStillAvailable = table == null ||
        restaurantTables == null ||
        restaurantTables.any((candidate) => candidate.id == table!.id);
    return copyWith(
      clearTable: !tableStillAvailable,
      items: [
        for (final item in items) _reconcileItem(item, catalog[item.productId]),
      ],
    );
  }

  DraftCartItem _reconcileItem(DraftCartItem item, CatalogProduct? product) {
    if (product == null) {
      return item.copyWith(state: DraftCartItemState.unavailable);
    }
    final priceChanged =
        (item.capturedUnitPrice - product.catalogPrice).abs() > 0.000000001;
    final currencyChanged = item.capturedCurrencyId != product.currencyId;
    final changed =
        item.productName != product.name || priceChanged || currencyChanged;
    return item.copyWith(
      state:
          changed ? DraftCartItemState.changed : DraftCartItemState.available,
      currentProductName: changed ? product.name : null,
      currentCatalogPrice: changed ? product.catalogPrice : null,
      currentCurrencyId: changed ? product.currencyId : null,
      clearCurrentValues: !changed,
    );
  }

  DraftCart copyWith({
    RestaurantTable? table,
    bool clearTable = false,
    List<DraftCartItem>? items,
    String? submissionOrderUuid,
    bool clearSubmissionIdentity = false,
    DateTime? updatedAt,
  }) =>
      DraftCart(
        context: context,
        table: clearTable ? null : table ?? this.table,
        items: items ?? this.items,
        submissionOrderUuid: clearSubmissionIdentity
            ? null
            : submissionOrderUuid ?? this.submissionOrderUuid,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now().toUtc(),
      );

  Map<String, Object?> toJson() => {
        'schemaVersion': currentSchemaVersion,
        'instanceKey': context.instanceKey,
        'userId': context.userId,
        'companyId': context.companyId,
        'posConfigId': context.posConfigId,
        'table': table == null
            ? null
            : {
                'id': table!.id,
                'number': table!.number,
                'floorId': table!.floorId,
                'floorName': table!.floorName,
                'active': table!.active,
                'seats': table!.seats,
              },
        'items': [for (final item in items) item.toJson()],
        'submissionOrderUuid': submissionOrderUuid,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory DraftCart.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != currentSchemaVersion) {
      throw const FormatException('Unsupported local cart schema.');
    }
    final tableValue = json['table'];
    final table = tableValue == null
        ? null
        : Map<String, dynamic>.from(tableValue as Map);
    return DraftCart(
      context: OperationalContext(
        instanceKey: json['instanceKey'] as String,
        userId: json['userId'] as int,
        companyId: json['companyId'] as int,
        posConfigId: json['posConfigId'] as int,
      ),
      table: table == null
          ? null
          : RestaurantTable(
              id: table['id'] as int,
              number: table['number'] as int,
              floorId: table['floorId'] as int,
              floorName: table['floorName'] as String,
              active: table['active'] as bool,
              seats: table['seats'] as int?,
            ),
      items: List<dynamic>.from(json['items'] as List)
          .map((item) => DraftCartItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
      submissionOrderUuid: json['submissionOrderUuid'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
