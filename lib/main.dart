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
  WidgetsFlutterBinding.ensureInitialized();

// Inicializa a localização para português brasileiro
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

// Define a orientação da tela para retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const credentialsStorage = CredentialsStorageService();
  const snapshotStorage = SnapshotStorageService();
  const cartStorage = CartStorageService();
  const runtimeFactory = OdooRuntimeFactory();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OdooSessionProvider(
            credentialsStorage: credentialsStorage,
            snapshotStorage: snapshotStorage,
            cartStorage: cartStorage,
            runtimeFactory: runtimeFactory,
          )..initialize(),
        ),
        ChangeNotifierProxyProvider<OdooSessionProvider, CatalogProvider>(
          create: (_) => CatalogProvider(snapshotStorage: snapshotStorage),
          update: (_, session, catalog) {
            catalog!.bind(session);
            return catalog;
          },
        ),
        ChangeNotifierProxyProvider2<OdooSessionProvider, CatalogProvider,
            CartProvider>(
          create: (_) => CartProvider(storage: cartStorage),
          update: (_, session, catalog, cart) {
            cart!.bind(session, catalog);
            return cart;
          },
        ),
      ],
      child: const MyApp(),
    ),
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
