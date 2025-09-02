# Guia de Configuração - Plataforma de Serviço de Conteúdo

Este guia explica como configurar e executar a plataforma de serviço de conteúdo com PostgreSQL e Node.js.

## 📋 Pré-requisitos

- **Node.js** (versão 16 ou superior)
- **PostgreSQL** (versão 12 ou superior)
- **Git** (para controle de versão)

## 🗄️ Configuração do PostgreSQL

### 1. Instalar PostgreSQL

#### Windows:
- Baixe e instale o PostgreSQL do site oficial: <https://www.postgresql.org/download/windows/>
- Durante a instalação, anote a senha do usuário `postgres`

#### Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### macOS:
```bash
brew install postgresql
brew services start postgresql
```

### 2. Criar Banco de Dados

Abra o terminal e execute os comandos SQL:

```bash
# Conectar ao PostgreSQL como superusuário
psql -U postgres

# Criar banco de dados
CREATE DATABASE content_service;

# Criar usuário da aplicação (opcional, mas recomendado)
CREATE USER content_user WITH PASSWORD 'your_secure_password';

# Conceder permissões
GRANT ALL PRIVILEGES ON DATABASE content_service TO content_user;

# Sair do psql
\q
```

### 3. Configurar Arquivo de Ambiente

Crie um arquivo `.env` em uma das seguintes localizações (o sistema irá procurar automaticamente):

**Opção 1 - Raiz do projeto TCC-Project:**
```
TCC-Project/.env
```

**Opção 2 - Pasta Documentos (recomendado se .env estiver fora do projeto):**
```
C:/Users/Edy/OneDrive/Documentos/.env
```

Conteúdo do arquivo `.env`:

```env
# Substitua pelos seus valores
DB_HOST=localhost
DB_PORT=5432
DB_NAME=content_service
DB_USER=postgres  # ou content_user se criou
DB_PASSWORD=your_password_here
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
PORT=3001
FRONTEND_URL=http://localhost:3000
NODE_ENV=development
```

**Nota:** O sistema agora procura automaticamente o arquivo `.env` em múltiplas localizações, incluindo a pasta Documentos, para maior flexibilidade na organização dos arquivos de configuração.

## 🚀 Configuração e Execução

### 1. Instalar Dependências

```bash
# Na raiz do projeto
npm install
```

### 2. Inicializar o Banco de Dados

Execute os scripts SQL na ordem correta:

```bash
# Conectar ao banco de dados
psql -U postgres -d content_service

# Executar script do esquema
\i database/schema.sql

# Executar script de dados iniciais
\i database/seed.sql

# Sair do psql
\q
```

### 3. Executar Scripts de Configuração (Opcional)

Se preferir usar Node.js para configurar o banco:

```bash
# Instalar dependências do backend
cd backend
npm install

# Executar script de configuração (se existir)
npm run setup-db

# Popular banco com dados iniciais
npm run seed-db
```

### 4. Iniciar o Servidor

```bash
# Modo desenvolvimento (com nodemon)
npm run dev

# Ou modo produção
npm start
```

O servidor estará rodando em: http://localhost:3001

### 5. Executar Testes da API (Opcional)

Você tem duas opções para testar a API:

#### Opção 1: Teste via Node.js (Terminal)
Após iniciar o servidor, execute:

```bash
# Executar testes da API
npm run test-api
```

#### Opção 2: Teste via Navegador (Compatível com GoLive)
Abra o arquivo `root/test-api.html` no navegador usando a extensão GoLive:

1. Clique com o botão direito no arquivo `root/test-api.html`
2. Selecione "Open with Live Server" (ou similar)
3. A página será aberta no navegador
4. Clique em "Executar Todos os Testes" para rodar os testes automaticamente

**Nota:** Certifique-se de que o servidor backend está rodando na porta 3001 antes de executar os testes.

Os testes incluem:
- ✅ Verificação da saúde da API
- ✅ Registro e login de usuários
- ✅ Criação de canais de criadores
- ✅ Criação e listagem de conteúdo
- ✅ Obtenção de criadores populares

## 🧪 Testando a API

### Verificar Status da API
```bash
curl http://localhost:3001/api/health
```

### Registrar um Novo Usuário
```bash
curl -X POST http://localhost:3001/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "teste",
    "email": "teste@email.com",
    "password": "senha123",
    "full_name": "Usuário Teste"
  }'
```

### Fazer Login
```bash
curl -X POST http://localhost:3001/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@email.com",
    "password": "senha123"
  }'
```

## 📁 Estrutura do Projeto

```
/
├── backend/                 # Código do servidor Node.js
│   ├── config/
│   │   └── database.js      # Configuração da conexão com PostgreSQL
│   ├── models/
│   │   └── index.js         # Modelos de dados
│   ├── routes/
│   │   ├── users.js         # Rotas de usuários
│   │   ├── creators.js      # Rotas de criadores
│   │   ├── content.js       # Rotas de conteúdo
│   │   ├── subscriptions.js # Rotas de inscrições
│   │   └── payments.js      # Rotas de pagamentos
│   ├── server.js            # Arquivo principal do servidor
│   └── package.json         # Dependências do backend
├── database/                # Scripts SQL
│   ├── schema.sql           # Esquema do banco de dados
│   ├── seed.sql             # Dados iniciais
│   └── migrations.sql       # Scripts de migração
├── root/                    # Frontend estático
│   ├── index.html
│   ├── css/
│   ├── pages/
│   └── scripts/
├── .env                     # Variáveis de ambiente
└── README-SETUP.md          # Este arquivo
```

## 🔧 Comandos Úteis

### Banco de Dados
```bash
# Backup do banco
pg_dump -U postgres content_service > backup.sql

# Restaurar backup
psql -U postgres content_service < backup.sql

# Ver logs do PostgreSQL
tail -f /var/log/postgresql/postgresql-*.log
```

### Aplicação
```bash
# Ver processos rodando na porta 3001
lsof -i :3001

# Matar processo na porta 3001
kill -9 $(lsof -t -i :3001)

# Ver logs da aplicação
tail -f logs/app.log
```

## 🔒 Segurança

### Em Produção:
1. **Mude a JWT_SECRET** para uma chave forte e única
2. **Use HTTPS** em produção
3. **Configure CORS** adequadamente
4. **Use variáveis de ambiente** para todas as configurações sensíveis
5. **Configure firewall** para permitir apenas portas necessárias
6. **Monitore logs** regularmente

### Configurações de Segurança Recomendadas:

```env
NODE_ENV=production
JWT_SECRET=your_super_secure_random_key_here
DB_PASSWORD=your_secure_database_password
```

## 🐛 Solução de Problemas

### Erro de Conexão com PostgreSQL
- Verifique se o PostgreSQL está rodando: `sudo systemctl status postgresql`
- Confirme as credenciais no arquivo `.env`
- Teste conexão: `psql -U postgres -d content_service`

### Porta Já em Uso
- Mude a porta no `.env`: `PORT=3002`
- Ou mate o processo usando a porta: `kill -9 $(lsof -t -i :3001)`

### Erro de Dependências
```bash
# Limpar cache do npm
npm cache clean --force

# Reinstalar dependências
rm -rf node_modules package-lock.json
npm install
```

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique os logs da aplicação
2. Consulte a documentação da API em `/api/health`
3. Verifique se todas as dependências estão instaladas
4. Confirme que o PostgreSQL está configurado corretamente

## 🚀 Próximos Passos

Após configurar com sucesso:
1. Teste todas as rotas da API
2. Configure o frontend para consumir a API
3. Implemente autenticação no frontend
4. Configure upload de arquivos
5. Implemente sistema de pagamentos
6. Configure monitoramento e logs

---

**Nota**: Este é um sistema em desenvolvimento. Mantenha backups regulares e teste em ambiente de desenvolvimento antes de implantar em produção.
