# Guia de Configuração do Supabase - BotecoPro

Este guia explica como configurar e usar o Supabase para gerenciamento de usuários no BotecoPro.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Configuração Inicial](#configuração-inicial)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Uso do Serviço de Autenticação](#uso-do-serviço-de-autenticação)
- [Migrando de SharedPreferences para Supabase](#migrando-de-sharedpreferences-para-supabase)
- [Próximos Passos](#próximos-passos)

## 🎯 Visão Geral

O BotecoPro agora inclui integração com Supabase para gerenciamento de usuários e autenticação. O Supabase é uma alternativa open-source ao Firebase que fornece:

- ✅ Autenticação de usuários (email/senha, OAuth)
- ✅ Banco de dados PostgreSQL
- ✅ Storage de arquivos
- ✅ Realtime subscriptions
- ✅ Edge Functions

## 📦 Pré-requisitos

### 1. Conta Supabase

Crie uma conta gratuita em [https://supabase.com](https://supabase.com)

### 2. Criar Projeto no Supabase

1. Acesse o [Dashboard do Supabase](https://app.supabase.com)
2. Clique em "New Project"
3. Preencha as informações:
   - **Nome do Projeto**: BotecoPro
   - **Database Password**: Escolha uma senha forte
   - **Região**: Escolha a região mais próxima (ex: South America - São Paulo)
4. Clique em "Create new project"

### 3. Obter Credenciais

Após criar o projeto:

1. Vá para **Settings** → **API**
2. Copie as seguintes informações:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Project API Key (anon public)**: `eyJhbGc...`

## ⚙️ Configuração Inicial

### 1. Configurar Variáveis de Ambiente

O projeto já inclui o arquivo `.env.example`. Siga estes passos:

```bash
# 1. Copie o arquivo de exemplo
cp .env.example .env

# 2. Edite o arquivo .env e adicione suas credenciais
```

Conteúdo do arquivo `.env`:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **IMPORTANTE**: O arquivo `.env` está no `.gitignore` e **nunca deve ser commitado** ao repositório.

### 2. Dependências

As dependências já foram adicionadas ao `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  flutter_dotenv: ^5.1.0
```

Instale as dependências:

```bash
flutter pub get
```

### 3. Inicialização

O Supabase é inicializado automaticamente no `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}
```

## 🏗️ Estrutura do Projeto

### Serviço de Autenticação

O projeto inclui `SupabaseAuthService` em `lib/services/supabase_auth_service.dart`:

```dart
import 'package:boteco_pro/services/supabase_auth_service.dart';

final authService = SupabaseAuthService();

// Verificar se usuário está autenticado
bool isLoggedIn = authService.isAuthenticated;

// Obter usuário atual
User? user = authService.currentUser;
```

### Métodos Disponíveis

#### Sign In (Login)

```dart
try {
  final response = await authService.signInWithEmail(
    email: 'usuario@exemplo.com',
    password: 'senha123',
  );
  
  if (response.user != null) {
    print('Login bem-sucedido: ${response.user!.email}');
  }
} catch (e) {
  print('Erro no login: $e');
}
```

#### Sign Up (Registro)

```dart
try {
  final response = await authService.signUpWithEmail(
    email: 'novousuario@exemplo.com',
    password: 'senha123',
    metadata: {
      'nome': 'João Silva',
      'estabelecimento': 'Bar do João',
    },
  );
  
  if (response.user != null) {
    print('Registro bem-sucedido!');
  }
} catch (e) {
  print('Erro no registro: $e');
}
```

#### Sign Out (Logout)

```dart
try {
  await authService.signOut();
  print('Logout realizado com sucesso');
} catch (e) {
  print('Erro no logout: $e');
}
```

#### Reset Password

```dart
try {
  await authService.resetPassword('usuario@exemplo.com');
  print('Email de recuperação enviado');
} catch (e) {
  print('Erro ao enviar email: $e');
}
```

#### Monitorar Estado de Autenticação

```dart
authService.authStateChanges.listen((AuthState state) {
  switch (state.event) {
    case AuthChangeEvent.signedIn:
      print('Usuário logado: ${state.session?.user.email}');
      break;
    case AuthChangeEvent.signedOut:
      print('Usuário deslogado');
      break;
    case AuthChangeEvent.tokenRefreshed:
      print('Token renovado');
      break;
    default:
      break;
  }
});
```

## 🔐 Configuração de Autenticação no Supabase

### 1. Habilitar Provedores de Autenticação

No Dashboard do Supabase:

1. Vá para **Authentication** → **Providers**
2. Habilite os provedores desejados:
   - ✅ **Email** (habilitado por padrão)
   - ⚪ **Google** (requer configuração OAuth)
   - ⚪ **Apple** (requer configuração OAuth)
   - ⚪ Outros...

### 2. Configurar Email Templates

Personalize os emails de autenticação:

1. Vá para **Authentication** → **Email Templates**
2. Personalize:
   - Confirm signup
   - Magic link
   - Change email address
   - Reset password

### 3. Configurar URL Redirect

Para aplicativos móveis/web:

1. Vá para **Authentication** → **URL Configuration**
2. Adicione suas URLs:
   - **Site URL**: `https://seu-dominio.com`
   - **Redirect URLs**: URLs permitidas após login

## 📊 Estrutura do Banco de Dados

### Tabela de Usuários (auth.users)

Criada automaticamente pelo Supabase. Campos principais:

- `id` (UUID): ID único do usuário
- `email`: Email do usuário
- `created_at`: Data de criação
- `user_metadata`: Metadados personalizados (JSONB)

### Criando Tabelas Personalizadas

Exemplo de tabela para vincular usuários aos estabelecimentos:

```sql
-- Criar tabela de estabelecimentos
CREATE TABLE public.estabelecimentos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  endereco TEXT,
  telefone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar Row Level Security
ALTER TABLE public.estabelecimentos ENABLE ROW LEVEL SECURITY;

-- Política: usuários só veem seus próprios estabelecimentos
CREATE POLICY "Users can view own estabelecimento"
  ON public.estabelecimentos
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: usuários só podem inserir para si mesmos
CREATE POLICY "Users can insert own estabelecimento"
  ON public.estabelecimentos
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: usuários só podem atualizar seus próprios
CREATE POLICY "Users can update own estabelecimento"
  ON public.estabelecimentos
  FOR UPDATE
  USING (auth.uid() = user_id);
```

## 🔄 Migrando de SharedPreferences para Supabase

### Estratégia de Migração

1. **Manter SharedPreferences para cache local**
2. **Usar Supabase como fonte de verdade**
3. **Sincronizar dados entre local e remoto**

### Exemplo: DatabaseService Híbrido

```dart
class DatabaseService {
  final SupabaseAuthService _auth = SupabaseAuthService();
  
  // Salvar produto localmente E remotamente
  Future<void> saveProduct(Product product) async {
    // 1. Salvar localmente (cache)
    await _saveProductLocally(product);
    
    // 2. Se autenticado, salvar no Supabase
    if (_auth.isAuthenticated) {
      await _saveProductRemotely(product);
    }
  }
  
  Future<void> _saveProductLocally(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    // ... código existente de SharedPreferences
  }
  
  Future<void> _saveProductRemotely(Product product) async {
    await Supabase.instance.client
      .from('products')
      .upsert({
        'id': product.id,
        'user_id': _auth.currentUser!.id,
        'name': product.name,
        'price': product.price,
        // ... outros campos
      });
  }
}
```

## 🎨 Criando Telas de Autenticação

### Tela de Login (Exemplo)

```dart
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (response.user != null && mounted) {
        // Navegar para a tela principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## 🚀 Próximos Passos

### 1. Implementar Telas de Autenticação
- [ ] Tela de login
- [ ] Tela de registro
- [ ] Tela de recuperação de senha
- [ ] Tela de perfil do usuário

### 2. Integrar com DatabaseService
- [ ] Modificar DatabaseService para suportar Supabase
- [ ] Implementar sincronização local/remoto
- [ ] Adicionar suporte offline

### 3. Configurar Row Level Security (RLS)
- [ ] Criar políticas de acesso para cada tabela
- [ ] Garantir que usuários só vejam seus próprios dados
- [ ] Testar políticas de segurança

### 4. Implementar Features Avançadas
- [ ] Login social (Google, Apple)
- [ ] Upload de imagens (avatares, logos)
- [ ] Notificações push
- [ ] Realtime updates

## 📚 Recursos Adicionais

- [Documentação Oficial do Supabase](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart)
- [Upgrade Guide](https://supabase.com/docs/reference/dart/upgrade-guide)
- [Tutorial Flutter + Supabase](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)

## ⚠️ Segurança

### Boas Práticas

1. **Nunca commite credenciais**
   - Sempre use `.env` para credenciais
   - Mantenha `.env` no `.gitignore`
   - Use `.env.example` para documentar variáveis necessárias

2. **Use Row Level Security (RLS)**
   - Habilite RLS em todas as tabelas
   - Crie políticas específicas por operação
   - Teste políticas antes de produção

3. **Valide no Frontend E Backend**
   - Validação de email
   - Força de senha
   - Políticas de RLS no Supabase

4. **Gerencie Tokens Adequadamente**
   - Tokens são renovados automaticamente
   - Implemente refresh token logic
   - Trate expiração de sessão

## 🐛 Troubleshooting

### Erro: "Invalid API Key"
- Verifique se copiou a chave correta do Dashboard
- Use a chave **anon/public**, não a **service_role**

### Erro: "Unable to load .env"
- Certifique-se que o arquivo `.env` existe na raiz
- Verifique se adicionou `assets: - .env` no `pubspec.yaml`

### Erro de CORS em Web
- Configure URLs permitidas no Supabase Dashboard
- Adicione sua URL de desenvolvimento (ex: `http://localhost:5000`)

### Problemas de Autenticação
- Verifique logs no Dashboard do Supabase → Logs
- Teste com usuário criado manualmente no Dashboard
- Confirme que email está habilitado em Providers

---

**BotecoPro + Supabase - Gestão de bar com autenticação profissional!** 🍻
