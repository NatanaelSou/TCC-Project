# Script de Correção Automática de Problemas Dart

Este script (`fix_dart_issues.dart`) foi criado para corrigir automaticamente problemas comuns no código Dart em projetos Flutter, incluindo depreciações, contextos assíncronos e construtores const.

## Funcionalidades

### 1. Correção de `withOpacity` depreciado

- Substitui `.withOpacity(0.5)` por `.withValues(alpha: 0.5)`
- Corrige automaticamente todas as ocorrências no projeto

### 2. Adição de `const` aos construtores

- Adiciona `const` aos construtores de classes marcadas com `@immutable`
- Mantém a indentação correta do código

### 3. Avisos sobre BuildContext assíncrono

- Adiciona comentários de aviso onde o BuildContext pode ser usado incorretamente após `await`
- Serve como lembrete para revisões manuais

## Como usar

1. Execute o script na raiz do projeto Flutter:

   ```bash
   dart run fix_dart_issues.dart
   ```

2. O script irá:
   - Encontrar todos os arquivos `.dart` no diretório `lib/`
   - Aplicar as correções automaticamente
   - Mostrar quais arquivos foram corrigidos

3. Execute `flutter analyze` para verificar se os problemas foram resolvidos

## Limitações

- A correção de BuildContext assíncrono é básica e adiciona apenas comentários
- Para correções mais precisas de BuildContext, considere usar `dart fix` ou revisões manuais
- O script não corrige problemas de lógica, apenas padrões de código comuns

## Exemplo de saída

Iniciando correção automática de problemas Dart...
Corrigido: lib/presentation/screens/home_page.dart
Corrigido: lib/presentation/widgets/user_card.dart
Correção concluída. Arquivos corrigidos: 2

## Problemas corrigidos no projeto

- ✅ `withOpacity` depreciado → `withValues(alpha: ...)`
- ✅ Construtores const em classes `@immutable`
- ⚠️ Avisos sobre BuildContext assíncrono (comentários adicionados)

## Notas

- Sempre faça backup do código antes de executar correções automáticas
- Revise as mudanças aplicadas, especialmente em casos complexos
- Para projetos maiores, considere integrar com CI/CD para correções automáticas
