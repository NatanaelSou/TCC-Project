import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widgets personalizados
import '../widgets/sidebar_item.dart';
import '../widgets/filter_tag.dart';
import '../widgets/creator_section.dart';

// Serviços e Estado
import '../user_state.dart';
import '../utils/filter_manager.dart';
import '../constants.dart';



/// Tela principal da aplicação com navegação e filtros
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado da interface
  bool _sidebarExpanded = true;
  int _currentPageIndex = 0;

  // Lista de páginas disponíveis
  static const List<String> _pageTitles = [
    'Página inicial',
    'Explorar',
    'Comunidade',
    'Notificações',
    'Configurações',
  ];

  /// Alterna o estado da sidebar
  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
  }



  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    // Estado do Usuário e Filtros
    final userState = Provider.of<UserState>(context);
    final filterManager = Provider.of<FilterManager>(context);

    // Layout Principal
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _sidebarExpanded ? 250 : 70,
            color: AppColors.sidebar,
            padding: EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              children: [
                // Toggle sidebar
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _sidebarExpanded
                          ? Icons.arrow_back_ios
                          : Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSidebar,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingSmall),
                // Avatar do usuário
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.sidebarItemActive,
                  backgroundImage: userState.avatarUrl != null
                      ? NetworkImage(userState.avatarUrl!)
                      : null,
                  child: userState.avatarUrl == null
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                ),

                // Nome do usuário
                if (_sidebarExpanded && userState.isLoggedIn)
                  Padding(
                    padding: EdgeInsets.only(top: AppDimensions.spacingSmall),
                    child: Text(
                      userState.name ?? 'Usuário',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: AppDimensions.spacingLarge),
                // Itens da Sidebar
                Expanded(
                  child: ListView(
                    children: [
                      SidebarItem(
                        icon: Icons.home,
                        label: _pageTitles[0],
                        active: _currentPageIndex == 0,
                        onTap: () => setState(() => _currentPageIndex = 0),
                        expanded: _sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.search,
                        label: _pageTitles[1],
                        active: _currentPageIndex == 1,
                        onTap: () => setState(() => _currentPageIndex = 1),
                        expanded: _sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.chat,
                        label: _pageTitles[2],
                        active: _currentPageIndex == 2,
                        onTap: () => setState(() => _currentPageIndex = 2),
                        expanded: _sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.notifications,
                        label: _pageTitles[3],
                        active: _currentPageIndex == 3,
                        onTap: () => setState(() => _currentPageIndex = 3),
                        expanded: _sidebarExpanded,
                      ),
                      SidebarItem(
                        icon: Icons.settings,
                        label: _pageTitles[4],
                        active: _currentPageIndex == 4,
                        onTap: () => setState(() => _currentPageIndex = 4),
                        expanded: _sidebarExpanded,
                      ),
                    ],
                  ),
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
              color: AppColors.background,
              child: IndexedStack(
                index: _currentPageIndex,
                children: [
                  _buildHomePage(filterManager),
                  _buildPlaceholderPage('Explorar'),
                  _buildPlaceholderPage('Comunidade'),
                  _buildPlaceholderPage('Notificações'),
                  _buildPlaceholderPage('Configurações'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a página inicial com filtros e seções de criadores
  Widget _buildHomePage(FilterManager filterManager) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingExtraLarge, vertical: AppDimensions.spacingLarge),
      child: Column(
        children: [
          // Barra de busca
          Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacingLarge),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar criadores ou tópicos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLarge),
              ),
            ),
          ),

          // Tags de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterTag(
                  label: AppStrings.filterAll,
                  active: filterManager.isFilterActive(AppStrings.filterAll),
                  onTap: () => filterManager.toggleFilter(AppStrings.filterAll),
                ),
                FilterTag(
                  label: 'Cultura pop',
                  active: filterManager.isFilterActive('Cultura pop'),
                  onTap: () => filterManager.toggleFilter('Cultura pop'),
                ),
                FilterTag(
                  label: 'Comédia',
                  active: filterManager.isFilterActive('Comédia'),
                  onTap: () => filterManager.toggleFilter('Comédia'),
                ),
                FilterTag(
                  label: 'Jogos de RPG',
                  active: filterManager.isFilterActive('Jogos de RPG'),
                  onTap: () => filterManager.toggleFilter('Jogos de RPG'),
                ),
                FilterTag(
                  label: 'Crimes reais',
                  active: filterManager.isFilterActive('Crimes reais'),
                  onTap: () => filterManager.toggleFilter('Crimes reais'),
                ),
                FilterTag(
                  label: 'Tutoriais de arte',
                  active: filterManager.isFilterActive('Tutoriais de arte'),
                  onTap: () => filterManager.toggleFilter('Tutoriais de arte'),
                ),
                FilterTag(
                  label: 'Artesanato',
                  active: filterManager.isFilterActive('Artesanato'),
                  onTap: () => filterManager.toggleFilter('Artesanato'),
                ),
                FilterTag(
                  label: 'Ilustração',
                  active: filterManager.isFilterActive('Ilustração'),
                  onTap: () => filterManager.toggleFilter('Ilustração'),
                ),
                FilterTag(
                  label: 'Música',
                  active: filterManager.isFilterActive('Música'),
                  onTap: () => filterManager.toggleFilter('Música'),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.spacingExtraLarge),
          // Seções de criadores
          CreatorSection(
            title: 'Principais criadores',
            activeFilters: filterManager.activeFilters,
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          CreatorSection(
            title: 'Em alta esta semana',
            activeFilters: filterManager.activeFilters,
          ),
        ],
      ),
    );
  }

  /// Constrói páginas placeholder para outras seções
  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
