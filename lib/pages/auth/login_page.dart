import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import '../../l10n/l10n.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App Name
                  SizedBox(height: screenSize.height * 0.08),
                    Center(
                      child: Text(
                        context.l10n.appName,
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: botecoWine,
                        ),
                      ),
                    ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
                  
                  const SizedBox(height: 12),
                    Center(
                      child: Text(
                        context.l10n.tagline,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600)),
                  
                  SizedBox(height: screenSize.height * 0.06),
                  
                  // Test Account Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: botecoMustard.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: botecoMustard.withOpacity(0.3))
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: botecoMustard),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Conta de Teste",
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: botecoMustard,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Já preenchemos o formulário com uma conta de teste. Basta clicar em 'Entrar'.",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                  
                  const SizedBox(height: 24),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      hintText: "Seu e-mail",
                      prefixIcon: const Icon(Icons.email_outlined, color: botecoWine),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, informe seu e-mail";
                      }
                      if (!value.contains("@") || !value.contains(".")) {
                        return "Por favor, informe um e-mail válido";
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                  
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      hintText: "Sua senha",
                      prefixIcon: const Icon(Icons.lock_outline, color: botecoWine),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: botecoWine,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, informe sua senha";
                      }
                      if (value.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                  
                  const SizedBox(height: 8),
                  
                  // Remember me & Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: botecoWine,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            "Lembrar-me",
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          "Esqueceu a senha?",
                          style: textTheme.bodyMedium?.copyWith(
                            color: botecoWine,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1000)),
                  
                  const SizedBox(height: 24),
                  
                  // Login button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: botecoWine,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Entrar",
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1200)),
                  
                  const SizedBox(height: 16),
                  
                  // Error message
                  if (authProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(),
                  
                  const SizedBox(height: 24),
                  
                  // OR separator
                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1, color: colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OU",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1, color: colorScheme.outline)),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1400)),
                  
                  const SizedBox(height: 24),
                  
                  // Google sign in button
                  OutlinedButton.icon(
                    onPressed: _loginWithGoogle,
                    icon: const Icon(Icons.login, color: botecoMustard),
                    label: Text(
                      "Continuar com Google",
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1600)),
                  
                  const SizedBox(height: 32),
                  
                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Não tem uma conta?",
                        style: textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                          );
                        },
                        child: Text(
                          "Cadastre-se",
                          style: textTheme.bodyLarge?.copyWith(
                            color: botecoWine,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1800)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}