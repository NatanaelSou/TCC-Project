// =====================================================================================
// SCRIPT DE CONFIGURAÇÃO DO BANCO DE DADOS
// =====================================================================================
// Este script executa os scripts SQL para criar tabelas e popular dados iniciais.
// Responsável por:
// - Carregar variáveis de ambiente do arquivo .env
// - Executar script do esquema do banco de dados
// - Popular banco com dados iniciais
// - Verificar se a configuração foi bem-sucedida

const fs = require('fs');
const path = require('path');

// =====================================================================================
// CARREGAR VARIÁVEIS DE AMBIENTE
// =====================================================================================
// É crucial carregar as variáveis de ambiente ANTES de importar a configuração do banco
// Caso contrário, as credenciais não estarão disponíveis quando o pool for criado

// Tentar carregar .env de múltiplas localizações possíveis
const possibleEnvPaths = [
  path.join(__dirname, '../../.env'), // TCC-Project/.env
  path.join(__dirname, '../../../.env'), // OneDrive/Documentos/.env
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
  console.error('❌ ERRO: Não foi possível encontrar o arquivo .env em nenhuma das localizações esperadas');
  console.error('💡 Localizações verificadas:');
  possibleEnvPaths.forEach(path => console.error(`   - ${path}`));
  console.error('💡 Certifique-se de que o arquivo .env existe em uma dessas localizações');
  process.exit(1);
}

// =====================================================================================
// VERIFICAÇÃO DAS VARIÁVEIS DE AMBIENTE
// =====================================================================================
// Verificar se as variáveis essenciais estão definidas antes de prosseguir
console.log('🔍 Verificando variáveis de ambiente...');
console.log('DB_HOST:', process.env.DB_HOST || 'localhost');
console.log('DB_PORT:', process.env.DB_PORT || '5432');
console.log('DB_NAME:', process.env.DB_NAME || 'content_service');
console.log('DB_USER:', process.env.DB_USER || 'postgres');
console.log('DB_PASSWORD:', process.env.DB_PASSWORD ? '***definida***' : '***não definida***');

// Verificar se a senha está definida
if (!process.env.DB_PASSWORD) {
  console.error('❌ ERRO: DB_PASSWORD não está definida no arquivo .env');
  console.error('💡 Verifique se o arquivo .env existe e contém DB_PASSWORD=your_password');
  process.exit(1);
}

const { pool } = require('../config/database');

async function setupDatabase() {
  try {
    console.log('🚀 Iniciando configuração do banco de dados...');

    // Ler arquivo do esquema
    const schemaPath = path.join(__dirname, '../../database/schema.sql');
    const schemaSQL = fs.readFileSync(schemaPath, 'utf8');

    console.log('📄 Executando script do esquema...');
    await pool.query(schemaSQL);
    console.log('✅ Esquema criado com sucesso!');

    // Ler arquivo de dados iniciais
    const seedPath = path.join(__dirname, '../../database/seed.sql');
    const seedSQL = fs.readFileSync(seedPath, 'utf8');

    console.log('🌱 Populando banco com dados iniciais...');
    await pool.query(seedSQL);
    console.log('✅ Dados iniciais inseridos com sucesso!');

    console.log('🎉 Banco de dados configurado com sucesso!');
    console.log('📊 Você pode agora iniciar o servidor com: npm start');

  } catch (error) {
    console.error('❌ Erro ao configurar banco de dados:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Executar apenas se chamado diretamente
if (require.main === module) {
  setupDatabase();
}

module.exports = { setupDatabase };
