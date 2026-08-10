import '../../models/connection.dart';
import 'odoo_catalog_service.dart';
import 'odoo_client.dart';
import 'odoo_connection_service.dart';
import 'odoo_pos_service.dart';

typedef OdooClientBuilder = OdooClient Function(
  ConnectionConfig connection,
  String apiKey,
);

class OdooRuntimeFactory {
  const OdooRuntimeFactory({this.clientBuilder = _defaultClientBuilder});

  final OdooClientBuilder clientBuilder;

  OdooRuntime create(ConnectionConfig connection, String apiKey) {
    final client = clientBuilder(connection, apiKey);
    final catalog = OdooCatalogService(client);
    final pos = OdooPosService(client, catalog);
    return OdooRuntime(
      client: client,
      connection: OdooConnectionService(client, pos),
      catalog: catalog,
      pos: pos,
    );
  }

  static OdooClient _defaultClientBuilder(
    ConnectionConfig connection,
    String apiKey,
  ) =>
      OdooClient(connection: connection, apiKey: apiKey);
}

class OdooRuntime {
  const OdooRuntime({
    required this.client,
    required this.connection,
    required this.catalog,
    required this.pos,
  });

  final OdooClient client;
  final OdooConnectionService connection;
  final OdooCatalogService catalog;
  final OdooPosService pos;

  void close() => client.close();
}
