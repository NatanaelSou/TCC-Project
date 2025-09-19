// dashboard.js
// Script para a página do dashboard

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

// Carregar conteúdo quando a página carrega
document.addEventListener('DOMContentLoaded', () => {
    checkAuthSession();
    loadContent();
    setupEventListeners();
    setupFilters();
    loadUserSubscriptions();
});

// Verificar sessão de autenticação
function checkAuthSession() {
    const user = localStorage.getItem('currentUser');
    if (user) {
        currentUser = JSON.parse(user);
        updateUserProfile();
    } else {
        window.location.href = 'landing.html';
    }
}

// Atualizar perfil do usuário na sidebar
function updateUserProfile() {
    if (currentUser) {
        const userName = document.querySelector('.user-name');
        const userAvatar = document.querySelector('.user-avatar');
        if (userName) userName.textContent = currentUser.name;
        if (userAvatar) userAvatar.textContent = currentUser.name.charAt(0).toUpperCase();
    }
}

// Configurar event listeners para botões e formulários
function setupEventListeners() {
    // Logout via menu do usuário
    const userMenuBtn = document.querySelector('.user-menu-btn');
    if (userMenuBtn) {
        userMenuBtn.addEventListener('click', () => {
            const choice = prompt('Escolha uma opção:\n1. Ver perfil\n2. Logout\n3. Configurações');
            if (choice === '2') {
                logout();
            } else if (choice === '1') {
                alert('Perfil: Em desenvolvimento.');
            } else if (choice === '3') {
                alert('Configurações: Em desenvolvimento.');
            }
        });
    }

    // Botões de scroll para seções de criadores
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
            alert('Funcionalidade de assinatura em desenvolvimento.');
        });
    }

    // Navegação da sidebar
    document.querySelectorAll('.sidebar-nav ul li').forEach(item => {
        item.addEventListener('click', () => switchScreen(item));
    });
}

// Logout
function logout() {
    localStorage.removeItem('currentUser');
    currentUser = null;
    window.location.href = 'landing.html';
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

        const matchesSearch = name.includes(searchTerm) || description.includes(searchTerm);
        const matchesTags = filterTags.includes('tudo') || filterTags.some(tag => description.includes(tag) || name.includes(tag));

        if (matchesSearch && matchesTags) {
            card.style.display = 'flex';
        } else {
            card.style.display = 'none';
        }
    });
}

// Alternar filtro de tags
function toggleFilterTag(tag) {
    tag.classList.add('clicked');
    setTimeout(() => {
        tag.classList.remove('clicked');
    }, 150);

    if (tag.classList.contains('active')) {
        tag.classList.remove('active');
    } else {
        if (tag.textContent.trim().toLowerCase() === 'tudo') {
            document.querySelectorAll('.filter-tags .tag').forEach(t => t.classList.remove('active'));
            tag.classList.add('active');
        } else {
            const tudoTag = Array.from(document.querySelectorAll('.filter-tags .tag')).find(t => t.textContent.trim().toLowerCase() === 'tudo');
            if (tudoTag) tudoTag.classList.remove('active');
            tag.classList.add('active');
        }
    }
    filterCreators();
}

// Carregar assinaturas do usuário
async function loadUserSubscriptions() {
    try {
        const response = await fetch('http://localhost:3000/api/subscriptions');
        const subscriptions = await response.json();
        const userSubs = subscriptions.filter(sub => sub.user_id === currentUser.id);
        communityState.userSubscriptions = userSubs;
    } catch (error) {
        console.error('Erro ao carregar assinaturas:', error);
    }
}

// Função para alternar entre telas da sidebar
function switchScreen(item) {
    document.querySelectorAll('.sidebar-nav ul li').forEach(li => li.classList.remove('active'));
    item.classList.add('active');
    const screenName = item.querySelector('.label').textContent.trim();
    updateMainContent(screenName);
}

// Função para atualizar o conteúdo principal baseado na tela selecionada
function updateMainContent(screenName) {
    const mainContent = document.querySelector('.main-content');
    let content = '';

    if (screenName === 'Comunidade') {
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
                    <div class="creator-cards scroll-container" id="topCreators"></div>
                </section>
                <section class="creator-section">
                    <h2>Em alta esta semana <button class="scroll-left" aria-label="Scroll left">‹</button><button class="scroll-right" aria-label="Scroll right">›</button></h2>
                    <div class="creator-cards scroll-container" id="trendingCreators"></div>
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
                <div class="creator-cards scroll-container" id="exploreCreators"></div>
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
                    <label>Nome: <input type="text" value="${currentUser ? currentUser.name : ''}" /></label><br>
                    <label>Email: <input type="email" value="${currentUser ? currentUser.email : ''}" /></label><br>
                    <button class="btn">Salvar</button>
                </form>
            `;
            break;
        default:
            content = '<h1>Página não encontrada</h1>';
    }
    mainContent.innerHTML = content;

    // Reconfigura event listeners
    if (screenName === 'Página inicial') {
        setupHomeEventListeners();
    } else if (screenName === 'Explorar') {
        setupExploreEventListeners();
    } else if (screenName === 'Comunidade') {
        setupCommunityEventListeners();
        renderUserList();
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
    document.querySelectorAll('.scroll-left').forEach(button => {
        button.addEventListener('click', () => scrollCreators(button, -300));
    });
    document.querySelectorAll('.scroll-right').forEach(button => {
        button.addEventListener('click', () => scrollCreators(button, 300));
    });
    document.querySelectorAll('.filter-tags .tag').forEach(tag => {
        tag.addEventListener('click', () => toggleFilterTag(tag));
    });
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
function loadCommunityData() {
    communityState.channels = [
        { id: 1, name: 'Geral', creatorId: 1, requiredTier: 'free', messages: [{ user: 'João', text: 'Olá a todos!', timestamp: new Date() }] },
        { id: 2, name: 'VIP', creatorId: 1, requiredTier: 'premium', messages: [{ user: 'Maria', text: 'Conteúdo exclusivo!', timestamp: new Date() }] },
        { id: 3, name: 'Arte Digital', creatorId: 2, requiredTier: 'basic', messages: [] }
    ];
    communityState.dms = [
        { id: 101, participants: [1, 2], messages: [{ user: 'João', text: 'Oi!', timestamp: new Date() }] },
        { id: 102, participants: [1, 3], messages: [] }
    ];
}

function checkChannelAccess(channel) {
    if (!currentUser) return false;
    if (channel.requiredTier === 'free') return true;
    const hasSubscription = communityState.userSubscriptions.some(sub => sub.creator_id === channel.creatorId && sub.tier === channel.requiredTier);
    return hasSubscription;
}

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

function createDMItem(dm) {
    const item = document.createElement('div');
    item.className = 'dm-item';
    item.textContent = `DM com ${dm.participants.filter(id => id !== currentUser.id).join(', ')}`;
    item.dataset.dmId = dm.id;
    item.addEventListener('click', () => switchToChat(dm.id, 'dm'));
    return item;
}

function renderChannelList() {
    const container = document.getElementById('channelList');
    if (!container) return;
    container.innerHTML = '<h3>Canais</h3>';
    communityState.channels.forEach(channel => {
        container.appendChild(createChannelItem(channel));
    });
}

function renderDMList() {
    const container = document.getElementById('dmList');
    if (!container) return;
    container.innerHTML = '<h3>DMs</h3>';
    communityState.dms.forEach(dm => {
        container.appendChild(createDMItem(dm));
    });
}

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
        const msgDiv = document.createElement('div');
        msgDiv.className = 'chat-message';
        msgDiv.innerHTML = `<strong>${msg.user}:</strong> ${msg.text} <small>${msg.timestamp.toLocaleTimeString()}</small>`;
        messagesDiv.appendChild(msgDiv);
    });
    container.appendChild(messagesDiv);
}

function switchToChat(chatId, type) {
    communityState.currentChat = { id: chatId, type };
    renderChatWindow(chatId, type);
}

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

function renderUserList() {
    const container = document.getElementById('userList');
    if (!container) return;

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

// Configurar filtros (simplificado para dashboard)
function setupFilters() {
    // Filtros já configurados nos event listeners
}
