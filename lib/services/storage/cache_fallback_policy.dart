import '../odoo/odoo_exception.dart';

class CacheFallbackPolicy {
  const CacheFallbackPolicy._();

  static bool canUse(Object error) =>
      error is OdooException &&
      (error.kind == OdooErrorKind.network ||
          error.kind == OdooErrorKind.timeout);
}
