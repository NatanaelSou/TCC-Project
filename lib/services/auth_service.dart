import '../models/user.dart';
import '../mock_data.dart';

/// Classe de serviço para autenticação (versão mock)
/// Simula login e registro com dados estáticos
class AuthService {
  /// Realiza login do usuário mock
  /// Permite login sem credenciais, retornando usuário padrão se campos vazios
  /// @param userNameOrEmail Nome de usuário ou email (opcional)
  /// @param password Senha do usuário (opcional)
  /// @returns Instância de User
  Future<User> login(String userNameOrEmail, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Se nenhum nome/email fornecido, retorna usuário padrão para login sem credenciais
    if (userNameOrEmail.trim().isEmpty) {
      return mockUsers[0];
    }
    try {
      final user = mockUsers.firstWhere(
        (u) =>
            (u.email == userNameOrEmail.trim() ||
                u.name.toLowerCase() == userNameOrEmail.trim().toLowerCase()) &&
            password.isNotEmpty, // Simula validação simples
      );
      return user;
    } catch (e) {
      throw Exception('Usuário ou senha inválidos');
    }
  }

  /// Registra um novo usuário mock
  /// @param email Email do usuário
  /// @param password Senha do usuário
  /// @param name Nome opcional do usuário
  /// @returns Instância de User criado
  Future<User> register(String email, String password, {String? name}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simula criação de usuário (retorna o primeiro mock para simplicidade)
    return mockUsers[0];
  }
}
