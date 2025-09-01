/**
 * Script simples para testar conexão com PostgreSQL
 */
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'content_service',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '512200Balatro'
});

async function testConnection() {
  try {
    console.log('🔗 Testando conexão com PostgreSQL...');
    console.log('📊 Configurações:');
    console.log(`   Host: ${process.env.DB_HOST || 'localhost'}`);
    console.log(`   Porta: ${process.env.DB_PORT || '5432'}`);
    console.log(`   Banco: ${process.env.DB_NAME || 'content_service'}`);
    console.log(`   Usuário: ${process.env.DB_USER || 'postgres'}`);
    console.log(`   Senha: ${process.env.DB_PASSWORD ? '***definida***' : '***não definida***'}`);

    const client = await pool.connect();
    console.log('✅ Conexão estabelecida com sucesso!');

    const result = await client.query('SELECT NOW() as current_time, version() as pg_version');
    console.log('🕒 Hora do servidor:', result.rows[0].current_time);
    console.log('📋 Versão PostgreSQL:', result.rows[0].pg_version.split(' ')[0] + ' ' + result.rows[0].pg_version.split(' ')[1]);

    // Testar se o banco content_service existe
    const dbResult = await client.query(`
      SELECT datname FROM pg_database
      WHERE datname = 'content_service'
    `);

    if (dbResult.rows.length > 0) {
      console.log('✅ Banco de dados "content_service" encontrado!');
    } else {
      console.log('❌ Banco de dados "content_service" não encontrado!');
    }

    client.release();
    console.log('🔌 Conexão fechada com sucesso.');

  } catch (error) {
    console.error('❌ Erro na conexão:', error.message);
    console.error('💡 Possíveis causas:');
    console.error('   - PostgreSQL não está rodando');
    console.error('   - Credenciais incorretas');
    console.error('   - Banco de dados não existe');
    console.error('   - Porta bloqueada pelo firewall');
  } finally {
    await pool.end();
  }
}

testConnection();
