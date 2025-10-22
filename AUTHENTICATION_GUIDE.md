# 🔐 Guia de Autenticação - BotecoPro

## Visão Geral

O BotecoPro agora inclui um sistema de autenticação simples baseado em sessão local. Este guia explica como o sistema funciona e como usá-lo.

## Fluxo de Autenticação

### 1. Splash Screen (Inicialização)
```
Usuário abre o app
    ↓
SplashScreen verifica estado de autenticação
    ↓
Se logado → MainNavigationScreen (Home)
Se não logado → LoginPage
```

### 2. Login
```
Usuário entra email e senha
    ↓
AuthService.login() valida credenciais
    ↓
Salva sessão em SharedPreferences
    ↓
Navega para MainNavigationScreen
```

### 3. Logout
```
Usuário clica no botão Logout (ícone no AppBar da Home)
    ↓
Dialog de confirmação
    ↓
AuthService.logout() limpa sessão
    ↓
Remove todas as rotas e navega para LoginPage
```

## Arquivos do Sistema de Autenticação

### `lib/services/auth_service.dart`
Serviço singleton que gerencia o estado de autenticação:

```dart
// Verificar se está logado
final isLoggedIn = await authService.isLoggedIn();

// Fazer login
final success = await authService.login(email, password);

// Obter nome do usuário
final userName = await authService.getUserName();

// Fazer logout
await authService.logout();
```

**Armazenamento:**
- `is_logged_in`: Boolean indicando estado de login
- `user_name`: Nome extraído do email
- `user_email`: Email do usuário

### `lib/pages/login_page.dart`
Tela de login com:
- Campo de email com validação
- Campo de senha com toggle de visibilidade
- Validação de formulário
- Animações de entrada
- Informações sobre credenciais de demo

### `lib/main.dart`
Configuração de rotas e navegação:
```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginPage(),
  '/home': (context) => const MainNavigationScreen(),
}
```

## Credenciais de Demo (MVP)

Para o MVP, **qualquer** combinação de email/senha é aceita:

**Requisitos mínimos:**
- Email: deve conter `@`
- Senha: mínimo 4 caracteres

**Exemplos:**
```
Email: admin@boteco.com
Senha: 1234
```

```
Email: gerente@bar.com
Senha: senha123
```

⚠️ **Importante**: Este é um sistema de autenticação MVP simplificado para demonstração. Em produção, você deve implementar:
- Validação de credenciais reais
- Hashing de senhas
- Tokens de sessão
- Backend de autenticação
- OAuth/Firebase Auth

## Proteção de Rotas

### Rotas Protegidas
Todas as funcionalidades principais estão protegidas pela verificação de autenticação no SplashScreen:

- ✅ Home/Dashboard
- ✅ Mesas
- ✅ Produtos
- ✅ Receitas
- ✅ Produção
- ✅ Fornecedores

### Rotas Públicas
- `/` - SplashScreen (redireciona baseado em auth)
- `/login` - LoginPage

## Navegação e Botão Voltar

### Comportamento do Botão Voltar

**Em páginas secundárias (com CustomAppBar):**
- Verifica se pode fazer `pop()` antes de tentar
- Previne navegação para páginas em branco
- Suporte para callback customizado via `onBackPressed`

**Na navegação principal:**
- Se não está na aba Home → volta para Home
- Se está na Home → mostra dialog de confirmação para sair
- Usa `PopScope` para controle fino do comportamento

### Exemplo: Navegação Segura
```dart
// CustomAppBar automaticamente verifica canPop
CustomAppBar(
  title: 'Detalhes',
  showBackButton: true,
)

// Ou com callback customizado
CustomAppBar(
  title: 'Detalhes',
  showBackButton: true,
  onBackPressed: () {
    // Lógica customizada antes de voltar
    Navigator.of(context).pop();
  },
)
```

## Persistência de Sessão

A sessão persiste entre:
- ✅ Fechamento e reabertura do app
- ✅ Recarregamento da página (web)
- ✅ Mudanças de aba (web)

A sessão é limpa quando:
- ❌ Usuário faz logout explícito
- ❌ Dados do localStorage são limpos

## Integração com Páginas Existentes

### HomePage
```dart
// Exibe nome do usuário na saudação
'Bom dia, $_userName'

// Botão de logout no AppBar
IconButton(
  icon: Icon(Icons.logout),
  onPressed: _handleLogout,
)
```

### Outras Páginas
Não precisam de mudanças - o acesso já está protegido pela verificação inicial no SplashScreen.

## Fluxo de Dados

```
┌─────────────────────────────────────────────────────┐
│              App Initialization                     │
├─────────────────────────────────────────────────────┤
│  main() → MyApp → SplashScreen                     │
│     ↓                                               │
│  AuthService.isLoggedIn()                          │
│     ↓                                               │
│  SharedPreferences.getBool('is_logged_in')         │
│     ↓                                               │
│  true? → /home    false? → /login                  │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                Login Flow                           │
├─────────────────────────────────────────────────────┤
│  LoginPage: usuário preenche formulário            │
│     ↓                                               │
│  Validação local (email @ / senha >= 4 chars)      │
│     ↓                                               │
│  AuthService.login(email, password)                │
│     ↓                                               │
│  SharedPreferences.setBool('is_logged_in', true)   │
│  SharedPreferences.setString('user_email', email)  │
│  SharedPreferences.setString('user_name', name)    │
│     ↓                                               │
│  Navigator.pushReplacementNamed('/home')           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│               Logout Flow                           │
├─────────────────────────────────────────────────────┤
│  HomePage: usuário clica logout                    │
│     ↓                                               │
│  Confirma no dialog                                │
│     ↓                                               │
│  AuthService.logout()                              │
│     ↓                                               │
│  SharedPreferences.setBool('is_logged_in', false)  │
│  SharedPreferences.remove('user_email')            │
│  SharedPreferences.remove('user_name')             │
│     ↓                                               │
│  Navigator.pushNamedAndRemoveUntil('/login')       │
└─────────────────────────────────────────────────────┘
```

## Teste do Fluxo Completo

### 1. Teste de Login
```bash
1. Abrir app → deve mostrar SplashScreen
2. Após 2s → redireciona para LoginPage (primeira vez)
3. Inserir qualquer email válido e senha (min 4 chars)
4. Clicar "Entrar"
5. ✅ Deve navegar para Home com nome de usuário
```

### 2. Teste de Sessão Persistente
```bash
1. Fazer login
2. Fechar navegador/app completamente
3. Reabrir
4. ✅ Deve mostrar SplashScreen e ir direto para Home (sem pedir login)
```

### 3. Teste de Logout
```bash
1. Na Home, clicar no ícone de logout (canto superior direito)
2. Confirmar no dialog
3. ✅ Deve retornar para LoginPage
4. ✅ Ao reabrir app, deve pedir login novamente
```

### 4. Teste de Navegação
```bash
1. Fazer login → chegar na Home
2. Clicar em "Fornecedores" → abre nova página
3. Clicar botão voltar
4. ✅ Deve voltar para Home (não página em branco)
5. Na navegação bottom/rail, mudar entre abas
6. Pressionar botão voltar do navegador
7. ✅ Deve voltar para aba Home (não sair do app)
8. Pressionar botão voltar novamente na Home
9. ✅ Deve mostrar dialog "Sair do aplicativo?"
```

## Próximos Passos (Produção)

Para evoluir este sistema para produção:

1. **Backend de Autenticação**
   - Implementar API de login/registro
   - Validar credenciais no servidor
   - Usar JWT ou OAuth tokens

2. **Segurança**
   - Hash de senhas (bcrypt, argon2)
   - HTTPS obrigatório
   - Proteção contra brute-force
   - Rate limiting

3. **Funcionalidades Adicionais**
   - Recuperação de senha
   - Registro de novos usuários
   - Perfis de usuário
   - Permissões/roles (admin, garçom, gerente)
   - Autenticação multifator (2FA)

4. **Integração**
   - Firebase Authentication
   - Auth0
   - Supabase Auth
   - Custom backend (Node.js, Python, Go)

## Suporte

Para dúvidas sobre autenticação:
- Veja `lib/services/auth_service.dart` para lógica de sessão
- Veja `lib/pages/login_page.dart` para UI de login
- Veja `lib/main.dart` para rotas e fluxo inicial

---

**Versão**: 1.1.0  
**Data**: Outubro 2025  
**Status**: ✅ Funcional (MVP Demo)
