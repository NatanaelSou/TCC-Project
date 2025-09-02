// =====================================================================================
// CONFIGURAÇÃO DE CONEXÃO COM BANCO DE DADOS MYSQL
// =====================================================================================
// Este arquivo gerencia a conexão e pool de conexões com o banco de dados MySQL.
// Responsável por:
// - Configurar pool de conexões para otimização de performance
// - Gerenciar eventos de conexão e desconexão
// - Fornecer funções utilitárias para execução de queries
// - Implementar middleware para transações de banco de dados

const mysql = require('mysql2/promise'); // Importar mysql2 para suporte a promises

// =====================================================================================
// CONFIGURAÇÃO DO POOL DE CONEXÕES
// =====================================================================================
// Pool de conexões otimiza o uso de recursos do banco de dados
// Mantém conexões abertas para reutilização, evitando overhead de criação/destruição
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost', // Host do servidor MySQL
  port: parseInt(process.env.DB_PORT, 10) || 3306, // Porta do servidor MySQL (padrão 3306)
  database: process.env.DB_NAME || 'content_service', // Nome do banco de dados
  user: process.env.DB_USER || 'root', // Usuário do banco de dados
  password: String(process.env.DB_PASSWORD || ''), // Senha do usuário convertida para string
  waitForConnections: true,
  connectionLimit: 20, // Máximo de conexões simultâneas no pool
  queueLimit: 0,
  acquireTimeout: 60000, // Timeout para adquirir conexão (60 segundos)
  timeout: 60000, // Timeout geral (60 segundos)
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
    // Obter conexão do pool para teste de conexão
    const connection = await pool.getConnection();
    console.log('✅ Conexão com MySQL estabelecida com sucesso');

    // Executar query simples para verificar funcionalidade do banco
    const [rows] = await connection.execute('SELECT NOW() as current_time');
    console.log('🕒 Hora do servidor MySQL:', rows[0].current_time);

    // Liberar conexão de volta ao pool
    connection.release();
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

// Função para obter conexão personalizada do pool com funcionalidades extras
// - Adiciona logging automático para todas as queries da conexão
// - Sobrescreve método release para logging de desconexão
// - Retorna conexão pronta para uso em operações complexas
async function getClient() {
  const connection = await pool.getConnection(); // Obter conexão do pool
  const execute = connection.execute; // Salvar referência original do método execute
  const release = connection.release; // Salvar referência original do método release

  // Monkey patch: sobrescrever método execute para adicionar logging
  connection.execute = (...args) => {
    const start = Date.now();
    return execute.apply(connection, args).then(res => {
      const duration = Date.now() - start;
      console.log('📊 Query da conexão executada em', duration, 'ms:', args[0]);
      return res;
    });
  };

  // Monkey patch: sobrescrever método release para adicionar logging
  connection.release = () => {
    console.log('🔌 Conexão liberada de volta ao pool');
    return release.apply(connection); // Chamar método original
  };

  return connection; // Retornar conexão personalizada
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
// - Libera conexão automaticamente após uso
async function withTransaction(callback) {
  const connection = await getClient(); // Obter conexão personalizada
  try {
    await connection.execute('START TRANSACTION'); // Iniciar transação MySQL
    const result = await callback(connection); // Executar operações da callback
    await connection.execute('COMMIT'); // Confirmar transação se tudo OK
    return result; // Retornar resultado das operações
  } catch (error) {
    await connection.execute('ROLLBACK'); // Desfazer transação em caso de erro
    throw error; // Re-throw erro para tratamento superior
  } finally {
    connection.release(); // Sempre liberar conexão de volta ao pool
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
