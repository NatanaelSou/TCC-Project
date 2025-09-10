import 'package:flutter/material.dart';

// ---------- Inicializa aplicação ----------
void main() {
  runApp(const MyApp());
}

// Aplicação
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conteúdo Premio',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

// ---------- Pagina da Aplicação ----------

// Pagina Inicial
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black, // cor de fundo
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // ação do botão no header
            },
          ),
        ],
      ),
      
      body: Center(
        child: ElevatedButton(
          child: const Text("Ir para a Segunda Página"),
          onPressed: () {
            // Aqui acontece a navegação 👇
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecondPage()),
            );
          },
        ),
      ),
    );
  }
}

// Pagina Segundaria
class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Segunda Página")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Voltar"),
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
      ),
    );
  }
}
