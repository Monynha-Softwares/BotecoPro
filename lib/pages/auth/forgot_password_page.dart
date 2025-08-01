import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../../l10n/l10n.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success =
          await authProvider.resetPassword(context, _emailController.text.trim());
      
      if (success) {
        setState(() {
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.forgotPasswordTitle),
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
            child: _emailSent ? _buildEmailSentSuccess() : _buildResetPasswordForm(authProvider, textTheme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm(AuthProvider authProvider, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 120),
        const SizedBox(height: 24),
        Text(
          context.l10n.forgotPasswordTitle,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: botecoWine,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        const SizedBox(height: 16),
        Text(
          context.l10n.forgotPasswordMessage,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        const SizedBox(height: 32),

        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideX(
                begin: 0.2, 
                end: 0,
                curve: Curves.easeOutQuad,
                duration: 800.ms
              ),
              const SizedBox(height: 24),

              // Send Reset Link Button
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _resetPassword,
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
                        context.l10n.sendResetLink,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).scale(
                delay: 600.ms,
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
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.rememberPassword,
              style: textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.backToLogin,
                style: textTheme.bodyMedium?.copyWith(
                  color: botecoWine,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildEmailSentSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: botecoWine,
        ).animate()
          .scale(duration: 400.ms, curve: Curves.easeOut)
          .then(delay: 200.ms)
          .shake(duration: 700.ms, curve: Curves.easeInOut),
        const SizedBox(height: 24),
        Text(
          context.l10n.emailSentTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: botecoWine,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        const SizedBox(height: 16),
        Text(
          context.l10n.emailSentMessage(_emailController.text),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        const SizedBox(height: 16),
        Text(
          context.l10n.checkSpam,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: botecoWine,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.arrow_back),
          label: Text(context.l10n.backToLogin),
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(
          begin: 0.2, 
          end: 0,
          curve: Curves.easeOutQuad,
          duration: 600.ms
        ),
      ],
    );
  }
}