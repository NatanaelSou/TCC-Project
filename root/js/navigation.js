/**
 * Arquivo JavaScript para controlar a navegação e funcionalidades do site
 * Gerencia as abas, navegação e interações do usuário
 */

// Classe principal para gerenciar a navegação do site
class SiteNavigation {
    constructor() {
        // Inicializar elementos da página
        this.sidebar = document.getElementById('sidebar');
        this.content = document.querySelector('.content');
        this.menuToggle = document.getElementById('menu-toggle');
        this.sidebarLinks = document.querySelectorAll('.sidebar-link');
        this.searchInput = document.querySelector('.search-input');
        this.searchBtn = document.querySelector('.search-btn');
        this.userBtn = document.querySelector('.user-btn');

        // Estado atual da aplicação
        this.currentPage = 'home';
        this.userLoggedIn = false; // Simulação de estado de login
        this.userData = {
            name: 'João Silva',
            username: 'joao_silva',
            avatar: 'https://via.placeholder.com/120x120?text=U',
            followers: 1200,
            videos: 45,
            views: 89000,
            bio: 'Desenvolvedor apaixonado por tecnologia e programação. Compartilhando conhecimento e experiências.'
        };

        // Inicializar eventos
        this.initEvents();

        // Carregar página inicial
        this.loadPage('home');
    }

    // Inicializar todos os event listeners
    initEvents() {
        // Toggle da sidebar em dispositivos móveis
        this.menuToggle.addEventListener('click', () => {
            this.sidebar.classList.toggle('open');
        });

        // Navegação entre abas
        this.sidebarLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const page = link.getAttribute('data-page');
                this.navigateTo(page);
            });
        });

        // Funcionalidade de busca
        this.searchBtn.addEventListener('click', () => {
            this.performSearch();
        });

        this.searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.performSearch();
            }
        });

        // Botão do usuário
        this.userBtn.addEventListener('click', () => {
            this.navigateTo('user');
        });

        // Delegação de eventos para elementos dinâmicos
        this.content.addEventListener('click', (e) => {
            this.handleDynamicEvents(e);
        });
    }

    // Manipular eventos de elementos dinâmicos
    handleDynamicEvents(e) {
        const target = e.target;

        // Botões de filtro na página "Em Alta"
        if (target.classList.contains('filter-btn')) {
            this.handleTrendingFilter(target);
        }

        // Abas do usuário
        if (target.classList.contains('tab-btn')) {
            this.handleUserTab(target);
        }

        // Abas da biblioteca
        if (target.classList.contains('library-tab-btn')) {
            this.handleLibraryTab(target);
        }

        // Botões de seguir criadores
        if (target.classList.contains('follow-btn')) {
            this.handleFollowCreator(target);
        }

        // Cards de conteúdo
        if (target.closest('.content-card')) {
            this.handleContentClick(target.closest('.content-card'));
        }

        // Cards de criador
        if (target.closest('.creator-card')) {
            this.handleCreatorClick(target.closest('.creator-card'));
        }
    }

    // Navegar para uma página específica
    navigateTo(page) {
        // Atualizar estado ativo na sidebar
        this.sidebarLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('data-page') === page) {
                link.classList.add('active');
            }
        });

        // Atualizar página atual
        this.currentPage = page;

        // Carregar conteúdo da página
        this.loadPage(page);

        // Fechar sidebar em dispositivos móveis após navegação
        if (window.innerWidth <= 768) {
            this.sidebar.classList.remove('open');
        }
    }

    // Carregar conteúdo da página
    loadPage(page) {
        let content = '';

        switch(page) {
            case 'home':
                content = this.getHomeContent();
                break;
            case 'trending':
                content = this.getTrendingContent();
                break;
            case 'subscriptions':
                content = this.getSubscriptionsContent();
                break;
            case 'creators':
                content = this.getCreatorsContent();
                break;
            case 'library':
                content = this.getLibraryContent();
                break;
            case 'settings':
                content = this.getSettingsContent();
                break;
            case 'user':
                content = this.getUserContent();
                break;
            default:
                content = this.getHomeContent();
        }

        this.content.innerHTML = content;
    }

    // Manipular filtros da página "Em Alta"
    handleTrendingFilter(button) {
        // Remover classe active de todos os botões
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // Adicionar classe active ao botão clicado
        button.classList.add('active');

        // Aqui seria implementada a lógica para filtrar conteúdo
        const filter = button.getAttribute('data-filter');
        console.log('Aplicando filtro:', filter);
    }

    // Manipular abas do usuário
    handleUserTab(button) {
        // Remover classe active de todas as abas
        document.querySelectorAll('.user-tabs .tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // Adicionar classe active à aba clicada
        button.classList.add('active');

        // Aqui seria implementada a lógica para trocar conteúdo da aba
        const tab = button.getAttribute('data-tab');
        console.log('Trocando para aba:', tab);
    }

    // Manipular abas da biblioteca
    handleLibraryTab(button) {
        // Remover classe active de todas as abas
        document.querySelectorAll('.library-tabs .tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // Adicionar classe active à aba clicada
        button.classList.add('active');

        // Aqui seria implementada a lógica para trocar conteúdo da aba
        const tab = button.getAttribute('data-tab');
        console.log('Trocando para aba da biblioteca:', tab);
    }

    // Manipular seguir criador
    handleFollowCreator(button) {
        const creatorId = button.getAttribute('data-creator-id');
        const isFollowing = button.classList.contains('following');

        if (isFollowing) {
            button.textContent = 'Seguir';
            button.classList.remove('following');
            console.log('Deixou de seguir criador:', creatorId);
        } else {
            button.textContent = 'Seguindo';
            button.classList.add('following');
            console.log('Seguindo criador:', creatorId);
        }
    }

    // Manipular clique em conteúdo
    handleContentClick(card) {
        const contentId = card.getAttribute('data-id');
        console.log('Clicou no conteúdo:', contentId);
        // Aqui seria implementada a navegação para a página do vídeo
        alert(`Abrindo conteúdo ${contentId}`);
    }

    // Manipular clique em criador
    handleCreatorClick(card) {
        const creatorId = card.getAttribute('data-id');
        console.log('Clicou no criador:', creatorId);
        // Aqui seria implementada a navegação para o perfil do criador
        alert(`Abrindo perfil do criador ${creatorId}`);
    }

    // Realizar busca
    performSearch() {
        const query = this.searchInput.value.trim();
        if (query) {
            console.log('Buscando por:', query);
            // Aqui seria implementada a lógica de busca real
            alert(`Buscando por: "${query}"`);
        }
    }

    // Conteúdo da página inicial
    getHomeContent() {
        return `
            <section class="page-header">
                <h1>🏠 Início</h1>
                <p>Descubra os melhores conteúdos da nossa plataforma</p>
            </section>

            <section class="content-grid">
                ${this.generateContentCards([
                    { title: 'Conteúdo Exclusivo Premium', creator: 'Criador 1', views: '1.2K', time: '2 dias atrás', duration: '10:30' },
                    { title: 'Tutorial Avançado React', creator: 'Criador 2', views: '850', time: '5 dias atrás', duration: '15:45' },
                    { title: 'Atualizações da Semana', creator: 'Criador 3', views: '2.5K', time: '1 semana atrás', duration: '8:20' },
                    { title: 'Node.js para Iniciantes', creator: 'Criador 4', views: '3.1K', time: '3 dias atrás', duration: '22:15' },
                    { title: 'CSS Grid Masterclass', creator: 'Criador 5', views: '1.8K', time: '1 dia atrás', duration: '18:30' },
                    { title: 'JavaScript ES6+', creator: 'Criador 6', views: '4.2K', time: '6 dias atrás', duration: '25:45' }
                ])}
            </section>
        `;
    }

    // Conteúdo da página "Em Alta"
    getTrendingContent() {
        return `
            <section class="page-header">
                <h1>🔥 Em Alta</h1>
                <p>Os conteúdos mais populares do momento</p>
            </section>

            <section class="trending-filters">
                <button class="filter-btn active" data-filter="today">Hoje</button>
                <button class="filter-btn" data-filter="week">Esta Semana</button>
                <button class="filter-btn" data-filter="month">Este Mês</button>
                <button class="filter-btn" data-filter="all">Todos os Tempos</button>
            </section>

            <section class="content-grid">
                ${this.generateContentCards([
                    { title: 'Vídeo Viral da Semana', creator: 'Criador Popular', views: '150K', time: '1 dia atrás', duration: '12:30', trending: true },
                    { title: 'Tutorial Mais Visto', creator: 'Tech Guru', views: '89K', time: '2 dias atrás', duration: '18:45', trending: true },
                    { title: 'Conteúdo Explosivo', creator: 'Viral Creator', views: '67K', time: '3 dias atrás', duration: '9:15', trending: true },
                    { title: 'Hit do Mês', creator: 'Top Creator', views: '45K', time: '4 dias atrás', duration: '14:20', trending: true },
                    { title: 'Tendência Atual', creator: 'Trend Setter', views: '32K', time: '5 dias atrás', duration: '11:10', trending: true },
                    { title: 'Vídeo Quente', creator: 'Hot Content', views: '28K', time: '6 dias atrás', duration: '16:55', trending: true }
                ])}
            </section>
        `;
    }

    // Conteúdo da página "Assinaturas"
    getSubscriptionsContent() {
        if (!this.userLoggedIn) {
            return `
                <section class="page-header">
                    <h1>📺 Assinaturas</h1>
                    <p>Faça login para ver seus canais assinados</p>
                </section>

                <section class="login-prompt">
                    <div class="login-card">
                        <h2>Entre na sua conta</h2>
                        <p>Para acessar seus canais assinados e conteúdos exclusivos</p>
                        <a href="pages/login.html" class="btn-primary">Fazer Login</a>
                    </div>
                </section>
            `;
        }

        return `
            <section class="page-header">
                <h1>📺 Assinaturas</h1>
                <p>Conteúdos dos seus criadores favoritos</p>
            </section>

            <section class="subscriptions-grid">
                ${this.generateContentCards([
                    { title: 'Novo vídeo do seu criador favorito', creator: 'Criador Assinado 1', views: '5.2K', time: '2 horas atrás', duration: '13:20' },
                    { title: 'Atualização semanal', creator: 'Criador Assinado 2', views: '3.1K', time: '1 dia atrás', duration: '16:45' },
                    { title: 'Conteúdo exclusivo para assinantes', creator: 'Criador Assinado 3', views: '2.8K', time: '3 dias atrás', duration: '11:30' },
                    { title: 'Live especial', creator: 'Criador Assinado 4', views: '8.9K', time: '5 dias atrás', duration: '2:15:30' }
                ])}
            </section>
        `;
    }

    // Conteúdo da página "Criadores"
    getCreatorsContent() {
        return `
            <section class="page-header">
                <h1>👥 Criadores</h1>
                <p>Descubra novos criadores e conteúdos incríveis</p>
            </section>

            <section class="creators-grid">
                ${this.generateCreatorCards([
                    { name: 'João Silva', channel: 'João Dev', subscribers: '15.4K', description: 'Desenvolvimento web e programação', verified: true },
                    { name: 'Maria Santos', channel: 'Maria Tech', subscribers: '8.7K', description: 'Tecnologia e inovação', verified: true },
                    { name: 'Carlos Games', channel: 'Carlos Games BR', subscribers: '45.2K', description: 'Reviews e gameplay', verified: false },
                    { name: 'Ana Cozinha', channel: 'Ana Receitas', subscribers: '28.9K', description: 'Receitas e culinária', verified: true },
                    { name: 'Pedro Música', channel: 'Pedro Beats', subscribers: '12.3K', description: 'Música e produção', verified: false },
                    { name: 'Lucas Arte', channel: 'Lucas Digital', subscribers: '6.8K', description: 'Arte digital e design', verified: true }
                ])}
            </section>
        `;
    }

    // Conteúdo da página "Biblioteca"
    getLibraryContent() {
        if (!this.userLoggedIn) {
            return `
                <section class="page-header">
                    <h1>📚 Biblioteca</h1>
                    <p>Sua coleção pessoal de conteúdos</p>
                </section>

                <section class="login-prompt">
                    <div class="login-card">
                        <h2>Acesse sua biblioteca</h2>
                        <p>Faça login para ver seus vídeos salvos, histórico e playlists</p>
                        <a href="pages/login.html" class="btn-primary">Fazer Login</a>
                    </div>
                </section>
            `;
        }

        return `
            <section class="page-header">
                <h1>📚 Biblioteca</h1>
                <p>Seus vídeos salvos e histórico de visualização</p>
            </section>

            <section class="library-tabs">
                <button class="tab-btn active" data-tab="history">Histórico</button>
                <button class="tab-btn" data-tab="saved">Salvos</button>
                <button class="tab-btn" data-tab="playlists">Playlists</button>
                <button class="tab-btn" data-tab="downloads">Downloads</button>
            </section>

            <section class="library-content">
                <h3>Histórico de Visualização</h3>
                <div class="content-grid">
                    ${this.generateContentCards([
                        { title: 'Vídeo assistido recentemente 1', creator: 'Criador A', views: '1.2K', time: '2 horas atrás', duration: '10:30' },
                        { title: 'Vídeo assistido recentemente 2', creator: 'Criador B', views: '850', time: '5 horas atrás', duration: '15:45' },
                        { title: 'Vídeo assistido recentemente 3', creator: 'Criador C', views: '2.5K', time: '1 dia atrás', duration: '8:20' }
                    ])}
                </div>
            </section>
        `;
    }

    // Conteúdo da página "Configurações"
    getSettingsContent() {
        return `
            <section class="page-header">
                <h1>⚙️ Configurações</h1>
                <p>Personalize sua experiência na plataforma</p>
            </section>

            <section class="settings-container">
                <div class="settings-section">
                    <h3>Conta</h3>
                    <div class="setting-item">
                        <label>Nome de usuário</label>
                        <input type="text" value="${this.userData.username}" readonly>
                    </div>
                    <div class="setting-item">
                        <label>Email</label>
                        <input type="email" value="usuario@email.com" readonly>
                    </div>
                    <div class="setting-item">
                        <label>Senha</label>
                        <button class="btn-secondary">Alterar Senha</button>
                    </div>
                </div>

                <div class="settings-section">
                    <h3>Preferências</h3>
                    <div class="setting-item">
                        <label>Idioma</label>
                        <select>
                            <option value="pt-BR" selected>Português (Brasil)</option>
                            <option value="en-US">English</option>
                            <option value="es-ES">Español</option>
                        </select>
                    </div>
                    <div class="setting-item">
                        <label>Qualidade padrão</label>
                        <select>
                            <option value="auto">Automática</option>
                            <option value="1080p" selected>1080p</option>
                            <option value="720p">720p</option>
                            <option value="480p">480p</option>
                        </select>
                    </div>
                    <div class="setting-item">
                        <label>Notificações</label>
                        <input type="checkbox" checked>
                    </div>
                </div>

                <div class="settings-section">
                    <h3>Privacidade</h3>
                    <div class="setting-item">
                        <label>Perfil público</label>
                        <input type="checkbox" checked>
                    </div>
                    <div class="setting-item">
                        <label>Histórico de visualização</label>
                        <input type="checkbox">
                    </div>
                </div>

                <div class="settings-actions">
                    <button class="btn-primary">Salvar Alterações</button>
                    <button class="btn-danger">Excluir Conta</button>
                </div>
            </section>
        `;
    }

    // Conteúdo da página "Usuário"
    getUserContent() {
        if (!this.userLoggedIn) {
            return `
                <section class="page-header">
                    <h1>👤 Usuário</h1>
                    <p>Gerencie seu perfil e conta</p>
                </section>

                <section class="login-prompt">
                    <div class="login-card">
                        <h2>Área do Usuário</h2>
                        <p>Faça login para acessar seu perfil, editar informações e gerenciar sua conta</p>
                        <a href="pages/login.html" class="btn-primary">Fazer Login</a>
                    </div>
                </section>
            `;
        }

        return `
            <section class="user-profile">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <img src="${this.userData.avatar}" alt="Avatar">
                    </div>
                    <div class="profile-info">
                        <h1>${this.userData.name}</h1>
                        <p>@${this.userData.username}</p>
                        <div class="profile-stats">
                            <span>${this.userData.followers.toLocaleString()} seguidores</span>
                            <span>${this.userData.videos} vídeos</span>
                            <span>${this.userData.views.toLocaleString()} visualizações</span>
                        </div>
                        <p class="profile-bio">${this.userData.bio}</p>
                    </div>
                    <div class="profile-actions">
                        <button class="btn-primary">Editar Perfil</button>
                        <button class="btn-secondary">Compartilhar</button>
                    </div>
                </div>

                <section class="user-tabs">
                    <button class="tab-btn active" data-tab="videos">Vídeos</button>
                    <button class="tab-btn" data-tab="about">Sobre</button>
                    <button class="tab-btn" data-tab="stats">Estatísticas</button>
                </section>

                <section class="user-videos">
                    <div class="content-grid">
                        ${this.generateContentCards([
                            { title: 'Meu primeiro vídeo', creator: this.userData.name, views: '1.2K', time: '2 dias atrás', duration: '10:30' },
                            { title: 'Tutorial React', creator: this.userData.name, views: '850', time: '5 dias atrás', duration: '15:45' },
                            { title: 'Projeto pessoal', creator: this.userData.name, views: '2.5K', time: '1 semana atrás', duration: '8:20' }
                        ])}
                    </div>
                </section>
            </section>
        `;
    }

    // Gerar cards de conteúdo dinamicamente
    generateContentCards(contents) {
        return contents.map((content, index) => `
            <div class="content-card" data-id="${index + 1}">
                <div class="thumbnail">
                    <img src="https://via.placeholder.com/320x180?text=Conteúdo+${index + 1}" alt="Thumbnail">
                    <span class="duration">${content.duration}</span>
                    ${content.trending ? '<span class="trending-badge">🔥</span>' : ''}
                </div>
                <div class="card-info">
                    <h3>${content.title}</h3>
                    <p>Conteúdo premium disponível para assinantes</p>
                    <div class="meta">
                        <span>${content.creator}</span> • <span>${content.views} visualizações</span> • <span>${content.time}</span>
                    </div>
                </div>
            </div>
        `).join('');
    }

    // Gerar cards de criadores dinamicamente
    generateCreatorCards(creators) {
        return creators.map((creator, index) => `
            <div class="creator-card" data-id="${index + 1}">
                <div class="creator-avatar">
                    <img src="https://via.placeholder.com/100x100?text=${creator.name.charAt(0)}" alt="Avatar">
                    ${creator.verified ? '<span class="verified-badge">✓</span>' : ''}
                </div>
                <div class="creator-info">
                    <h3>${creator.channel}</h3>
                    <p>${creator.name}</p>
                    <span class="subscriber-count">${creator.subscribers} seguidores</span>
                    <p class="creator-description">${creator.description}</p>
                </div>
                <div class="creator-actions">
                    <button class="follow-btn btn-primary" data-creator-id="${index + 1}">Seguir</button>
                </div>
            </div>
        `).join('');
    }
}

// Função utilitária para mostrar notificações
function showNotification(message, type = 'info') {
    // Criar elemento de notificação
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;

    // Adicionar ao DOM
    document.body.appendChild(notification);

    // Mostrar notificação
    setTimeout(() => {
        notification.classList.add('show');
    }, 100);

    // Remover após 3 segundos
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Inicializar a navegação quando a página carregar
document.addEventListener('DOMContentLoaded', function() {
    window.siteNavigation = new SiteNavigation();
});
