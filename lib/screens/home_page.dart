import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widgets personalizados
import '../widgets/sidebar_widget.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/home_content_widget.dart';
import '../widgets/content_type_bottom_sheet.dart';

// Serviços e Estado
import '../user_state.dart';
import '../constants.dart';
import '../mock_data.dart';
import '../models/profile_models.dart';
import 'profile_page.dart';
import 'explore_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'search_results_page.dart';
import 'content_creation_page.dart';
import 'community_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado da interface
  bool _sidebarExpanded = true;
  int _currentPageIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Mostra o bottom sheet para seleção do tipo de conteúdo
  void _showContentTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ContentTypeBottomSheet(
        onTypeSelected: _onContentTypeSelected,
      ),
    );
  }

  /// Chamado quando um tipo de conteúdo é selecionado
  void _onContentTypeSelected(ContentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentCreationPage(contentType: type),
      ),
    ).then((result) {
      if (result != null && result is ProfileContent) {
        _onContentCreated(result);
      }
    });
  }

  /// Chamado quando um conteúdo é criado com sucesso
  void _onContentCreated(ProfileContent content) {
    // Adiciona o conteúdo aos dados mock
    addContentToMock(content);
    // Atualiza a interface
    setState(() {});
  }

  /// Função para navegar para resultados de busca
  void _handleSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(query: query),
      ),
    );
  }

  /// Função para navegar para perfil
  void _handleProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  /// Função para alternar sidebar
  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
  }

  /// Função para mudar página
  void _onPageChanged(int index) {
    setState(() => _currentPageIndex = index);
  }

  /// Lista de páginas disponíveis
  static const List<Widget> _pages = [
    HomeContentWidget(),
    ExplorePage(),
    CommunityPage(),
    NotificationsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Estado do Usuário e Filtros
    final userState = Provider.of<UserState>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 1000;

        if (isWideScreen) {
          // Layout para telas grandes (desktop)
          return Scaffold(
            body: Row(
              children: [
                // Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  child: SidebarWidget(
                    expanded: _sidebarExpanded,
                    currentPageIndex: _currentPageIndex,
                    onPageChanged: _onPageChanged,
                    onToggle: _toggleSidebar,
                    userState: userState,
                  ),
                ),
                // Conteúdo principal
                Expanded(
                  child: Column(
                    children: [
                      // Top bar
                      TopBarWidget(
                        onSearch: _handleSearch,
                        onCreateContent: _showContentTypeBottomSheet,
                        onProfileTap: _handleProfileTap,
                        userState: userState,
                      ),
                      // Conteúdo das páginas
                      Expanded(
                        child: Container(
                          color: AppColors.background,
                          child: IndexedStack(
                            index: _currentPageIndex,
                            children: _pages,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Layout para telas pequenas (mobile)
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: AppColors.sidebar,
              foregroundColor: AppColors.iconDark,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: AppColors.iconDark),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text('Página inicial'), // Título fixo ou dinâmico
            ),
            drawer: SidebarWidget(
              expanded: true,
              currentPageIndex: _currentPageIndex,
              onPageChanged: (index) {
                _onPageChanged(index);
                Navigator.of(context).pop(); // Close drawer
              },
              onToggle: () {}, // Não usado no drawer
              userState: userState,
              isDrawer: true,
            ),
            body: Column(
              children: [
                // Top bar
                TopBarWidget(
                  onSearch: _handleSearch,
                  onCreateContent: _showContentTypeBottomSheet,
                  onProfileTap: _handleProfileTap,
                  userState: userState,
                ),
                // Conteúdo das páginas
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: IndexedStack(
                      index: _currentPageIndex,
                      children: _pages,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
