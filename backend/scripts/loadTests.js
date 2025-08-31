/**
 * Script de Testes de Carga e Performance
 * Este arquivo contém testes para avaliar:
 * - Capacidade de carga do sistema
 * - Performance sob múltiplas conexões simultâneas
 * - Tempo de resposta em diferentes cenários
 * - Limites de recursos do sistema
 */

const axios = require('axios');
const { Pool } = require('pg');

// Configurações
const API_BASE_URL = 'http://localhost:3001/api';
const CONCURRENT_REQUESTS = 50; // Número de requisições simultâneas
const TEST_DURATION = 30000; // Duração do teste em ms (30 segundos)

// Estatísticas de teste
let loadTestResults = {
  totalRequests: 0,
  successfulRequests: 0,
  failedRequests: 0,
  responseTimes: [],
  errors: []
};

/**
 * Função para medir tempo de resposta de uma requisição
 */
async function measureResponseTime(url, method = 'GET', data = null) {
  const startTime = Date.now();

  try {
    const config = {
      method,
      url: `${API_BASE_URL}${url}`,
      timeout: 10000 // 10 segundos timeout
    };

    if (data) {
      config.data = data;
      config.headers = { 'Content-Type': 'application/json' };
    }

    const response = await axios(config);
    const endTime = Date.now();
    const responseTime = endTime - startTime;

    loadTestResults.totalRequests++;
    loadTestResults.successfulRequests++;
    loadTestResults.responseTimes.push(responseTime);

    return { success: true, responseTime, status: response.status };
  } catch (error) {
    const endTime = Date.now();
    const responseTime = endTime - startTime;

    loadTestResults.totalRequests++;
    loadTestResults.failedRequests++;
    loadTestResults.responseTimes.push(responseTime);
    loadTestResults.errors.push({
      url,
      method,
      error: error.message,
      status: error.response?.status,
      responseTime
    });

    return { success: false, responseTime, error: error.message };
  }
}

/**
 * Teste de carga para endpoints de leitura
 */
async function testReadLoad() {
  console.log('\n📖 Testando carga de endpoints de leitura...');

  const endpoints = [
    '/content',
    '/categories',
    '/creators',
    '/users'
  ];

  const promises = [];

  // Criar múltiplas requisições simultâneas
  for (let i = 0; i < CONCURRENT_REQUESTS; i++) {
    const endpoint = endpoints[i % endpoints.length];
    promises.push(measureResponseTime(endpoint));
  }

  const results = await Promise.all(promises);

  const successful = results.filter(r => r.success).length;
  const avgResponseTime = results.reduce((sum, r) => sum + r.responseTime, 0) / results.length;

  console.log(`✅ ${successful}/${results.length} requisições de leitura bem-sucedidas`);
  console.log(`⏱️  Tempo médio de resposta: ${avgResponseTime.toFixed(2)}ms`);

  return successful === results.length;
}

/**
 * Teste de carga para endpoints mistos
 */
async function testMixedLoad() {
  console.log('\n🔄 Testando carga mista de endpoints...');

  const operations = [
    () => measureResponseTime('/content'),
    () => measureResponseTime('/categories'),
    () => measureResponseTime('/creators/popular'),
    () => measureResponseTime('/users')
  ];

  const promises = [];

  // Criar requisições variadas
  for (let i = 0; i < CONCURRENT_REQUESTS; i++) {
    const operation = operations[i % operations.length];
    promises.push(operation());
  }

  const results = await Promise.all(promises);

  const successful = results.filter(r => r.success).length;
  const avgResponseTime = results.reduce((sum, r) => sum + r.responseTime, 0) / results.length;

  console.log(`✅ ${successful}/${results.length} requisições mistas bem-sucedidas`);
  console.log(`⏱️  Tempo médio de resposta: ${avgResponseTime.toFixed(2)}ms`);

  return successful >= results.length * 0.95; // Aceitar 95% de sucesso
}

/**
 * Teste de carga contínua por período
 */
async function testContinuousLoad() {
  console.log('\n🔄 Testando carga contínua...');

  const startTime = Date.now();
  let requestCount = 0;
  const maxRequests = 1000; // Máximo de requisições durante o teste

  while (Date.now() - startTime < TEST_DURATION && requestCount < maxRequests) {
    // Fazer requisições variadas
    const promises = [
      measureResponseTime('/content'),
      measureResponseTime('/categories'),
      measureResponseTime('/creators')
    ];

    await Promise.all(promises);
    requestCount += promises.length;

    // Pequena pausa para não sobrecarregar
    await new Promise(resolve => setTimeout(resolve, 10));
  }

  const duration = (Date.now() - startTime) / 1000;
  const requestsPerSecond = requestCount / duration;

  console.log(`📊 Teste contínuo concluído:`);
  console.log(`   - Duração: ${duration.toFixed(2)}s`);
  console.log(`   - Total de requisições: ${requestCount}`);
  console.log(`   - Requisições por segundo: ${requestsPerSecond.toFixed(2)}`);

  return requestsPerSecond > 10; // Esperar pelo menos 10 req/s
}

/**
 * Teste de stress com dados grandes
 */
async function testLargeDataLoad() {
  console.log('\n📊 Testando carga com dados grandes...');

  try {
    // Buscar todos os dados disponíveis
    const [contentRes, usersRes, creatorsRes] = await Promise.all([
      axios.get(`${API_BASE_URL}/content`),
      axios.get(`${API_BASE_URL}/users`),
      axios.get(`${API_BASE_URL}/creators`)
    ]);

    const contentCount = contentRes.data.content?.length || 0;
    const usersCount = usersRes.data.users?.length || 0;
    const creatorsCount = creatorsRes.data.creators?.length || 0;

    console.log(`📊 Dados encontrados:`);
    console.log(`   - Conteúdo: ${contentCount} itens`);
    console.log(`   - Usuários: ${usersCount} usuários`);
    console.log(`   - Criadores: ${creatorsCount} criadores`);

    // Testar paginação se houver muitos dados
    if (contentCount > 20) {
      const paginatedRes = await axios.get(`${API_BASE_URL}/content?page=1&limit=10`);
      const success = paginatedRes.status === 200;
      console.log(`✅ Paginação funcionando: ${success ? 'Sim' : 'Não'}`);
      return success;
    }

    return true;
  } catch (error) {
    console.log(`❌ Erro no teste de dados grandes: ${error.message}`);
    return false;
  }
}

/**
 * Análise de performance
 */
function analyzePerformance() {
  console.log('\n📈 Análise de Performance:');

  if (loadTestResults.responseTimes.length === 0) {
    console.log('❌ Nenhum dado de performance coletado');
    return;
  }

  const times = loadTestResults.responseTimes.sort((a, b) => a - b);
  const avgTime = times.reduce((sum, time) => sum + time, 0) / times.length;
  const minTime = Math.min(...times);
  const maxTime = Math.max(...times);
  const p95Time = times[Math.floor(times.length * 0.95)];
  const p99Time = times[Math.floor(times.length * 0.99)];

  console.log(`⏱️  Tempo de resposta médio: ${avgTime.toFixed(2)}ms`);
  console.log(`⚡ Tempo de resposta mínimo: ${minTime}ms`);
  console.log(`🐌 Tempo de resposta máximo: ${maxTime}ms`);
  console.log(`📊 Percentil 95: ${p95Time}ms`);
  console.log(`📊 Percentil 99: ${p99Time}ms`);

  // Avaliar performance
  const performanceScore = avgTime < 500 ? 'Excelente' :
                          avgTime < 1000 ? 'Boa' :
                          avgTime < 2000 ? 'Aceitável' : 'Ruim';

  console.log(`🎯 Avaliação de performance: ${performanceScore}`);

  return avgTime < 1000; // Considerar bom se média < 1s
}

/**
 * Relatório final de carga
 */
function generateLoadReport() {
  console.log('\n' + '='.repeat(60));
  console.log('📊 RELATÓRIO DE TESTES DE CARGA');
  console.log('='.repeat(60));

  console.log(`📈 Total de requisições: ${loadTestResults.totalRequests}`);
  console.log(`✅ Requisições bem-sucedidas: ${loadTestResults.successfulRequests}`);
  console.log(`❌ Requisições com falha: ${loadTestResults.failedRequests}`);

  const successRate = (loadTestResults.successfulRequests / loadTestResults.totalRequests * 100).toFixed(2);
  console.log(`📊 Taxa de sucesso: ${successRate}%`);

  if (loadTestResults.errors.length > 0) {
    console.log(`\n🚨 Principais erros encontrados:`);
    // Agrupar erros por tipo
    const errorGroups = {};
    loadTestResults.errors.forEach(error => {
      const key = `${error.status || 'Unknown'}: ${error.error}`;
      errorGroups[key] = (errorGroups[key] || 0) + 1;
    });

    Object.entries(errorGroups)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 5)
      .forEach(([error, count]) => {
        console.log(`   - ${error}: ${count} ocorrência(s)`);
      });
  }

  console.log('='.repeat(60));
}

/**
 * Executa todos os testes de carga
 */
async function runLoadTests() {
  console.log('🚀 Iniciando Testes de Carga e Performance');
  console.log('='.repeat(60));

  try {
    let allTestsPassed = true;

    // Executar testes individuais
    const tests = [
      { name: 'Carga de Leitura', func: testReadLoad },
      { name: 'Carga Mista', func: testMixedLoad },
      { name: 'Carga Contínua', func: testContinuousLoad },
      { name: 'Dados Grandes', func: testLargeDataLoad }
    ];

    for (const test of tests) {
      console.log(`\n🔬 Executando: ${test.name}`);
      const success = await test.func();
      if (!success) {
        allTestsPassed = false;
      }
    }

    // Análise de performance
    const performanceGood = analyzePerformance();
    if (!performanceGood) {
      allTestsPassed = false;
    }

    // Gerar relatório
    generateLoadReport();

    if (allTestsPassed) {
      console.log('\n🎉 Todos os testes de carga passaram!');
      console.log('✅ Sistema preparado para produção.');
    } else {
      console.log('\n⚠️  Alguns testes de carga falharam.');
      console.log('🔧 Considere otimizar a performance do sistema.');
    }

    console.log('='.repeat(60));

    return allTestsPassed;

  } catch (error) {
    console.error('❌ Erro fatal durante testes de carga:', error);
    return false;
  }
}

// Executar apenas se chamado diretamente
if (require.main === module) {
  runLoadTests()
    .then(success => {
      process.exit(success ? 0 : 1);
    })
    .catch(error => {
      console.error('❌ Erro fatal:', error);
      process.exit(1);
    });
}

module.exports = { runLoadTests, loadTestResults };
