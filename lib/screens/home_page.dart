// lib/screens/home_page.dart
//
// Tela principal da aplicação
// Contém a sidebar de navegação e o conteúdo principal com filtros funcionais
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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Tela Principal - Estado
class _HomePageState extends State<HomePage> {
  // Estado da Sidebar e Página Atual
  bool sidebarExpanded = true; // Controla se a sidebar está expandida ou retraída
  int currentPageIndex = 0; // Índice da página atual (0 = Home, 1 = Explorar, etc.)
  bool showCreatorPrompt = true; // Controla se o prompt de se tornar criador deve ser exibido

  // Estado dos filtros ativos (múltiplos filtros podem ser selecionados)
  List<String> activeFilters = ['Tudo']; // Categorias de filtro selecionadas atualmente

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

  // Função para lidar com mudança de filtro (múltiplos filtros)
  void _onFilterChanged(String filter) {
    setState(() {
      if (filter == 'Tudo') {
        // Se "Tudo" for selecionado, limpa todos os outros filtros
        activeFilters = ['Tudo'];
      } else {
        // Remove "Tudo" se outro filtro for selecionado
        activeFilters.remove('Tudo');

        // Adiciona ou remove o filtro da lista
        if (activeFilters.contains(filter)) {
          activeFilters.remove(filter);
          // Se nenhum filtro estiver ativo, volta para "Tudo"
          if (activeFilters.isEmpty) {
            activeFilters = ['Tudo'];
          }
        } else {
          activeFilters.add(filter);
        }
      }
    });
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
                if (!userState.isLoggedIn && sidebarExpanded && showCreatorPrompt)
                  SidebarPrompt(
                    onPressed: _showLoginModal,
                    expanded: sidebarExpanded,
                    onClose: () {
                      // Fecha o prompt quando X é clicado
                      setState(() {
                        showCreatorPrompt = false;
                      });
                    },
                  ),
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
              color: const Color(0xFFF5F5F5),
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

          // Tags de filtro - Sistema de filtragem funcional por categoria
          // Cada tag é clicável e altera o estado do filtro ativo
          // Quando uma tag é clicada, chama _onFilterChanged para atualizar o estado
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtro "Tudo" - mostra todo o conteúdo disponível
                FilterTag(
                  label: 'Tudo',
                  active: activeFilters.contains('Tudo'),
                  onTap: () => _onFilterChanged('Tudo'),
                ),
                // Filtro "Cultura pop" - filtra conteúdo relacionado a cultura pop
                FilterTag(
                  label: 'Cultura pop',
                  active: activeFilters.contains('Cultura pop'),
                  onTap: () => _onFilterChanged('Cultura pop'),
                ),
                // Filtro "Comédia" - filtra conteúdo de comédia e humor
                FilterTag(
                  label: 'Comédia',
                  active: activeFilters.contains('Comédia'),
                  onTap: () => _onFilterChanged('Comédia'),
                ),
                // Filtro "Jogos de RPG" - filtra conteúdo de jogos de RPG
                FilterTag(
                  label: 'Jogos de RPG',
                  active: activeFilters.contains('Jogos de RPG'),
                  onTap: () => _onFilterChanged('Jogos de RPG'),
                ),
                // Filtro "Crimes reais" - filtra conteúdo sobre crimes reais
                FilterTag(
                  label: 'Crimes reais',
                  active: activeFilters.contains('Crimes reais'),
                  onTap: () => _onFilterChanged('Crimes reais'),
                ),
                // Filtro "Tutoriais de arte" - filtra conteúdo de tutoriais de arte
                FilterTag(
                  label: 'Tutoriais de arte',
                  active: activeFilters.contains('Tutoriais de arte'),
                  onTap: () => _onFilterChanged('Tutoriais de arte'),
                ),
                // Filtro "Artesanato" - filtra conteúdo de artesanato e DIY
                FilterTag(
                  label: 'Artesanato',
                  active: activeFilters.contains('Artesanato'),
                  onTap: () => _onFilterChanged('Artesanato'),
                ),
                // Filtro "Ilustração" - filtra conteúdo de ilustração
                FilterTag(
                  label: 'Ilustração',
                  active: activeFilters.contains('Ilustração'),
                  onTap: () => _onFilterChanged('Ilustração'),
                ),
                // Filtro "Música" - filtra conteúdo relacionado a música
                FilterTag(
                  label: 'Música',
                  active: activeFilters.contains('Música'),
                  onTap: () => _onFilterChanged('Música'),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          // Seções de criadores com filtros ativos (múltiplos filtros)
          CreatorSection(
            title: 'Principais criadores',
            activeFilters: activeFilters,
          ),
          SizedBox(height: 20),
          CreatorSection(
            title: 'Em alta esta semana',
            activeFilters: activeFilters,
          ),
        ],
      ),
    );
  }
}


