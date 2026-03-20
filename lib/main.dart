import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'data/remote/remote_backend_config.dart';
import 'data/remote/remote_sync_service.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/production_page.dart';
import 'presentation/pages/products_page.dart';
import 'presentation/pages/recipes_page.dart';
import 'presentation/pages/tables_page.dart';
import 'presentation/widgets/bottom_navigation.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  runApp(
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider()..initialize(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BotecoPro | Monynha Softwares',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final RemoteSyncService _remoteSyncService =
      const RemoteSyncService(RemoteBackendConfig.mocked);

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.wait<void>(<Future<void>>[
      Future<void>.delayed(const Duration(milliseconds: 1800)),
      context.read<AuthProvider>().initialize(),
      _remoteSyncService.enqueueBootstrapSync(),
    ]);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) {
          final auth = context.read<AuthProvider>();
          return auth.isSignedIn ? const MainNavigationScreen() : const LoginPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Icon(
                Icons.sports_bar_rounded,
                size: 80,
                color: colorScheme.onPrimary,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(duration: const Duration(milliseconds: 1100)),
            const SizedBox(height: 24),
            Text(
              'BotecoPro',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimary,
                  ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
            const SizedBox(height: 8),
            Text(
              'Operação inteligente para bares e restaurantes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.82),
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: const Duration(milliseconds: 250)),
            const SizedBox(height: 24),
            Text(
              'Marcelo Santos • Monynha Softwares',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.72),
                  ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 450)),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  NavigationTab _currentTab = NavigationTab.home;
  final GlobalKey _homeKey = GlobalKey();

  late final Map<NavigationTab, Widget> _screens = <NavigationTab, Widget>{
    NavigationTab.home: HomePage(key: _homeKey, onTabSelected: _selectTab),
    NavigationTab.tables: const TablesPage(),
    NavigationTab.products: const ProductsPage(),
    NavigationTab.recipes: const RecipesPage(),
    NavigationTab.production: const ProductionPage(),
  };

  void _selectTab(NavigationTab tab) {
    if (tab == NavigationTab.home) {
      final dynamic state = _homeKey.currentState;
      state?.reload?.call();
    }

    setState(() => _currentTab = tab);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _currentTab.index,
              onDestinationSelected: (index) => _selectTab(NavigationTab.values[index]),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.sports_bar_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BotecoPro',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.displayName,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: IconButton(
                  onPressed: _logout,
                  tooltip: 'Sair',
                  icon: const Icon(Icons.logout_rounded),
                ),
              ),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Início'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.table_bar_outlined),
                  selectedIcon: Icon(Icons.table_bar_rounded),
                  label: Text('Mesas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded),
                  label: Text('Produtos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: Text('Receitas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.factory_outlined),
                  selectedIcon: Icon(Icons.factory_rounded),
                  label: Text('Produção'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_currentTab]!),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentTab],
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onTabSelected: _selectTab,
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(auth.displayName),
                subtitle: Text(auth.user?.email ?? 'Sessão local'),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Encerrar sessão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
