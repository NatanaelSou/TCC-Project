import 'package:flutter/material.dart';

/// Classe centralizada de constantes de cores da aplicação
/// Organiza todas as cores utilizadas na interface para facilitar manutenção
class AppColors {
  // Primary palette - Cores principais da aplicação
  static const Color primary = Color(0xFFFF6F91);
  static const Color secondary = Color(0xFFFF6F91);

  // Sidebar - Cores específicas da barra lateral
  static const Color sidebar = Colors.white;
  static const Color sidebarItemActive = Colors.black;
  static const Color sidebarPromptBg = Color.fromARGB(184, 255, 255, 255);
  static const Color sidebarPromptShadow = Color(0x30FF6F91);

  // Text - Cores para textos em diferentes contextos
  static const Color textLight = Color.fromARGB(255, 255, 255, 255);
  static const Color textDark = Colors.black;
  static const Color textGrey = Colors.grey;

  // Icons - Cores para ícones
  static const Color iconLight = Colors.white;
  static const Color iconDark = Colors.black;

  // Cards - Cores para cards de conteúdo
  static const Color cardBg = Color(0xFFF5F5F7);
  static const Color cardImagePlaceholder = Colors.grey;

  // Inputs - Cores para campos de entrada
  static const Color inputFill = Colors.white;

  // Background - Cores de fundo
  static const Color background = Color(0xFFF5F5F5);

  // Buttons - Cores para botões
  static const Color btnSecondary = Color(0xFFFF6F91);
}

/// Classe para constantes de texto reutilizáveis
class AppStrings {
  // Textos comuns da interface
  static const String appTitle = 'App Flutter + Node.js + mySQL';
  static const String loginTitle = 'Login';
  static const String logoutText = 'Logout';
  static const String welcomeMessage = 'Bem-vindo ao App!';
  static const String searchPlaceholder = 'Buscar criadores ou tópicos';

  // Mensagens de erro
  static const String emailRequiredError = 'O email não pode estar vazio';
  static const String invalidEmailError = 'Digite um email válido';
  static const String passwordRequiredError = 'A senha não pode estar vazia';
  static const String passwordTooShortError = 'A senha deve ter pelo menos 6 caracteres';
  static const String invalidCredentialsError = 'Usuário ou senha inválidos';

  // Labels de navegação
  static const String homeLabel = 'Página inicial';
  static const String exploreLabel = 'Explorar';
  static const String communityLabel = 'Comunidade';
  static const String notificationsLabel = 'Notificações';
  static const String settingsLabel = 'Configurações';

  // Labels de filtro
  static const String filterAll = 'Tudo';
  static const String filterPopCulture = 'Cultura pop';
  static const String filterComedy = 'Comédia';
  static const String filterRPG = 'Jogos de RPG';
  static const String filterTrueCrime = 'Crimes reais';
  static const String filterArtTutorials = 'Tutoriais de arte';
  static const String filterCrafts = 'Artesanato';
  static const String filterIllustration = 'Ilustração';
  static const String filterMusic = 'Música';
}

/// Classe para constantes de layout e dimensões
class AppDimensions {
  // Espaçamentos padrão
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingExtraLarge = 30.0;

  // Tamanhos de componentes
  static const double sidebarWidthExpanded = 250.0;
  static const double sidebarWidthCollapsed = 70.0;
  static const double creatorCardWidth = 160.0;
  static const double creatorCardImageHeight = 160.0;
  static const double avatarRadius = 24.0;

  // Border radius
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 15.0;
  static const double borderRadiusLarge = 25.0;

  // Animações
  static const Duration animationDuration = Duration(milliseconds: 300);
}
