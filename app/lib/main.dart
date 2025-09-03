import 'package:flutter/material.dart';

void main() { runApp(const MyApp()); } // Inicializa Aplicativo

//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Página inicial do app
      home: const MyHomePage(title: 'App Demo'),
    );
  }
}

//
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior do app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      // Corpo vazio
      body: const Center(
        child: Text(''), // Aqui você pode adicionar conteúdo futuramente
      ),
    );
  }
}
