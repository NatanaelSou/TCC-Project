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
    return MaterialApp(
      title: 'App Flutter + Node.js + mySQL',
      home: LandingPage(),
    );
  }
}
