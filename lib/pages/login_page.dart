import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // Navigate to home and remove all previous routes
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais inválidas. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    Icon(
                      Icons.sports_bar,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .scale(),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Boteco PRO',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 600)),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Gestão completa para seu bar',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 600)),
                    const SizedBox(height: 48),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'seu@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 600))
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 4) {
                          return 'Senha deve ter no mínimo 4 caracteres';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(
                            delay: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 600))
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 24),

                    // Login button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                        .animate()
                        .fadeIn(
                            delay: const Duration(milliseconds: 600),
                            duration: const Duration(milliseconds: 600))
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),

                    // Demo credentials info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Demo MVP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Use qualquer email e senha (mín. 4 caracteres)',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                            delay: const Duration(milliseconds: 700),
                            duration: const Duration(milliseconds: 600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
