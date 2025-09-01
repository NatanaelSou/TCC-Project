// Script de teste para validar os endpoints críticos da API
// Este script testa os principais fluxos da aplicação

const axios = require('axios');

const API_BASE_URL = 'http://localhost:3001/api';

// Variáveis para armazenar dados de teste
let testUser = null;
let testToken = null;
let testCreator = null;
let testContent = null;

// Função auxiliar para fazer requisições HTTP
async function makeRequest(method, url, data = null, token = null) {
  try {
    const config = {
      method,
      url: `${API_BASE_URL}${url}`,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    if (data) {
      config.data = data;
    }

    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return {
      success: false,
      error: error.response?.data || error.message,
      status: error.response?.status
    };
  }
}

// Teste 1: Verificar saúde da API
async function testAPIHealth() {
  console.log('\n🩺 Testando saúde da API...');
  const result = await makeRequest('GET', '/health');

  if (result.success) {
    console.log('✅ API está saudável');
    console.log('📊 Status:', result.data);
  } else {
    console.log('❌ Erro na API:', result.error);
  }

  return result.success;
}

// Teste 2: Registrar novo usuário
async function testUserRegistration() {
  console.log('\n👤 Testando registro de usuário...');

  const userData = {
    username: 'testuser_' + Date.now(),
    email: 'test' + Date.now() + '@example.com',
    password: 'testpassword123',
    full_name: 'Usuário de Teste'
  };

  const result = await makeRequest('POST', '/users/register', userData);

  if (result.success) {
    console.log('✅ Usuário registrado com sucesso');
    testUser = result.data.user;
    console.log('👤 Usuário criado:', testUser.username);
  } else {
    console.log('❌ Erro no registro:', result.error);
  }

  return result.success;
}

// Teste 3: Fazer login
async function testUserLogin() {
  console.log('\n🔐 Testando login de usuário...');

  if (!testUser) {
    console.log('❌ Nenhum usuário de teste disponível');
    return false;
  }

  const loginData = {
    email: testUser.email,
    password: 'testpassword123'
  };

  const result = await makeRequest('POST', '/users/login', loginData);

  if (result.success) {
    console.log('✅ Login realizado com sucesso');
    testToken = result.data.token;
    console.log('🔑 Token JWT obtido');
  } else {
    console.log('❌ Erro no login:', result.error);
  }

  return result.success;
}

// Teste 4: Obter perfil do usuário
async function testGetUserProfile() {
  console.log('\n👤 Testando obtenção de perfil...');

  if (!testToken) {
    console.log('❌ Nenhum token disponível');
    return false;
  }

  const result = await makeRequest('GET', '/users/profile', null, testToken);

  if (result.success) {
    console.log('✅ Perfil obtido com sucesso');
    console.log('👤 Perfil:', result.data.user.username);
  } else {
    console.log('❌ Erro ao obter perfil:', result.error);
  }

  return result.success;
}

// Teste 5: Criar canal de criador
async function testCreateCreatorChannel() {
  console.log('\n🎬 Testando criação de canal...');

  if (!testToken) {
    console.log('❌ Nenhum token disponível');
    return false;
  }

  const channelData = {
    channel_name: 'Canal de Teste ' + Date.now(),
    channel_description: 'Este é um canal de teste para validação da API'
  };

  const result = await makeRequest('POST', '/creators/channel', channelData, testToken);

  if (result.success) {
    console.log('✅ Canal criado com sucesso');
    testCreator = result.data.creator;
    console.log('🎬 Canal:', testCreator.channel_name);
  } else {
    console.log('❌ Erro ao criar canal:', result.error);
  }

  return result.success;
}

// Teste 6: Criar conteúdo
async function testCreateContent() {
  console.log('\n🎥 Testando criação de conteúdo...');

  if (!testToken || !testCreator) {
    console.log('❌ Token ou criador não disponível');
    return false;
  }

  const contentData = {
    title: 'Vídeo de Teste ' + Date.now(),
    description: 'Este é um vídeo de teste para validação da API',
    video_url: 'https://example.com/video.mp4',
    thumbnail_url: 'https://example.com/thumbnail.jpg',
    category_id: '550e8400-e29b-41d4-a716-446655440000', // UUID de exemplo
    tags: ['teste', 'api', 'backend']
  };

  const result = await makeRequest('POST', '/content', contentData, testToken);

  if (result.success) {
    console.log('✅ Conteúdo criado com sucesso');
    testContent = result.data.content;
    console.log('🎥 Conteúdo:', testContent.title);
  } else {
    console.log('❌ Erro ao criar conteúdo:', result.error);
  }

  return result.success;
}

// Teste 7: Listar conteúdo
async function testListContent() {
  console.log('\n📋 Testando listagem de conteúdo...');

  const result = await makeRequest('GET', '/content');

  if (result.success) {
    console.log('✅ Conteúdo listado com sucesso');
    console.log('📊 Total de itens:', result.data.content?.length || 0);
  } else {
    console.log('❌ Erro ao listar conteúdo:', result.error);
  }

  return result.success;
}

// Teste 8: Obter criadores populares
async function testGetPopularCreators() {
  console.log('\n⭐ Testando criadores populares...');

  const result = await makeRequest('GET', '/creators/popular');

  if (result.success) {
    console.log('✅ Criadores populares obtidos com sucesso');
    console.log('📊 Total de criadores:', result.data.creators?.length || 0);
  } else {
    console.log('❌ Erro ao obter criadores populares:', result.error);
  }

  return result.success;
}

// Função principal de teste
async function runTests() {
  console.log('🚀 Iniciando testes críticos da API...\n');

  const results = {
    total: 0,
    passed: 0,
    failed: 0
  };

  // Array de testes a serem executados
  const tests = [
    { name: 'Saúde da API', func: testAPIHealth },
    { name: 'Registro de Usuário', func: testUserRegistration },
    { name: 'Login de Usuário', func: testUserLogin },
    { name: 'Perfil do Usuário', func: testGetUserProfile },
    { name: 'Criar Canal', func: testCreateCreatorChannel },
    { name: 'Criar Conteúdo', func: testCreateContent },
    { name: 'Listar Conteúdo', func: testListContent },
    { name: 'Criadores Populares', func: testGetPopularCreators }
  ];

  // Executar todos os testes
  for (const test of tests) {
    results.total++;
    console.log(`\n${'='.repeat(50)}`);
    console.log(`Teste ${results.total}: ${test.name}`);
    console.log(`${'='.repeat(50)}`);

    try {
      const success = await test.func();
      if (success) {
        results.passed++;
        console.log(`✅ ${test.name}: PASSOU`);
      } else {
        results.failed++;
        console.log(`❌ ${test.name}: FALHOU`);
      }
    } catch (error) {
      results.failed++;
      console.log(`❌ ${test.name}: ERRO -`, error.message);
    }
  }

  // Resultado final
  console.log('\n' + '='.repeat(60));
  console.log('📊 RESULTADO FINAL DOS TESTES');
  console.log('='.repeat(60));
  console.log(`Total de testes: ${results.total}`);
  console.log(`✅ Aprovados: ${results.passed}`);
  console.log(`❌ Reprovados: ${results.failed}`);
  console.log(`📈 Taxa de sucesso: ${((results.passed / results.total) * 100).toFixed(1)}%`);

  if (results.failed === 0) {
    console.log('\n🎉 Todos os testes passaram! A API está funcionando corretamente.');
  } else {
    console.log(`\n⚠️  ${results.failed} teste(s) falharam. Verifique os logs acima para detalhes.`);
  }

  console.log('='.repeat(60));
}

// Executar apenas se chamado diretamente
if (require.main === module) {
  runTests().catch(error => {
    console.error('❌ Erro fatal durante os testes:', error);
    process.exit(1);
  });
}

module.exports = { runTests };
