# Contribuição para o Projeto Premiora

Bem-vindo! Agradecemos seu interesse em contribuir para o Premiora, uma plataforma que une conteúdo, comunidade e monetização para criadores.

## Como Contribuir

### Padrões de Commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/) para manter um histórico claro e automatizar o versionamento.

Formato: `<tipo>(<escopo>): <descrição>`

Tipos:

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças na documentação
- `style`: Mudanças de estilo (formatação, etc.)
- `refactor`: Refatoração de código
- `test`: Adição ou correção de testes
- `chore`: Mudanças em ferramentas, configurações

Exemplos:

- `feat(auth): adicionar login com Google`
- `fix(ui): corrigir alinhamento do botão`
- `docs(readme): atualizar instruções de instalação`

### Pull Requests

1. Fork o repositório
2. Crie uma branch para sua feature: `git checkout -b feat/nome-da-feature`
3. Faça suas mudanças
4. Adicione testes se aplicável
5. Certifique-se de que todos os testes passam
6. Commit suas mudanças seguindo os padrões acima
7. Push para sua branch: `git push origin feat/nome-da-feature`
8. Abra um Pull Request descrevendo as mudanças

### Estilo de Código

- **Flutter/Dart**: Siga as [diretrizes oficiais do Dart](https://dart.dev/guides/language/effective-dart)
- **Node.js**: Use ESLint com as regras padrão
- **JavaScript**: Camel case para variáveis/funções, Pascal case para classes
- **Comentários**: Em português para explicar lógica complexa, apenas quando trabalhando no código

### Testes

- Adicione testes unitários para novas funcionalidades
- Execute `flutter test` para o frontend
- Execute `npm test` para o backend

### Relatório de Bugs

Use o template de issue para bugs, incluindo:

- Descrição clara do problema
- Passos para reproduzir
- Ambiente (OS, versão do Flutter/Node.js)
- Logs de erro se aplicável

Obrigado por contribuir para o Premiora!
