# TODO: Remover Banco de Dados e APIs, Usar Dados Mock Estáticos

## Etapas para Tornar o App Estático

### 1. Criar Arquivo de Dados Mock
- [x] Criar `lib/mock_data.dart` com dados estáticos para usuários, perfis, posts, vídeos, tiers de suporte, etc.

### 2. Modificar Serviços
- [x] Modificar `lib/services/api_service.dart` para retornar dados mock ao invés de fazer chamadas HTTP
- [x] Modificar `lib/services/auth_service.dart` para simular login/registro com dados mock
- [x] Modificar `lib/services/http_service.dart` para remover dependências HTTP ou criar versão mock
- [x] Verificar e modificar `lib/services/profile_service.dart` se necessário

### 3. Modificar Telas
- [ ] Modificar `lib/screens/home_page.dart` para usar dados mock ao invés de estado dinâmico
- [ ] Modificar `lib/screens/profile_page.dart` para carregar dados mock diretamente
- [ ] Modificar `lib/screens/landing_page.dart` para funcionar sem APIs

### 4. Modificar Ponto de Entrada
- [ ] Modificar `lib/main.dart` para inicializar com dados mock e remover teste de conexão API

### 5. Ajustar Estado do Usuário
- [ ] Verificar e ajustar `lib/user_state.dart` para trabalhar com dados mock

### 6. Testar Funcionalidade
- [ ] Executar o app e verificar se funciona totalmente estático
- [ ] Verificar navegação, filtros, perfil, etc.
