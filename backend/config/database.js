// Configuração de conexão com o banco de dados PostgreSQL
// Este arquivo gerencia a conexão e pool de conexões com o banco

const { Pool } = require('pg');

// Configuração do pool de conexões
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'content_service',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  max: 20, // Máximo de conexões no pool
  idleTimeoutMillis: 30000, // Fechar conexões idle após 30 segundos
  connectionTimeoutMillis: 2000, // Timeout de conexão de 2 segundos
});

// Event listeners para monitoramento do pool
pool.on('connect', (client) => {
  console.log('🔗 Novo cliente conectado ao banco de dados');
});

pool.on('error', (err, client) => {
  console.error('❌ Erro inesperado no cliente do banco:', err);
});

// Função para conectar ao banco de dados
async function connectDB() {
  try {
    // Testar conexão
    const client = await pool.connect();
    console.log('✅ Conexão com PostgreSQL estabelecida com sucesso');

    // Verificar se o banco está acessível
    const result = await client.query('SELECT NOW()');
    console.log('🕒 Hora do servidor PostgreSQL:', result.rows[0].now);

    client.release();
    return true;
  } catch (error) {
    console.error('❌ Erro ao conectar ao banco de dados:', error.message);
    throw error;
  }
}

// Função para executar queries
async function query(text, params) {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    console.log('📊 Query executada em', duration, 'ms:', text);
    return res;
  } catch (error) {
    console.error('❌ Erro na query:', error);
    throw error;
  }
}

// Função para obter um cliente do pool
async function getClient() {
  const client = await pool.connect();
  const query = client.query;
  const release = client.release;

  // Monkey patch para logging de queries
  client.query = (...args) => {
    const start = Date.now();
    return query.apply(client, args).then(res => {
      const duration = Date.now() - start;
      console.log('📊 Query do cliente executada em', duration, 'ms:', args[0]);
      return res;
    });
  };

  client.release = () => {
    console.log('🔌 Cliente liberado de volta ao pool');
    return release.apply(client);
  };

  return client;
}

// Função para fechar o pool de conexões
async function closePool() {
  console.log('🔒 Fechando pool de conexões...');
  await pool.end();
  console.log('✅ Pool de conexões fechado');
}

// Middleware para transações
async function withTransaction(callback) {
  const client = await getClient();
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
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
