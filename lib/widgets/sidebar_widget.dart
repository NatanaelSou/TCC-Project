import 'package:flutter/material.dart';
import '../constants.dart';
import '../user_state.dart';
import 'sidebar_item.dart';

/// Widget para a sidebar lateral da aplicação
class SidebarWidget extends StatelessWidget {
  final bool expanded;
  final int currentPageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onToggle;
  final UserState userState;
  final bool isDrawer; // Se é usado como drawer no mobile

  const SidebarWidget({
    super.key,
    required this.expanded,
    required this.currentPageIndex,
    required this.onPageChanged,
    required this.onToggle,
    required this.userState,
    this.isDrawer = false,
  });

  static const List<String> _pageTitles = [
    'Página inicial',
    'Explorar',
    'Comunidade',
    'Notificações',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expanded ? 250 : 70,
      color: AppColors.sidebar,
      padding: EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        children: [
          // Toggle sidebar (só se não for drawer)
          if (!isDrawer)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  expanded ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                  color: AppColors.iconDark,
                ),
                onPressed: onToggle,
              ),
            ),
          if (!isDrawer) SizedBox(height: AppDimensions.spacingLarge),
          // Itens da Sidebar
          Expanded(
            child: ListView(
              children: [
                SidebarItem(
                  icon: Icons.home,
                  label: _pageTitles[0],
                  active: currentPageIndex == 0,
                  onTap: () => onPageChanged(0),
                  expanded: expanded || isDrawer,
                ),
                SidebarItem(
                  icon: Icons.search,
                  label: _pageTitles[1],
                  active: currentPageIndex == 1,
                  onTap: () => onPageChanged(1),
                  expanded: expanded || isDrawer,
                ),
                SidebarItem(
                  icon: Icons.chat,
                  label: _pageTitles[2],
                  active: currentPageIndex == 2,
                  onTap: () => onPageChanged(2),
                  expanded: expanded || isDrawer,
                ),
                SidebarItem(
                  icon: Icons.notifications,
                  label: _pageTitles[3],
                  active: currentPageIndex == 3,
                  onTap: () => onPageChanged(3),
                  expanded: expanded || isDrawer,
                ),
                SidebarItem(
                  icon: Icons.settings,
                  label: _pageTitles[4],
                  active: currentPageIndex == 4,
                  onTap: () => onPageChanged(4),
                  expanded: expanded || isDrawer,
                ),
              ],
            ),
          ),
          // Logout se logado
          if (userState.isLoggedIn)
            TextButton(
              onPressed: () {
                userState.logout();
                // Se for drawer, fechar
                if (isDrawer) Navigator.of(context).pop();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
