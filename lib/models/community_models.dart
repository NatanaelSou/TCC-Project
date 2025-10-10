import 'dart:convert';

/// Modelo para mensagens de chat
class Message {
  final String id;
  final String senderId;
  final String channelId;
  final String text;
  final DateTime timestamp;
  final bool isPrivate;
  final String? tierRequired;

  Message({
    required this.id,
    required this.senderId,
    required this.channelId,
    required this.text,
    required this.timestamp,
    this.isPrivate = false,
    this.tierRequired,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      channelId: json['channel_id'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      isPrivate: json['is_private'] ?? false,
      tierRequired: json['tier_required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'channel_id': channelId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'is_private': isPrivate,
      'tier_required': tierRequired,
    };
  }
}

/// Modelo para posts de mural (discussão)
class MuralPost {
  final String id;
  final String creatorId;
  final String channelId;
  final String? title;
  final String? description;
  final List<String>? images;
  final String? parentId; // Para threading/replies
  final DateTime createdAt;
  final int likes;
  final List<MuralPost> replies;
  final bool isPrivate;
  final String? tierRequired;

  MuralPost({
    required this.id,
    required this.creatorId,
    required this.channelId,
    this.title,
    this.description,
    this.images,
    this.parentId,
    required this.createdAt,
    this.likes = 0,
    this.replies = const [],
    this.isPrivate = false,
    this.tierRequired,
  });

  factory MuralPost.fromJson(Map<String, dynamic> json) {
    return MuralPost(
      id: json['id'],
      creatorId: json['creator_id'],
      channelId: json['channel_id'],
      title: json['title'],
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      parentId: json['parent_id'],
      createdAt: DateTime.parse(json['created_at']),
      likes: json['likes'] ?? 0,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => MuralPost.fromJson(r)).toList()
          : [],
      isPrivate: json['is_private'] ?? false,
      tierRequired: json['tier_required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'channel_id': channelId,
      'title': title,
      'description': description,
      'images': images,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'replies': replies.map((r) => r.toJson()).toList(),
      'is_private': isPrivate,
      'tier_required': tierRequired,
    };
  }
}

/// Modelo para canais de comunidade (chat ou mural)
class Channel {
  final String id;
  final String creatorId;
  final String name;
  final String? description;
  final String type; // 'chat' or 'mural'
  final bool isPrivate;
  final String? tierRequired;
  final List<String> members;

  Channel({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description,
    required this.type,
    this.isPrivate = false,
    this.tierRequired,
    this.members = const [],
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      creatorId: json['creator_id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      isPrivate: json['is_private'] ?? false,
      tierRequired: json['tier_required'],
      members: json['members'] != null ? List<String>.from(json['members']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'description': description,
      'type': type,
      'is_private': isPrivate,
      'tier_required': tierRequired,
      'members': members,
    };
  }
}
