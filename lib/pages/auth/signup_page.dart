import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../../l10n/l10n.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você precisa aceitar os termos de uso para continuar'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUpWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (success && mounted) {
        // Registration was successful, navigate back to login
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Você já pode fazer login.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.signUpTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Header
                const SizedBox(height: 100),
                const SizedBox(height: 16),
                Text(
                  context.l10n.signUpTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: botecoWine,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                const SizedBox(height: 8),
                Text(
                  context.l10n.signUpSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                const SizedBox(height: 32),
                
                // Signup Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: context.l10n.nameLabel,
                          hintText: context.l10n.nameHint,
                          prefixIcon: const Icon(Icons.person_outline, color: botecoWine),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.nameEmpty;
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideX(
                        begin: 0.2, 
                        end: 0,
                        curve: Curves.easeOutQuad,
                        duration: 800.ms
                      ),
                      const SizedBox(height: 16),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: context.l10n.emailLabel,
                          hintText: context.l10n.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined, color: botecoWine),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.emailEmpty;
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return context.l10n.emailInvalid;
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideX(
                        begin: 0.2, 
                        end: 0,
                        curve: Curves.easeOutQuad,
                        duration: 800.ms
                      ),
                      const SizedBox(height: 16),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: context.l10n.passwordLabel,
                          hintText: context.l10n.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline, color: botecoWine),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.passwordEmpty;
                          }
                          if (value.length < 6) {
                            return context.l10n.passwordLength;
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideX(
                        begin: 0.2, 
                        end: 0,
                        curve: Curves.easeOutQuad,
                        duration: 800.ms
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirm Password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: context.l10n.confirmPasswordLabel,
                          hintText: context.l10n.confirmPasswordHint,
                          prefixIcon: const Icon(Icons.lock_outline, color: botecoWine),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: _toggleConfirmPasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.confirmPasswordEmpty;
                          }
                          if (value != _passwordController.text) {
                            return context.l10n.passwordsNotMatch;
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideX(
                        begin: 0.2, 
                        end: 0,
                        curve: Curves.easeOutQuad,
                        duration: 800.ms
                      ),
                      const SizedBox(height: 16),
                      
                      // Terms and conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: botecoWine,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: context.l10n.acceptTerms,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: context.l10n.termsOfUse,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: botecoWine,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: context.l10n.and,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: context.l10n.privacyPolicy,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: botecoWine,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                      
                      const SizedBox(height: 24),
                      
                      // Sign Up Button
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: botecoWine,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                context.l10n.signUpButton,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ).animate().fadeIn(delay: 1000.ms, duration: 600.ms).scale(
                        delay: 1000.ms,
                        duration: 600.ms,
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutQuad
                      ),
                      
                      // Error message if any
                      if (authProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            authProvider.error!,
                            style: TextStyle(color: Colors.red[700], fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().shake(delay: 100.ms),
                      
                      const SizedBox(height: 24),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              context.l10n.orContinueWith,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                        ],
                      ).animate().fadeIn(delay: 1100.ms, duration: 600.ms),
                      
                      const SizedBox(height: 24),
                      
                      // Google Sign Up Button
                      OutlinedButton(
                        onPressed: authProvider.isLoading ? null : _signUpWithGoogle,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_g_logo.svg',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.continueWithGoogle,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 1200.ms, duration: 600.ms).slideY(
                        begin: 0.2, 
                        end: 0,
                        curve: Curves.easeOutQuad,
                        duration: 800.ms
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.alreadyHaveAccount,
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        context.l10n.loginLink,
                        style: textTheme.bodyMedium?.copyWith(
                          color: botecoWine,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1300.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}