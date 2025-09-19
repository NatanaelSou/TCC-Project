// @ts-nocheck
// Variáveis globais
let currentUser = null;
let currentPage = 1;
let currentFilters = {
    search: '',
    category: '',
    creator: '',
    sortBy: 'newest'
};
let totalPages = 1;

// Estado da comunidade
let communityState = {
    channels: [],
    dms: [],
    currentChat: null,
    userSubscriptions: []
};

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

    // Botões de navegação da sidebar
    document.querySelectorAll('.sidebar-nav ul li').forEach(item => {
        item.addEventListener('click', () => switchScreen(item));
    });
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
        communityState.userSubscriptions = userSubs; // Atualizar estado da comunidade
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

// Exibir conteúdo filtrado
function displayContent(content) {
    const contentGrid = document.getElementById('contentGrid');
    if (!contentGrid) return;
    contentGrid.innerHTML = '';
    content.forEach(item => {
        const card = createCreatorCard(item);
        contentGrid.appendChild(card);
    });
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

// Função para alternar entre telas da sidebar
function switchScreen(item) {
    // Remove a classe active de todos os itens de navegação
    document.querySelectorAll('.sidebar-nav ul li').forEach(li => li.classList.remove('active'));
    // Adiciona a classe active ao item clicado
    item.classList.add('active');
    // Obtém o nome da tela
    const screenName = item.querySelector('.label').textContent.trim();
    // Atualiza o conteúdo principal baseado na tela
    updateMainContent(screenName);
}

// Função para atualizar o conteúdo principal baseado na tela selecionada
function updateMainContent(screenName) {
    const mainContent = document.querySelector('.main-content');
    let content = '';

    if (screenName === 'Comunidade') {
        // Se usuário não está logado ou não tem assinaturas, redireciona para Explorar
        if (!currentUser || !communityState.userSubscriptions || communityState.userSubscriptions.length === 0) {
            alert('Você não está inscrito em nenhuma comunidade. Redirecionando para Explorar.');
            screenName = 'Explorar';
        }
    }

    switch (screenName) {
        case 'Página inicial':
            content = `
                <div class="top-bar">
                    <input type="search" placeholder="Buscar criadores ou tópicos" class="search-input" />
                </div>
                <div class="filter-tags">
                    <button class="tag active">Tudo</button>
                    <button class="tag">Cultura pop</button>
                    <button class="tag">Comédia</button>
                    <button class="tag">Jogos de RPG</button>
                    <button class="tag">Crimes reais</button>
                    <button class="tag">Tutoriais de arte</button>
                    <button class="tag">Artesanato</button>
                    <button class="tag">Ilustração</button>
                    <button class="tag">Música</button>
                </div>
                <section class="creator-section">
                    <h2>Principais criadores <button class="scroll-left" aria-label="Scroll left">‹</button><button class="scroll-right" aria-label="Scroll right">›</button></h2>
                    <div class="creator-cards scroll-container" id="topCreators">
                    </div>
                </section>
                <section class="creator-section">
                    <h2>Em alta esta semana <button class="scroll-left" aria-label="Scroll left">‹</button><button class="scroll-right" aria-label="Scroll right">›</button></h2>
                    <div class="creator-cards scroll-container" id="trendingCreators">
                    </div>
                </section>
            `;
            break;
        case 'Explorar':
            content = `
                <h1>Explorar</h1>
                <p>Descubra novos criadores e conteúdos.</p>
                <div class="top-bar">
                    <input type="search" placeholder="Buscar..." class="search-input" />
                </div>
                <div class="creator-cards scroll-container" id="exploreCreators">
                </div>
            `;
            break;
        case 'Comunidade':
            content = `
                <h1>Comunidade</h1>
                <div class="community-layout" style="display:flex; height: 100%;">

                    <div class="sidebar-community" style="width: 250px; background-color: #2f3136; color: white; display: flex; flex-direction: column; padding: 10px;">

                        <div id="channelList" style="flex: 1; overflow-y: auto; margin-bottom: 10px;"></div>
                        <div id="dmList" style="flex: 1; overflow-y: auto;"></div>

                    </div>

                    <div class="main-chat" style="flex: 1; background-color: #36393f; color: white; display: flex; flex-direction: column;">

                        <div id="chatWindow" style="flex: 1; overflow-y: auto; padding: 10px;">
                            <p>Selecione um canal ou DM para começar a conversar.</p>
                        </div>

                        <div id="chatInputContainer" style="padding: 10px; background-color: #40444b;">
                            <input type="text" id="messageInput" placeholder="Digite sua mensagem..." style="width: 80%; padding: 5px; border-radius: 3px; border: none;" />
                            <button id="sendMessageBtn" class="btn" style="width: 18%; margin-left: 2%;">Enviar</button>
                        </div>

                    </div>

                    <div class="sidebar-users" style="width: 200px; background-color: #2f3136; color: white; display: flex; flex-direction: column; padding: 10px;">

                        <h3>Usuários</h3>
                        <div id="userList" style="flex: 1; overflow-y: auto;"></div>

                    </div>

                </div>
            `;
            break;
        case 'Notificações':
            content = `
                <h1>Notificações</h1>
                <ul>
                    <li>Novo seguidor: João</li>
                    <li>Novo conteúdo de Maria</li>
                    <li>Lembrete: Assinatura expira em 3 dias</li>
                </ul>
            `;
            break;
        case 'Configurações':
            content = `
                <h1>Configurações</h1>
                <form>
                    <label>Nome: <input type="text" /></label><br>
                    <label>Email: <input type="email" /></label><br>
                    <button class="btn">Salvar</button>
                </form>
            `;
            break;
        default:
            content = '<h1>Página não encontrada</h1>';
    }
    mainContent.innerHTML = content;
    // Reconfigura os event listeners para os novos elementos
    if (screenName === 'Página inicial') {
        setupHomeEventListeners();
    } else if (screenName === 'Explorar') {
        setupExploreEventListeners();
    } else if (screenName === 'Comunidade') {
        setupCommunityEventListeners();
        renderUserList(); // Renderiza a lista de usuários na sidebar direita
    }
    // Carrega conteúdo se necessário
    if (screenName === 'Página inicial') {
        loadContent();
    } else if (screenName === 'Explorar') {
        loadExploreContent();
    } else if (screenName === 'Comunidade') {
        loadCommunityData();
        renderChannelList();
        renderDMList();
    }
}

// Configura event listeners para a tela inicial
function setupHomeEventListeners() {
    // Botões de scroll
    document.querySelectorAll('.scroll-left').forEach(button => {
        button.addEventListener('click', () => scrollCreators(button, -300));
    });
    document.querySelectorAll('.scroll-right').forEach(button => {
        button.addEventListener('click', () => scrollCreators(button, 300));
    });
    // Tags de filtro
    document.querySelectorAll('.filter-tags .tag').forEach(tag => {
        tag.addEventListener('click', () => toggleFilterTag(tag));
    });
    // Input de busca
    const searchInput = document.querySelector('.search-input');
    if (searchInput) {
        searchInput.addEventListener('input', () => filterCreators());
    }
}

// Configura event listeners para a tela de explorar
function setupExploreEventListeners() {
    const searchInput = document.querySelector('.search-input');
    if (searchInput) {
        searchInput.addEventListener('input', () => filterExploreCreators());
    }
}

// Configura event listeners para a tela de comunidade
function setupCommunityEventListeners() {
    // Event listeners já são configurados ao criar os itens de canal e DM
    // Adicionar listeners adicionais se necessário

    // Event listener para enviar mensagem no chat
    const sendBtn = document.getElementById('sendMessageBtn');
    const messageInput = document.getElementById('messageInput');
    if (sendBtn) {
        sendBtn.addEventListener('click', () => {
            if (communityState.currentChat) {
                sendMessage(communityState.currentChat.id, communityState.currentChat.type);
            }
        });
    }
    if (messageInput) {
        messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && communityState.currentChat) {
                sendMessage(communityState.currentChat.id, communityState.currentChat.type);
            }
        });
    }
}

// Renderizar lista de usuários na sidebar direita
function renderUserList() {
    const container = document.getElementById('userList');
    if (!container) return;

    // Mock de usuários online/offline para demonstração
    const users = [
        { id: 1, name: 'João', online: true },
        { id: 2, name: 'Maria', online: true },
        { id: 3, name: 'Carlos', online: false },
        { id: 4, name: 'Ana', online: true },
        { id: 5, name: 'Pedro', online: false }
    ];

    container.innerHTML = '';
    users.forEach(user => {
        const userDiv = document.createElement('div');
        userDiv.className = 'user-item';
        userDiv.style.display = 'flex';
        userDiv.style.alignItems = 'center';
        userDiv.style.marginBottom = '8px';

        const statusDot = document.createElement('span');
        statusDot.style.width = '10px';
        statusDot.style.height = '10px';
        statusDot.style.borderRadius = '50%';
        statusDot.style.marginRight = '8px';
        statusDot.style.backgroundColor = user.online ? '#43b581' : '#747f8d';

        const nameSpan = document.createElement('span');
        nameSpan.textContent = user.name;

        userDiv.appendChild(statusDot);
        userDiv.appendChild(nameSpan);

        container.appendChild(userDiv);
    });
}

// Carrega conteúdo para a tela de explorar
function loadExploreContent() {
    fetch('http://localhost:3000/api/content')
        .then(response => response.json())
        .then(content => {
            const container = document.getElementById('exploreCreators');
            if (container) {
                container.innerHTML = '';
                content.forEach(creator => {
                    const card = createCreatorCard(creator);
                    container.appendChild(card);
                });
            }
        })
        .catch(error => console.error('Erro ao carregar exploradores:', error));
}

// Filtra criadores na tela de explorar
function filterExploreCreators() {
    const searchInput = document.querySelector('.search-input');
    const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
    const allCards = document.querySelectorAll('#exploreCreators .creator-card');
    allCards.forEach(card => {
        const name = card.querySelector('.creator-name')?.textContent.toLowerCase() || '';
        const description = card.querySelector('.creator-description')?.textContent.toLowerCase() || '';
        if (name.includes(searchTerm) || description.includes(searchTerm)) {
            card.style.display = 'flex';
        } else {
            card.style.display = 'none';
        }
    });
}

// Funções para a comunidade

// Carregar dados da comunidade (mock para front-end)
function loadCommunityData() {
    // Mock channels
    communityState.channels = [
        { id: 1, name: 'Geral', creatorId: 1, requiredTier: 'free', messages: [{ user: 'João', text: 'Olá a todos!', timestamp: new Date() }] },
        { id: 2, name: 'VIP', creatorId: 1, requiredTier: 'premium', messages: [{ user: 'Maria', text: 'Conteúdo exclusivo!', timestamp: new Date() }] },
        { id: 3, name: 'Arte Digital', creatorId: 2, requiredTier: 'basic', messages: [] }
    ];
    // Mock DMs
    communityState.dms = [
        { id: 101, participants: [1, 2], messages: [{ user: 'João', text: 'Oi!', timestamp: new Date() }] },
        { id: 102, participants: [1, 3], messages: [] }
    ];
}

// Verificar acesso ao canal baseado em assinaturas
function checkChannelAccess(channel) {
    if (!currentUser) return false;
    if (channel.requiredTier === 'free') return true;
    const hasSubscription = communityState.userSubscriptions.some(sub => sub.creator_id === channel.creatorId && sub.tier === channel.requiredTier);
    return hasSubscription;
}

// Criar item de canal
function createChannelItem(channel) {
    const item = document.createElement('div');
    item.className = 'channel-item';
    item.textContent = `#${channel.name}`;
    item.dataset.channelId = channel.id;
    if (!checkChannelAccess(channel)) {
        item.classList.add('locked');
        item.textContent += ' 🔒';
    }
    item.addEventListener('click', () => switchToChat(channel.id, 'channel'));
    return item;
}

// Criar item de DM
function createDMItem(dm) {
    const item = document.createElement('div');
    item.className = 'dm-item';
    item.textContent = `DM com ${dm.participants.filter(id => id !== currentUser.id).join(', ')}`;
    item.dataset.dmId = dm.id;
    item.addEventListener('click', () => switchToChat(dm.id, 'dm'));
    return item;
}

// Criar mensagem de chat
function createChatMessage(message) {
    const msgDiv = document.createElement('div');
    msgDiv.className = 'chat-message';
    msgDiv.innerHTML = `<strong>${message.user}:</strong> ${message.text} <small>${message.timestamp.toLocaleTimeString()}</small>`;
    return msgDiv;
}

// Renderizar lista de canais
function renderChannelList() {
    const container = document.getElementById('channelList');
    if (!container) return;
    container.innerHTML = '<h3>Canais</h3>';
    communityState.channels.forEach(channel => {
        container.appendChild(createChannelItem(channel));
    });
}

// Renderizar lista de DMs
function renderDMList() {
    const container = document.getElementById('dmList');
    if (!container) return;
    container.innerHTML = '<h3>DMs</h3>';
    communityState.dms.forEach(dm => {
        container.appendChild(createDMItem(dm));
    });
}

// Renderizar janela de chat
function renderChatWindow(chatId, type) {
    const container = document.getElementById('chatWindow');
    if (!container) return;
    container.innerHTML = '';

    let chatData;
    if (type === 'channel') {
        chatData = communityState.channels.find(c => c.id === chatId);
    } else {
        chatData = communityState.dms.find(d => d.id === chatId);
    }

    if (!chatData) return;

    if (type === 'channel' && !checkChannelAccess(chatData)) {
        container.innerHTML = '<p>Acesso negado. Assine o tier necessário.</p>';
        return;
    }

    const title = document.createElement('h3');
    title.textContent = type === 'channel' ? `#${chatData.name}` : `DM com ${chatData.participants.filter(id => id !== currentUser.id).join(', ')}`;
    container.appendChild(title);

    const messagesDiv = document.createElement('div');
    messagesDiv.className = 'chat-messages';
    chatData.messages.forEach(msg => {
        messagesDiv.appendChild(createChatMessage(msg));
    });
    container.appendChild(messagesDiv);

    const inputDiv = document.createElement('div');
    inputDiv.className = 'chat-input';
    inputDiv.innerHTML = `
        <input type="text" id="messageInput" placeholder="Digite sua mensagem..." />
        <button id="sendMessageBtn" class="btn">Enviar</button>
    `;
    container.appendChild(inputDiv);

    // Event listener para enviar mensagem
    document.getElementById('sendMessageBtn').addEventListener('click', () => sendMessage(chatId, type));
    document.getElementById('messageInput').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendMessage(chatId, type);
    });
}

// Trocar para chat
function switchToChat(chatId, type) {
    communityState.currentChat = { id: chatId, type };
    renderChatWindow(chatId, type);
}

// Enviar mensagem (mock)
function sendMessage(chatId, type) {
    const input = document.getElementById('messageInput');
    if (!input || !input.value.trim()) return;

    const message = {
        user: currentUser.name,
        text: input.value.trim(),
        timestamp: new Date()
    };

    if (type === 'channel') {
        const channel = communityState.channels.find(c => c.id === chatId);
        if (channel) channel.messages.push(message);
    } else {
        const dm = communityState.dms.find(d => d.id === chatId);
        if (dm) dm.messages.push(message);
    }

    input.value = '';
    renderChatWindow(chatId, type);
}
