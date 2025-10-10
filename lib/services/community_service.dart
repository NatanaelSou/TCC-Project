import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community_models.dart';
import '../mock_data.dart';

/// Serviço para gerenciar funcionalidades de comunidade via API
class CommunityService {
  final String baseUrl;

  CommunityService({required this.baseUrl});

  /// Cria um novo canal
  /// @param creatorId ID do criador
  /// @param channelData Dados do canal
  /// @returns Canal criado
  Future<Channel> createChannel(String creatorId, Map<String, dynamic> channelData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/community/users/$creatorId/channels'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(channelData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Channel.fromJson(data);
    } else {
      throw Exception('Erro ao criar canal');
    }
  }

  /// Busca canais acessíveis ao usuário
  /// @param userId ID do usuário
  /// @returns Lista de canais
  Future<List<Channel>> getChannels(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/community/users/$userId/channels'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => Channel.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar canais');
      }
    } catch (e) {
      // Fallback para dados mock quando API não está disponível
      return mockChannels;
    }
  }

  /// Junta-se a um canal
  /// @param userId ID do usuário
  /// @param channelId ID do canal
  /// @returns Status da operação
  Future<void> joinChannel(String userId, String channelId) async {
    final response = await http.post(Uri.parse('$baseUrl/community/channels/$channelId/join/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao juntar-se ao canal');
    }
  }

  /// Envia uma mensagem em um canal
  /// @param senderId ID do remetente
  /// @param channelId ID do canal
  /// @param messageData Dados da mensagem
  /// @returns Mensagem enviada
  Future<Message> sendMessage(String senderId, String channelId, Map<String, dynamic> messageData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/community/channels/$channelId/messages/$senderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Erro ao enviar mensagem');
      }
    } catch (e) {
      // Fallback para modo mock: cria mensagem local e adiciona à lista mock
      final newMessage = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        channelId: channelId,
        text: messageData['text'] ?? '',
        timestamp: DateTime.now(),
        isPrivate: messageData['isPrivate'] ?? false,
        tierRequired: messageData['tierRequired'],
      );
      mockMessages.add(newMessage);
      return newMessage;
    }
  }

  /// Busca mensagens de um canal
  /// @param channelId ID do canal
  /// @param limit Limite de mensagens
  /// @returns Lista de mensagens
  Future<List<Message>> getMessages(String channelId, {int limit = 50}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/community/channels/$channelId/messages?limit=$limit'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => Message.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar mensagens');
      }
    } catch (e) {
      // Fallback para dados mock quando API não está disponível
      return mockMessages.where((m) => m.channelId == channelId).toList();
    }
  }

  /// Cria um post de mural em um canal
  /// @param creatorId ID do criador
  /// @param channelId ID do canal
  /// @param postData Dados do post
  /// @returns Post criado
  Future<MuralPost> createMuralPost(String creatorId, String channelId, Map<String, dynamic> postData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/community/channels/$channelId/posts/$creatorId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(postData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return MuralPost.fromJson(data);
    } else {
      throw Exception('Erro ao criar post de mural');
    }
  }

  /// Busca posts de mural de um canal
  /// @param channelId ID do canal
  /// @returns Lista de posts
  Future<List<MuralPost>> getMuralPosts(String channelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/community/channels/$channelId/posts'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => MuralPost.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar posts de mural');
      }
    } catch (e) {
      // Fallback para dados mock quando API não está disponível
      return mockMuralPosts.where((p) => p.channelId == channelId).toList();
    }
  }
}
