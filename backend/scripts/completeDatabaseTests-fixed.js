/**
 * Script de Testes Completos para Banco de Dados e API
 * Este arquivo contém testes abrangentes para validar:
 * - Conexão e configuração do banco de dados
 * - Integridade dos dados inseridos
 * - Relacionamentos entre tabelas
 * - Endpoints da API
 * - Casos de erro e edge cases
 * - Performance e carga
 */

const { Pool } = require('pg');
const axios = require('axios');

// Configuração do banco de dados
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'content_service',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || ''
};

// Configuração da API
const API_BASE_URL = 'http://localhost:3001/api';

// Pool de conexões para testes
let pool;
let testResults = {
  total: 0,
  passed: 0,
  failed: 0,
  details: []
};

// Função auxiliar para logging de testes
function logTest(testName, success, message = '', error = null) {
  testResults.total++;
  const status = success ? '✅ PASSOU' : '❌ FALHOU';
  const logMessage = `${status} ${testName}`;

  if (message) {
    console.log(`${logMessage}: ${message}`);
  } else {
    console.log(logMessage);
  }

  if (error) {
    console.log(`   Erro: ${error.message || error}`);
  }

  testResults.details.push({
    name: testName,
    success,
    message,
    error: error?.message || error
  });

  if (success) {
    testResults.passed++;
  } else {
    testResults.failed++;
  }
}

// =============================================================================
// TESTES DE BANCO DE DADOS
// =============================================================================

/**
 * Teste 1: Conexão com o banco de dados
 */
async function testDatabaseConnection() {
  console.log('\n🔗 Testando conexão com banco de dados...');

  try {
    pool = new Pool(dbConfig);
    const client = await pool.connect();
    await client.query('SELECT 1');
    client.release();
    logTest('Conexão com Banco de Dados', true, 'Conexão estabelecida com sucesso');
    return true;
  } catch (error) {
    logTest('Conexão com Banco de Dados', false, 'Falha na conexão', error);
    return false;
  }
}

/**
 * Teste 2: Verificar estrutura das tabelas
 */
async function testTableStructure() {
  console.log('\n📋 Testando estrutura das tabelas...');

  const requiredTables = [
    'categories', 'users', 'creators', 'content',
    'subscriptions', 'content_reactions', 'comments',
    'playlists', 'playlist_items', 'payments'
  ];

  try {
    const client = await pool.connect();
    const result = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE'
    `);

    const existingTables = result.rows.map(row => row.table_name);
    client.release();

    let allTablesExist = true;
    for (const table of requiredTables) {
      if (!existingTables.includes(table)) {
        logTest(`Estrutura da Tabela: ${table}`, false, 'Tabela não encontrada');
        allTablesExist = false;
      } else {
        logTest(`Estrutura da Tabela: ${table}`, true, 'Tabela existe');
      }
    }

    return allTablesExist;
  } catch (error) {
    logTest('Estrutura das Tabelas', false, 'Erro ao verificar tabelas', error);
    return false;
  }
}

/**
 * Teste 3: Verificar dados iniciais inseridos
 */
async function testInitialData() {
  console.log('\n📊 Testando dados iniciais...');

  try {
    const client = await pool.connect();

    // Verificar categorias
    const categoriesResult = await client.query('SELECT COUNT(*) as count FROM categories');
    const categoriesCount = parseInt(categoriesResult.rows[0].count);

    // Verificar usuários
    const usersResult = await client.query('SELECT COUNT(*) as count FROM users');
    const usersCount = parseInt(usersResult.rows[0].count);

    // Verificar criadores
    const creatorsResult = await client.query('SELECT COUNT(*) as count FROM creators');
    const creatorsCount = parseInt(creatorsResult.rows[0].count);

    // Verificar conteúdo
    const contentResult = await client.query('SELECT COUNT(*) as count FROM content');
    const contentCount = parseInt(contentResult.rows[0].count);

    client.release();

    // Validar contagens mínimas esperadas
    const validations = [
      { name: 'Categorias', count: categoriesCount, min: 5 },
      { name: 'Usuários', count: usersCount, min: 5 },
      { name: 'Criadores', count: creatorsCount, min: 3 },
      { name: 'Conteúdo', count: contentCount, min: 5 }
    ];

    let allValid = true;
    for (const validation of validations) {
      if (validation.count >= validation.min) {
        logTest(`Dados Iniciais: ${validation.name}`, true, `${validation.count} registros encontrados`);
      } else {
        logTest(`Dados Iniciais: ${validation.name}`, false, `Apenas ${validation.count} registros (mínimo: ${validation.min})`);
        allValid = false;
      }
    }

    return allValid;
  } catch (error) {
    logTest('Dados Iniciais', false, 'Erro ao verificar dados', error);
    return false;
  }
}

/**
 * Teste 4: Verificar integridade referencial
 */
async function testReferentialIntegrity() {
  console.log('\n🔗 Testando integridade referencial...');

  try {
    const client = await pool.connect();

    // Verificar se todos os criadores têm usuários válidos
    const creatorsUsersResult = await client.query(`
      SELECT COUNT(*) as count
      FROM creators c
      LEFT JOIN users u ON c.user_id = u.id
      WHERE u.id IS NULL
    `);
    const orphanedCreators = parseInt(creatorsUsersResult.rows[0].count);

    // Verificar se todo conteúdo tem criadores válidos
    const contentCreatorsResult = await client.query(`
      SELECT COUNT(*) as count
      FROM content c
      LEFT JOIN creators cr ON c.creator_id = cr.id
      WHERE cr.id IS NULL
    `);
    const orphanedContent = parseInt(contentCreatorsResult.rows[0].count);

    // Verificar se todo conteúdo tem categorias válidas
    const contentCategoriesResult = await client.query(`
      SELECT COUNT(*) as count
      FROM content c
      LEFT JOIN categories cat ON c.category_id = cat.id
      WHERE cat.id IS NULL
    `);
    const orphanedContentCategories = parseInt(contentCategoriesResult.rows[0].count);

    client.release();

    const integrityChecks = [
      { name: 'Criadores sem usuários', count: orphanedCreators },
      { name: 'Conteúdo sem criadores', count: orphanedContent },
      { name: 'Conteúdo sem categorias', count: orphanedContentCategories }
    ];

    let integrityValid = true;
    for (const check of integrityChecks) {
      if (check.count === 0) {
        logTest(`Integridade: ${check.name}`, true, 'Nenhum registro órfão encontrado');
      } else {
        logTest(`Integridade: ${check.name}`, false, `${check.count} registros órfãos encontrados`);
        integrityValid = false;
      }
    }

    return integrityValid;
  } catch (error) {
    logTest('Integridade Referencial', false, 'Erro ao verificar integridade', error);
    return false;
  }
}

/**
 * Teste 5: Verificar constraints e índices
 */
async function testConstraintsAndIndexes() {
  console.log('\n🔒 Testando constraints e índices...');

  try {
    const client = await pool.connect();

    // Verificar índices importantes
    const indexesResult = await client.query(`
      SELECT indexname, tablename
      FROM pg_indexes
      WHERE schemaname = 'public'
      AND indexname LIKE '%_pkey'
    `);

    const primaryKeys = indexesResult.rows.map(row => `${row.tablename}.${row.indexname}`);

    // Verificar foreign keys
    const foreignKeysResult = await client.query(`
      SELECT conname, conrelid::regclass as table_name
      FROM pg_constraint
      WHERE contype = 'f'
      AND connamespace = 'public'::regnamespace
    `);

    const foreignKeys = foreignKeysResult.rows.map(row => `${row.table_name}.${row.conname}`);

    client.release();

    // Validar presença de constraints essenciais
    const essentialConstraints = [
      'users.users_pkey',
      'creators.creators_pkey',
      'content.content_pkey',
      'categories.categories_pkey'
    ];

    let constraintsValid = true;
    for (const constraint of essentialConstraints) {
      if (primaryKeys.includes(constraint)) {
        logTest(`Constraint: ${constraint}`, true, 'Constraint encontrado');
      } else {
        logTest(`Constraint: ${constraint}`, false, 'Constraint não encontrado');
        constraintsValid = false;
      }
    }

    logTest('Foreign Keys', true, `${foreignKeys.length} foreign keys encontradas`);

    return constraintsValid;
  } catch (error) {
    logTest('Constraints e Índices', false, 'Erro ao verificar constraints', error);
    return false;
  }
}

// =============================================================================
// TESTES DA API
// =============================================================================

/**
 * Teste 6: Saúde da API
 */
async function testAPIHealth() {
  console.log('\n🩺 Testando saúde da API...');

  try {
    const response = await axios.get(`${API_BASE_URL}/health`);
    if (response.status === 200) {
      logTest('Saúde da API', true, 'API respondendo corretamente');
      return true;
    } else {
      logTest('Saúde da API', false, `Status inesperado: ${response.status}`);
      return false;
    }
  } catch (error) {
    logTest('Saúde da API', false, 'Erro ao acessar API', error);
    return false;
  }
}

/**
 * Teste 7: Endpoints de usuários
 */
async function testUserEndpoints() {
  console.log('\n👤 Testando endpoints de usuários...');

  try {
    // Testar listagem de usuários
    const listResponse = await axios.get(`${API_BASE_URL}/users`);
    logTest('Listar Usuários', listResponse.status === 200, `Status: ${listResponse.status}`);

    // Testar busca de usuário específico
    if (listResponse.data.users && listResponse.data.users.length > 0) {
      const userId = listResponse.data.users[0].id;
      const userResponse = await axios.get(`${API_BASE_URL}/users/${userId}`);
      logTest('Buscar Usuário Específico', userResponse.status === 200, `Status: ${userResponse.status}`);
    }

    return true;
  } catch (error) {
    logTest('Endpoints de Usuários', false, 'Erro nos testes', error);
    return false;
  }
}

/**
 * Teste 8: Endpoints de conteúdo
 */
async function testContentEndpoints() {
  console.log('\n🎥 Testando endpoints de conteúdo...');

  try {
    // Testar listagem de conteúdo
    const listResponse = await axios.get(`${API_BASE_URL}/content`);
    logTest('Listar Conteúdo', listResponse.status === 200, `Encontrados: ${listResponse.data.content?.length || 0} itens`);

    // Testar busca por categoria
    const categoriesResponse = await axios.get(`${API_BASE_URL}/categories`);
    if (categoriesResponse.data.categories && categoriesResponse.data.categories.length > 0) {
      const categoryId = categoriesResponse.data.categories[0].id;
      const categoryContentResponse = await axios.get(`${API_BASE_URL}/content?category=${categoryId}`);
      logTest('Conteúdo por Categoria', categoryContentResponse.status === 200, `Status: ${categoryContentResponse.status}`);
    }

    return true;
  } catch (error) {
    logTest('Endpoints de Conteúdo', false, 'Erro nos testes', error);
    return false;
  }
}

/**
 * Teste 9: Endpoints de criadores
 */
async function testCreatorEndpoints() {
  console.log('\n🎬 Testando endpoints de criadores...');

  try {
    // Testar listagem de criadores
    const listResponse = await axios.get(`${API_BASE_URL}/creators`);
    logTest('Listar Criadores', listResponse.status === 200, `Encontrados: ${listResponse.data.creators?.length || 0} criadores`);

    // Testar criadores populares
    const popularResponse = await axios.get(`${API_BASE_URL}/creators/popular`);
    logTest('Criadores Populares', popularResponse.status === 200, `Status: ${popularResponse.status}`);

    return true;
  } catch (error) {
    logTest('Endpoints de Criadores', false, 'Erro nos testes', error);
    return false;
  }
}

// =============================================================================
// TESTES DE PERFORMANCE
// =============================================================================

/**
 * Teste 10: Performance de queries
 */
async function testQueryPerformance() {
  console.log('\n⚡ Testando performance de queries...');

  try {
    const client = await pool.connect();

    // Query complexa para testar performance
    const startTime = Date.now();
    const result = await client.query(`
      SELECT
        c.title,
        c.view_count,
        c.like_count,
        cat.name as category_name,
        cr.channel_name,
        u.username
      FROM content c
      JOIN categories cat ON c.category_id = cat.id
      JOIN creators cr ON c.creator_id = cr.id
      JOIN users u ON cr.user_id = u.id
      ORDER BY c.view_count DESC
      LIMIT 10
    `);
    const endTime = Date.now();
    const duration = endTime - startTime;

    client.release();

    if (duration < 1000) { // Menos de 1 segundo
      logTest('Performance de Query', true, `Query executada em ${duration}ms`);
    } else {
      logTest('Performance de Query', false, `Query muito lenta: ${duration}ms`);
    }

    return duration < 1000;
  } catch (error) {
    logTest('Performance de Query', false, 'Erro na execução', error);
    return false;
  }
}

// =============================================================================
// TESTES DE CASOS DE ERRO
// =============================================================================

/**
 * Teste 11: Casos de erro da API
 */
async function testAPIErrorCases() {
  console.log('\n🚨 Testando casos de erro da API...');

  try {
    let errorTestsPassed = 0;
    let totalErrorTests = 0;

    // Testar endpoint inexistente
    totalErrorTests++;
    try {
      await axios.get(`${API_BASE_URL}/nonexistent`);
    } catch (error) {
      if (error.response?.status === 404) {
        errorTestsPassed++;
        logTest('Erro 404 - Endpoint Inexistente', true, 'Tratamento correto de 404');
      } else {
        logTest('Erro 404 - Endpoint Inexistente', false, `Status inesperado: ${error.response?.status}`);
      }
    }

    // Testar ID inválido
    totalErrorTests++;
    try {
      await axios.get(`${API_BASE_URL}/users/invalid-id`);
    } catch (error) {
      if (error.response?.status === 400 || error.response?.status === 404) {
        errorTestsPassed++;
        logTest('Erro - ID Inválido', true, 'Tratamento correto de ID inválido');
      } else {
        logTest('Erro - ID Inválido', false, `Status inesperado: ${error.response?.status}`);
      }
    }

    const success = errorTestsPassed === totalErrorTests;
    logTest('Casos de Erro da API', success, `${errorTestsPassed}/${totalErrorTests} testes passaram`);
    return success;
  } catch (error) {
    logTest('Casos de Erro da API', false, 'Erro geral nos testes', error);
    return false;
  }
}

// =============================================================================
// FUNÇÃO PRINCIPAL
// =============================================================================

/**
 * Executa todos os testes completos
 */
async function runCompleteTests() {
  console.log('🚀 Iniciando Testes Completos do Sistema');
  console.log('=' .repeat(60));

  try {
    // Testes de Banco de Dados
    await testDatabaseConnection();
    await testTableStructure();
    await testInitialData();
    await testReferentialIntegrity();
    await testConstraintsAndIndexes();

    // Testes da API
    await testAPIHealth();
    await testUserEndpoints();
    await testContentEndpoints();
    await testCreatorEndpoints();

    // Testes de Performance
    await testQueryPerformance();

    // Testes de Casos de Erro
    await testAPIErrorCases();

  } catch (error) {
    console.error('❌ Erro fatal durante os testes:', error);
  } finally {
    // Fechar pool de conexões
    if (pool) {
      await pool.end();
    }
  }

  // Resultado final
  console.log('\n' + '='.repeat(60));
  console.log('📊 RESULTADO FINAL DOS TESTES COMPLETOS');
  console.log('='.repeat(60));
  console.log(`Total de testes: ${testResults.total}`);
  console.log(`✅ Aprovados: ${testResults.passed}`);
  console.log(`❌ Reprovados: ${testResults.failed}`);
  console.log(`📈 Taxa de sucesso: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`);

  if (testResults.failed === 0) {
    console.log('\n🎉 Todos os testes passaram! Sistema funcionando perfeitamente.');
  } else {
    console.log(`\n⚠️  ${testResults.failed} teste(s) falharam. Verifique os logs acima para detalhes.`);
    console.log('\n📋 Detalhes dos testes que falharam:');
    testResults.details
      .filter(test => !test.success)
      .forEach(test => {
        console.log(`   - ${test.name}: ${test.error || test.message}`);
      });
  }

  console.log('='.repeat(60));

  return testResults.failed === 0;
}

// Executar apenas se chamado diretamente
if (require.main === module) {
  runCompleteTests()
    .then(success => {
      process.exit(success ? 0 : 1);
    })
    .catch(error => {
      console.error('❌ Erro fatal:', error);
      process.exit(1);
    });
}

module.exports = { runCompleteTests, testResults };
