// landing.js
// Script para interações da página inicial (landing page)

// Função para configurar event listeners dos botões de login e registro
function setupLandingPage() {
    const loginButtons = document.querySelectorAll('button[onclick*="login.html"]');
    const registerButtons = document.querySelectorAll('button[onclick*="register.html"]');

    loginButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            window.location.href = 'login.html';
        });
    });

    registerButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            window.location.href = 'register.html';
        });
    });
}

// Verifica se o usuário já está logado e redireciona para dashboard
function checkSession() {
    const currentUser = localStorage.getItem('currentUser');
    if (currentUser) {
        window.location.href = 'dashboard.html';
    }
}

// Inicialização ao carregar a página
document.addEventListener('DOMContentLoaded', () => {
    checkSession();
    setupLandingPage();
});
