import '../models/user.dart';
import 'http_service.dart';

/// Classe de serviço para API
/// Gerencia todas as chamadas para a API backend com tratamento de erro robusto
class ApiService extends HttpService {
  /// Obtém lista de usuários
  /// @returns Lista de usuários
  /// @throws HttpException em caso de erro
  Future<List<User>> getUsers() async {
    try {
      final response = await get('/users');

      final data = handleResponse(response, 'carregar usuários') as List<dynamic>;
      return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Obtém dados de um usuário específico
  /// @param userId ID do usuário
  /// @returns Dados do usuário
  /// @throws HttpException em caso de erro
  Future<User> getUserById(String userId) async {
    try {
      final response = await get('/users/$userId');

      final data = handleResponse(response, 'carregar usuário $userId') as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Atualiza dados de um usuário
  /// @param userId ID do usuário
  /// @param userData Dados a serem atualizados
  /// @returns Dados atualizados do usuário
  /// @throws HttpException em caso de erro
  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await put('/users/$userId', userData);

      final data = handleResponse(response, 'atualizar usuário $userId') as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Deleta um usuário
  /// @param userId ID do usuário
  /// @throws HttpException em caso de erro
  Future<void> deleteUser(String userId) async {
    try {
      final response = await delete('/users/$userId');

      handleResponse(response, 'deletar usuário $userId');
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }
}
