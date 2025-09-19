// auth.js
// Script compartilhado para autenticação (login e registro)

// Variáveis globais para autenticação
let currentUser = null;

// Função para verificar sessão e redirecionar se necessário
function checkAuthSession() {
    const user = localStorage.getItem('currentUser');
    if (user) {
        currentUser = JSON.parse(user);
        // Se estiver em login ou register e já logado, redirecionar para dashboard
        if (window.location.pathname.includes('login.html') || window.location.pathname.includes('register.html')) {
            window.location.href = 'dashboard.html';
        }
    } else {
        // Se não estiver logado e tentar acessar dashboard, redirecionar para landing
        if (window.location.pathname.includes('dashboard.html')) {
            window.location.href = 'landing.html';
        }
    }
}

// Função para lidar com login
async function handleLogin(event) {
    event.preventDefault(); // Impede o envio padrão do formulário

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        // Busca usuários da API
        const response = await fetch('http://localhost:3000/api/users');
        const users = await response.json();

        // Verifica se o usuário existe e a senha está correta
        const user = users.find(u => u.email === email && u.password === password);

        if (user) {
            // Salva usuário no localStorage
            currentUser = user;
            localStorage.setItem('currentUser', JSON.stringify(user));

            alert('Login realizado com sucesso!');
            // Redireciona para dashboard
            window.location.href = 'dashboard.html';
        } else {
            alert('Email ou senha incorretos.');
        }
    } catch (error) {
        console.error('Erro ao fazer login:', error);
        alert('Erro ao fazer login. Tente novamente.');
    }
}

// Função para lidar com registro
async function handleRegister(event) {
    event.preventDefault(); // Impede o envio padrão do formulário

    const name = document.getElementById('name').value;
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        // Envia dados para a API
        const response = await fetch('http://localhost:3000/api/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name, email, password })
        });

        if (response.ok) {
            const result = await response.json();
            alert('Usuário registrado com sucesso!');

            // Faz login automático após registro
            currentUser = result;
            localStorage.setItem('currentUser', JSON.stringify(result));

            // Redireciona para dashboard
            window.location.href = 'dashboard.html';
        } else {
            alert('Erro ao registrar usuário. Tente novamente.');
        }
    } catch (error) {
        console.error('Erro ao registrar usuário:', error);
        alert('Erro ao registrar usuário. Tente novamente.');
    }
}

// Função para logout
function logout() {
    localStorage.removeItem('currentUser');
    currentUser = null;
    window.location.href = 'landing.html';
}

// Inicialização ao carregar a página
document.addEventListener('DOMContentLoaded', () => {
    checkAuthSession();

    // Configura event listeners para formulários
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');

    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }

    if (registerForm) {
        registerForm.addEventListener('submit', handleRegister);
    }
});
