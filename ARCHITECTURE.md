# Arquitetura do Sistema - Projeto Premiora

## Visão Geral

O Premiora é construído com uma arquitetura híbrida cliente-servidor, utilizando tecnologias modernas para garantir escalabilidade, manutenibilidade e experiência do usuário consistente.

## Arquitetura Geral

```
┌─────────────────┐    HTTP/HTTPS    ┌─────────────────┐
│   Flutter App   │◄────────────────►│   Node.js API   │
│   (Mobile/Web)  │                  │   (Backend)     │
└─────────────────┘                  └─────────────────┘
         │                                   │
         │                                   │
         ▼                                   ▼
┌─────────────────┐                  ┌─────────────────┐
│   MySQL DB      │◄────────────────►│  File Storage   │
│   (Dados)       │                  │  (AWS S3/GCP)   │
└─────────────────┘                  └─────────────────┘
```

## Componentes Principais

### 1. Frontend (Flutter)

**Tecnologias**: Dart, Flutter Framework

**Estrutura**:

```
lib/
├── core/           # Utilitários compartilhados
│   ├── constants/  # Constantes da aplicação
│   ├── utils/      # Funções auxiliares
│   └── themes/     # Temas e estilos
├── data/           # Camada de dados
│   ├── models/     # Modelos de dados
│   ├── services/   # Serviços de API
│   └── repositories/ # Repositórios de dados
├── presentation/   # Camada de apresentação
│   ├── screens/    # Telas da aplicação
│   ├── widgets/    # Componentes reutilizáveis
│   └── providers/  # Gerenciamento de estado
└── main.dart       # Ponto de entrada
```

**Padrões**:

- **Provider Pattern**: Gerenciamento de estado
- **Repository Pattern**: Abstração de dados
- **Clean Architecture**: Separação de responsabilidades

### 2. Backend (Node.js)

**Tecnologias**: Node.js, Express.js, MySQL

**Estrutura**:

```
backend/
├── config/         # Configurações
│   ├── db.js       # Conexão banco de dados
│   └── auth.js     # Configuração JWT
├── controllers/    # Controladores da API
├── models/         # Modelos de dados
├── routes/         # Definição de rotas
├── services/       # Lógica de negócio
├── middleware/     # Middlewares
└── index.js        # Servidor principal
```

**Padrões**:

- **MVC Pattern**: Separação Model-View-Controller
- **Service Layer**: Lógica de negócio isolada
- **Middleware Pattern**: Autenticação, validação, etc.

### 3. Banco de Dados (MySQL)

**Esquema Principal**:

```sql
-- Usuários
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    type ENUM('creator', 'viewer') DEFAULT 'viewer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts de conteúdo
CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    creator_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    type ENUM('text', 'image', 'video', 'audio') NOT NULL,
    visibility ENUM('public', 'paid') DEFAULT 'public',
    min_tier INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id)
);

-- Tiers de assinatura
CREATE TABLE tiers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    creator_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    level INT NOT NULL,
    benefits JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id)
);

-- Assinaturas
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    viewer_id INT NOT NULL,
    creator_id INT NOT NULL,
    tier_id INT NOT NULL,
    status ENUM('active', 'cancelled', 'expired') DEFAULT 'active',
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (viewer_id) REFERENCES users(id),
    FOREIGN KEY (creator_id) REFERENCES users(id),
    FOREIGN KEY (tier_id) REFERENCES tiers(id)
);

-- Canais de comunidade
CREATE TABLE channels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    creator_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    type ENUM('chat', 'board') NOT NULL,
    description TEXT,
    visibility ENUM('public', 'subscribers', 'private') DEFAULT 'public',
    min_tier INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id)
);

-- Mensagens de chat
CREATE TABLE messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    channel_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id) REFERENCES channels(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Posts do mural
CREATE TABLE board_posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    channel_id INT NOT NULL,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id) REFERENCES channels(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Fluxos de Dados

### 1. Autenticação

```
Usuário → Flutter App → API Login → JWT Token → Banco
       ← Resposta ← Validação ← Geração ← Verificação
```

### 2. Publicação de Conteúdo

```
Criador → Flutter App → API Upload → Validação → Banco
         ← Confirmação ← Processamento ← Armazenamento
```

### 3. Assinatura

```
Espectador → Flutter App → Gateway Pagamento → API Assinatura → Banco
           ← Confirmação ← Processamento ← Validação
```

## Segurança

### Autenticação

- **JWT Tokens**: Autenticação stateless
- **Bcrypt**: Hash de senhas
- **Refresh Tokens**: Renovação automática

### Autorização

- **Role-based Access**: Criador vs Espectador
- **Tier-based Access**: Controle por nível de assinatura
- **Channel Permissions**: Controle por canal

### Dados Sensíveis

- **Criptografia**: Dados em trânsito (HTTPS)
- **Sanitização**: Prevenção de SQL injection
- **Validação**: Input sanitization

## Escalabilidade

### Backend

- **Horizontal Scaling**: Múltiplas instâncias
- **Load Balancing**: Distribuição de carga
- **Caching**: Redis para sessões/dados frequentes

### Banco de Dados

- **Indexing**: Índices em campos de busca
- **Partitioning**: Divisão de tabelas grandes
- **Read Replicas**: Separação leitura/escrita

### Frontend

- **Code Splitting**: Carregamento sob demanda
- **Lazy Loading**: Componentes carregados quando necessário
- **PWA**: Funcionamento offline limitado

## Monitoramento

### Métricas

- **Performance**: Tempo de resposta APIs
- **Uso**: Número de usuários ativos
- **Erros**: Taxa de falhas por endpoint

### Logs

- **Aplicação**: Eventos importantes
- **Erro**: Exceções e falhas
- **Auditoria**: Ações sensíveis

### Ferramentas

- **PM2**: Gerenciamento de processos Node.js
- **New Relic**: Monitoramento de performance
- **Sentry**: Rastreamento de erros

## Deploy

### Desenvolvimento

- **Local**: Docker Compose para ambiente completo
- **Staging**: Ambiente de testes automatizados

### Produção

- **Containerização**: Docker para consistência
- **Orquestração**: Kubernetes para escalabilidade
- **CI/CD**: GitHub Actions para automação

## Dependências Principais

### Frontend

- `flutter`: Framework principal
- `provider`: Gerenciamento de estado
- `http`: Cliente HTTP
- `shared_preferences`: Persistência local
- `image_picker`: Seleção de imagens

### Backend

- `express`: Framework web
- `mysql2`: Driver MySQL
- `jsonwebtoken`: JWT tokens
- `bcrypt`: Hash de senhas
- `multer`: Upload de arquivos
- `cors`: Cross-Origin Resource Sharing

## Considerações Futuras

### Melhorias Planejadas

- **Microserviços**: Separação de responsabilidades
- **GraphQL**: API mais flexível
- **WebRTC**: Videochamadas em tempo real
- **Machine Learning**: Recomendações personalizadas

### Tecnologias Emergentes

- **Flutter Web**: Melhor suporte PWA
- **Serverless**: Funções Lambda para escalabilidade
- **Blockchain**: Pagamentos descentralizados

Esta arquitetura fornece uma base sólida e escalável para o crescimento do Premiora como plataforma de conteúdo e comunidade.
