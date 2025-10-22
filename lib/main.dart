import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/home_page.dart';
import 'pages/production_page.dart';
import 'pages/products_page.dart';
import 'pages/recipes_page.dart';
import 'pages/tables_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'theme.dart';
import 'widgets/bottom_navigation.dart';
import 'services/supabase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (if .env file exists)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found - continue without Supabase
    print('Warning: .env file not found. Supabase features will be disabled.');
  }

  // Initialize Supabase (only if credentials are available)
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      print('Warning: Failed to initialize Supabase: $e');
    }
  }

  // Inicializa a localização para português brasileiro
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  runApp(const MyApp());
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
      home: const SplashScreen(),
      // Disable browser back button default behavior for better web experience
      navigatorObservers: [],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = SupabaseAuthService();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check if Supabase is configured and user is authenticated
    bool isSupabaseConfigured = false;
    try {
      isSupabaseConfigured = _authService.client.auth.currentUser != null;
    } catch (e) {
      // Supabase not configured, proceed without auth
      isSupabaseConfigured = false;
    }

    if (mounted) {
      // Always go to main navigation, auth is optional
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_bar,
              size: 80,
              color: Theme.of(context).colorScheme.onPrimary,
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut),
            const SizedBox(height: 24),
            Text(
              'Boteco PRO',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ).animate().fadeIn(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeIn),
            const SizedBox(height: 8),
            Text(
              'Gestão completa para seu bar',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.8),
                  ),
            ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 800)),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  NavigationTab _currentTab = NavigationTab.home;

  late final Map<NavigationTab, Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = {
      NavigationTab.home: HomePage(onTabSelected: _selectTab),
      NavigationTab.tables: const TablesPage(),
      NavigationTab.products: const ProductsPage(),
      NavigationTab.recipes: const RecipesPage(),
      NavigationTab.production: const ProductionPage(),
      NavigationTab.profile: const ProfilePage(),
    };
  }

  void _selectTab(NavigationTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWebLarge = MediaQuery.of(context).size.width > 800;
    
    // Handle browser back button - prevent blank page
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        
        // If not on home tab, go to home instead of popping
        if (_currentTab != NavigationTab.home) {
          _selectTab(NavigationTab.home);
        }
        // If on home tab, do nothing (stay in app)
      },
      child: _buildMainLayout(isWebLarge),
    );
  }

  Widget _buildMainLayout(bool isWebLarge) {
    if (isWebLarge) {
      // Layout desktop/web avec sidebar
      return Scaffold(
        body: Row(
          children: [
            // Navigation latérale
            NavigationRail(
              selectedIndex: _currentTab.index,
              onDestinationSelected: (index) => _selectTab(NavigationTab.values[index]),
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: Container(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.sports_bar,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: const Text('Início'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.table_bar_outlined),
                  selectedIcon: const Icon(Icons.table_bar),
                  label: const Text('Mesas'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon: const Icon(Icons.inventory_2),
                  label: const Text('Produtos'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.menu_book_outlined),
                  selectedIcon: const Icon(Icons.menu_book),
                  label: const Text('Receitas'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.production_quantity_limits_outlined),
                  selectedIcon: const Icon(Icons.production_quantity_limits),
                  label: const Text('Produção'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: const Text('Perfil'),
                ),
              ],
            ),
            // Conteúdo principal
            Expanded(
              child: IndexedStack(
                index: _currentTab.index,
                children: _screens.values.toList(),
              ),
            ),
          ],
        ),
      );
    }
    
    // Layout mobile avec bottom navigation
    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: _screens.values.toList(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onTabSelected: _selectTab,
      ),
    );
  }
}
