// =====================================================================================
// CONFIGURAÇÃO DE CONEXÃO COM BANCO DE DADOS POSTGRESQL
// =====================================================================================
// Este arquivo gerencia a conexão e pool de conexões com o banco de dados PostgreSQL.
// Responsável por:
// - Configurar pool de conexões para otimização de performance
// - Gerenciar eventos de conexão e desconexão
// - Fornecer funções utilitárias para execução de queries
// - Implementar middleware para transações de banco de dados

const { Pool } = require('pg'); // Importar classe Pool do driver PostgreSQL

// =====================================================================================
// CONFIGURAÇÃO DO POOL DE CONEXÕES
// =====================================================================================
// Pool de conexões otimiza o uso de recursos do banco de dados
// Mantém conexões abertas para reutilização, evitando overhead de criação/destruição
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost', // Host do servidor PostgreSQL
  port: process.env.DB_PORT || 5432, // Porta do servidor PostgreSQL (padrão 5432)
  database: process.env.DB_NAME || 'content_service', // Nome do banco de dados
  user: process.env.DB_USER || 'postgres', // Usuário do banco de dados
  password: process.env.DB_PASSWORD || '', // Senha do usuário
  max: 20, // Máximo de conexões simultâneas no pool
  idleTimeoutMillis: 30000, // Fechar conexões ociosas após 30 segundos
  connectionTimeoutMillis: 2000, // Timeout para estabelecimento de conexão (2 segundos)
});

// =====================================================================================
// MONITORAMENTO DO POOL DE CONEXÕES
// =====================================================================================

// Event listener para novas conexões estabelecidas
// Útil para monitoramento e debugging de conexões ativas
pool.on('connect', (client) => {
  console.log('🔗 Novo cliente conectado ao banco de dados');
});

// Event listener para erros inesperados nos clientes do pool
// Importante para identificar problemas de conectividade ou configuração
pool.on('error', (err, client) => {
  console.error('❌ Erro inesperado no cliente do banco:', err);
});

// =====================================================================================
// FUNÇÕES UTILITÁRIAS PARA GERENCIAMENTO DE CONEXÃO
// =====================================================================================

// Função assíncrona para estabelecer e testar conexão com o banco de dados
// Executa verificações básicas para garantir que o banco está acessível
async function connectDB() {
  try {
    // Obter cliente do pool para teste de conexão
    const client = await pool.connect();
    console.log('✅ Conexão com PostgreSQL estabelecida com sucesso');

    // Executar query simples para verificar funcionalidade do banco
    const result = await client.query('SELECT NOW()');
    console.log('🕒 Hora do servidor PostgreSQL:', result.rows[0].now);

    // Liberar cliente de volta ao pool
    client.release();
    return true;
  } catch (error) {
    console.error('❌ Erro ao conectar ao banco de dados:', error.message);
    throw error; // Re-throw para tratamento no nível superior
  }
}

// =====================================================================================
// FUNÇÕES UTILITÁRIAS PARA EXECUÇÃO DE QUERIES
// =====================================================================================

// Função para executar queries SQL de forma segura e com logging de performance
// - Mede o tempo de execução da query para monitoramento de performance
// - Registra queries executadas para debugging e auditoria
// - Trata erros de forma consistente
async function query(text, params) {
  const start = Date.now(); // Capturar tempo inicial para medição de performance
  try {
    const res = await pool.query(text, params); // Executar query usando pool
    const duration = Date.now() - start; // Calcular duração da execução
    console.log('📊 Query executada em', duration, 'ms:', text);
    return res; // Retornar resultado da query
  } catch (error) {
    console.error('❌ Erro na query:', error);
    throw error; // Re-throw para tratamento no nível superior
  }
}

// Função para obter cliente personalizado do pool com funcionalidades extras
// - Adiciona logging automático para todas as queries do cliente
// - Sobrescreve método release para logging de desconexão
// - Retorna cliente pronto para uso em operações complexas
async function getClient() {
  const client = await pool.connect(); // Obter cliente do pool
  const query = client.query; // Salvar referência original do método query
  const release = client.release; // Salvar referência original do método release

  // Monkey patch: sobrescrever método query para adicionar logging
  client.query = (...args) => {
    const start = Date.now();
    return query.apply(client, args).then(res => {
      const duration = Date.now() - start;
      console.log('📊 Query do cliente executada em', duration, 'ms:', args[0]);
      return res;
    });
  };

  // Monkey patch: sobrescrever método release para adicionar logging
  client.release = () => {
    console.log('🔌 Cliente liberado de volta ao pool');
    return release.apply(client); // Chamar método original
  };

  return client; // Retornar cliente personalizado
}

// Função para fechar o pool de conexões de forma graciosa
// - Encerra todas as conexões ativas no pool
// - Deve ser chamada durante o shutdown da aplicação
async function closePool() {
  console.log('🔒 Fechando pool de conexões...');
  await pool.end(); // Fechar pool e todas as conexões
  console.log('✅ Pool de conexões fechado');
}

// =====================================================================================
// MIDDLEWARE PARA TRANSAÇÕES DE BANCO DE DADOS
// =====================================================================================

// Função utilitária para executar operações dentro de uma transação
// - Garante atomicidade das operações (tudo ou nada)
// - Faz rollback automático em caso de erro
// - Libera cliente automaticamente após uso
async function withTransaction(callback) {
  const client = await getClient(); // Obter cliente personalizado
  try {
    await client.query('BEGIN'); // Iniciar transação
    const result = await callback(client); // Executar operações da callback
    await client.query('COMMIT'); // Confirmar transação se tudo OK
    return result; // Retornar resultado das operações
  } catch (error) {
    await client.query('ROLLBACK'); // Desfazer transação em caso de erro
    throw error; // Re-throw erro para tratamento superior
  } finally {
    client.release(); // Sempre liberar cliente de volta ao pool
  }
}

module.exports = {
  pool,
  connectDB,
  query,
  getClient,
  closePool,
  withTransaction
};
