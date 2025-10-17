# Guia de Instalação do Projeto Premiora

Este guia fornece instruções detalhadas para instalar e configurar o Projeto Premiora em seu ambiente local.

## Pré-requisitos

Antes de começar, certifique-se de ter os seguintes softwares instalados:

- **Node.js** (versão 16 ou superior): [Download](https://nodejs.org/)
- **Flutter** (versão 3.0 ou superior): [Instalação](https://flutter.dev/docs/get-started/install)
- **MySQL Server** (versão 8.0 ou superior): [Download](https://dev.mysql.com/downloads/mysql/)
- **Git**: [Download](https://git-scm.com/downloads)

### Verificar Instalação

Abra um terminal e execute:

```bash
node --version
flutter --version
mysql --version
git --version
```

## Clonando o Repositório

```bash
git clone https://github.com/seu-usuario/premiora.git
cd premiora
```

## Configuração do Backend (Node.js)

### 1. Instalar Dependências

```bash
cd backend
npm install
```

### 2. Configurar Banco de Dados

1. Crie um banco de dados MySQL chamado `tcc_project`:

   ```sql
   CREATE DATABASE tcc_project;
   ```

2. Configure as credenciais no arquivo `backend/config/db.js`:

   ```javascript
   const dbConfig = {
     host: "localhost",
     user: "seu_usuario_mysql",
     password: "sua_senha_mysql",
     database: "tcc_project",
   };
   ```

3. Execute o script de criação das tabelas:

   ```bash
   mysql -u seu_usuario_mysql -p tcc_project < backend/database/schema.sql
   ```

4. (Opcional) Insira dados de exemplo:

   ```bash
   mysql -u seu_usuario_mysql -p tcc_project < backend/database/insert_sample_data.sql
   ```

### 3. Executar o Backend

```bash
npm start
# ou para desenvolvimento:
npm run dev
```

O servidor estará rodando em `http://localhost:3000`.

## Configuração do Frontend (Flutter)

### 1. Instalar Dependências

```bash
flutter pub get
```

### 2. Configurar para Plataforma Específica

#### Para Android

- Instale o Android Studio e configure um emulador ou dispositivo físico.
- Execute `flutter doctor` para verificar se tudo está configurado.

#### Para iOS (macOS apenas)

- Instale o Xcode.
- Execute `flutter doctor` para verificar.

#### Para Web

- Execute `flutter config --enable-web` (se ainda não estiver habilitado).

### 3. Executar o Frontend

```bash
# Para mobile (Android/iOS):
flutter run

# Para web:
flutter run -d chrome
```

## Verificação da Instalação

1. Abra o navegador e acesse `http://localhost:3000/ping` - deve retornar `{"message": "pong"}`.

2. Execute o app Flutter - deve conectar ao backend e permitir cadastro/login.

## Solução de Problemas

### Erro de Conexão com Banco de Dados

- Verifique se o MySQL está rodando.
- Confirme as credenciais em `db.js`.
- Certifique-se de que o usuário tem permissões no banco `tcc_project`.

### Flutter Doctor Erros

- Instale os SDKs necessários (Android SDK, Xcode).
- Configure variáveis de ambiente (JAVA_HOME, ANDROID_HOME).

### Porta 3000 Ocupada

- Mude a porta no `backend/index.js` ou libere a porta.

### Problemas com Dependências

- Execute `npm install` novamente no backend.
- Execute `flutter clean && flutter pub get` no frontend.

## Próximos Passos

Após a instalação, consulte:

- [SETUP.md](SETUP.md) para configuração avançada do ambiente de desenvolvimento.
- [USAGE.md](USAGE.md) para aprender a usar o projeto.
- [CONTRIBUTING.md](CONTRIBUTING.md) para contribuir com o projeto.
