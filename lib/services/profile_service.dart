import '../models/profile_models.dart';
import 'http_service.dart';

/// Serviço para gerenciar dados do perfil do usuário
/// Busca informações dinâmicas do backend
class ProfileService extends HttpService {
  /// Busca estatísticas do perfil do usuário
  /// @param userId ID do usuário
  /// @returns Estatísticas do perfil
  /// @throws HttpException em caso de erro
  Future<ProfileStats> getProfileStats(String userId) async {
    // Mock data para demonstração (remover quando backend estiver disponível)
    await Future.delayed(Duration(milliseconds: 500)); // Simular delay de rede
    return ProfileStats(
      followers: 1250,
      posts: 45,
      subscribers: 89,
      viewers: 15000,
    );

    try {
      final response = await get('/users/$userId/stats');
      final data = handleResponse(response, 'busca de estatísticas') as Map<String, dynamic>;
      return ProfileStats.fromJson(data);
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Busca conteúdo do perfil por tipo
  /// @param userId ID do usuário
  /// @param type Tipo de conteúdo ('posts', 'videos', 'exclusive')
  /// @param limit Limite de itens (padrão: 10)
  /// @returns Lista de conteúdos
  /// @throws HttpException em caso de erro
  Future<List<ProfileContent>> getProfileContent(String userId, String type, {int limit = 10}) async {
    // Mock data para demonstração (remover quando backend estiver disponível)
    await Future.delayed(Duration(milliseconds: 500)); // Simular delay de rede
    
    List<ProfileContent> mockContent = [];
    switch (type) {
      case 'posts':
        mockContent = List.generate(limit, (index) => ProfileContent(
          id: 'post_$index',
          title: 'Post sobre ${['tecnologia', 'arte', 'viagens', 'culinária'][index % 4]} #$index',
          type: 'post',
          thumbnailUrl: 'https://via.placeholder.com/200x150/4A90E2/FFFFFF?text=Post+$index',
          createdAt: DateTime.now().subtract(Duration(days: index)),
          views: 100 + (index * 50),
        ));
        break;
      case 'videos':
        mockContent = List.generate(limit, (index) => ProfileContent(
          id: 'video_$index',
          title: 'Vídeo tutorial #$index',
          type: 'video',
          thumbnailUrl: 'https://via.placeholder.com/200x150/E74C3C/FFFFFF?text=Video+$index',
          createdAt: DateTime.now().subtract(Duration(days: index * 2)),
          views: 500 + (index * 200),
        ));
        break;
      case 'exclusive':
        mockContent = List.generate(limit, (index) => ProfileContent(
          id: 'exclusive_$index',
          title: 'Conteúdo exclusivo #$index',
          type: 'exclusive',
          thumbnailUrl: 'https://via.placeholder.com/200x150/9B59B6/FFFFFF?text=Exclusivo+$index',
          createdAt: DateTime.now().subtract(Duration(days: index * 3)),
          views: 200 + (index * 100),
        ));
        break;
    }
    return mockContent;

    try {
      final response = await get('/users/$userId/content?type=$type&limit=$limit');
      final data = handleResponse(response, 'busca de conteúdo') as List<dynamic>;
      return data.map((item) => ProfileContent.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Busca níveis de suporte do usuário
  /// @param userId ID do usuário
  /// @returns Lista de tiers de suporte
  /// @throws HttpException em caso de erro
  Future<List<SupportTier>> getSupportTiers(String userId) async {
    // Mock data para demonstração (remover quando backend estiver disponível)
    await Future.delayed(Duration(milliseconds: 500)); // Simular delay de rede
    return [
      SupportTier(
        id: 'basic',
        name: 'Básico',
        price: 5.0,
        description: 'Acesso a posts exclusivos e atualizações',
        color: '#2ECC71',
        subscriberCount: 45,
      ),
      SupportTier(
        id: 'premium',
        name: 'Premium',
        price: 15.0,
        description: 'Vídeos exclusivos + chat privado + descontos',
        color: '#3498DB',
        subscriberCount: 23,
      ),
      SupportTier(
        id: 'vip',
        name: 'VIP',
        price: 30.0,
        description: 'Conteúdo personalizado + encontros virtuais + benefícios especiais',
        color: '#9B59B6',
        subscriberCount: 12,
      ),
    ];

    try {
      final response = await get('/users/$userId/tiers');
      final data = handleResponse(response, 'busca de tiers') as List<dynamic>;
      return data.map((item) => SupportTier.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Seguir/deseguir usuário
  /// @param targetUserId ID do usuário alvo
  /// @returns Status da operação
  /// @throws HttpException em caso de erro
  Future<bool> toggleFollow(String targetUserId) async {
    try {
      final response = await post('/users/$targetUserId/follow', {});
      final data = handleResponse(response, 'toggle follow') as Map<String, dynamic>;
      return data['following'] ?? false;
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }

  /// Apoiar um tier específico
  /// @param userId ID do criador
  /// @param tierId ID do tier
  /// @returns Status da operação
  /// @throws HttpException em caso de erro
  Future<bool> supportTier(String userId, String tierId) async {
    try {
      final response = await post('/users/$userId/support', {'tier_id': tierId});
      final data = handleResponse(response, 'apoio ao tier') as Map<String, dynamic>;
      return data['success'] ?? false;
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException('Erro inesperado: ${e.toString()}');
    }
  }
}
