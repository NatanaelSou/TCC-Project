import 'package:flutter/material.dart';

// Modelos
import 'models/user.dart';

/// Classe de estado global do usuário
/// Gerencia informações do usuário logado e notifica mudanças na interface
class UserState extends ChangeNotifier {
  // Propriedade do usuário
  User? _user;

  // Constantes
  static const String _defaultAvatarUrl = 'https://example.com/default_avatar.png';
  static const String _defaultDisplayName = 'Visitante';

  /// Construtor com parâmetro opcional
  UserState({User? user}) {
    _user = user;
  }

  // Getters
  User? get user => _user;
  String? get name => _user?.name;
  String? get email => _user?.email;
  String? get avatarUrl => _user?.avatarUrl;

  /// Verifica se o usuário está logado
  bool get isLoggedIn => _user != null;

  /// Retorna o nome de exibição do usuário
  String get displayName => _user?.name ?? _defaultDisplayName;

  /// Retorna a URL do avatar com fallback para avatar padrão
  String get displayAvatar => _user?.avatarUrl ?? _defaultAvatarUrl;

  /// Realiza login com instância de User
  /// @param user Instância de User
  void loginWithUser(User user) {
    _user = user;
    notifyListeners();
  }

  /// Realiza login com credenciais do usuário (para compatibilidade)
  /// @param userName Nome do usuário
  /// @param userEmail Email do usuário
  /// @param avatar URL opcional do avatar
  void login({
    required String userName,
    required String userEmail,
    String? avatar
  }) {
    _user = User(
      name: userName,
      email: userEmail,
      avatarUrl: avatar,
    );
    notifyListeners();
  }

  /// Realiza login a partir de um mapa de dados do usuário (para compatibilidade)
  /// @param userData Mapa contendo dados do usuário
  void loginFromMap(Map<String, dynamic> userData) {
    _user = User.fromJson(userData);
    notifyListeners();
  }

  /// Realiza logout limpando todos os dados do usuário
  void logout() {
    _user = null;
    notifyListeners();
  }

  /// Atualiza apenas o nome do usuário
  /// @param newName Novo nome do usuário
  void setName(String newName) {
    if (_user != null) {
      _user = _user!.copyWith(name: newName);
      notifyListeners();
    }
  }

  /// Atualiza apenas o avatar do usuário
  /// @param avatar Nova URL do avatar
  void setProfile(String avatar) {
    if (_user != null) {
      _user = _user!.copyWith(avatarUrl: avatar);
      notifyListeners();
    }
  }

  /// Atualiza múltiplos campos do perfil do usuário
  /// @param newName Novo nome (opcional)
  /// @param newAvatar Nova URL do avatar (opcional)
  void updateProfile({String? newName, String? newAvatar}) {
    if (_user != null) {
      _user = _user!.copyWith(
        name: newName ?? _user!.name,
        avatarUrl: newAvatar ?? _user!.avatarUrl,
      );
      notifyListeners();
    }
  }

  /// Verifica se o usuário tem um avatar personalizado
  bool get hasCustomAvatar => _user?.avatarUrl != null && _user!.avatarUrl != _defaultAvatarUrl;

  /// Retorna as iniciais do usuário para casos onde o avatar não carrega
  String get userInitials {
    if (_user?.name != null && _user!.name.isNotEmpty) {
      return _user!.name.split(' ')
          .take(2)
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
          .join('');
    }
    return _defaultDisplayName[0].toUpperCase();
  }
}
