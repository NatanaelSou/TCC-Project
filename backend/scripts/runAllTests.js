/**
 * Script Principal para Executar Todos os Testes
 * Este arquivo coordena a execução de todos os testes do sistema:
 * - Testes de banco de dados
 * - Testes da API
 * - Testes de carga e performance
 * - Geração de relatórios consolidados
 */

const { runCompleteTests } = require('./completeDatabaseTests');
const { runLoadTests } = require('./loadTests');
const fs = require('fs');
const path = require('path');

// Configurações dos testes
const TEST_CONFIG = {
  enableDatabaseTests: true,
  enableAPITests: true,
  enableLoadTests: true,
  outputReport: true,
  reportFile: 'test-report.json'
};

// Resultados consolidados
let consolidatedResults = {
  timestamp: new Date().toISOString(),
  summary: {
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    successRate: 0
  },
  database: null,
  api: null,
  load: null,
  recommendations: []
};

/**
 * Executa testes de banco de dados
 */
async function runDatabaseTests() {
  console.log('\n🗄️  EXECUTANDO TESTES DE BANCO DE DADOS');
  console.log('='.repeat(50));

  try {
    const success = await runCompleteTests();
    consolidatedResults.database = {
      success,
      timestamp: new Date().toISOString()
    };
    return success;
  } catch (error) {
    console.error('❌ Erro nos testes de banco de dados:', error);
    consolidatedResults.database = {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
    return false;
  }
}

/**
 * Executa testes da API
 */
async function runAPITests() {
  console.log('\n🌐 EXECUTANDO TESTES DA API');
  console.log('='.repeat(50));

  try {
    // Importar e executar testes da API existentes
    const { runTests } = require('./testAPI');
    await runTests();

    consolidatedResults.api = {
      success: true,
      timestamp: new Date().toISOString()
    };
    return true;
  } catch (error) {
    console.error('❌ Erro nos testes da API:', error);
    consolidatedResults.api = {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
    return false;
  }
}

/**
 * Executa testes de carga
 */
async function runLoadTestsSuite() {
  console.log('\n⚡ EXECUTANDO TESTES DE CARGA');
  console.log('='.repeat(50));

  try {
    const success = await runLoadTests();
    consolidatedResults.load = {
      success,
      timestamp: new Date().toISOString()
    };
    return success;
  } catch (error) {
    console.error('❌ Erro nos testes de carga:', error);
    consolidatedResults.load = {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };
    return false;
  }
}

/**
 * Gera recomendações baseadas nos resultados
 */
function generateRecommendations() {
  const recommendations = [];

  if (!consolidatedResults.database?.success) {
    recommendations.push({
      type: 'database',
      priority: 'high',
      message: 'Problemas críticos no banco de dados - verificar conexão, estrutura e dados',
      actions: [
        'Verificar configuração do PostgreSQL',
        'Executar migrations pendentes',
        'Verificar integridade dos dados',
        'Corrigir constraints e índices'
      ]
    });
  }

  if (!consolidatedResults.api?.success) {
    recommendations.push({
      type: 'api',
      priority: 'high',
      message: 'Problemas na API - verificar endpoints e funcionalidades',
      actions: [
        'Verificar se o servidor está rodando',
        'Testar endpoints individualmente',
        'Verificar logs de erro da aplicação',
        'Validar configurações de middleware'
      ]
    });
  }

  if (!consolidatedResults.load?.success) {
    recommendations.push({
      type: 'performance',
      priority: 'medium',
      message: 'Problemas de performance detectados',
      actions: [
        'Otimizar queries do banco de dados',
        'Implementar cache onde apropriado',
        'Configurar pool de conexões',
        'Considerar load balancer para produção'
      ]
    });
  }

  if (recommendations.length === 0) {
    recommendations.push({
      type: 'success',
      priority: 'low',
      message: 'Sistema funcionando corretamente',
      actions: [
        'Monitorar performance em produção',
        'Configurar alertas para downtime',
        'Fazer backup regular dos dados',
        'Planejar escalabilidade futura'
      ]
    });
  }

  consolidatedResults.recommendations = recommendations;
}

/**
 * Salva relatório em arquivo
 */
function saveReport() {
  try {
    const reportPath = path.join(__dirname, '..', '..', TEST_CONFIG.reportFile);
    fs.writeFileSync(reportPath, JSON.stringify(consolidatedResults, null, 2));
    console.log(`\n📄 Relatório salvo em: ${reportPath}`);
  } catch (error) {
    console.error('❌ Erro ao salvar relatório:', error);
  }
}

/**
 * Exibe relatório final
 */
function displayFinalReport() {
  console.log('\n' + '='.repeat(80));
  console.log('📊 RELATÓRIO CONSOLIDADO DE TESTES');
  console.log('='.repeat(80));

  console.log(`🕒 Timestamp: ${consolidatedResults.timestamp}`);
  console.log(`📈 Total de Testes: ${consolidatedResults.summary.totalTests}`);
  console.log(`✅ Aprovados: ${consolidatedResults.summary.passedTests}`);
  console.log(`❌ Reprovados: ${consolidatedResults.summary.failedTests}`);
  console.log(`📊 Taxa de Sucesso: ${consolidatedResults.summary.successRate.toFixed(2)}%`);

  console.log('\n📋 Status dos Módulos:');
  console.log(`   🗄️  Banco de Dados: ${consolidatedResults.database?.success ? '✅ OK' : '❌ FALHA'}`);
  console.log(`   🌐 API: ${consolidatedResults.api?.success ? '✅ OK' : '❌ FALHA'}`);
  console.log(`   ⚡ Carga/Performance: ${consolidatedResults.load?.success ? '✅ OK' : '❌ FALHA'}`);

  if (consolidatedResults.recommendations.length > 0) {
    console.log('\n💡 RECOMENDAÇÕES:');
    consolidatedResults.recommendations.forEach((rec, index) => {
      const priorityIcon = rec.priority === 'high' ? '🔴' :
                          rec.priority === 'medium' ? '🟡' : '🟢';
      console.log(`   ${priorityIcon} ${rec.message}`);
      rec.actions.forEach(action => {
        console.log(`      • ${action}`);
      });
      if (index < consolidatedResults.recommendations.length - 1) {
        console.log('');
      }
    });
  }

  console.log('='.repeat(80));
}

/**
 * Função principal que executa todos os testes
 */
async function runAllTests() {
  console.log('🚀 INICIANDO SUITE COMPLETA DE TESTES');
  console.log('Testando: Banco de Dados, API e Performance');
  console.log('='.repeat(80));

  const startTime = Date.now();
  let testCount = 0;
  let passedCount = 0;

  try {
    // Executar testes de banco de dados
    if (TEST_CONFIG.enableDatabaseTests) {
      testCount++;
      const dbSuccess = await runDatabaseTests();
      if (dbSuccess) passedCount++;
    }

    // Executar testes da API
    if (TEST_CONFIG.enableAPITests) {
      testCount++;
      const apiSuccess = await runAPITests();
      if (apiSuccess) passedCount++;
    }

    // Executar testes de carga
    if (TEST_CONFIG.enableLoadTests) {
      testCount++;
      const loadSuccess = await runLoadTestsSuite();
      if (loadSuccess) passedCount++;
    }

  } catch (error) {
    console.error('❌ Erro fatal durante execução dos testes:', error);
  }

  const endTime = Date.now();
  const duration = (endTime - startTime) / 1000;

  // Atualizar resumo
  consolidatedResults.summary.totalTests = testCount;
  consolidatedResults.summary.passedTests = passedCount;
  consolidatedResults.summary.failedTests = testCount - passedCount;
  consolidatedResults.summary.successRate = testCount > 0 ? (passedCount / testCount) * 100 : 0;

  // Gerar recomendações
  generateRecommendations();

  // Exibir relatório final
  displayFinalReport();

  // Salvar relatório se configurado
  if (TEST_CONFIG.outputReport) {
    saveReport();
  }

  console.log(`⏱️  Tempo total de execução: ${duration.toFixed(2)} segundos`);

  // Resultado final
  const overallSuccess = passedCount === testCount;
  if (overallSuccess) {
    console.log('\n🎉 TODOS OS TESTES PASSARAM!');
    console.log('✅ Sistema pronto para produção.');
  } else {
    console.log(`\n⚠️  ${testCount - passedCount} teste(s) falharam.`);
    console.log('🔧 Verifique as recomendações acima para correções.');
  }

  console.log('='.repeat(80));

  return overallSuccess;
}

/**
 * Função para executar testes específicos
 */
async function runSpecificTests(options = {}) {
  const config = { ...TEST_CONFIG, ...options };
  console.log('🔧 Executando testes específicos:', JSON.stringify(config, null, 2));

  // Temporariamente atualizar configuração
  Object.assign(TEST_CONFIG, config);

  return await runAllTests();
}

// Executar apenas se chamado diretamente
if (require.main === module) {
  // Verificar argumentos da linha de comando
  const args = process.argv.slice(2);
  const options = {};

  if (args.includes('--no-database')) {
    options.enableDatabaseTests = false;
  }
  if (args.includes('--no-api')) {
    options.enableAPITests = false;
  }
  if (args.includes('--no-load')) {
    options.enableLoadTests = false;
  }
  if (args.includes('--no-report')) {
    options.outputReport = false;
  }

  runSpecificTests(options)
    .then(success => {
      process.exit(success ? 0 : 1);
    })
    .catch(error => {
      console.error('❌ Erro fatal:', error);
      process.exit(1);
    });
}

module.exports = {
  runAllTests,
  runSpecificTests,
  consolidatedResults,
  TEST_CONFIG
};
