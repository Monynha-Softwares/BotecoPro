

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/tables_page.dart';
import 'pages/products_page.dart';
import 'pages/recipes_page.dart';
import 'pages/production_page.dart';
import 'pages/orders_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/app_drawer.dart';
import 'services/service_provider.dart';
import 'services/theme_provider.dart';
import 'services/user_provider.dart';
import 'services/sound_provider.dart';

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
  
  // We'll initialize the sound service through the provider

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ServiceProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SoundProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Boteco PRO',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
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
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
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
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
            const SizedBox(height: 24),
            Text(
              'Boteco PRO',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 800), curve: Curves.easeIn),
            const SizedBox(height: 8),
            Text(
              'Gestão completa para seu bar',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
            )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 800)),
            const SizedBox(height: 48),
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated circle
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                    strokeWidth: 3,
                  ),
                  // Custom design inside the circle
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: const Duration(seconds: 2)),            
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

  final Map<NavigationTab, Widget> _screens = {
    NavigationTab.home: const HomePage(),
    NavigationTab.tables: const TablesPage(),
    NavigationTab.products: const ProductsPage(),
    NavigationTab.reports: const OrdersPage(),
    NavigationTab.settings: const SettingsPage(),
  };

  void _selectTab(NavigationTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: _screens[_currentTab] ?? const HomePage(),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onTabSelected: _selectTab,
      ),
    );
  }
}