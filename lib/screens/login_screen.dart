// lib/screens/login_screen.dart 
//
// package
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

// Serviços e Estado
import '../services/auth_service.dart';
import '../user_state.dart';

// Tela de Login
class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginScreen({this.onLoginSuccess, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Tela de Login
class _LoginScreenState extends State<LoginScreen> {
  // Varaiveis de Controle
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variaveis de Estado
  final AuthService authService = AuthService();
  String? _emailError;
  String? _passwordError;

  // Helper function para links
  // mudar formatação dependendo do tamanho da tela
  List<Widget> _buildLinks() => [
    // Esqueceu a senha?
    GestureDetector(
      onTap: () {},
      child: Text(
        'Esqueceu a senha?',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
    SizedBox(width: 20, height: 10), // espaço entre links
    // Cadastre-se
    Expanded(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(text: 'Não tem uma conta? '),
            TextSpan(
              text: 'Cadastre-se',
              style: TextStyle(
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
          ],
        ),
      ),
    ),
  ];

  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 500, // largura máxima do login
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Título ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                // --- Email Input ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      errorText: _emailError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O email não pode estar vazio';
                      }
                      // validação simples de formato
                      if (!value.contains('@')) {
                        return 'Digite um email válido';
                      }
                      return null;
                    },
                  ),
                ),

                // --- Password Input ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      errorText: _passwordError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A senha não pode estar vazia';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ),

                // --- Privacy Policy ---
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (bool? value) {}),
                    Expanded(
                      // ← já corrige o overflow
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: 'Li e aceito a '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // --- Login Button ---
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                          _emailError = null;
                          _passwordError = null;
                        });
                      if (_formKey.currentState!.validate()) {
                        try {
                          final result = await authService.login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );

                          // usa o método loginFromMap, mais simples
                          Provider.of<UserState>(
                            context,
                            listen: false,
                          ).loginFromMap(result);

                          setState(() {}); // atualiza tela sem mudar de página
                        } catch (e) {
                          setState(() {
                            _emailError = "Usuário ou senha inválidos";
                          });
                          _formKey.currentState!.validate();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: StadiumBorder(),
                    ),
                    child: Text('Entrar'),
                  ),
                ),

                // --- Additional Links ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool useColumn = constraints.maxWidth < 360;

                    return useColumn
                        ? Column(children: [..._buildLinks()])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [..._buildLinks()],
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
