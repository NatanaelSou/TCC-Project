import '../models/profile_models.dart';
import '../mock_data.dart';

/// Serviço para gerenciar dados do perfil do usuário (versão mock)
/// Retorna dados estáticos ao invés de fazer chamadas HTTP
class ProfileService {
  /// Busca estatísticas do perfil do usuário mock
  /// @param userId ID do usuário
  /// @returns Estatísticas do perfil
  Future<ProfileStats> getProfileStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de rede
    return mockProfileStats;
  }

  /// Busca conteúdo do perfil por tipo mock
  /// @param userId ID do usuário
  /// @param type Tipo de conteúdo ('posts', 'exclusive')
  /// @param limit Limite de itens (padrão: 10)
  /// @returns Lista de conteúdos
  Future<List<ProfileContent>> getProfileContent(String userId, String type, {int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de rede

    switch (type) {
      case 'posts':
        return mockRecentPosts.take(limit).toList();
      case 'exclusive':
        return mockExclusiveContent.take(limit).toList();
      default:
        return [];
    }
  }

  /// Busca níveis de suporte do usuário mock
  /// @param userId ID do usuário
  /// @returns Lista de tiers de suporte
  Future<List<SupportTier>> getSupportTiers(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de rede
    return mockSupportTiers;
  }

  /// Seguir/deseguir usuário mock
  /// @param targetUserId ID do usuário alvo
  /// @returns Status da operação
  Future<bool> toggleFollow(String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simula operação (sempre retorna true)
    return true;
  }

  /// Apoiar um tier específico mock
  /// @param userId ID do criador
  /// @param tierId ID do tier
  /// @returns Status da operação
  Future<bool> supportTier(String userId, String tierId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simula operação (sempre retorna true)
    return true;
  }
}
