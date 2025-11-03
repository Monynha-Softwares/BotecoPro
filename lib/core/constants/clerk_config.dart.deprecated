// lib/core/constants/clerk_config.dart

/// ClerkConfig - Configuração de autenticação Clerk
///
/// INSTRUÇÕES DE USO:
///
/// 1. Obtenha sua Publishable Key no dashboard.clerk.com:
///    - Navegue para o seu projeto
///    - Acesse "API Keys"
///    - Copie a "Publishable Key" (começa com pk_test_ ou pk_live_)
///
/// 2. OPÇÃO A - Uso direto (apenas para testes locais):
///    Substitua o valor abaixo diretamente
///
/// 3. OPÇÃO B - Uso com .env (recomendado para produção):
///    - Crie um arquivo .env na raiz do projeto
///    - Adicione: CLERK_PUBLISHABLE_KEY=pk_test_seu_valor_aqui
///    - Carregue com flutter_dotenv no main.dart
///    - Use: dotenv.env['CLERK_PUBLISHABLE_KEY']
///
/// 4. SEGURANÇA:
///    - NUNCA commite chaves reais no repositório
///    - Adicione .env ao .gitignore
///    - Use variáveis de ambiente em CI/CD
///
/// EXEMPLO DE INTEGRAÇÃO NO main.dart:
/// ```dart
/// import 'package:flutter_dotenv/flutter_dotenv.dart';
/// import 'core/constants/clerk_config.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Carregar variáveis de ambiente (opcional)
///   await dotenv.load(fileName: ".env");
///   
///   runApp(const MyApp());
/// }
///
/// // Usar na configuração do Clerk:
/// ClerkAuth(
///   config: ClerkAuthConfig(
///     publishableKey: ClerkConfig.publishableKey,
///   ),
///   // ...
/// )
/// ```

class ClerkConfig {
  /// Publishable Key do Clerk
  /// 
  /// Para desenvolvimento: substitua com sua chave de teste
  /// Para produção: carregue de variáveis de ambiente
  static const String publishableKey = 'pk_test_c3Ryb25nLXF1ZXR6YWwtMTUuY2xlcmsuYWNjb3VudHMuZGV2JA';
  
  /// Verifica se a chave foi configurada corretamente
  static bool get isConfigured => 
      publishableKey != 'pk_test_PLACEHOLDER_REPLACE_WITH_YOUR_KEY' &&
      publishableKey.isNotEmpty;
  
  /// Obtém a chave de ambiente (.env) se disponível
  /// Caso contrário, retorna a chave padrão
  /// 
  /// Requer flutter_dotenv carregado no main.dart
  static String getPublishableKey([String? envKey]) {
    // Se fornecido uma chave do .env, use-a
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    
    // Caso contrário, use a chave estática
    return publishableKey;
  }
}
