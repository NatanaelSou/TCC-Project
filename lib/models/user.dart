/// Modelo de dados para representar um usuário
/// Contém informações básicas do usuário e métodos de serialização
class User {
  final int? id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;

  /// Construtor da classe User
  /// @param id ID único do usuário (opcional)
  /// @param name Nome do usuário
  /// @param email Email do usuário
  /// @param avatarUrl URL do avatar (opcional)
  /// @param createdAt Data de criação (opcional)
  User({
    this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.createdAt,
  });

  /// Cria uma instância de User a partir de um mapa JSON
  /// @param json Mapa contendo dados do usuário
  /// @returns Instância de User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Converte a instância de User para um mapa JSON
  /// @returns Mapa representando o usuário
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (avatarUrl != null) 'avatar': avatarUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Cria uma cópia do usuário com campos atualizados
  /// @param name Novo nome (opcional)
  /// @param email Novo email (opcional)
  /// @param avatarUrl Nova URL do avatar (opcional)
  /// @returns Nova instância de User com campos atualizados
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.avatarUrl == avatarUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        avatarUrl.hashCode ^
        createdAt.hashCode;
  }
}
