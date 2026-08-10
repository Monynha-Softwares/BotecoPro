import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:boteco_pro/models/connection.dart';
import 'package:boteco_pro/services/odoo/odoo_runtime.dart';

const _urlKey = 'ODOO_ONLINE_URL';
const _usernameKey = 'ODOO_ONLINE_USERNAME';
const _apiKeyKey = 'ODOO_ONLINE_API_KEY';

void main() {
  final environment = Platform.environment;
  final enabled = [
    environment[_urlKey],
    environment[_usernameKey],
    environment[_apiKeyKey],
  ].every((value) => value != null && value.trim().isNotEmpty);

  test(
    'read-only Odoo Online smoke test',
    () async {
      final connection = ConnectionConfig.fromInput(
        baseUrl: environment[_urlKey]!,
        username: environment[_usernameKey]!,
      );
      final runtime = const OdooRuntimeFactory().create(
        connection,
        environment[_apiKeyKey]!,
      );
      addTearDown(runtime.close);

      final diagnostic = await runtime.connection.testConnection(
        expectedUsername: connection.username,
      );
      expect(diagnostic.odooVersion, isNotEmpty);
      expect(diagnostic.identity.login.toLowerCase(),
          connection.username.toLowerCase());
      expect(diagnostic.currentCompany.id, greaterThan(0));
      expect(diagnostic.companies, isNotEmpty);
      expect(diagnostic.modelAccess.values, everyElement(isTrue));
      expect(diagnostic.posConfigs, isNotEmpty);

      final posConfig = diagnostic.posConfigs.first;
      expect(posConfig.catalogProductCount, greaterThan(0));
      final posCategories = await runtime.catalog.listCategories(
        companyId: diagnostic.currentCompany.id,
        categoryIds: posConfig.limitCategories ? posConfig.categoryIds : null,
      );
      expect(posCategories, isNotEmpty);

      if (posConfig.restaurant) {
        final floors = await runtime.pos.listRestaurantFloors(
          companyId: diagnostic.currentCompany.id,
          posConfigId: posConfig.id,
        );
        final tables = await runtime.pos.listRestaurantTables(
          companyId: diagnostic.currentCompany.id,
          floors: floors,
        );
        expect(floors, isNotEmpty);
        expect(tables, isNotEmpty);
      }

      final productCategories = await runtime.client.call(
        'product.category',
        'search_read',
        arguments: {
          'domain': <Object?>[],
          'fields': ['id'],
          'limit': 1,
          'context': {
            'allowed_company_ids': [diagnostic.currentCompany.id]
          },
        },
      );
      expect(productCategories, isA<List>());

      final firstPage = await runtime.catalog.listProducts(
        companyId: diagnostic.currentCompany.id,
        posConfig: posConfig,
        limit: 5,
      );
      final secondPage = await runtime.catalog.listProducts(
        companyId: diagnostic.currentCompany.id,
        posConfig: posConfig,
        offset: 5,
        limit: 5,
      );
      expect(firstPage, isNotEmpty);
      expect(posConfig.catalogProductCount,
          greaterThanOrEqualTo(firstPage.length));
      expect(
        firstPage.map((product) => product.id).toSet().intersection(
              secondPage.map((product) => product.id).toSet(),
            ),
        isEmpty,
      );
    },
    skip: !enabled
        ? 'Defina credenciais locais para executar o smoke test.'
        : false,
  );
}
