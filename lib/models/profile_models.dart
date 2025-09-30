/// Modelo de dados para estatísticas do perfil
class ProfileStats {
  final int followers;
  final int posts;
  final int subscribers;
  final int viewers;

  ProfileStats({
    required this.followers,
    required this.posts,
    required this.subscribers,
    required this.viewers,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      followers: json['followers'] ?? 0,
      posts: json['posts'] ?? 0,
      subscribers: json['subscribers'] ?? 0,
      viewers: json['viewers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'followers': followers,
    'posts': posts,
    'subscribers': subscribers,
    'viewers': viewers,
  };
}

/// Enumeração para tipos de conteúdo suportados
enum ContentType {
  post,
  video,
  live,
  podcast,
  course,
  other,
}

/// Modelo de dados para conteúdo do perfil
class ProfileContent {
  final String id;
  final String title;
  final String type; // 'post', 'video', 'exclusive'
  final String thumbnailUrl;
  final DateTime createdAt;
  final int views;
  final String? category; // Categoria opcional para filtros
  final String? description; // Descrição detalhada do conteúdo
  final List<String>? keywords; // Palavras-chave para busca
  final bool is18Plus; // Conteúdo para maiores de 18 anos
  final bool isPrivate; // Conteúdo privado para assinantes
  final String? quality; // Qualidade para vídeos ('low', 'medium', 'high')
  final List<String>? images; // URLs de imagens para posts
  final String? tierRequired; // ID do tier necessário para acesso exclusivo
  final String? creatorId; // ID do criador do conteúdo

  ProfileContent({
    required this.id,
    required this.title,
    required this.type,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.views,
    this.category,
    this.description,
    this.keywords,
    this.is18Plus = false,
    this.isPrivate = false,
    this.quality,
    this.images,
    this.tierRequired,
    this.creatorId,
  });

  factory ProfileContent.fromJson(Map<String, dynamic> json) {
    return ProfileContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'post',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      views: json['views'] ?? 0,
      category: json['category'],
      description: json['description'],
      keywords: json['keywords'] != null ? List<String>.from(json['keywords']) : null,
      is18Plus: json['is_18_plus'] ?? false,
      isPrivate: json['is_private'] ?? false,
      quality: json['quality'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      tierRequired: json['tier_required'],
      creatorId: json['creator_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'thumbnail_url': thumbnailUrl,
    'created_at': createdAt.toIso8601String(),
    'views': views,
    'category': category,
    'description': description,
    'keywords': keywords,
    'is_18_plus': is18Plus,
    'is_private': isPrivate,
    'quality': quality,
    'images': images,
    'tier_required': tierRequired,
    'creator_id': creatorId,
  };
}

/// Modelo de dados para níveis de suporte
class SupportTier {
  final String id;
  final String name;
  final double price;
  final String description;
  final String color; // hex color
  final int subscriberCount;

  SupportTier({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.color,
    required this.subscriberCount,
  });

  factory SupportTier.fromJson(Map<String, dynamic> json) {
    return SupportTier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      color: json['color'] ?? '#FF0000',
      subscriberCount: json['subscriber_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'description': description,
    'color': color,
    'subscriber_count': subscriberCount,
  };
}
