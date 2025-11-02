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
/// │   │   ├── database_service.dart    # Persistência com SharedPreferences
/// │   │   └── auth_service.dart        # Autenticação (placeholder)
/// │   └── providers/               # Gerenciamento de estado
/// │       ├── auth_provider.dart       # Estado de autenticação
/// │       └── database_provider.dart   # SQLite (implementação futura)
/// └── presentation/                # Interface do usuário
///     ├── pages/                   # Telas do app
///     │   ├── home_page.dart
///     │   ├── login_page.dart      # (placeholder)
///     │   ├── signup_page.dart     # (placeholder)
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
/// - Singleton (DatabaseService, Providers)
/// - StatefulWidget para gerenciamento de estado local
/// - ChangeNotifier para estado global (preparado)
///
/// FLUXO DE DADOS:
/// 1. UI (Pages) → DatabaseService → SharedPreferences
/// 2. Modelos implementam toJson/fromJson para serialização
/// 3. Cada entidade tem chave única no SharedPreferences
///
/// PREPARAÇÃO PARA FUTURO:
/// - AuthProvider pronto para Firebase Authentication
/// - DatabaseProvider pronto para migração SQLite
/// - LoginPage/SignupPage prontas para integração
///
/// DEPENDÊNCIAS PRINCIPAIS:
/// - flutter_animate: Animações
/// - shared_preferences: Persistência local
/// - provider: Gerenciamento de estado (preparado)
/// - intl: Formatação de datas e moeda (pt_BR)
///
library;


import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/clerk_config.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém a chave do Clerk (.env ou configuração padrão)
    // Verifica se dotenv foi inicializado antes de acessar
    String? envKey;
    try {
      if (dotenv.isInitialized) {
        envKey = dotenv.env['CLERK_PUBLISHABLE_KEY'];
      }
    } catch (e) {
      // dotenv não inicializado, usar configuração padrão
      envKey = null;
    }
    
    final clerkKey = ClerkConfig.getPublishableKey(envKey);
    
    // Verifica se a chave está configurada corretamente
    final isKeyValid = clerkKey.startsWith('pk_test_') || clerkKey.startsWith('pk_live_');
    
    if (!isKeyValid) {
      debugPrint('❌ ERRO: Chave Clerk inválida!');
      debugPrint('A chave deve começar com pk_test_ ou pk_live_');
      debugPrint('Chave atual: ${clerkKey.substring(0, 20)}...');
      debugPrint('Configure em lib/core/constants/clerk_config.dart ou .env');
      
      // Retorna app com tela de erro
      return MaterialApp(
        title: 'Boteco PRO',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Configuração Necessária',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'A chave Clerk não está configurada corretamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Configure sua Publishable Key do Clerk em:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. lib/core/constants/clerk_config.dart'),
                        Text('   ou'),
                        Text('2. Arquivo .env na raiz do projeto'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Obtenha sua chave em:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const SelectableText(
                    'https://dashboard.clerk.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Tenta inicializar o Clerk com tratamento de erro
    try {
      return ClerkAuth(
        config: ClerkAuthConfig(publishableKey: clerkKey),
        child: ClerkErrorListener(
          child: ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              // Quando autenticado, roteia para dashboard e habilita rotas protegidas
              debugPrint('✅ Usuário autenticado: ${authState.user?.id ?? 'desconhecido'}');
              return MaterialApp(
                title: 'Boteco PRO',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
                initialRoute: '/dashboard',
                routes: {
                  '/login': (context) => const LoginPage(),
                  '/dashboard': (context) => const MainNavigationScreen(),
                  '/profile': (context) => const ProfilePage(),
                },
              );
            },
            signedOutBuilder: (context, authState) {
              // Quando deslogado, roteia para /login e restringe acesso às rotas protegidas
              debugPrint('ℹ️ Usuário não autenticado - redirecionando para /login');
              return MaterialApp(
                title: 'Boteco PRO',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
                initialRoute: '/login',
                onGenerateRoute: (settings) {
                  // Em estado signed-out, qualquer rota cai no /login
                  return MaterialPageRoute(builder: (_) => const LoginPage());
                },
              );
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Clerk: $e');
      
      // Fallback: retorna app com tela de erro
      return MaterialApp(
        title: 'Boteco PRO',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Erro ao Inicializar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verifique se sua chave Clerk está correta.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
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
