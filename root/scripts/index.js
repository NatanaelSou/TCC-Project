// @ts-nocheck
// Variáveis globais
let currentUser = null;
let currentUser = null;
let currentPage = 1;
let currentFilters = {
    search: '',
    category: '',
    creator: '',
    sortBy: 'newest'
};
let totalPages = 1;

(function() {
// Carregar conteúdo quando a página carrega
document.addEventListener('DOMContentLoaded', () => {
    loadContent();
    setupEventListeners();
    setupFilters();
    checkLoginStatus();
});
})();

// Configurar event listeners para botões e formulários
function setupEventListeners() {
    // Botões de login e registro
    document.getElementById('loginBtn')?.addEventListener('click', () => showModal('login'));
    document.getElementById('registerBtn')?.addEventListener('click', () => showModal('register'));

    // Fechar modal
    document.querySelector('.close')?.addEventListener('click', hideModal);
    window.addEventListener('click', (e) => {
        if (e.target === document.getElementById('authModal')) hideModal();
    });

    // Alternar entre login e registro
    document.getElementById('switchToRegister')?.addEventListener('click', () => switchForm('register'));
    document.getElementById('switchToLogin')?.addEventListener('click', () => switchForm('login'));

    // Formulários
    document.getElementById('loginFormEl')?.addEventListener('submit', handleLogin);
    document.getElementById('registerFormEl')?.addEventListener('submit', handleRegister);

    // Logout
    document.getElementById('logoutBtn')?.addEventListener('click', logout);

    // Scroll buttons for creator sections
    document.querySelectorAll('.scroll-left').forEach(button => {
        button.addEventListener('click', () => scrollCreators(button, -300));
    });
    document.querySelectorAll('.scroll-right').forEach(button => {
        button.addEventListener('click', () => scrollCreators(button, 300));
    });

    // Filter tags click
    document.querySelectorAll('.filter-tags .tag').forEach(tag => {
        tag.addEventListener('click', () => toggleFilterTag(tag));
    });

    // Search input
    const searchInput = document.querySelector('.search-input');
    if (searchInput) {
        searchInput.addEventListener('input', () => filterCreators());
    }

    // Botão de fechar prompt do criador
    const closePromptBtn = document.querySelector('.close-prompt');
    if (closePromptBtn) {
        closePromptBtn.addEventListener('click', () => {
            const prompt = document.querySelector('.sidebar-creator-prompt');
            if (prompt) prompt.style.display = 'none';
        });
    }

    // Botão de assinar (Comece agora mesmo)
    const subscribeBtn = document.querySelector('.subscribe-btn');
    if (subscribeBtn) {
        subscribeBtn.addEventListener('click', () => {
            showModal('register'); // Mostra o modal de registro para iniciar o processo de assinatura
        });
    }

    // Botão de menu do usuário
    const userMenuBtn = document.querySelector('.user-menu-btn');
    if (userMenuBtn) {
        userMenuBtn.addEventListener('click', () => {
            // Exibe opções simples de menu do usuário
            const options = '1. Ver perfil\n2. Logout\n3. Configurações';
            const choice = prompt('Escolha uma opção:\n' + options);
            if (choice === '1') {
                alert('Perfil: Em desenvolvimento.');
            } else if (choice === '2') {
                logout();
            } else if (choice === '3') {
                // Navegar para a página de configurações
                window.location.href = 'settings.html';
            }
        });
    }
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
    const loginBtn = document.getElementById('loginBtn');
    const registerBtn = document.getElementById('registerBtn');
    if (loginBtn) loginBtn.style.display = 'none';
    if (registerBtn) registerBtn.style.display = 'none';
}

// Mostrar perfil
function showProfile() {
    const profileSection = document.getElementById('profile');
    const userProfile = document.getElementById('userProfile');

    if (profileSection && userProfile) {
        profileSection.classList.remove('hidden');
        userProfile.innerHTML = `
            <p><strong>Nome:</strong> ${currentUser.name}</p>
            <p><strong>Email:</strong> ${currentUser.email}</p>
            <h3>Minhas Assinaturas</h3>
            <div id="userSubscriptions"></div>
        `;
        loadUserSubscriptions();
    }
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
    if (!subsDiv) return;
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
    const profileSection = document.getElementById('profile');
    if (profileSection) profileSection.classList.add('hidden');
    const loginBtn = document.getElementById('loginBtn');
    const registerBtn = document.getElementById('registerBtn');
    if (loginBtn) loginBtn.style.display = 'inline-block';
    if (registerBtn) registerBtn.style.display = 'inline-block';
    location.reload();
}

// Função para carregar conteúdo da API
async function loadContent() {
    try {
        const response = await fetch('http://localhost:3000/api/content');
        const content = await response.json();
        displayCreators(content);
    } catch (error) {
        console.error('Erro ao carregar conteúdo:', error);
    }
}

// Exibir criadores nas seções
function displayCreators(content) {
    const topCreatorsContainer = document.getElementById('topCreators');
    const trendingCreatorsContainer = document.getElementById('trendingCreators');
    if (!topCreatorsContainer || !trendingCreatorsContainer) return;

    // Limpar containers
    topCreatorsContainer.innerHTML = '';
    trendingCreatorsContainer.innerHTML = '';

    // Filtrar e distribuir criadores (exemplo simples)
    const topCreators = content.slice(0, 5);
    const trendingCreators = content.slice(5, 10);

    topCreators.forEach(creator => {
        const card = createCreatorCard(creator);
        topCreatorsContainer.appendChild(card);
    });

    trendingCreators.forEach(creator => {
        const card = createCreatorCard(creator);
        trendingCreatorsContainer.appendChild(card);
    });
}

// Criar card de criador
function createCreatorCard(creator) {
    const card = document.createElement('div');
    card.className = 'creator-card';
    card.innerHTML = `
        <img src="${creator.image || 'placeholder.jpg'}" alt="${creator.name}" />
        <div class="creator-name">${creator.name}</div>
        <div class="creator-description">${creator.description || ''}</div>
    `;
    return card;
}

// Scroll horizontal para as seções de criadores
function scrollCreators(button, distance) {
    const section = button.closest('.creator-section');
    if (!section) return;
    const container = section.querySelector('.scroll-container');
    if (!container) return;
    container.scrollBy({ left: distance, behavior: 'smooth' });
}

// Filtrar criadores por tags e busca
function filterCreators() {
    const searchInput = document.querySelector('.search-input');
    const filterTags = Array.from(document.querySelectorAll('.filter-tags .tag.active')).map(t => t.textContent.trim().toLowerCase());
    const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';

    const allCards = document.querySelectorAll('.creator-card');
    allCards.forEach(card => {
        const name = card.querySelector('.creator-name')?.textContent.toLowerCase() || '';
        const description = card.querySelector('.creator-description')?.textContent.toLowerCase() || '';

        // Check if card matches search term and filter tags
        const matchesSearch = name.includes(searchTerm) || description.includes(searchTerm);
        const matchesTags = filterTags.includes('tudo') || filterTags.some(tag => description.includes(tag) || name.includes(tag));

        if (matchesSearch && matchesTags) {
            card.style.display = 'flex';
        } else {
            card.style.display = 'none';
        }
    });
}

// Alternar filtro de tags com animação de clique
function toggleFilterTag(tag) {
    // Adicionar animação de clique (escala reduzida)
    tag.classList.add('clicked');
    setTimeout(() => {
        tag.classList.remove('clicked');
    }, 150); // Remover a classe após 150ms para a animação

    // Lógica de alternância do filtro
    if (tag.classList.contains('active')) {
        tag.classList.remove('active');
    } else {
        // Se "Tudo" for clicado, desativa outras tags
        if (tag.textContent.trim().toLowerCase() === 'tudo') {
            document.querySelectorAll('.filter-tags .tag').forEach(t => t.classList.remove('active'));
            tag.classList.add('active');
        } else {
            // Desativa "Tudo" se outra tag for ativada
            const tudoTag = Array.from(document.querySelectorAll('.filter-tags .tag')).find(t => t.textContent.trim().toLowerCase() === 'tudo');
            if (tudoTag) tudoTag.classList.remove('active');
            tag.classList.add('active');
        }
    }
    filterCreators();
}

// Função para registrar usuário
async function handleRegister(e) {
    e.preventDefault(); // eslint-disable-line
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

async function handleLogin(e) {
    e.preventDefault(); // eslint-disable-line
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

// Configurar filtros e paginação
function setupFilters() {
    // Criar elementos de filtro
    const contentSection = document.getElementById('content');
    const filterSection = document.createElement('div');
    filterSection.id = 'contentFilters';
    filterSection.className = 'content-filters';
    filterSection.innerHTML = `
        <div class="filter-row">
            <input type="text" id="searchInput" placeholder="Buscar conteúdo..." class="search-input">
            <select id="sortSelect" class="sort-select">
                <option value="newest">Mais recentes</option>
                <option value="oldest">Mais antigos</option>
                <option value="popular">Mais populares</option>
                <option value="price_low">Preço: menor para maior</option>
                <option value="price_high">Preço: maior para menor</option>
            </select>
            <button id="filterBtn" class="btn filter-btn">Filtrar</button>
            <button id="clearFiltersBtn" class="btn clear-btn">Limpar</button>
        </div>
        <div id="pagination" class="pagination"></div>
    `;

    contentSection.insertBefore(filterSection, document.getElementById('contentGrid'));

    // Event listeners para filtros
    document.getElementById('searchInput').addEventListener('input', debounce(applyFilters, 500));
    document.getElementById('sortSelect').addEventListener('change', applyFilters);
    document.getElementById('filterBtn').addEventListener('click', applyFilters);
    document.getElementById('clearFiltersBtn').addEventListener('click', clearFilters);
}

// Aplicar filtros
function applyFilters() {
    currentFilters.search = document.getElementById('searchInput').value;
    currentFilters.sortBy = document.getElementById('sortSelect').value;
    currentPage = 1; // Reset para primeira página
    loadContentWithFilters();
}

// Limpar filtros
function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('sortSelect').value = 'newest';
    currentFilters = {
        search: '',
        category: '',
        creator: '',
        sortBy: 'newest'
    };
    currentPage = 1;
    loadContentWithFilters();
}

// Carregar conteúdo com filtros e paginação
async function loadContentWithFilters() {
    try {
        const params = new URLSearchParams({
            page: currentPage,
            limit: 12, // 12 itens por página
            search: currentFilters.search,
            sortBy: currentFilters.sortBy
        });

        const response = await fetch(`http://localhost:3000/api/content/filtered?${params}`);
        const data = await response.json();

        displayContent(data.content || data);
        setupPagination(data.totalPages || 1, data.currentPage || 1);
        totalPages = data.totalPages || 1;
    } catch (error) {
        console.error('Erro ao carregar conteúdo filtrado:', error);
        // Fallback para carregamento sem filtros
        loadContent();
    }
}

// Configurar paginação
function setupPagination(totalPages, currentPage) {
    const paginationDiv = document.getElementById('pagination');
    paginationDiv.innerHTML = '';

    if (totalPages <= 1) return;

    // Botão anterior
    if (currentPage > 1) {
        const prevBtn = document.createElement('button');
        prevBtn.textContent = '← Anterior';
        prevBtn.className = 'btn pagination-btn';
        prevBtn.onclick = () => changePage(currentPage - 1);
        paginationDiv.appendChild(prevBtn);
    }

    // Números das páginas
    const startPage = Math.max(1, currentPage - 2);
    const endPage = Math.min(totalPages, currentPage + 2);

    for (let i = startPage; i <= endPage; i++) {
        const pageBtn = document.createElement('button');
        pageBtn.textContent = i;
        pageBtn.className = `btn pagination-btn ${i === currentPage ? 'active' : ''}`;
        pageBtn.onclick = () => changePage(i);
        paginationDiv.appendChild(pageBtn);
    }

    // Botão próximo
    if (currentPage < totalPages) {
        const nextBtn = document.createElement('button');
        nextBtn.textContent = 'Próximo →';
        nextBtn.className = 'btn pagination-btn';
        nextBtn.onclick = () => changePage(currentPage + 1);
        paginationDiv.appendChild(nextBtn);
    }
}

// Mudar página
function changePage(page) {
    currentPage = page;
    loadContentWithFilters();
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Função debounce para busca
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}
