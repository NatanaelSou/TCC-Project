// Variáveis globais
let currentUser = null;

// Carregar conteúdo quando a página carrega
document.addEventListener('DOMContentLoaded', () => {
    loadContent();
    setupEventListeners();
    checkLoginStatus();
});

// Configurar event listeners para botões e formulários
function setupEventListeners() {
    // Botões de login e registro
    document.getElementById('loginBtn').addEventListener('click', () => showModal('login'));
    document.getElementById('registerBtn').addEventListener('click', () => showModal('register'));

    // Fechar modal
    document.querySelector('.close').addEventListener('click', hideModal);
    window.addEventListener('click', (e) => {
        if (e.target === document.getElementById('authModal')) hideModal();
    });

    // Alternar entre login e registro
    document.getElementById('switchToRegister').addEventListener('click', () => switchForm('register'));
    document.getElementById('switchToLogin').addEventListener('click', () => switchForm('login'));

    // Formulários
    document.getElementById('loginFormEl').addEventListener('submit', handleLogin);
    document.getElementById('registerFormEl').addEventListener('submit', handleRegister);

    // Logout
    document.getElementById('logoutBtn').addEventListener('click', logout);
}

// Mostrar modal
function showModal(type) {
    const modal = document.getElementById('authModal');
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');

    modal.style.display = 'block';
    if (type === 'login') {
        loginForm.classList.remove('hidden');
        registerForm.classList.add('hidden');
    } else {
        registerForm.classList.remove('hidden');
        loginForm.classList.add('hidden');
    }
}

// Ocultar modal
function hideModal() {
    document.getElementById('authModal').style.display = 'none';
}

// Alternar formulários
function switchForm(type) {
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');

    if (type === 'register') {
        loginForm.classList.add('hidden');
        registerForm.classList.remove('hidden');
    } else {
        registerForm.classList.add('hidden');
        loginForm.classList.remove('hidden');
    }
}

// Verificar status de login
function checkLoginStatus() {
    const user = localStorage.getItem('currentUser');
    if (user) {
        currentUser = JSON.parse(user);
        showProfile();
        hideLoginButtons();
    }
}

// Ocultar botões de login
function hideLoginButtons() {
    document.getElementById('loginBtn').style.display = 'none';
    document.getElementById('registerBtn').style.display = 'none';
}

// Mostrar perfil
function showProfile() {
    const profileSection = document.getElementById('profile');
    const userProfile = document.getElementById('userProfile');

    profileSection.classList.remove('hidden');
    userProfile.innerHTML = `
        <p><strong>Nome:</strong> ${currentUser.name}</p>
        <p><strong>Email:</strong> ${currentUser.email}</p>
        <h3>Minhas Assinaturas</h3>
        <div id="userSubscriptions"></div>
    `;
    loadUserSubscriptions();
}

// Carregar assinaturas do usuário
async function loadUserSubscriptions() {
    try {
        const response = await fetch('http://localhost:3000/api/subscriptions');
        const subscriptions = await response.json();
        const userSubs = subscriptions.filter(sub => sub.user_id === currentUser.id);
        displaySubscriptions(userSubs);
    } catch (error) {
        console.error('Erro ao carregar assinaturas:', error);
    }
}

// Exibir assinaturas
function displaySubscriptions(subscriptions) {
    const subsDiv = document.getElementById('userSubscriptions');
    if (subscriptions.length === 0) {
        subsDiv.innerHTML = '<p>Você ainda não assinou nenhum criador.</p>';
    } else {
        subsDiv.innerHTML = subscriptions.map(sub => `<p>Assinado ao criador ID: ${sub.creator_id}</p>`).join('');
    }
}

// Logout
function logout() {
    localStorage.removeItem('currentUser');
    currentUser = null;
    document.getElementById('profile').classList.add('hidden');
    document.getElementById('loginBtn').style.display = 'inline-block';
    document.getElementById('registerBtn').style.display = 'inline-block';
    location.reload();
}

// Função para carregar conteúdo da API
async function loadContent() {
    try {
        const response = await fetch('http://localhost:3000/api/content');
        const content = await response.json();
        displayContent(content);
    } catch (error) {
        console.error('Erro ao carregar conteúdo:', error);
    }
}

// Função para exibir conteúdo no grid
function displayContent(content) {
    const grid = document.getElementById('contentGrid');
    grid.innerHTML = '';
    content.forEach(item => {
        const card = document.createElement('div');
        card.className = 'content-card';
        card.innerHTML = `
            <img src="placeholder.jpg" alt="${item.title}">
            <h3>${item.title}</h3>
            <p>${item.description}</p>
            <div class="price">R$ ${item.price}</div>
            ${currentUser ? `<button class="subscribe-btn" onclick="subscribeToCreator(${item.user_id})">Assinar Criador</button>` : ''}
        `;
        grid.appendChild(card);
    });
}

// Assinar criador
async function subscribeToCreator(creatorId) {
    if (!currentUser) return;

    try {
        const response = await fetch('http://localhost:3000/api/subscriptions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ user_id: currentUser.id, creator_id: creatorId })
        });
        const result = await response.json();
        alert('Assinatura realizada com sucesso!');
        loadUserSubscriptions();
    } catch (error) {
        console.error('Erro ao assinar:', error);
    }
}

// Função para registrar usuário
async function handleRegister(e) {
    e.preventDefault();
    const name = document.getElementById('registerName').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;

    try {
        const response = await fetch('http://localhost:3000/api/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name, email, password })
        });
        const result = await response.json();
        alert('Usuário registrado com sucesso!');
        hideModal();
    } catch (error) {
        console.error('Erro ao registrar usuário:', error);
    }
}

// Função para fazer login
async function handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;

    try {
        const response = await fetch('http://localhost:3000/api/users');
        const users = await response.json();
        const user = users.find(u => u.email === email && u.password === password);

        if (user) {
            currentUser = user;
            localStorage.setItem('currentUser', JSON.stringify(user));
            alert('Login realizado com sucesso!');
            hideModal();
            showProfile();
            hideLoginButtons();
            loadContent(); // Recarregar para mostrar botões de assinar
        } else {
            alert('Email ou senha incorretos.');
        }
    } catch (error) {
        console.error('Erro ao fazer login:', error);
    }
}
