// lib/screens/home_page.dart
//
// Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widgets personalizados
import '../widgets/sidebar_item.dart';
import '../widgets/filter_tag.dart';
import '../widgets/creator_section.dart';

// Serviços e Estado
import '../user_state.dart';
import '../constants.dart';

// Telas
import 'login_screen.dart';

// Tela Principal - Widget
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

// Tela Principal - Estado
class _HomePageState extends State<HomePage> {
  // Estado da Sidebar e Página Atual
  bool sidebarExpanded = true;
  int currentPageIndex = 0;

  // Alterna o estado da sidebar
  void _toggleSidebar() {
    setState(() => sidebarExpanded = !sidebarExpanded);
  }

  // Mostra o modal de login/Registrar-se
  void _showLoginModal() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(20), // espaço das bordas da tela
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // tamanho baseado no conteúdo
            children: [
              LoginScreen(
                onLoginSuccess: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    // Estado do Usuário
    final userState = Provider.of<UserState>(context);

    // Layout Principal
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: sidebarExpanded ? 250 : 70,
            color: AppColors.sidebar,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Toggle sidebar
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      sidebarExpanded
                          ? Icons.arrow_back_ios
                          : Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSidebar,
                  ),
                ),
                SizedBox(height: 10), // espaço
                // Avatar -> sera troacado por Titulo e Logotipo do App
                // Avatar do usuário
                GestureDetector(
                  onTap: userState.isLoggedIn ? null : _showLoginModal,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.sidebarItemActive,
                    backgroundImage: userState.avatarUrl != null
                        ? NetworkImage(userState.avatarUrl!)
                        : null,
                    child: userState.avatarUrl == null
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),

                // Nome do usuário
                if (sidebarExpanded && userState.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      userState.name ?? 'Usuário',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: 20), // espaço
                // Itens da Sidebar
                Expanded(
                  child: ListView(
                    children: [
                      SidebarItem(
                        icon: Icons.home,
                        label: 'Página inicial',
                        active: currentPageIndex == 0,
                        onTap: () => setState(() => currentPageIndex = 0),
                        expanded: sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.search,
                        label: 'Explorar',
                        active: currentPageIndex == 1,
                        onTap: () => setState(() => currentPageIndex = 1),
                        expanded: sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.chat,
                        label: 'Comunidade',
                        active: currentPageIndex == 2,
                        onTap: () => setState(() => currentPageIndex = 2),
                        expanded: sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.notifications,
                        label: 'Notificações',
                        active: currentPageIndex == 3,
                        onTap: () => setState(() => currentPageIndex = 3),
                        expanded: sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.settings,
                        label: 'Configurações',
                        active: currentPageIndex == 4,
                        onTap: () => setState(() => currentPageIndex = 4),
                        expanded: sidebarExpanded,
                      ),
                    ],
                  ),
                ),
                // Prompt para se tornar criador ou botão de logout
                if (!userState.isLoggedIn)
                  SidebarPrompt(onPressed: _showLoginModal),
                if (userState.isLoggedIn)
                  TextButton(
                    onPressed: () {
                      userState.logout();
                      setState(() {});
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo principal
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: IndexedStack(
                index: currentPageIndex,
                children: [
                  _buildHomePage(),
                  Center(child: Text('Explorar')),
                  Center(child: Text('Comunidade')),
                  Center(child: Text('Notificações')),
                  Center(child: Text('Configurações')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          // Barra de busca
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar criadores ou tópicos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),

          // Tags de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterTag(label: 'Tudo', active: true),
                FilterTag(label: 'Cultura pop'),
                FilterTag(label: 'Comédia'),
                FilterTag(label: 'Jogos de RPG'),
                FilterTag(label: 'Crimes reais'),
                FilterTag(label: 'Tutoriais de arte'),
                FilterTag(label: 'Artesanato'),
                FilterTag(label: 'Ilustração'),
                FilterTag(label: 'Música'),
              ],
            ),
          ),
          SizedBox(height: 30),
          // Seções de criadores
          CreatorSection(title: 'Principais criadores'),
          SizedBox(height: 20),
          CreatorSection(title: 'Em alta esta semana'),
        ],
      ),
    );
  }
}

// Widget SidebarPrompt
class SidebarPrompt extends StatelessWidget {
  final VoidCallback? onPressed;
  const SidebarPrompt({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.sidebarPromptBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.sidebarPromptShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seja um criador',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(icon: Icon(Icons.close), onPressed: () {}),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Crie uma assinatura para seus fãs e receba para criar da forma que quiser.',
          ),
          SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.btnSecondary,
              shape: StadiumBorder(),
            ),
            onPressed: onPressed,
            child: Text('Comece agora mesmo'),
          ),
        ],
      ),
    );
  }
}
