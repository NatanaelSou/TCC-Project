// lib/screens/home_page.dart
//
// package
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';

// Serviços e Estado
import '../services/auth_service.dart';
import '../user_state.dart';
//import '../constants.dart';

// Tela de Login
class HomePage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const HomePage({super.key, this.onLoginSuccess});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Tela de Login - Estado
class _HomePageState extends State<HomePage> {
  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isMobile) // Se for mobile
    {
      return Scaffold(
        appBar: myMobileHeader(context),
        drawer: mySidebarMenuMobile(context),
        body: Center(child: Text("Layout Mobile")),
        bottomNavigationBar: myMobileFooter(context),
      );
    } else if (ResponsiveBreakpoints.of(context).isTablet) // Se for tablet
    {
      return Scaffold(
        appBar: myTabletHeader(context),
        drawer: mySidebarMenu(context),
        body: Center(child: Text("Layout Tablet")),
      );
    } else // Se for desktop
    {
      return Scaffold(
        appBar: myDesktopHeader(context),
        drawer: mySidebarMenu(context),
        body: Center(child: Text("Layout Desktop")),
      );
    }
  }
}

// Header Desktop
AppBar myDesktopHeader(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 2,
    titleSpacing: 0,
    automaticallyImplyLeading: false,
    title: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 INÍCIO: botão menu + logo + nome
          Row(
            children: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu, color: Colors.black87),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              SizedBox(width: 8),
              Icon(
                Icons.flutter_dash,
                color: Colors.blue,
                size: 28,
              ), // logotipo
              SizedBox(width: 8),
              Text(
                "MeuApp",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          Spacer(), // Gap entre seções
          // 🔹 MEIO: barra de pesquisa + microfone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: 600,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Pesquisar...",
                        border: InputBorder.none,
                      ),
                      onTap: () {
                        // 🔹 aqui no mobile já abre o teclado automaticamente
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.black54),
                    onPressed: () {
                      // ação de busca
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.black54),
                    onPressed: () {
                      // ação microfone
                    },
                  ),
                ],
              ),
            ),
          ),

          Spacer(), // Gap entre seções
          // 🔹 FIM: configurações + login
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.black87),
                onPressed: () {
                  // abrir menu de opções
                },
              ),
              TextButton.icon(
                onPressed: () {
                  showAuthDialog(context);
                },
                icon: Icon(Icons.person, color: Colors.black87),
                label: Text(
                  "Fazer login",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Header Tablet
AppBar myTabletHeader(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 2,
    titleSpacing: 0,
    automaticallyImplyLeading: false,
    title: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 INÍCIO: botão menu + logo + nome
          Row(
            children: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu, color: Colors.black87),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              SizedBox(width: 8),
              Icon(
                Icons.flutter_dash,
                color: Colors.blue,
                size: 28,
              ), // logotipo
              SizedBox(width: 8),
              Text(
                "MeuApp",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          Spacer(), // Gap entre seções
          // 🔹 MEIO: barra de pesquisa + microfone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Pesquisar...",
                        border: InputBorder.none,
                      ),
                      onTap: () {
                        // 🔹 aqui no mobile já abre o teclado automaticamente
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.black54),
                    onPressed: () {
                      // ação de busca
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.black54),
                    onPressed: () {
                      // ação microfone
                    },
                  ),
                ],
              ),
            ),
          ),

          Spacer(), // Gap entre seções
          // 🔹 FIM: configurações + login
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.black87),
                onPressed: () {
                  // abrir menu de opções
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.black87),
                onPressed: () {
                  showAuthDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Header Mobile
AppBar myMobileHeader(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 2,
    titleSpacing: 0,
    toolbarHeight: 120, // aumenta a altura do AppBar
    automaticallyImplyLeading: false,
    title: Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 LINHA SUPERIOR: logo + notificações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.flutter_dash, color: Colors.blue, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "MeuApp",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.black87),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.black87),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          // 🔹 LINHA INFERIOR: bússola + filtros + feedback
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // importante
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(Icons.explore, color: Colors.blue),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                SizedBox(width: 8),
                Row(
                  children: [
                    FilterButton(label: 'Todos'),
                    FilterButton(label: 'Hypes'),
                    FilterButton(label: 'Ao vivo'),
                    FilterButton(label: 'Jogos'),
                    FilterButton(label: 'Músicas'),
                    FilterButton(label: 'Animes'),
                    FilterButton(label: 'Desenhos'),
                    FilterButton(label: 'Animais'),
                    FilterButton(label: 'Novidades para você'),
                  ],
                ),
                SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Feedback',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Drawer mySidebarMenu(BuildContext context) {
  return Drawer(
    child: SafeArea(
      child: SingleChildScrollView(
        // permite rolagem vertical
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Cabeçalho: Menu + Logo + Título
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue,
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                        },
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.flutter_dash, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "MeuApp",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Botões principais
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Início"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.explore),
              title: Text("Explorar"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Comunidades"),
              onTap: () {},
            ),

            Divider(), // Linha divisória
            // 🔹 Popup de login/criação de conta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // fundo do box
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Faça login para curtir vídeos, comentar e se inscrever.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // ação de login
                        },
                        icon: Icon(Icons.login, color: Colors.blue),
                        label: Text(
                          "Fazer Login",
                          style: TextStyle(color: Colors.blue),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue),
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text("Você"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Histórico"),
              onTap: () {},
            ),

            Divider(), // Linha divisória
            // 🔹 Configurações gerais
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Configurações"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text("Ajuda"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text("Feedback"),
              onTap: () {},
            ),

            Divider(), // Linha divisória
            // 🔹 Informações de rodapé
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "Sobre",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(
                "Sobre 2",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "© 2025 Minha Empresa",
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Drawer mySidebarMenuMobile(BuildContext context) {
  return Drawer(
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              // rolagem vertical
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Cabeçalho: Menu + Logo + Título
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.blue,
                    child: Row(
                      children: [
                        Icon(Icons.flutter_dash, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text(
                          "MeuApp",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Botões principais
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text("Início"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.explore),
                    title: Text("Explorar"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text("Comunidades"),
                    onTap: () {},
                  ),

                  Divider(), // Linha divisória

                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Você"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text("Histórico"),
                    onTap: () {},
                  ),

                  Divider(), // Linha divisória
                  // 🔹 Configurações gerais
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Configurações"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text("Ajuda"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback),
                    title: Text("Feedback"),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Rodapé fixo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "© 2025 Minha Empresa",
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget myMobileFooter(BuildContext context) {
  return BottomAppBar(
    color: Colors.white,
    elevation: 8,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.home, color: Colors.black87),
          onPressed: () {
            // ação início
          },
        ),
        IconButton(
          icon: Icon(Icons.search, color: Colors.black87),
          onPressed: () {
            // ação pesquisa
          },
        ),
        // 🔹 Botão "Mais" destacado
        Container(
          decoration: BoxDecoration(
            color: Colors.blue, // destaque no botão
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // ação criar / mais
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.group, color: Colors.black87),
          onPressed: () {
            // ação comunidade
          },
        ),
        IconButton(
          icon: Icon(Icons.person, color: Colors.black87),
          onPressed: () {
            // ação perfil
          },
        ),
      ],
    ),
  );
}

Future<void> showAuthDialog(BuildContext context) {
  bool isLogin = true;
  bool obscurePassword = true;
  bool acceptTerms = false;

  // 🔹 Controladores e validação
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // 🔹 Variáveis de erro
  String? emailError;
  String? passwordError;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          InputDecoration inputStyle(
            String label,
            IconData icon,
            bool isPassword, {
            String? errorText,
          }) {
            return InputDecoration(
              labelText: label,
              errorText: errorText,
              prefixIcon: Icon(icon, color: Colors.blue),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            );
          }

          Widget buildLoginForm() {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Email
                  TextFormField(
                    controller: emailController,
                    decoration: inputStyle(
                      "Email",
                      Icons.email,
                      false,
                      errorText: emailError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "O email não pode estar vazio";
                      }
                      if (!value.contains("@")) {
                        return "Digite um email válido";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // 🔹 Senha
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: inputStyle(
                      "Senha",
                      Icons.lock,
                      true,
                      errorText: passwordError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "A senha não pode estar vazia";
                      }
                      if (value.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // 🔹 Botão Login
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        emailError = null;
                        passwordError = null;
                      });

                      if (!formKey.currentState!.validate()) return;
                      
                      // se passou na validação, tenta logar
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      // obtém o estado do usuário
                      final userState = Provider.of<UserState>(context, listen: false);
                      final navigator = Navigator.of(context);

                      try {
                        final result = await AuthService().login(
                          email,
                          password,
                        );

                        userState.loginFromMap(result);

                        // apenas fecha o dialog, sem mudar a página
                        navigator.pop();
                      } catch (e) {
                        setState(() {
                          emailError = "Usuário ou senha inválidos";
                        });
                        formKey.currentState!.validate();
                      }
                    },
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text(
                      "Entrar",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  TextButton(
                    onPressed: () => setState(() => isLogin = false),
                    child: Text("Não tem conta? Criar agora"),
                  ),
                ],
              ),
            );
          }

          Widget buildRegisterForm() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(decoration: inputStyle("Nome", Icons.person, false)),
                SizedBox(height: 12),
                TextField(decoration: inputStyle("Email", Icons.email, false)),
                SizedBox(height: 12),
                TextField(
                  decoration: inputStyle("Senha", Icons.lock, true),
                  obscureText: obscurePassword,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: acceptTerms,
                      onChanged: (v) => setState(() => acceptTerms = v!),
                    ),
                    Expanded(
                      child: Text(
                        "Aceito os termos de serviço e política de privacidade",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: acceptTerms
                      ? () {
                          Navigator.pop(context);
                        }
                      : null,
                  icon: Icon(Icons.person_add, color: Colors.white),
                  label: Text(
                    "Registrar",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => isLogin = true),
                  child: Text("Já tem conta? Entrar"),
                ),
              ],
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Center(
              child: Text(
                isLogin ? "Bem-vindo de volta" : "Crie sua conta",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            content: SizedBox(
              width: ResponsiveBreakpoints.of(context).isMobile
                  ? MediaQuery.of(context).size.width * 1
                  : ResponsiveBreakpoints.of(context).isTablet
                  ? MediaQuery.of(context).size.width * 0.4
                  : MediaQuery.of(context).size.width * 0.25,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: isLogin ? buildLoginForm() : buildRegisterForm(),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// 🔹 Widget auxiliar para botões de filtro
class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const FilterButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[200],
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ),
    );
  }
}
