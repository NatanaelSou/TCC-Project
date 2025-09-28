import '../models/user.dart';
import 'http_service.dart';

/// Classe de serviço para autenticação
/// Gerencia login e registro de usuários com tratamento robusto de erros
class AuthService extends HttpService {
  /// Realiza login do usuário
  /// @param userNameOrEmail Nome de usuário ou email
  /// @param password Senha do usuário
  /// @returns Instância de User
  /// @throws HttpException em caso de erro
  Future<User> login(String userNameOrEmail, String password) async {
    try {
      final response = await post('/login', {
        'email': userNameOrEmail.trim(),
        'password': password.trim(),
      });

      final data = handleResponse(response, 'login') as Map<String, dynamic>;
      if (data['user'] != null) {
        return User.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        throw HttpException('Dados do usuário não encontrados na resposta');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Registra um novo usuário
  /// @param email Email do usuário
  /// @param password Senha do usuário
  /// @param name Nome opcional do usuário
  /// @returns Instância de User criado
  /// @throws HttpException em caso de erro
  Future<User> register(String email, String password, {String? name}) async {
    try {
      final body = {
        'email': email.trim(),
        'password': password.trim(),
        if (name != null && name.isNotEmpty) 'name': name.trim(),
      };

      final response = await post('/users/register', body);

      final data = handleResponse(response, 'registro') as Map<String, dynamic>;
      if (data['user'] != null) {
        return User.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        throw HttpException('Dados do usuário não encontrados na resposta');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }


}
