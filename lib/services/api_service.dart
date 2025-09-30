import '../models/user.dart';
import '../models/profile_models.dart';
import '../mock_data.dart';

/// Classe de serviço para API (versão mock)
/// Retorna dados estáticos ao invés de fazer chamadas HTTP
class ApiService {
  /// Obtém lista de usuários mock
  /// @returns Lista de usuários
  Future<List<User>> getUsers() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    return mockUsers;
  }

  /// Obtém dados de um usuário específico mock
  /// @param userId ID do usuário
  /// @returns Dados do usuário
  Future<User> getUserById(String userId) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    final user = mockUsers.firstWhere(
      (u) => u.id.toString() == userId,
      orElse: () => throw Exception('Usuário não encontrado'),
    );
    return user;
  }

  /// Atualiza dados de um usuário mock
  /// @param userId ID do usuário
  /// @param userData Dados a serem atualizados
  /// @returns Dados atualizados do usuário
  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 400));
    final user = await getUserById(userId);
    // Simula atualização (na prática, apenas retorna o usuário existente)
    return user;
  }

  /// Deleta um usuário mock
  /// @param userId ID do usuário
  Future<void> deleteUser(String userId) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    // Simula exclusão (não faz nada na prática)
  }

  /// Busca criadores mock por query
  /// @param query String de busca
  /// @returns Lista de criadores filtrados
  Future<List<Map<String, dynamic>>> searchCreators(String query) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return mockCreators.where((creator) {
      final name = creator['name'].toString().toLowerCase();
      final category = creator['category'].toString().toLowerCase();
      return name.contains(lowerQuery) || category.contains(lowerQuery);
    }).toList();
  }

  /// Busca conteúdos mock por query
  /// @param query String de busca
  /// @returns Lista de conteúdos filtrados
  Future<List<ProfileContent>> searchContents(String query) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final allContents = [...mockRecentPosts, ...mockVideos, ...mockExclusiveContent];
    return allContents.where((content) {
      final title = content.title.toLowerCase();
      final category = content.category?.toLowerCase() ?? '';
      return title.contains(lowerQuery) || category.contains(lowerQuery);
    }).toList();
  }
}
