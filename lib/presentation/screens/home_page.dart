// lib/presentation/screens/home_page.dart
//
// Package Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
// Resources Imports
import '../../core/constants/constants.dart';
import '../../data/mocks/mock_data.dart';
import '../../data/models/profile_models.dart';
import '../../providers/user_state.dart';
//
// Widget Imports
import '../widgets/sidebar_widget.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/home_content_widget.dart';
import '../widgets/content_type_bottom_sheet.dart';
//
// Screen Imports
import 'profile_page.dart';
import 'explore_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'search_results_page.dart';
import 'content_creation_page.dart';
import 'community_page.dart';

// - Pagina Inicial
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// - Estados da Página Inicial
class _HomePageState extends State<HomePage> {
  // === Estados da interface ===

  bool _sidebarExpanded = true;
  int _currentPageIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista de páginas
  static const List<Widget> _pages = [
    HomeContentWidget(),
    ExplorePage(),
    CommunityPage(),
    NotificationsPage(),
    SettingsPage(),
  ];

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

  // Layouts
  Widget _desktopLayout(UserState userState) {
    return Scaffold(
      body: Row(
        children: [
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
          Expanded(
            child: Column(
              children: [
                TopBarWidget(
                  onSearch: _handleSearch,
                  onCreateContent: _showContentTypeBottomSheet,
                  onProfileTap: _handleProfileTap,
                  userState: userState,
                ),
                Expanded(child: _pageContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabletLayout(UserState userState) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        foregroundColor: AppColors.iconDark,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.iconDark),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Página inicial'),
      ),
      drawer: SidebarWidget(
        expanded: true,
        currentPageIndex: _currentPageIndex,
        onPageChanged: (index) {
          _onPageChanged(index);
          Navigator.of(context).pop();
        },
        onToggle: () {},
        userState: userState,
        isDrawer: true,
      ),
      body: Column(
        children: [
          TopBarWidget(
            onSearch: _handleSearch,
            onCreateContent: _showContentTypeBottomSheet,
            onProfileTap: _handleProfileTap,
            userState: userState,
          ),
          Expanded(child: _pageContent()),
        ],
      ),
    );
  }

  Widget _mobileLayout(UserState userState) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        foregroundColor: AppColors.iconDark,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.iconDark),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Página inicial'),
      ),
      drawer: SidebarWidget(
        expanded: true,
        currentPageIndex: _currentPageIndex,
        onPageChanged: (index) {
          _onPageChanged(index);
          Navigator.of(context).pop();
        },
        onToggle: () {},
        userState: userState,
        isDrawer: true,
      ),
      body: Column(
        children: [
          TopBarWidget(
            onSearch: _handleSearch,
            onCreateContent: _showContentTypeBottomSheet,
            onProfileTap: _handleProfileTap,
            userState: userState,
          ),
          Expanded(child: _pageContent()),
        ],
      ),
    );
  }

  Widget _pageContent() {
    return Container(
      color: AppColors.background,
      child: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
    );
  }

  // - Construtor da interface
  @override
  Widget build(BuildContext context) {
    // Estado do Usuário e Filtros
    final userState = Provider.of<UserState>(context);
    //final filterManager = Provider.of<FilterManager>(context);

    // Layout responsivo
    return LayoutBuilder(
      builder: (context, constraints) {
        if      (constraints.maxWidth > 1000) { return _desktopLayout(userState); }
        else if (constraints.maxWidth > 600)  { return _tabletLayout(userState); }
        else { return _mobileLayout(userState); }
      },
    );
  }
}
