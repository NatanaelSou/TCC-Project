# Guia de Configuração do Ambiente de Desenvolvimento - Projeto Premiora

Este documento fornece instruções técnicas detalhadas para preparar o ambiente de desenvolvimento do Projeto Premiora.

## Visão Geral do Ambiente

O Premiora utiliza uma arquitetura híbrida:

- **Frontend**: Flutter (Dart) para mobile e web
- **Backend**: Node.js com Express.js
- **Banco de Dados**: MySQL
- **Versionamento**: Git

## Configuração do Sistema

### 1. Instalar JDK (Java Development Kit)

Para o Flutter compilar para Android, é necessário o JDK.

```bash
# Criar diretório para o JDK
mkdir jdk

# Baixar OpenJDK 17 (exemplo para Windows)
# Visite https://adoptium.net/ e baixe o zip
# Extrair para jdk/

# Configurar no android/gradle.properties
echo "org.gradle.java.home=../../jdk" >> android/gradle.properties
```

### 2. Configurar Flutter

```bash
# Verificar instalação
flutter doctor

# Habilitar web (se necessário)
flutter config --enable-web

# Aceitar licenças
flutter doctor --android-licenses
```

### 3. Configurar Node.js

```bash
# Instalar dependências globais (opcional)
npm install -g nodemon
npm install -g eslint
```

### 4. Configurar MySQL

```bash
# Instalar MySQL Server
# Criar banco de dados
mysql -u root -p
CREATE DATABASE tcc_project;
EXIT;
```

## Estrutura de Diretórios

Após clonar o repositório:

```
premiora/
├── android/          # Configurações Android
├── backend/          # API Node.js
│   ├── config/       # Configurações DB
│   ├── controllers/  # Lógica de negócio
│   ├── models/       # Modelos de dados
│   ├── routes/       # Rotas da API
│   └── services/     # Serviços
├── ios/              # Configurações iOS
├── lib/              # Código Flutter
│   ├── core/         # Utilitários compartilhados
│   ├── data/         # Modelos e serviços
│   ├── presentation/ # UI (screens, widgets)
│   └── providers/    # Gerenciamento de estado
├── linux/            # Build Linux
├── macos/            # Build macOS
├── web/              # Build Web
├── windows/          # Build Windows
└── pubspec.yaml      # Dependências Flutter
```

## Configurações de Desenvolvimento

### Backend (Node.js)

1. **Variáveis de Ambiente**:

   Crie `backend/.env`:

   ```env
   NODE_ENV=development
   PORT=3000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=sua_senha
   DB_NAME=tcc_project
   JWT_SECRET=seu_secret_jwt
   ```

2. **Scripts NPM**:

   No `backend/package.json`, adicionar:

   ```json
   "scripts": {
     "start": "node index.js",
     "dev": "nodemon index.js",
     "test": "jest",
     "lint": "eslint ."
   }
   ```

3. **ESLint**:

   Criar `backend/.eslintrc.js`:

   ```javascript
   module.exports = {
     env: {
       node: true,
       es2021: true,
     },
     extends: "eslint:recommended",
     parserOptions: {
       ecmaVersion: 12,
     },
     rules: {
       "no-unused-vars": "warn",
       "no-console": "off",
     },
   };
   ```

### Frontend (Flutter)

1. **Análise de Código**:

   O `analysis_options.yaml` já está configurado. Para executar:

   ```bash
   flutter analyze
   ```

2. **Testes**:

   ```bash
   flutter test
   ```

3. **Builds**:

   ```bash
   # Android APK
   flutter build apk --release

   # iOS (macOS apenas)
   flutter build ios --release

   # Web
   flutter build web --release
   ```

## Ferramentas de Desenvolvimento Recomendadas

### IDEs

- **VS Code** com extensões:
  - Flutter
  - Dart
  - Node.js
  - MySQL
- **Android Studio** para desenvolvimento Android
- **Xcode** para desenvolvimento iOS

### Ferramentas de Banco de Dados

- **MySQL Workbench** ou **DBeaver** para gerenciar o banco
- **Postman** ou **Insomnia** para testar APIs

### Versionamento

- **Git Flow** para branching strategy
- **Conventional Commits** para mensagens de commit

## Debugging

### Backend

- Usar `console.log()` ou debugger do VS Code
- Logs em arquivo: configurar Winston

### Frontend

- Flutter DevTools: `flutter pub global run devtools`
- Hot Reload: pressione `r` no terminal do Flutter

### Banco de Dados

- Queries de debug no MySQL Workbench
- Logs de queries no backend

## Deploy e CI/CD

### GitHub Actions (exemplo básico)

Criar `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: "16"
      - name: Install dependencies
        run: npm install
        working-directory: backend
      - name: Run tests
        run: npm test
        working-directory: backend
```

## Troubleshooting Comum

### Flutter

- `flutter clean && flutter pub get`
- Verificar `flutter doctor`

### Node.js

- Limpar cache: `npm cache clean --force`
- Reinstalar: `rm -rf node_modules && npm install`

### MySQL

- Reiniciar serviço: `sudo service mysql restart`
- Verificar conexões: `SHOW PROCESSLIST;`

## Próximos Passos

- Consultar [USAGE.md](USAGE.md) para usar o projeto
- Ver [CONTRIBUTING.md](CONTRIBUTING.md) para contribuir
- Ver [ARCHITECTURE.md](ARCHITECTURE.md) para entender a arquitetura
