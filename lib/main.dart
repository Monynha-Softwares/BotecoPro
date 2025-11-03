// lib/main.dart
//
/// BotecoPro - Aplicativo de Gestão para Bares
///
/// ARQUITETURA DO PROJETO:
///
/// ```
/// lib/
/// ├── main.dart                    # Entry point e navegação principal
/// ├── theme.dart                   # Tema e cores do app
/// ├── core/                        # Lógica de negócio e dados
/// │   ├── models/                  # Modelos de dados
/// │   │   └── data_models.dart     # Todas as entidades (Product, Order, etc)
/// │   ├── services/                # Serviços de lógica de negócio
/// │   │   ├── database_service.dart          # Persistência com SharedPreferences
/// │   │   ├── supabase_database_service.dart # Persistência com Supabase
/// │   │   └── auth_service.dart              # Autenticação (legacy)
/// │   ├── config/                  # Configurações
/// │   │   └── database_config.dart           # Toggle SharedPreferences/Supabase
/// │   └── providers/               # Gerenciamento de estado
/// │       ├── auth_provider.dart             # Estado de autenticação (legacy)
/// │       └── database_provider.dart         # SQLite (implementação futura)
/// └── presentation/                # Interface do usuário
///     ├── pages/                   # Telas do app
///     │   ├── home_page.dart
///     │   ├── login_page.dart      # Supabase Auth com Magic Link
///     │   ├── account_page.dart    # Gerenciamento de perfil
///     │   ├── profile_page.dart    # Wrapper para account_page
///     │   ├── signup_page.dart     # (placeholder - não usado)
///     │   ├── tables_page.dart
///     │   ├── products_page.dart
///     │   ├── recipes_page.dart
///     │   ├── production_page.dart
///     │   └── suppliers_page.dart
///     └── widgets/                 # Componentes reutilizáveis
///         ├── shared_widgets.dart
///         └── bottom_navigation.dart
/// ```
///
/// PADRÕES UTILIZADOS:
/// - Clean Architecture (separação core/presentation)
/// - Singleton (DatabaseService, Supabase client)
/// - StatefulWidget para gerenciamento de estado local
/// - Reactive streams para auth state changes
///
/// FLUXO DE DADOS:
/// 1. UI (Pages) → DatabaseService → SharedPreferences (default)
/// 2. UI (Pages) → SupabaseDatabaseService → Supabase (optional)
/// 3. Modelos implementam toJson/fromJson para serialização
/// 4. Auth gerenciado por Supabase Auth (magic link email)
///
/// AUTENTICAÇÃO:
/// - Supabase Auth com Magic Link (passwordless)
/// - User profiles armazenados em public.profiles
/// - Row Level Security habilitada
/// - Deep links para iOS/Android
///
/// DEPENDÊNCIAS PRINCIPAIS:
/// - supabase_flutter: Autenticação e persistência remota
/// - shared_preferences: Persistência local
/// - flutter_dotenv: Variáveis de ambiente
/// - intl: Formatação de datas e moeda (pt_BR)
///
library;


import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/production_page.dart';
import 'presentation/pages/products_page.dart';
import 'presentation/pages/recipes_page.dart';
import 'presentation/pages/tables_page.dart';
import 'theme.dart';
import 'presentation/widgets/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a localização para português brasileiro
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';
  
  // Carrega variáveis de ambiente (opcional - se .env existir)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env carregado com sucesso');
  } catch (e) {
    // .env não existe - usar configuração padrão
    debugPrint('⚠️ .env não encontrado, usando configuração padrão');
  }

  // Inicializa Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('✅ Supabase inicializado com sucesso');
  } else {
    debugPrint('⚠️ Credenciais Supabase não encontradas no .env');
  }

  runApp(const MyApp());
}

// Global Supabase client instance
final supabase = Supabase.instance.client;

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
      home: supabase.auth.currentSession == null
          ? const LoginPage()
          : const MainNavigationScreen(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigationScreen(),
      },
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

  late final Map<NavigationTab, Widget> _screens;
  // Key to access HomePage state for manual reload when switching tabs
  final GlobalKey _homeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _screens = {
      NavigationTab.home: HomePage(key: _homeKey, onTabSelected: _selectTab),
      NavigationTab.tables: const TablesPage(),
      NavigationTab.products: const ProductsPage(),
      NavigationTab.recipes: const RecipesPage(),
      NavigationTab.production: const ProductionPage(),
      NavigationTab.profile: const ProfilePage(),
    };
  }

  void _selectTab(NavigationTab tab) {
    if (tab == NavigationTab.home) {
      // Trigger a reload on Home if available
      final state = _homeKey.currentState;
      try {
        // Call `reload()` on _HomePageState via dynamic access
        // ignore: avoid_dynamic_calls
        (state as dynamic)?.reload?.call();
      } catch (_) {
        // no-op if method not available
      }
    }
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final isWebLarge = MediaQuery.of(context).size.width > 800;
    
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
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Início'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.table_bar_outlined),
                  selectedIcon: Icon(Icons.table_bar),
                  label: Text('Mesas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('Produtos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: Text('Receitas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.production_quantity_limits_outlined),
                  selectedIcon: Icon(Icons.production_quantity_limits),
                  label: Text('Produção'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Perfil'),
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

// Extension for showing snackbars throughout the app
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
