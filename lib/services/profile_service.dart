import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_models.dart';

/// Serviço para gerenciar dados do perfil do usuário via API
class ProfileService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Busca estatísticas do perfil do usuário via API
  /// @param userId ID do usuário
  /// @returns Estatísticas do perfil
  Future<ProfileStats> getProfileStats(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profiles/$userId/stats'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProfileStats(
        followers: data['followers'] ?? 0,
        posts: data['posts'] ?? 0,
        subscribers: data['subscribers'] ?? 0,
        viewers: data['viewers'] ?? 0,
      );
    } else {
      throw Exception('Erro ao buscar estatísticas do perfil');
    }
  }

  /// Busca conteúdo do perfil por tipo via API
  /// @param userId ID do usuário
  /// @param type Tipo de conteúdo ('posts', 'videos', 'exclusive')
  /// @param limit Limite de itens (padrão: 10)
  /// @returns Lista de conteúdos
  Future<List<ProfileContent>> getProfileContent(String userId, String type, {int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/$userId?type=$type&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProfileContent.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar conteúdo do perfil');
    }
  }

  /// Busca níveis de suporte do usuário via API
  /// @param userId ID do usuário
  /// @returns Lista de tiers de suporte
  Future<List<SupportTier>> getSupportTiers(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profiles/$userId/tiers'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => SupportTier.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar tiers de suporte');
    }
  }

  /// Seguir/deseguir usuário via API
  /// @param followerId ID do seguidor
  /// @param followedId ID do seguido
  /// @returns Status da operação
  Future<bool> toggleFollow(String followerId, String followedId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profiles/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'followerId': followerId,
        'followedId': followedId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isFollowing'] ?? false;
    } else {
      throw Exception('Erro ao alternar follow');
    }
  }

  /// Apoiar um tier específico via API
  /// @param userId ID do usuário
  /// @param tierId ID do tier
  /// @returns Status da operação
  Future<bool> supportTier(String userId, String tierId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profiles/$userId/support'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tierId': tierId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Erro ao apoiar tier');
    }
  }

  /// Busca canais do usuário via API
  /// @param userId ID do usuário
  /// @returns Lista de canais
  Future<List<dynamic>> getChannels(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profiles/$userId/channels'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erro ao buscar canais');
    }
  }
}
