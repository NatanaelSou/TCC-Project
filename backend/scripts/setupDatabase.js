// Script para configurar o banco de dados
// Executa os scripts SQL para criar tabelas e popular dados iniciais

const fs = require('fs');
const path = require('path');
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
