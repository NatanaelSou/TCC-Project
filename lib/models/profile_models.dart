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

/// Modelo de dados para conteúdo do perfil
class ProfileContent {
  final String id;
  final String title;
  final String type; // 'post', 'video', 'exclusive'
  final String thumbnailUrl;
  final DateTime createdAt;
  final int views;
  final String? category; // Categoria opcional para filtros

  ProfileContent({
    required this.id,
    required this.title,
    required this.type,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.views,
    this.category,
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
