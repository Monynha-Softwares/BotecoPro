import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../main.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      _showSnack(authProvider.lastError ?? 'Não foi possível iniciar a sessão.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainNavigationScreen()),
    );
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Informe um email válido para solicitar a recuperação.');
      return;
    }

    await context.read<AuthProvider>().sendPasswordReset(email);
    if (!mounted) {
      return;
    }

    _showSnack(
      'Solicitação registrada localmente. Conecte o backend para enviar emails reais.',
      isError: false,
    );
  }

  void _showSnack(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final formCard = _LoginCard(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              isLoading: auth.isLoading,
              onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
              onLogin: _handleLogin,
              onForgotPassword: _handlePasswordReset,
            );

            if (!isWide) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: formCard,
                ),
              );
            }

            return Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Monynha Softwares',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'BotecoPro para uma operação de bar mais estável, rastreável e pronta para sincronização.',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sessão local preparada para futura autenticação com Supabase ou FastAPI. Nada de endpoints hardcoded na UI.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.84),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: const <Widget>[
                            _BrandChip(label: 'Mesas e comandas'),
                            _BrandChip(label: 'Produtos e estoque'),
                            _BrandChip(label: 'Receitas e produção'),
                            _BrandChip(label: 'Base pronta para sync'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: formCard,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.sports_bar_rounded,
                  size: 72,
                  color: theme.colorScheme.primary,
                ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
                const SizedBox(height: 20),
                Text(
                  'Entrar no BotecoPro',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestão operacional com identidade Monynha e base preparada para backend seguro.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'operacao@seuboteco.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o email de acesso';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Digite um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Mínimo de 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : onForgotPassword,
                    child: const Text('Esqueci minha senha'),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: isLoading ? null : onLogin,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login_rounded),
                  label: Text(isLoading ? 'Entrando...' : 'Acessar painel'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const SignupPage()),
                          );
                        },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Criar conta local'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ao entrar, você usa o fluxo local preparado para futura autenticação real.',
                  style: theme.textTheme.bodySmall,
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

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.check_circle_rounded, size: 18),
      side: BorderSide.none,
      backgroundColor: Colors.white.withOpacity(0.16),
      labelStyle: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      avatarBoxConstraints: const BoxConstraints(minHeight: 18, minWidth: 18),
    );
  }
}
