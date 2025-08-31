// =====================================================================================
// SERVIDOR PRINCIPAL DA API DE SERVIÇO DE CONTEÚDO
// =====================================================================================
// Este arquivo é o ponto de entrada principal da aplicação backend.
// Responsável por:
// - Inicializar o servidor Express
// - Configurar middlewares de segurança e validação
// - Registrar todas as rotas da API
// - Gerenciar tratamento de erros
// - Conectar ao banco de dados PostgreSQL
// - Iniciar o servidor na porta especificada

// =====================================================================================
// CARREGAR VARIÁVEIS DE AMBIENTE
// =====================================================================================
// Carregar variáveis de ambiente do arquivo .env com múltiplas localizações possíveis
const path = require('path');
const fs = require('fs');

// Tentar carregar .env de múltiplas localizações possíveis
const possibleEnvPaths = [
  path.join(__dirname, '../.env'), // TCC-Project/.env
  path.join(__dirname, '../../.env'), // OneDrive/Documentos/.env
  path.join(process.cwd(), '.env'), // Diretório atual
  '.env' // Raiz do projeto
];

let envLoaded = false;
for (const envPath of possibleEnvPaths) {
  try {
    const result = require('dotenv').config({ path: envPath });
    if (!result.error) {
      console.log(`✅ Arquivo .env carregado de: ${envPath}`);
      envLoaded = true;
      break;
    }
  } catch (error) {
    // Continuar tentando próximos caminhos
  }
}

if (!envLoaded) {
  console.error('❌ AVISO: Não foi possível encontrar o arquivo .env');
  console.error('💡 O servidor continuará com valores padrão, mas verifique a configuração do banco');
}

// Importar dependências principais
const express = require('express'); // Framework web para Node.js
const cors = require('cors'); // Middleware para permitir requisições cross-origin
const helmet = require('helmet'); // Middleware de segurança para headers HTTP
const rateLimit = require('express-rate-limit'); // Middleware para limitar taxa de requisições
const { connectDB } = require('./config/database'); // Função para conectar ao banco de dados

// =====================================================================================
// IMPORTAÇÃO DAS ROTAS DA API
// =====================================================================================
// Cada arquivo de rotas contém os endpoints específicos para uma entidade do sistema
const userRoutes = require('./routes/users'); // Rotas para gerenciamento de usuários
const creatorRoutes = require('./routes/creators'); // Rotas para gerenciamento de criadores
const contentRoutes = require('./routes/content'); // Rotas para gerenciamento de conteúdo
const subscriptionRoutes = require('./routes/subscriptions'); // Rotas para inscrições
const paymentRoutes = require('./routes/payments'); // Rotas para pagamentos

// =====================================================================================
// INICIALIZAÇÃO DA APLICAÇÃO EXPRESS
// =====================================================================================
const app = express(); // Criar instância da aplicação Express
const PORT = process.env.PORT || 3001; // Porta do servidor (padrão 3001 se não especificada)

// =====================================================================================
// CONFIGURAÇÃO DE MIDDLEWARES DA APLICAÇÃO
// =====================================================================================

// Middleware de segurança - Define headers HTTP seguros para prevenir ataques comuns
app.use(helmet());

// Configuração CORS - Permite requisições do frontend
// - origin: Define quais domínios podem fazer requisições (padrão: localhost:3000)
// - credentials: Permite envio de cookies e headers de autenticação
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting - Protege contra ataques de força bruta e abuso da API
// - windowMs: Janela de tempo de 15 minutos
// - max: Máximo de 100 requisições por IP nesta janela
// - message: Mensagem de erro quando limite é excedido
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // limite de 100 requisições por janela
  message: 'Muitas requisições deste IP, tente novamente mais tarde.'
});
app.use('/api/', limiter); // Aplica apenas às rotas da API

// Middleware para parsing de dados JSON e URL-encoded
// - express.json(): Converte corpo das requisições JSON em objetos JavaScript
// - express.urlencoded(): Converte dados de formulários em objetos JavaScript
// - limit: Define tamanho máximo do corpo da requisição (10MB)
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Middleware de logging personalizado
// Registra todas as requisições no console com timestamp, método HTTP e caminho
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// =====================================================================================
// REGISTRO DAS ROTAS DA API
// =====================================================================================
// Cada rota é montada em um caminho específico e delega o tratamento para seu respectivo módulo
app.use('/api/users', userRoutes); // Endpoints: /register, /login, /profile, /:id
app.use('/api/creators', creatorRoutes); // Endpoints para gerenciamento de criadores
app.use('/api/content', contentRoutes); // Endpoints para gerenciamento de conteúdo
app.use('/api/subscriptions', subscriptionRoutes); // Endpoints para inscrições
app.use('/api/payments', paymentRoutes); // Endpoints para pagamentos

// =====================================================================================
// ROTAS UTILITÁRIAS
// =====================================================================================

// Rota de saúde da API - Endpoint para verificar se o serviço está funcionando
// Retorna informações básicas sobre o status do serviço
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK', // Status do serviço
    timestamp: new Date().toISOString(), // Timestamp atual
    service: 'Content Service API', // Nome do serviço
    version: '1.0.0' // Versão da API
  });
});

// Rota raiz - Página inicial da API
// Fornece informações básicas sobre o serviço e link para documentação
app.get('/', (req, res) => {
  res.json({
    message: 'Bem-vindo à API de Serviço de Conteúdo',
    version: '1.0.0',
    documentation: '/api/health' // Link para endpoint de saúde
  });
});

// =====================================================================================
// MIDDLEWARE DE TRATAMENTO DE ERROS
// =====================================================================================

// Middleware global de tratamento de erros - Captura todos os erros não tratados
// - Registra o erro no console para debugging
// - Retorna resposta padronizada ao cliente
// - Em desenvolvimento mostra mensagem detalhada, em produção mensagem genérica
app.use((err, req, res, next) => {
  console.error('Erro na aplicação:', err);
  res.status(500).json({
    error: 'Erro interno do servidor',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Algo deu errado'
  });
});

// Middleware para tratamento de rotas não encontradas (404)
// - Captura qualquer requisição para rotas que não existem
// - Retorna erro 404 com mensagem descritiva
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Rota não encontrada',
    message: `A rota ${req.originalUrl} não existe nesta API`
  });
});

// =====================================================================================
// INICIALIZAÇÃO E GERENCIAMENTO DO SERVIDOR
// =====================================================================================

// Função assíncrona para inicializar o servidor
// Responsável por:
// 1. Estabelecer conexão com o banco de dados
// 2. Iniciar o servidor HTTP na porta especificada
// 3. Tratar erros durante a inicialização
async function startServer() {
  try {
    // Etapa 1: Conectar ao banco de dados PostgreSQL
    await connectDB();
    console.log('✅ Conectado ao banco de dados PostgreSQL');

    // Etapa 2: Iniciar servidor HTTP
    app.listen(PORT, () => {
      console.log(`🚀 Servidor rodando na porta ${PORT}`);
      console.log(`📚 Documentação da API: http://localhost:${PORT}/api/health`);
    });
  } catch (error) {
    // Em caso de erro, registrar e encerrar aplicação
    console.error('❌ Erro ao iniciar o servidor:', error);
    process.exit(1); // Código de saída 1 indica erro
  }
}

// =====================================================================================
// TRATAMENTO DE SINAIS DO SISTEMA
// =====================================================================================

// Tratamento do sinal SIGINT (Ctrl+C) - Encerramento gracioso
process.on('SIGINT', () => {
  console.log('🛑 Recebido sinal de interrupção, encerrando servidor...');
  process.exit(0); // Código de saída 0 indica encerramento normal
});

// Tratamento do sinal SIGTERM - Encerramento gracioso em ambientes de produção
process.on('SIGTERM', () => {
  console.log('🛑 Recebido sinal de término, encerrando servidor...');
  process.exit(0); // Código de saída 0 indica encerramento normal
});

// =====================================================================================
// INÍCIO DA APLICAÇÃO
// =====================================================================================

// Chamar função de inicialização do servidor
startServer();

// Exportar a aplicação Express para uso em testes ou outros módulos
module.exports = app;
