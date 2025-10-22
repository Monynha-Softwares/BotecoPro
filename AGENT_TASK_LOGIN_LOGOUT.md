# Task: Implement Full Login/Logout Flow with Supabase

## 📋 Task Overview

Implement complete authentication flow in the BotecoPro Flutter application using the existing Supabase infrastructure. This includes creating login/signup UI, managing authentication state, and implementing secure logout functionality.

## 🎯 Objectives

1. Create login and signup pages with proper UI/UX
2. Implement authentication state management throughout the app
3. Add logout functionality with proper session cleanup
4. Protect authenticated routes
5. Handle authentication errors gracefully
6. Ensure smooth user experience with loading states

## 📊 Current State Analysis

### ✅ Already Implemented

1. **Supabase Infrastructure**
   - Location: `lib/services/supabase_auth_service.dart`
   - Features: SignIn, SignUp, SignOut, Password Reset, OAuth support
   - Pattern: Singleton service

2. **Environment Configuration**
   - `.env.example` template exists
   - Supabase initialization in `main.dart`
   - Secure credential management via `flutter_dotenv`

3. **App Structure**
   - Main navigation: `MainNavigationScreen` in `main.dart`
   - Bottom navigation: 5 tabs (home, tables, products, recipes, production)
   - Splash screen with 2-second delay
   - Theme: Portuguese locale (pt_BR), Boteco-themed colors

### ❌ Not Yet Implemented

1. **Authentication UI**
   - Login page
   - Signup page
   - Password recovery page

2. **Authentication State Management**
   - Auth state listener
   - Protected routes
   - Session persistence check on app start

3. **User Experience**
   - Loading states during auth operations
   - Error handling and user feedback
   - Logout button/option in UI

## 🏗️ Implementation Requirements

### 1. Create Authentication Pages

#### A. Login Page (`lib/pages/auth/login_page.dart`)

**UI Requirements:**
- Email input field (with validation)
- Password input field (with visibility toggle)
- "Login" button (with loading state)
- "Forgot Password?" link
- "Don't have an account? Sign up" link
- Error message display area
- Boteco branding (use app logo/icon)

**Functionality:**
- Form validation (email format, password not empty)
- Call `SupabaseAuthService().signInWithEmail()`
- Handle loading state during authentication
- Display error messages in Portuguese
- Navigate to home on successful login
- Store auth state

**Code Structure:**
```dart
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SupabaseAuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  
  // Implement: _login(), _dispose(), build()
}
```

#### B. Signup Page (`lib/pages/auth/signup_page.dart`)

**UI Requirements:**
- Name/Display name input field
- Email input field (with validation)
- Password input field (min 6 characters, with visibility toggle)
- Confirm password input field
- "Sign Up" button (with loading state)
- "Already have an account? Login" link
- Terms and conditions checkbox (optional)
- Error message display area

**Functionality:**
- Form validation (email format, password match, min length)
- Call `SupabaseAuthService().signUpWithEmail()`
- Handle loading state
- Display error messages in Portuguese
- Navigate to home or email verification page
- Store user metadata if needed

#### C. Password Recovery Page (`lib/pages/auth/forgot_password_page.dart`)

**UI Requirements:**
- Email input field
- "Send Reset Link" button
- Back to login link
- Success message display

**Functionality:**
- Call `SupabaseAuthService().resetPassword()`
- Show success message
- Navigate back to login after 3 seconds

### 2. Implement Auth State Management

#### A. Create Auth Wrapper (`lib/widgets/auth_wrapper.dart`)

**Purpose:** Check authentication state on app start and route accordingly

```dart
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);
  
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = SupabaseAuthService();
  
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }
  
  Future<void> _checkAuthState() async {
    // Check if user is authenticated
    // Route to MainNavigationScreen or LoginPage
  }
  
  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth state
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

#### B. Update Main App Entry Point

**File:** `lib/main.dart`

**Changes Required:**
1. Replace `SplashScreen` navigation with `AuthWrapper`
2. Keep splash screen for branding
3. After splash delay, navigate to AuthWrapper instead of MainNavigationScreen

```dart
// In _SplashScreenState._navigateToHome()
Future<void> _navigateToHome() async {
  await Future.delayed(const Duration(seconds: 2));
  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }
}
```

#### C. Listen to Auth State Changes

**Implementation:** Use Supabase auth state stream

```dart
// In AuthWrapper or a dedicated AuthProvider
StreamSubscription<AuthState>? _authSubscription;

@override
void initState() {
  super.initState();
  _authSubscription = _authService.authStateChanges.listen((AuthState data) {
    final event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      // Navigate to home
    } else if (event == AuthChangeEvent.signedOut) {
      // Navigate to login
    }
  });
}

@override
void dispose() {
  _authSubscription?.cancel();
  super.dispose();
}
```

### 3. Implement Logout Functionality

#### A. Add Logout Option in HomePage

**File:** `lib/pages/home_page.dart`

**Changes Required:**
1. Add logout button/menu item in CustomAppBar
2. Show confirmation dialog before logout
3. Call `SupabaseAuthService().signOut()`
4. Navigate to login page

**Implementation:**
```dart
// In HomePage's CustomAppBar actions
actions: [
  PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'logout') {
        _showLogoutDialog();
      }
    },
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 'logout',
        child: Row(
          children: [
            Icon(Icons.logout),
            SizedBox(width: 8),
            Text('Sair'),
          ],
        ),
      ),
    ],
  ),
],

Future<void> _showLogoutDialog() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sair'),
      content: const Text('Tem certeza que deseja sair?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sair'),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    await _logout();
  }
}

Future<void> _logout() async {
  try {
    await SupabaseAuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  } catch (e) {
    // Show error message
  }
}
```

#### B. Add User Profile Display (Optional Enhancement)

Show current user email/name in home page or app bar

### 4. Error Handling and User Feedback

#### A. Error Messages in Portuguese

Create helper function for translating Supabase errors:

```dart
// lib/utils/auth_error_messages.dart
String getAuthErrorMessage(dynamic error) {
  final errorMessage = error.toString().toLowerCase();
  
  if (errorMessage.contains('invalid login credentials')) {
    return 'Email ou senha incorretos';
  } else if (errorMessage.contains('user already registered')) {
    return 'Este email já está cadastrado';
  } else if (errorMessage.contains('invalid email')) {
    return 'Email inválido';
  } else if (errorMessage.contains('password should be at least')) {
    return 'A senha deve ter pelo menos 6 caracteres';
  } else if (errorMessage.contains('network')) {
    return 'Erro de conexão. Verifique sua internet';
  } else {
    return 'Ocorreu um erro. Tente novamente';
  }
}
```

#### B. Loading States

Use consistent loading indicators:
- Disable form while loading
- Show CircularProgressIndicator in button
- Prevent multiple submissions

#### C. Success Feedback

- Show SnackBar on successful operations
- Auto-navigate after delay on signup confirmation

### 5. UI/UX Specifications

#### Color Scheme (Use Existing Theme)

From `lib/theme.dart`:
- Primary: Wine `#8B1E3F` (buttons, branding)
- Secondary: Mustard (accents)
- Surface: Light beige background
- Text: High contrast for readability

#### Typography

- Use existing theme text styles
- Form labels: `bodyMedium`
- Buttons: `labelLarge`
- Error text: `bodySmall` with error color

#### Layout

- Centered form on mobile
- Maximum width 400px on web
- Consistent padding: 24px
- Form field spacing: 16px
- Use CustomAppBar for consistency

#### Animations

- Use `flutter_animate` for page transitions
- Fade in forms on load
- Smooth error message appearance

### 6. Security Considerations

#### A. Password Requirements

- Minimum 6 characters (Supabase default)
- Show password strength indicator (optional)
- Never log passwords

#### B. Session Management

- Sessions are handled by Supabase automatically
- Tokens stored securely by Supabase client
- Refresh tokens handled automatically

#### C. Email Verification (Optional)

Configure in Supabase dashboard:
- Enable email confirmation
- Customize email templates
- Handle unverified state in app

#### D. Rate Limiting

Supabase provides built-in rate limiting for auth endpoints

### 7. Testing Requirements

#### A. Manual Testing Checklist

- [ ] User can sign up with valid email/password
- [ ] User receives appropriate error for invalid email
- [ ] User receives appropriate error for short password
- [ ] User can log in with correct credentials
- [ ] User receives error for incorrect credentials
- [ ] Password visibility toggle works
- [ ] User can request password reset
- [ ] User can log out successfully
- [ ] Auth state persists across app restarts
- [ ] App routes to login when not authenticated
- [ ] App routes to home when authenticated
- [ ] Loading states display correctly
- [ ] Error messages display in Portuguese
- [ ] Logout confirmation dialog appears
- [ ] All form validations work

#### B. Edge Cases

- [ ] Handle no internet connection
- [ ] Handle Supabase service errors
- [ ] Handle session expiration
- [ ] Handle multiple rapid login attempts
- [ ] Test on web, iOS, and Android

#### C. Screenshot Requirements

Take screenshots of:
1. Login page (empty state)
2. Login page (with validation errors)
3. Login page (loading state)
4. Signup page
5. Forgot password page
6. Home page with logout option
7. Logout confirmation dialog

### 8. Step-by-Step Implementation Guide

#### Step 1: Create Directory Structure
```bash
mkdir -p lib/pages/auth
mkdir -p lib/utils
```

#### Step 2: Create Login Page
1. Create `lib/pages/auth/login_page.dart`
2. Implement form with email/password fields
3. Add validation
4. Implement `_login()` method using `SupabaseAuthService`
5. Add error handling
6. Test manually

#### Step 3: Create Signup Page
1. Create `lib/pages/auth/signup_page.dart`
2. Implement form with name, email, password, confirm password
3. Add validation (password match, email format)
4. Implement `_signup()` method
5. Add error handling
6. Test manually

#### Step 4: Create Password Recovery Page
1. Create `lib/pages/auth/forgot_password_page.dart`
2. Implement email input form
3. Implement `_sendResetEmail()` method
4. Show success message
5. Test manually

#### Step 5: Create Auth Wrapper
1. Create `lib/widgets/auth_wrapper.dart`
2. Check authentication state in `initState()`
3. Route to appropriate page (Login or Main)
4. Listen to auth state changes
5. Test navigation flow

#### Step 6: Update Main.dart
1. Import new auth pages
2. Update splash screen navigation to use `AuthWrapper`
3. Test app startup flow

#### Step 7: Implement Logout
1. Add logout menu option in `home_page.dart`
2. Implement confirmation dialog
3. Call `signOut()` method
4. Navigate to login page
5. Clear navigation stack
6. Test logout flow

#### Step 8: Create Error Message Utility
1. Create `lib/utils/auth_error_messages.dart`
2. Implement `getAuthErrorMessage()` function
3. Add Portuguese translations for common errors
4. Use in all auth pages

#### Step 9: Polish UI
1. Ensure consistent theme usage
2. Add animations using `flutter_animate`
3. Test on different screen sizes
4. Verify Portuguese locale

#### Step 10: Final Testing
1. Run through complete flow
2. Test all edge cases
3. Verify error messages
4. Test session persistence
5. Take required screenshots

### 9. Code Examples

#### Complete Login Page Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/supabase_auth_service.dart';
import '../../utils/auth_error_messages.dart';
import '../../widgets/shared_widgets.dart';
import '../home_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SupabaseAuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = getAuthErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(
                    Icons.sports_bar,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .scale(),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Boteco PRO',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600)),
                  const SizedBox(height: 8),

                  Text(
                    'Faça login para continuar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 600)),
                  const SizedBox(height: 48),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
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
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                            child: const Text('Esqueceu a senha?'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Error message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn()
                              .shake(),
                        if (_errorMessage != null) const SizedBox(height: 16),

                        // Login button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                        const SizedBox(height: 16),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Não tem uma conta?'),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupPage(),
                                        ),
                                      );
                                    },
                              child: const Text('Cadastre-se'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 600),
                          duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 10. Files to Create/Modify

#### New Files to Create:
1. `lib/pages/auth/login_page.dart` - Login UI
2. `lib/pages/auth/signup_page.dart` - Signup UI
3. `lib/pages/auth/forgot_password_page.dart` - Password recovery
4. `lib/widgets/auth_wrapper.dart` - Auth state checker
5. `lib/utils/auth_error_messages.dart` - Error message translator

#### Files to Modify:
1. `lib/main.dart` - Update navigation to use AuthWrapper
2. `lib/pages/home_page.dart` - Add logout functionality

### 11. Success Criteria

The implementation is complete when:

- [ ] User can successfully sign up with email/password
- [ ] User can successfully log in with credentials
- [ ] User can log out and is redirected to login page
- [ ] User can request password reset
- [ ] Authentication state persists across app restarts
- [ ] App shows login page when not authenticated
- [ ] App shows main navigation when authenticated
- [ ] All error messages are in Portuguese
- [ ] Loading states work correctly
- [ ] UI follows Boteco theme
- [ ] Navigation flows are smooth
- [ ] All forms have proper validation
- [ ] Security best practices are followed

### 12. Additional Notes

#### Environment Setup for Testing

Ensure `.env` file exists with valid Supabase credentials:
```bash
cp .env.example .env
# Edit .env with actual credentials
```

#### Supabase Dashboard Configuration

In Supabase project settings:
1. **Authentication > Providers**: Enable Email provider
2. **Authentication > Settings**: 
   - Set site URL for redirects
   - Configure email templates (optional)
   - Set minimum password length

#### Future Enhancements (Out of Scope)

- Social login (Google, Apple)
- Profile page with user info editing
- Email verification flow
- Two-factor authentication
- Remember me functionality
- Biometric authentication

### 13. References

- **Supabase Auth Service**: `lib/services/supabase_auth_service.dart`
- **Existing Theme**: `lib/theme.dart`
- **Existing Widgets**: `lib/widgets/shared_widgets.dart`
- **App Structure**: `lib/main.dart`
- **Documentation**: 
  - `SUPABASE_SETUP_GUIDE.md`
  - `SUPABASE_QUICKSTART.md`
  - `SUPABASE_IMPLEMENTATION_SUMMARY.md`

---

## 🚀 Ready to Start?

This task document provides everything needed to implement full login/logout functionality. Follow the step-by-step guide, use the code examples, and check off items as you complete them. Good luck!

**Estimated Time:** 6-8 hours
**Difficulty:** Intermediate
**Priority:** High
