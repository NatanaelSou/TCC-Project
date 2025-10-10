/// Modelo de dados para comentários em conteúdos
class Comment {
  final String id;
  final String contentId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final int likes;

  Comment({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.text,
    required this.createdAt,
    this.likes = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      contentId: json['content_id'] ?? '',
      userId: json['user_id'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content_id': contentId,
    'user_id': userId,
    'text': text,
    'created_at': createdAt.toIso8601String(),
    'likes': likes,
  };
}
