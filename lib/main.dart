// lib/main.dart
//
// Ponto de entrada da aplicação Flutter
// Configura providers globais e inicializa a interface
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Serviços e Estado
import 'services/api_service.dart';
import 'screens/landing_page.dart';
import 'user_state.dart';
import 'utils/filter_manager.dart';
import 'providers/theme_provider.dart';
import 'screens/community_chat_screen.dart';
import 'screens/community_mural_screen.dart';
import 'models/community_models.dart';

/// Ponto de entrada da aplicação
/// Inicializa o app com providers globais e configurações básicas
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa serviços
  final apiService = ApiService();

  // Testa conexão com API (opcional)
  try {
    await apiService.getUsers();
  } catch (e) {
    // Conexão falhou, mas continua
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => FilterManager()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

// App Principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'App Flutter + Node.js + mySQL',
          theme: theme.currentTheme,
          home: LandingPage(),
          routes: {
            '/community_chat': (context) => CommunityChatScreen(channel: ModalRoute.of(context)!.settings.arguments as Channel),
            '/community_mural': (context) => CommunityMuralScreen(channel: ModalRoute.of(context)!.settings.arguments as Channel),
          },
        );
      },
    );
  }
}
