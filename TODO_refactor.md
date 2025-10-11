# TODO: Refatoração para Melhor Leitura do Código

## Arquivos Prioritários para Refatoração

### Flutter (lib/)

1. **lib/screens/landing_page.dart** (1000+ linhas) ✅ COMPLETADO
   - Quebrar em widgets menores: HeaderWidget, HeroSectionWidget, FeaturesSectionWidget, TestimonialsSectionWidget, FooterWidget, LoginModal, RegisterModal
   - Extrair métodos longos
   - Adicionar comentários explicativos em português

2. **lib/screens/home_page.dart** (500+ linhas) ✅ COMPLETADO
   - Extrair SidebarWidget, TopBarWidget, HomeContentWidget
   - Simplificar o método build com layouts separados para desktop e mobile
   - Adicionar comentários

3. **lib/screens/community_page.dart**
   - Verificar tamanho e complexidade
   - Refatorar se necessário

4. **lib/screens/post_detail_screen.dart**
   - Verificar e refatorar

5. **lib/widgets/post_creation_form.dart**
   - Verificar complexidade

### Backend (backend/)

1. **backend/controllers/** - Geralmente curtos, adicionar comentários se necessário
2. **backend/services/** - Verificar lógica complexa
3. **backend/routes/** - Adicionar comentários

## Melhorias Gerais

- Adicionar comentários explicativos em português para funções e classes
- Melhorar nomes de variáveis e métodos se ambíguos
- Quebrar funções muito longas
- Usar constantes para valores mágicos
- Organizar imports

## Etapas

1. Refatorar landing_page.dart
2. Refatorar home_page.dart
3. Verificar e refatorar outros screens/widgets
4. Adicionar comentários ao backend
5. Testar aplicação após refatorações
