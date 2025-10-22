// Template: Copy this file to lib/utils/auth_error_messages.dart
// This utility translates Supabase authentication errors to Portuguese

/// Translates Supabase authentication errors to user-friendly Portuguese messages
/// 
/// Usage:
/// ```dart
/// try {
///   await authService.signInWithEmail(...);
/// } catch (e) {
///   final message = getAuthErrorMessage(e);
///   // Display message to user
/// }
/// ```
String getAuthErrorMessage(dynamic error) {
  // Convert error to string and make lowercase for easier matching
  final errorMessage = error.toString().toLowerCase();
  
  // Authentication errors
  if (errorMessage.contains('invalid login credentials') ||
      errorMessage.contains('invalid email or password')) {
    return 'Email ou senha incorretos';
  }
  
  if (errorMessage.contains('email not confirmed')) {
    return 'Por favor, confirme seu email antes de fazer login';
  }
  
  // Signup errors
  if (errorMessage.contains('user already registered') ||
      errorMessage.contains('email already exists')) {
    return 'Este email já está cadastrado';
  }
  
  if (errorMessage.contains('weak password') ||
      errorMessage.contains('password should be at least')) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  
  // Email validation errors
  if (errorMessage.contains('invalid email') ||
      errorMessage.contains('invalid format')) {
    return 'Email inválido';
  }
  
  if (errorMessage.contains('email is required')) {
    return 'Email é obrigatório';
  }
  
  // Password errors
  if (errorMessage.contains('password is required')) {
    return 'Senha é obrigatória';
  }
  
  // Network errors
  if (errorMessage.contains('network') ||
      errorMessage.contains('connection') ||
      errorMessage.contains('timeout')) {
    return 'Erro de conexão. Verifique sua internet';
  }
  
  // Rate limiting
  if (errorMessage.contains('rate limit') ||
      errorMessage.contains('too many requests')) {
    return 'Muitas tentativas. Aguarde alguns minutos';
  }
  
  // Password reset errors
  if (errorMessage.contains('password reset')) {
    return 'Erro ao enviar email de recuperação';
  }
  
  // OAuth errors
  if (errorMessage.contains('oauth')) {
    return 'Erro ao autenticar com provedor externo';
  }
  
  // Session errors
  if (errorMessage.contains('session') || errorMessage.contains('token')) {
    return 'Sessão expirada. Faça login novamente';
  }
  
  // User not found
  if (errorMessage.contains('user not found')) {
    return 'Usuário não encontrado';
  }
  
  // Generic error
  return 'Ocorreu um erro. Tente novamente';
}

/// Validates if an email has a valid format
/// Returns true if email is valid, false otherwise
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

/// Validates if a password meets minimum requirements
/// Returns error message if invalid, null if valid
String? validatePassword(String password) {
  if (password.isEmpty) {
    return 'A senha é obrigatória';
  }
  
  if (password.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  
  // Optional: Add more strict requirements
  // if (!password.contains(RegExp(r'[0-9]'))) {
  //   return 'A senha deve conter pelo menos um número';
  // }
  
  return null; // Password is valid
}

/// Validates if two passwords match
/// Returns error message if they don't match, null if they match
String? validatePasswordMatch(String password, String confirmPassword) {
  if (password != confirmPassword) {
    return 'As senhas não coincidem';
  }
  return null;
}

/// Gets a user-friendly success message for authentication actions
String getAuthSuccessMessage(String action) {
  switch (action) {
    case 'login':
      return 'Login realizado com sucesso!';
    case 'signup':
      return 'Conta criada com sucesso!';
    case 'logout':
      return 'Logout realizado com sucesso!';
    case 'password_reset':
      return 'Email de recuperação enviado! Verifique sua caixa de entrada';
    case 'password_update':
      return 'Senha atualizada com sucesso!';
    default:
      return 'Operação realizada com sucesso!';
  }
}
