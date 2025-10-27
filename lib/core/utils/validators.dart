// lib/core/utils/validators.dart

/// Utilitários de validação para formulários
///
/// Contém validadores reutilizáveis para email, senha, nome, etc.
/// com mensagens de erro em português.

class Validators {
  /// Regex para validação de email
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Valida se o email está no formato correto
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }

    return null;
  }

  /// Valida senha com requisitos de segurança
  /// - Mínimo 6 caracteres
  /// - Pelo menos uma letra maiúscula
  /// - Pelo menos uma letra minúscula
  /// - Pelo menos um número
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    // Verifica se tem pelo menos uma letra maiúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }

    // Verifica se tem pelo menos uma letra minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }

    // Verifica se tem pelo menos um número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número';
    }

    return null;
  }

  /// Valida senha simples (apenas comprimento mínimo)
  /// Útil para login onde não queremos mostrar requisitos completos
  static String? validatePasswordSimple(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  /// Valida confirmação de senha
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }

    if (value != password) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  /// Valida nome (mínimo 3 caracteres)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome';
    }

    if (value.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }

    // Verifica se contém apenas letras e espaços (Unicode-aware)
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(value)) {
      return 'Nome deve conter apenas letras';
    }

    return null;
  }

  /// Valida campo obrigatório genérico
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira $fieldName';
    }
    return null;
  }

  /// Valida número de telefone brasileiro
  static String? validatePhoneBR(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu telefone';
    }

    // Remove caracteres não numéricos
    final numbersOnly = value.replaceAll(RegExp(r'\D'), '');

    // Valida formato brasileiro (11 dígitos com DDD)
    if (numbersOnly.length != 11) {
      return 'Telefone deve ter 11 dígitos (DDD + número)';
    }

    return null;
  }

  /// Retorna dicas de senha forte
  static String getPasswordHint() {
    return 'A senha deve conter:\n'
        '• Pelo menos 6 caracteres\n'
        '• Uma letra maiúscula\n'
        '• Uma letra minúscula\n'
        '• Um número';
  }

  /// Verifica a força da senha (0-4)
  /// 0 = muito fraca, 4 = muito forte
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return (strength / 1.5).round().clamp(0, 4);
  }

  /// Retorna cor baseada na força da senha
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Muito fraca';
      case 2:
        return 'Fraca';
      case 3:
        return 'Média';
      case 4:
        return 'Forte';
      default:
        return '';
    }
  }
}
