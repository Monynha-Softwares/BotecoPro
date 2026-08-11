import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'pages/connection/connection_gate.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/odoo_session_provider.dart';
import 'services/odoo/odoo_runtime.dart';
import 'services/storage/cart_storage_service.dart';
import 'services/storage/credentials_storage_service.dart';
import 'services/storage/snapshot_storage_service.dart';
import 'theme.dart';

void main() async {
  await initializeBotecoProPlatform();
  runApp(const BotecoProApp());
}

Future<void> initializeBotecoProPlatform() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt-BR', null);
  Intl.defaultLocale = 'pt-BR';

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class BotecoProDependencies {
  const BotecoProDependencies({
    this.credentialsStorage = const CredentialsStorageService(),
    this.snapshotStorage = const SnapshotStorageService(),
    this.cartStorage = const CartStorageService(),
    this.runtimeFactory = const OdooRuntimeFactory(),
  });

  final CredentialsStorageService credentialsStorage;
  final SnapshotStorageService snapshotStorage;
  final CartStorageService cartStorage;
  final OdooRuntimeFactory runtimeFactory;
}

class BotecoProApp extends StatelessWidget {
  const BotecoProApp({
    this.dependencies = const BotecoProDependencies(),
    super.key,
  });

  final BotecoProDependencies dependencies;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => OdooSessionProvider(
              credentialsStorage: dependencies.credentialsStorage,
              snapshotStorage: dependencies.snapshotStorage,
              cartStorage: dependencies.cartStorage,
              runtimeFactory: dependencies.runtimeFactory,
            )..initialize(),
          ),
          ChangeNotifierProxyProvider<OdooSessionProvider, CatalogProvider>(
            create: (_) => CatalogProvider(
              snapshotStorage: dependencies.snapshotStorage,
            ),
            update: (_, session, catalog) {
              catalog!.bind(session);
              return catalog;
            },
          ),
          ChangeNotifierProxyProvider2<OdooSessionProvider, CatalogProvider,
              CartProvider>(
            create: (_) => CartProvider(storage: dependencies.cartStorage),
            update: (_, session, catalog, cart) {
              cart!.bind(session, catalog);
              return cart;
            },
          ),
        ],
        child: const MyApp(),
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boteco PRO',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const ConnectionGate(),
    );
  }
}
