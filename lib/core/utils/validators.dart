/// Utilitários de validação para formulários
/// Contém funções para validar campos comuns como email e senha
class Validators {
  /// Valida um endereço de email
  /// @param value Valor do campo email
  /// @return Mensagem de erro se inválido, null se válido
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email não pode estar vazio';
    }
    if (!value.contains('@')) {
      return 'Email inválido';
    }
    // Validação mais robusta opcional
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Formato de email inválido';
    }
    return null;
  }

  /// Valida uma senha
  /// @param value Valor do campo senha
  /// @return Mensagem de erro se inválido, null se válido
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha não pode estar vazia';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  /// Valida um nome de usuário
  /// @param value Valor do campo nome
  /// @return Mensagem de erro se inválido, null se válido
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome não pode estar vazio';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  /// Valida se um campo é obrigatório
  /// @param value Valor do campo
  /// @param fieldName Nome do campo para mensagem de erro
  /// @return Mensagem de erro se vazio, null se válido
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName não pode estar vazio';
    }
    return null;
  }
}
