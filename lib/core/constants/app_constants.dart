// lib/core/constants/app_constants.dart

/// Constantes globais do aplicativo BotecoPro
///
/// Centraliza todas as strings mágicas, chaves de storage,
/// valores de configuração e outras constantes usadas no app.

class AppConstants {
  // Previne instanciação
  AppConstants._();

  // ==================== STORAGE KEYS ====================
  
  /// Chaves do SharedPreferences para persistência local
  static const String authUserKey = 'auth_user';
  static const String suppliersKey = 'suppliers';
  static const String productsKey = 'products';
  static const String tablesKey = 'tables';
  static const String ordersKey = 'orders';
  static const String salesKey = 'sales';
  static const String recipesKey = 'recipes';
  static const String productionsKey = 'productions';

  // ==================== APP INFO ====================
  
  static const String appName = 'Boteco PRO';
  static const String appTagline = 'Gestão completa para seu bar';
  static const String appVersion = '1.0.0';

  // ==================== NAVIGATION ====================
  
  static const int bottomNavHomeIndex = 0;
  static const int bottomNavTablesIndex = 1;
  static const int bottomNavProductsIndex = 2;
  static const int bottomNavRecipesIndex = 3;
  static const int bottomNavProductionIndex = 4;

  // ==================== VALIDATION ====================
  
  /// Comprimento mínimo de senha
  static const int minPasswordLength = 6;
  
  /// Comprimento mínimo de nome
  static const int minNameLength = 3;
  
  /// Comprimento de telefone brasileiro (com DDD)
  static const int phoneLength = 11;

  // ==================== UI CONFIG ====================
  
  /// Breakpoint para layout desktop (pixels)
  static const double desktopBreakpoint = 800.0;
  
  /// Duração padrão de animações
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  /// Duração de splash screen
  static const Duration splashDuration = Duration(seconds: 2);
  
  /// Raio de borda padrão para cards e inputs
  static const double defaultBorderRadius = 12.0;
  
  /// Padding padrão
  static const double defaultPadding = 16.0;

  // ==================== API / NETWORK ====================
  
  /// Timeout para requisições HTTP
  static const Duration networkTimeout = Duration(seconds: 30);
  
  /// Número de tentativas para retry
  static const int maxRetries = 3;

  // ==================== BUSINESS RULES ====================
  
  /// Número máximo de itens por pedido
  static const int maxOrderItems = 50;
  
  /// Número máximo de mesas
  static const int maxTables = 100;
  
  /// Quantidade mínima de estoque para alerta
  static const int minStockAlert = 10;

  // ==================== DATE FORMATS ====================
  
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String locale = 'pt_BR';

  // ==================== ERROR MESSAGES ====================
  
  static const String networkErrorMessage = 
      'Erro de conexão. Verifique sua internet.';
  static const String genericErrorMessage = 
      'Ocorreu um erro. Tente novamente.';
  static const String authErrorMessage = 
      'Erro de autenticação. Faça login novamente.';
  static const String permissionErrorMessage = 
      'Você não tem permissão para esta ação.';

  // ==================== SUCCESS MESSAGES ====================
  
  static const String loginSuccessMessage = 'Login realizado com sucesso!';
  static const String logoutSuccessMessage = 'Logout realizado com sucesso!';
  static const String signupSuccessMessage = 'Cadastro realizado com sucesso!';
  static const String saveSuccessMessage = 'Salvo com sucesso!';
  static const String deleteSuccessMessage = 'Excluído com sucesso!';
  static const String updateSuccessMessage = 'Atualizado com sucesso!';

  // ==================== FEATURE FLAGS ====================
  
  /// Habilitar Firebase Auth (vs fallback local)
  static const bool useFirebaseAuth = true;
  
  /// Habilitar modo debug
  static const bool isDebugMode = true;
  
  /// Habilitar analytics
  static const bool enableAnalytics = false;

  // ==================== ASSETS ====================
  
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';

  // ==================== URLS ====================
  
  static const String privacyPolicyUrl = 'https://boteco-pro.com/privacy';
  static const String termsOfServiceUrl = 'https://boteco-pro.com/terms';
  static const String supportEmail = 'suporte@boteco-pro.com';
}

/// Constantes de cores do tema (referência rápida)
class AppColors {
  AppColors._();

  // Cores principais do tema Boteco
  static const int primaryWine = 0xFF8B1E3F;
  static const int secondaryMustard = 0xFFF2C14E;
  static const int tertiaryBeige = 0xFFF78154;
  static const int surfaceLight = 0xFFF5E6D3;
}

/// Constantes de ícones
class AppIcons {
  AppIcons._();

  // Ícones personalizados (se houver)
  static const String customIcon = 'assets/icons/custom.svg';
}
