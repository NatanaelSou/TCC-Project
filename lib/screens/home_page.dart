import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widgets personalizados
import '../widgets/sidebar_item.dart';
import '../widgets/filter_tag.dart';
import '../widgets/creator_section.dart';
import '../widgets/content_section.dart';
import '../widgets/content_type_bottom_sheet.dart';

// Serviços e Estado
import '../user_state.dart';
import '../utils/filter_manager.dart';
import '../utils/content_utils.dart';
import '../constants.dart';
import '../mock_data.dart';
import '../models/profile_models.dart';
import 'profile_page.dart';
import 'explore_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'search_results_page.dart';
import 'content_creation_page.dart';



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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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



  /// Constrói a página inicial com filtros e seções de criadores
  Widget _buildHomePage(FilterManager filterManager) {
    // Função para filtrar conteúdos pela categoria selecionada
    List<ProfileContent> filterContents(List<ProfileContent> contents) {
      // Sempre mostrar tudo por padrão
      if (filterManager.activeFilters.isEmpty || filterManager.isFilterActive('Todos')) {
        return contents;
      }
      return ContentUtils.filterContents(contents, filterManager.activeFilters);
    }

    // Função para verificar se um filtro está ativo
    bool isFilterActive(String filter) {
      return filterManager.isFilterActive(filter);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingExtraLarge, vertical: AppDimensions.spacingLarge),
      child: Column(
        children: [
          // Tags de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FilterManager.availableFilters.map((filter) => FilterTag(
                key: ValueKey(filter),
                label: filter,
                active: isFilterActive(filter),
                onTap: () => filterManager.toggleFilter(filter),
              )).toList(),
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
          SizedBox(height: AppDimensions.spacingExtraLarge),
          // Seções de conteúdo filtradas
          ContentSection(
            title: 'Em alta',
            contents: filterContents(mockRecentPosts),
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          ContentSection(
            title: 'Vídeos',
            contents: filterContents(mockVideos),
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          ContentSection(
            title: 'Conteúdo Exclusivo',
            contents: filterContents(mockExclusiveContent),
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          // Seção Ao vivo (placeholder)
          _buildLiveSection(),
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

  /// Constrói a seção Ao vivo (placeholder)
  Widget _buildLiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ao vivo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver tudo',
                style: TextStyle(
                  color: AppColors.btnSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingSmall),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          child: Center(
            child: Text(
              'Nenhuma transmissão ao vivo no momento',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    // Estado do Usuário e Filtros
    final userState = Provider.of<UserState>(context);
    final filterManager = Provider.of<FilterManager>(context);

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
                  duration: Duration(milliseconds: 800),
                  curve: Curves.fastOutSlowIn,
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
                            color: AppColors.iconDark,
                          ),
                          onPressed: _toggleSidebar,
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
                  child: Column(
                    children: [
                      // Top bar com busca e avatar
                      Container(
                        height: 70,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Barra de busca
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 600),
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
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchResultsPage(query: value.trim()),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Botões à direita
                            Row(
                              children: [
                                // Botão de criar conteúdo
                                IconButton(
                                  icon: Icon(Icons.add, color: AppColors.btnSecondary),
                                  onPressed: _showContentTypeBottomSheet,
                                  tooltip: 'Criar conteúdo',
                                ),
                                SizedBox(width: 10),
                                // Avatar do usuário
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfilePage()),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.btnSecondary,
                                    backgroundImage: userState.avatarUrl != null
                                        ? NetworkImage(userState.avatarUrl!)
                                        : null,
                                    child: userState.avatarUrl == null
                                        ? Icon(Icons.person, color: Colors.white)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Conteúdo das páginas
                      Expanded(
                        child: Container(
                          color: AppColors.background,
                          child: IndexedStack(
                            index: _currentPageIndex,
                            children: [
                              _buildHomePage(filterManager),
                              ExplorePage(),
                              _buildPlaceholderPage('Comunidade'),
                              NotificationsPage(),
                              SettingsPage(),
                            ],
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
                icon: Icon(Icons.menu, color: AppColors.iconDark),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text(_pageTitles[_currentPageIndex]),
            ),
            drawer: Drawer(
              backgroundColor: AppColors.sidebar,
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          SidebarItem(
                            icon: Icons.home,
                            label: _pageTitles[0],
                            active: _currentPageIndex == 0,
                            onTap: () {
                              setState(() => _currentPageIndex = 0);
                              Navigator.of(context).pop(); // Close drawer
                            },
                            expanded: true, // Always expanded in drawer
                          ),
                          SidebarItem(
                            icon: Icons.search,
                            label: _pageTitles[1],
                            active: _currentPageIndex == 1,
                            onTap: () {
                              setState(() => _currentPageIndex = 1);
                              Navigator.of(context).pop();
                            },
                            expanded: true,
                          ),
                          SidebarItem(
                            icon: Icons.chat,
                            label: _pageTitles[2],
                            active: _currentPageIndex == 2,
                            onTap: () {
                              setState(() => _currentPageIndex = 2);
                              Navigator.of(context).pop();
                            },
                            expanded: true,
                          ),
                          SidebarItem(
                            icon: Icons.notifications,
                            label: _pageTitles[3],
                            active: _currentPageIndex == 3,
                            onTap: () {
                              setState(() => _currentPageIndex = 3);
                              Navigator.of(context).pop();
                            },
                            expanded: true,
                          ),
                          SidebarItem(
                            icon: Icons.settings,
                            label: _pageTitles[4],
                            active: _currentPageIndex == 4,
                            onTap: () {
                              setState(() => _currentPageIndex = 4);
                              Navigator.of(context).pop();
                            },
                            expanded: true,
                          ),
                        ],
                      ),
                    ),
                    if (userState.isLoggedIn)
                      TextButton(
                        onPressed: () {
                          userState.logout();
                          setState(() {});
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                // Top bar com busca e avatar
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Barra de busca
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
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
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchResultsPage(query: value.trim()),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Spacer(),
                      // Botão de criar conteúdo
                      IconButton(
                        icon: Icon(Icons.add, color: AppColors.btnSecondary),
                        onPressed: _showContentTypeBottomSheet,
                        tooltip: 'Criar conteúdo',
                      ),
                      SizedBox(width: 10),
                      // Avatar do usuário
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.btnSecondary,
                          backgroundImage: userState.avatarUrl != null
                              ? NetworkImage(userState.avatarUrl!)
                              : null,
                          child: userState.avatarUrl == null
                              ? Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                // Conteúdo das páginas
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: IndexedStack(
                      index: _currentPageIndex,
                      children: [
                        _buildHomePage(filterManager),
                        ExplorePage(),
                        _buildPlaceholderPage('Comunidade'),
                        NotificationsPage(),
                        SettingsPage(),
                      ],
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
