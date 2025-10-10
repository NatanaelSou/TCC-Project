import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import '../models/profile_models.dart';

/// Serviço para gerenciar conteúdo e interações via API
class ContentService {
  final String baseUrl;

  ContentService({required this.baseUrl});

  /// Busca comentários para um conteúdo específico
  /// @param contentId ID do conteúdo
  /// @returns Lista de comentários
  Future<List<Comment>> getCommentsForContent(String contentId) async {
    final response = await http.get(Uri.parse('$baseUrl/content/$contentId/comments'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Comment.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar comentários');
    }
  }

  /// Adiciona um comentário a um conteúdo
  /// @param contentId ID do conteúdo
  /// @param userId ID do usuário
  /// @param text Texto do comentário
  /// @returns Comentário criado
  Future<Comment> addComment(String contentId, String userId, String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/content/$contentId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'text': text,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Comment.fromJson(data);
    } else {
      throw Exception('Erro ao adicionar comentário');
    }
  }

  /// Busca vídeos similares baseado em categorias
  /// @param contentId ID do conteúdo atual
  /// @param categories Lista de categorias
  /// @returns Lista de vídeos similares
  Future<List<ProfileContent>> getSimilarVideos(String contentId, List<String> categories) async {
    final response = await http.post(
      Uri.parse('$baseUrl/content/$contentId/similar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'categories': categories}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProfileContent.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar vídeos similares');
    }
  }

  /// Busca recomendações para um conteúdo
  /// @param contentId ID do conteúdo
  /// @returns Lista de conteúdos recomendados
  Future<List<ProfileContent>> getRecommendations(String contentId) async {
    final response = await http.get(Uri.parse('$baseUrl/content/$contentId/recommendations'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProfileContent.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar recomendações');
    }
  }

  /// Incrementa visualizações de um conteúdo
  /// @param contentId ID do conteúdo
  Future<void> incrementViews(String contentId) async {
    final response = await http.post(Uri.parse('$baseUrl/content/$contentId/views'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao incrementar visualizações');
    }
  }

  /// Cria novo conteúdo
  /// @param userId ID do usuário criador
  /// @param contentData Dados do conteúdo
  /// @returns Conteúdo criado
  Future<ProfileContent> createContent(String userId, Map<String, dynamic> contentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/content/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contentData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ProfileContent.fromJson(data);
    } else {
      throw Exception('Erro ao criar conteúdo');
    }
  }
}
