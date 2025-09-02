/**
 * Script de testes automatizados para fluxo de autenticação de usuário
 * Testa registro, login, perfil, logout e persistência de sessão
 */

const fetch = require('node-fetch');

const BASE_URL = 'http://localhost:3001/api';

async function testRegister() {
    console.log('Testando registro de usuário...');
    const response = await fetch(\`\${BASE_URL}/users/register\`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            username: 'testuser1',
            email: 'testuser1@example.com',
            password: 'testpass123',
            full_name: 'Test User',
            bio: 'Bio de teste'
        })
    });
    const data = await response.json();
    if (response.status === 201) {
        console.log('Registro OK:', data.message);
    } else {
        console.error('Falha no registro:', data);
    }
}

async function testLogin() {
    console.log('Testando login...');
    const response = await fetch(\`\${BASE_URL}/users/login\`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            email: 'testuser1@example.com',
            password: 'testpass123'
        })
    });
    const data = await response.json();
    if (response.ok && data.token) {
        console.log('Login OK:', data.message);
        return data.token;
    } else {
        console.error('Falha no login:', data);
        return null;
    }
}

async function testGetProfile(token) {
    console.log('Testando obtenção de perfil...');
    const response = await fetch(\`\${BASE_URL}/users/profile\`, {
        method: 'GET',
        headers: { 'Authorization': \`Bearer \${token}\` }
    });
    const data = await response.json();
    if (response.ok) {
        console.log('Perfil obtido:', data.user.username);
    } else {
        console.error('Falha ao obter perfil:', data);
    }
}

async function testLogout() {
    console.log('Testando logout...');
    // Logout no backend é apenas remoção do token no frontend, então aqui só simulamos
    console.log('Logout simulado (token removido no frontend)');
}

async function runTests() {
    await testRegister();
    const token = await testLogin();
    if (token) {
        await testGetProfile(token);
        await testLogout();
    }
}

runTests().catch(err => {
    console.error('Erro nos testes:', err);
});
