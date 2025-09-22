// lib/main.dart
//
// package
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Serviços e Estado
import 'services/api_service.dart';
import 'screens/landing_page.dart';
import 'user_state.dart';

// Ponto de entrada
// inicialização do app
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
      ],
      child: MyApp(),
    ),
  );
  ApiService.getUsers().then((res) => print(res));
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
