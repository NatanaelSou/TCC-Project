import '../models/profile_models.dart';

/// Serviço para criação e gerenciamento de conteúdo
class ContentService {
  /// Faz upload de um arquivo e retorna a URL mock
  /// @param filePath Caminho do arquivo local
  /// @returns URL do arquivo após upload
  Future<String?> uploadFile(String filePath) async {
    try {
      // Simulação de delay de upload
      await Future.delayed(Duration(seconds: 2));

      // Simula upload bem-sucedido retornando uma URL mock
      // Em um app real, isso seria uma URL do servidor de arquivos
      final fileName = filePath.split('/').last;
      return 'https://mock-cdn.example.com/uploads/$fileName';
    } catch (e) {
      // Em caso de erro, retorna null
      return null;
    }
  }

  /// Cria um novo conteúdo baseado nos dados fornecidos
  /// Retorna o conteúdo criado ou null em caso de erro
  Future<ProfileContent?> createContent(Map<String, dynamic> data) async {
    try {
      // Simulação de delay de rede
      await Future.delayed(Duration(seconds: 1));

      // Faz upload dos arquivos se fornecidos
      String? uploadedThumbnailUrl;
      String? uploadedVideoUrl;
      List<String>? uploadedImageUrls;

      // Upload do thumbnail se fornecido
      if (data['thumbnailUrl'] != null && data['thumbnailUrl'].isNotEmpty) {
        uploadedThumbnailUrl = await uploadFile(data['thumbnailUrl']);
        if (uploadedThumbnailUrl == null) {
          throw Exception('Falha no upload do thumbnail');
        }
      }

      // Upload do vídeo se fornecido
      if (data['videoUrl'] != null && data['videoUrl'].isNotEmpty) {
        uploadedVideoUrl = await uploadFile(data['videoUrl']);
        if (uploadedVideoUrl == null) {
          throw Exception('Falha no upload do vídeo');
        }
      }

      // Upload das imagens se fornecidas
      if (data['images'] != null && data['images'].isNotEmpty) {
        uploadedImageUrls = [];
        for (String imagePath in data['images']) {
          final uploadedUrl = await uploadFile(imagePath);
          if (uploadedUrl == null) {
            throw Exception('Falha no upload de uma imagem');
          }
          uploadedImageUrls.add(uploadedUrl);
        }
      }

      // Gera ID único para o conteúdo
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      // Cria o conteúdo com os dados fornecidos e URLs dos arquivos enviados
      final content = ProfileContent(
        id: id,
        title: data['title'] ?? '',
        type: data['type'] ?? 'post',
        thumbnailUrl: uploadedThumbnailUrl ?? '',
        videoUrl: uploadedVideoUrl ?? '',
        createdAt: DateTime.now(),
        views: 0,
        category: data['category'],
        description: data['description'],
        keywords: data['keywords'] != null ? List<String>.from(data['keywords']) : null,
        is18Plus: data['is18Plus'] ?? false,
        isPrivate: data['isPrivate'] ?? false,
        quality: data['quality'],
        images: uploadedImageUrls,
        tierRequired: data['tierRequired'],
        creatorId: data['creatorId'] ?? '1', // Mock creator ID
      );

      // Aqui seria feita a chamada para o backend
      // Por enquanto, apenas retorna o conteúdo criado
      return content;
    } catch (e) {
      // Em caso de erro, retorna null
      return null;
    }
  }
}
