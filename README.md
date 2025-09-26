# Aplication

Projeto Flutter + Node.js configurando ambiente inicial.
Descripiton...

Objetivo do MVP
Criar uma versão mínima funcional com:

- **Cadastro e login** de usuários (criadores e espectadores).
- **Publicação de conteúdo básico** (posts de texto/imagem).
- **Assinaturas mensais** com tiers simulados.
- **Comunidade inicial** (chat/mural).
- **Conteúdo gratuito mínimo** para todos os usuários.

## Estrutura do projeto

```shell
APP/ # Flutter App
- backend/ # Node.js
  - config/
  - controllers/
  - models/
  - routes/
  - index.js # servidor
  - package.json
- assets/
- lib/ # Front-End
  - models/
  - screens/
  - services/
    - api_service.dart # comunicação com backend
  - widgets/
  - main.dart
```

## Como rodar

### Backend (Node.js)

No terminal 1 inicilize e execute o Node.JS

```bash
cd backend
npm install
node index.js
Servidor rodando em: http://localhost:3000
```

### Frontend (Flutter)

No terminal 2 inicialize

```bash
flutter pub get
flutter run           # para mobile
flutter run -d chrome # para web
# selecione modo ( escolha o chrome caso nao tenha um emulator )
# Outras saidas.. Se Saida -> 
{ "message": "pong" } # Saida: API mínima: /ping retorna 
# Conexao Node.JS normal
```

### Database Setup (MySQL)

O banco de dados `tcc_project` já existe. Para configurar o acesso:

1. Instale o MySQL Server se não tiver.

2. Configure as credenciais no backend/config/db.js (atualmente: host: 'localhost', user: 'root', password: '512200Balatro@', database: 'tcc_project').

3. Execute o schema para criar a tabela users (se necessário):

   ```sql
   -- backend/database/schema.sql
   CREATE TABLE IF NOT EXISTS users (
       id INT AUTO_INCREMENT PRIMARY KEY,
       email VARCHAR(255) NOT NULL UNIQUE,
       password VARCHAR(255) NOT NULL,
       name VARCHAR(100)
   );

   -- Usuário de teste (senha: 123456)
   INSERT INTO users (email, password, name) VALUES ('teste@teste.com', '123456', 'Usuário Teste')
       ON DUPLICATE KEY UPDATE email=email;
   ```

   Use um cliente MySQL (como MySQL Workbench) para executar o schema.sql se a tabela não existir.

   **Acesso ao BD:**
   - Host: localhost
   - Port: 3306 (padrão)
   - User: root
   - Password: 512200Balatro@
   - Database: tcc_project

   Nota: Em produção, use credenciais seguras e variáveis de ambiente (.env).
