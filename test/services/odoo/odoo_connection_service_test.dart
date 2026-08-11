import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/services/odoo/odoo_client.dart';
import 'package:boteco_pro/services/odoo/odoo_catalog_service.dart';
import 'package:boteco_pro/services/odoo/odoo_connection_service.dart';
import 'package:boteco_pro/services/odoo/odoo_exception.dart';
import 'package:boteco_pro/services/odoo/odoo_pos_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _AccessProbeClient extends OdooClient {
  _AccessProbeClient({required this.failingModel, required this.failure})
      : super(
          connection: const ConnectionConfig(
            baseUrl: 'https://odoo.example.com',
            username: 'user@example.com',
          ),
          apiKey: 'sentinel-test-key',
        );

  final String failingModel;
  final OdooException failure;

  @override
  Future<String> getVersion() async => 'saas~19.4+e';

  @override
  Future<dynamic> call(
    String model,
    String method, {
    Map<String, dynamic> arguments = const {},
  }) async {
    if (model == 'res.users' && method == 'context_get') return {'uid': 2};
    if (model == 'res.users') {
      return [
        {
          'id': 2,
          'name': 'Utilizador',
          'login': 'user@example.com',
          'company_id': [1, 'Empresa'],
          'company_ids': [1],
          'lang': 'pt_BR',
          'tz': 'UTC',
        },
      ];
    }
    if (model == 'res.company' && arguments['fields'] is List) {
      final fields = List<Object?>.from(arguments['fields'] as List);
      if (fields.contains('name')) {
        return [
          {
            'id': 1,
            'name': 'Empresa',
            'currency_id': [6, 'BRL'],
            'country_id': false,
          },
        ];
      }
    }
    final fields = arguments['fields'];
    final isAccessProbe =
        fields is List && fields.length == 1 && fields.single == 'id';
    if (isAccessProbe && model == failingModel) throw failure;
    return const <dynamic>[];
  }
}

OdooConnectionService _service({
  required String failingModel,
  required OdooException failure,
}) {
  final client = _AccessProbeClient(
    failingModel: failingModel,
    failure: failure,
  );
  return OdooConnectionService(
    client,
    OdooPosService(client, OdooCatalogService(client)),
  );
}

void main() {
  test('reports a genuine model permission denial without aborting identity',
      () async {
    final diagnostic = await _service(
      failingModel: 'pos.category',
      failure: const OdooException(
        kind: OdooErrorKind.forbidden,
        message: 'Sem acesso.',
      ),
    ).testConnection(expectedUsername: 'user@example.com');

    expect(diagnostic.identity.id, 2);
    expect(diagnostic.modelAccess['pos.category'], isFalse);
    expect(diagnostic.modelAccess['product.product'], isTrue);
  });

  test('propagates transient access-probe failures so connection can retry',
      () async {
    await expectLater(
      _service(
        failingModel: 'pos.category',
        failure: const OdooException(
          kind: OdooErrorKind.network,
          message: 'Falha transitória.',
        ),
      ).testConnection(expectedUsername: 'user@example.com'),
      throwsA(
        isA<OdooException>().having(
          (error) => error.kind,
          'kind',
          OdooErrorKind.network,
        ),
      ),
    );
  });
}
