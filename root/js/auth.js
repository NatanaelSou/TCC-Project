/**
 * Módulo de autenticação - Gerencia estado de login e sessão do usuário
 * Trabalha em conjunto com o ApiService para manter a sessão ativa
 */

class AuthService {
    constructor() {
        this.currentUser = null;
        this.isLoggedIn = false;
        this.loginListeners = [];
        this.logoutListeners = [];

        // Verificar se já existe uma sessão ativa ao inicializar
        this.checkExistingSession();
    }

    /**
     * Verifica se existe uma sessão válida no localStorage
     */
    async checkExistingSession() {
        try {
            const token = window.apiService.getAuthToken();
            if (token) {
                // Tentar obter perfil do usuário para validar token
                const response = await window.apiService.getProfile();
                this.currentUser = response.user;
                this.isLoggedIn = true;
                this.notifyLoginListeners();
                console.log('Sessão existente validada:', this.currentUser.username);
            }
        } catch (error) {
            console.log('Sessão inválida ou expirada, fazendo logout');
            this.logout();
        }
    }

    /**
     * Faz login do usuário
     */
    async login(email, password) {
        try {
            const response = await window.apiService.login({ email, password });
            this.currentUser = response.user;
            this.isLoggedIn = true;
            this.notifyLoginListeners();
            console.log('Login realizado com sucesso:', this.currentUser.username);
            return { success: true, user: this.currentUser };
        } catch (error) {
            console.error('Erro no login:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Registra um novo usuário
     */
    async register(userData) {
        try {
            const response = await window.apiService.register(userData);
            console.log('Registro realizado com sucesso:', response.user.username);
            return { success: true, user: response.user };
        } catch (error) {
            console.error('Erro no registro:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Faz logout do usuário
     */
    logout() {
        window.apiService.logout();
        this.currentUser = null;
        this.isLoggedIn = false;
        this.notifyLogoutListeners();
        console.log('Logout realizado');
    }

    /**
     * Atualiza dados do usuário
     */
    async updateProfile(profileData) {
        try {
            const response = await window.apiService.updateProfile(profileData);
            this.currentUser = response.user;
            console.log('Perfil atualizado:', this.currentUser.username);
            return { success: true, user: this.currentUser };
        } catch (error) {
            console.error('Erro ao atualizar perfil:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Verifica se o usuário está logado
     */
    isAuthenticated() {
        return this.isLoggedIn && !!this.currentUser;
    }

    /**
     * Obtém dados do usuário atual
     */
    getCurrentUser() {
        return this.currentUser;
    }

    /**
     * Adiciona listener para eventos de login
     */
    addLoginListener(callback) {
        this.loginListeners.push(callback);
    }

    /**
     * Remove listener de login
     */
    removeLoginListener(callback) {
        this.loginListeners = this.loginListeners.filter(listener => listener !== callback);
    }

    /**
     * Adiciona listener para eventos de logout
     */
    addLogoutListener(callback) {
        this.logoutListeners.push(callback);
    }

    /**
     * Remove listener de logout
     */
    removeLogoutListener(callback) {
        this.logoutListeners = this.logoutListeners.filter(listener => listener !== callback);
    }

    /**
     * Notifica todos os listeners de login
     */
    notifyLoginListeners() {
        this.loginListeners.forEach(callback => {
            try {
                callback(this.currentUser);
            } catch (error) {
                console.error('Erro em listener de login:', error);
            }
        });
    }

    /**
     * Notifica todos os listeners de logout
     */
    notifyLogoutListeners() {
        this.logoutListeners.forEach(callback => {
            try {
                callback();
            } catch (error) {
                console.error('Erro em listener de logout:', error);
            }
        });
    }

    /**
     * Verifica se o usuário atual é um criador
     */
    async isCreator() {
        if (!this.isAuthenticated()) return false;

        try {
            // Tentar obter perfil de criador
            const response = await window.apiService.get('/creators/profile');
            return !!response.creator;
        } catch (error) {
            return false;
        }
    }

    /**
     * Registra o usuário como criador
     */
    async becomeCreator(creatorData) {
        try {
            const response = await window.apiService.becomeCreator(creatorData);
            console.log('Registrado como criador:', response.creator.channel_name);
            return { success: true, creator: response.creator };
        } catch (error) {
            console.error('Erro ao registrar como criador:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Atualiza dados do criador
     */
    async updateCreator(creatorData) {
        try {
            const response = await window.apiService.updateCreator(creatorData);
            console.log('Dados do criador atualizados');
            return { success: true, creator: response.creator };
        } catch (error) {
            console.error('Erro ao atualizar dados do criador:', error);
            return { success: false, error: error.message };
        }
    }
}

// =====================================================================================
// INSTÂNCIA GLOBAL DO SERVIÇO DE AUTENTICAÇÃO
// =====================================================================================

// Criar instância global do serviço de autenticação
window.authService = new AuthService();

// Exportar para uso em módulos ES6 (se necessário)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AuthService;
}
