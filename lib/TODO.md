# TODO: Refatoração do App Flutter

## Passos Pendentes da Refatoração

1. **Criar modelo User**: 
   - Arquivo: `lib/models/user.dart`
   - Implementar classe User com propriedades name, email, avatarUrl.
   - Incluir construtor fromJson para conversão de Map<String, dynamic>.
   - Incluir toJson para serialização.

2. **Criar utilitários de validação**:
   - Arquivo: `lib/utils/validators.dart`
   - Extrair lógica de validação de email, senha e outros campos de AuthService e login_screen.
   - Funções como validateEmail, validatePassword.

3. **Criar serviço base HTTP**:
   - Arquivo: `lib/services/http_service.dart`
   - Classe base com _baseUrl, _timeout, _defaultHeaders, _handleResponse.
   - Métodos genéricos para GET, POST, PUT, DELETE.

4. **Atualizar AuthService**:
   - Estender HttpService.
   - Usar modelo User em login e register (converter response para User).
   - Remover validações duplicadas (mover para validators).

5. **Atualizar ApiService**:
   - Estender HttpService.
   - Atualizar métodos para retornar List<User> ou User em vez de Map<String, dynamic>.

6. **Atualizar UserState**:
   - Usar instância de User em vez de propriedades separadas.
   - Atualizar métodos login, loginFromMap, logout, etc., para trabalhar com User.

7. **Atualizar login_screen**:
   - Usar funções de validators.dart para validação no Form.
   - Atualizar chamada de login para receber User e passar para UserState.

8. **Extrair lógica de filtros**:
   - Criar classe FilterManager em `lib/utils/filter_manager.dart`.
   - Extrair lógica de filtros de home_page.dart.
   - Gerenciar estado de filtros com ChangeNotifier se necessário.

9. **Testar a app**:
   - Executar `flutter run` para verificar UI e funcionalidade.
   - Testar login, navegação, filtros.
   - Verificar se não há quebras na funcionalidade existente.

## Progresso
- [ ] Passo 1: Modelo User criado
- [ ] Passo 2: Validators criados
- [ ] Passo 3: HttpService criado
- [ ] Passo 4: AuthService atualizado
- [ ] Passo 5: ApiService atualizado
- [ ] Passo 6: UserState atualizado
- [ ] Passo 7: login_screen atualizado
- [ ] Passo 8: FilterManager extraído
- [ ] Passo 9: Testes realizados

Atualize este arquivo conforme completar cada passo.
