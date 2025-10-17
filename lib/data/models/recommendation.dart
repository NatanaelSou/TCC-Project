/// Modelo de dados para recomendações de conteúdo
class Recommendation {
  final String contentId;
  final List<String> recommendedContentIds;
  final String basedOn; // e.g., 'category', 'views'

  Recommendation({
    required this.contentId,
    required this.recommendedContentIds,
    required this.basedOn,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      contentId: json['content_id'] ?? '',
      recommendedContentIds: json['recommended_content_ids'] != null
          ? List<String>.from(json['recommended_content_ids'])
          : [],
      basedOn: json['based_on'] ?? 'category',
    );
  }

  Map<String, dynamic> toJson() => {
    'content_id': contentId,
    'recommended_content_ids': recommendedContentIds,
    'based_on': basedOn,
  };
}
