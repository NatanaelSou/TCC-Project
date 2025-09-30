# Implementation Plan

Criar telas funcionais para "Explorar", "Notificações" e "Configurações" no app Flutter, seguindo o padrão de design existente e integrando com o sistema de navegação.

[Overview]
O app atualmente possui uma página inicial (HomePage) com navegação via sidebar, mas as telas "Explorar", "Notificações" e "Configurações" são apenas placeholders. Este plano implementa essas telas com funcionalidades básicas, mantendo consistência visual e integração com o estado do usuário e filtros. A tela Explorar permitirá descoberta de conteúdo, Notificações mostrará atividades do usuário, e Configurações permitirá ajustes de conta.

[Types]
Nenhuma alteração nos tipos existentes. Os modelos ProfileContent, User, etc., serão reutilizados.

[Files]
Novos arquivos de tela:
- lib/screens/explore_page.dart: Tela de exploração com busca avançada e filtros
- lib/screens/notifications_page.dart: Tela de notificações com lista de atividades
- lib/screens/settings_page.dart: Tela de configurações com opções de conta

Modificações em arquivos existentes:
- lib/screens/home_page.dart: Substituir placeholders por navegação real para as novas telas

[Functions]
Novas funções:
- explore_page.dart: _performSearch(), _applyFilters()
- notifications_page.dart: _loadNotifications(), _markAsRead()
- settings_page.dart: _updateProfile(), _changePassword()

[Classes]
Novas classes:
- ExplorePage: StatefulWidget com busca e filtros
- NotificationsPage: StatefulWidget com lista de notificações
- SettingsPage: StatefulWidget com formulários de configuração

[Dependencies]
Nenhuma nova dependência necessária. Utilizar pacotes existentes (provider, flutter/material).

[Testing]
Testar navegação entre telas, funcionalidade de busca/filtros na exploração, marcação de notificações como lidas, e atualização de configurações.

[Implementation Order]
1. Criar explore_page.dart com layout básico e integração de filtros
2. Criar notifications_page.dart com lista mock de notificações
3. Criar settings_page.dart com opções básicas de conta
4. Atualizar home_page.dart para navegar para as novas telas
