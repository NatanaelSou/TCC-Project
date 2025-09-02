/**
 * Módulo de serviço da API - Cliente centralizado para comunicação com o backend
 * Gerencia todas as chamadas para a API, autenticação e tratamento de erros
 */

class ApiService {
    constructor() {
        // URL base da API (ajuste conforme necessário)
        this.baseURL = 'http://localhost:3001/api';

        // Headers padrão para todas as requisições
        this.defaultHeaders = {
            'Content-Type': 'application/json'
        };
    }

    /**
     * Obtém o token de autenticação do localStorage
     */
    getAuthToken() {
        return localStorage.getItem('authToken');
    }

    /**
     * Define o token de autenticação no localStorage
     */
    setAuthToken(token) {
        if (token) {
            localStorage.setItem('authToken', token);
        } else {
            localStorage.removeItem('authToken');
        }
    }

    /**
     * Cria headers para requisição incluindo token de autenticação se disponível
     */
    getHeaders(includeAuth = true) {
        const headers = { ...this.defaultHeaders };

        if (includeAuth) {
            const token = this.getAuthToken();
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
        }

        return headers;
    }

    /**
     * Trata resposta da API, verificando erros e convertendo para JSON
     */
    async handleResponse(response) {
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({ error: 'Erro na resposta da API' }));

            // Tratamento específico para diferentes códigos de erro
            switch (response.status) {
                case 401:
                    // Token expirado ou inválido
                    this.setAuthToken(null);
                    throw new Error('Sessão expirada. Faça login novamente.');
                case 403:
                    throw new Error('Acesso negado. Você não tem permissão para esta ação.');
                case 404:
                    throw new Error('Recurso não encontrado.');
                case 409:
                    throw new Error(errorData.error || 'Conflito de dados.');
                case 422:
                    throw new Error('Dados inválidos fornecidos.');
                default:
                    throw new Error(errorData.error || `Erro ${response.status}: ${response.statusText}`);
            }
        }

        return response.json();
    }

    /**
     * Faz requisição GET para a API
     */
    async get(endpoint, params = {}) {
        try {
            const url = new URL(`${this.baseURL}${endpoint}`);

            // Adiciona parâmetros de query se fornecidos
            Object.keys(params).forEach(key => {
                if (params[key] !== null && params[key] !== undefined) {
                    url.searchParams.append(key, params[key]);
                }
            });

            const response = await fetch(url, {
                method: 'GET',
                headers: this.getHeaders()
            });

            return await this.handleResponse(response);
        } catch (error) {
            console.error(`Erro na requisição GET ${endpoint}:`, error);
            throw error;
        }
    }

    /**
     * Faz requisição POST para a API
     */
    async post(endpoint, data = {}, includeAuth = true) {
        try {
            const response = await fetch(`${this.baseURL}${endpoint}`, {
                method: 'POST',
                headers: this.getHeaders(includeAuth),
                body: JSON.stringify(data)
            });

            return await this.handleResponse(response);
        } catch (error) {
            console.error(`Erro na requisição POST ${endpoint}:`, error);
            throw error;
        }
    }

    /**
     * Faz requisição PUT para a API
     */
    async put(endpoint, data = {}) {
        try {
            const response = await fetch(`${this.baseURL}${endpoint}`, {
                method: 'PUT',
                headers: this.getHeaders(),
                body: JSON.stringify(data)
            });

            return await this.handleResponse(response);
        } catch (error) {
            console.error(`Erro na requisição PUT ${endpoint}:`, error);
            throw error;
        }
    }

    /**
     * Faz requisição DELETE para a API
     */
    async delete(endpoint) {
        try {
            const response = await fetch(`${this.baseURL}${endpoint}`, {
                method: 'DELETE',
                headers: this.getHeaders()
            });

            return await this.handleResponse(response);
        } catch (error) {
            console.error(`Erro na requisição DELETE ${endpoint}:`, error);
            throw error;
        }
    }

    /**
     * Faz upload de arquivo para a API
     */
    async uploadFile(endpoint, file, additionalData = {}) {
        try {
            const formData = new FormData();
            formData.append('file', file);

            // Adiciona dados adicionais ao FormData
            Object.keys(additionalData).forEach(key => {
                formData.append(key, additionalData[key]);
            });

            const headers = {};
            const token = this.getAuthToken();
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }

            const response = await fetch(`${this.baseURL}${endpoint}`, {
                method: 'POST',
                headers: headers,
                body: formData
            });

            return await this.handleResponse(response);
        } catch (error) {
            console.error(`Erro no upload ${endpoint}:`, error);
            throw error;
        }
    }

    // =====================================================================================
    // MÉTODOS ESPECÍFICOS PARA USUÁRIOS
    // =====================================================================================

    /**
     * Registra um novo usuário
     */
    async register(userData) {
        return await this.post('/users/register', userData, false);
    }

    /**
     * Faz login do usuário
     */
    async login(credentials) {
        const response = await this.post('/users/login', credentials, false);
        if (response.token) {
            this.setAuthToken(response.token);
        }
        return response;
    }

    /**
     * Faz logout do usuário
     */
    logout() {
        this.setAuthToken(null);
    }

    /**
     * Obtém perfil do usuário logado
     */
    async getProfile() {
        return await this.get('/users/profile');
    }

    /**
     * Atualiza perfil do usuário
     */
    async updateProfile(profileData) {
        return await this.put('/users/profile', profileData);
    }

    /**
     * Obtém usuário por ID
     */
    async getUserById(userId) {
        return await this.get(`/users/${userId}`);
    }

    // =====================================================================================
    // MÉTODOS ESPECÍFICOS PARA CONTEÚDO
    // =====================================================================================

    /**
     * Lista conteúdo com filtros
     */
    async getContent(params = {}) {
        return await this.get('/content', params);
    }

    /**
     * Obtém conteúdo em destaque
     */
    async getFeaturedContent(limit = 10) {
        return await this.get('/content/featured', { limit });
    }

    /**
     * Obtém conteúdo por ID
     */
    async getContentById(contentId) {
        return await this.get(`/content/${contentId}`);
    }

    /**
     * Cria novo conteúdo
     */
    async createContent(contentData) {
        return await this.post('/content', contentData);
    }

    /**
     * Atualiza conteúdo
     */
    async updateContent(contentId, contentData) {
        return await this.put(`/content/${contentId}`, contentData);
    }

    /**
     * Deleta conteúdo
     */
    async deleteContent(contentId) {
        return await this.delete(`/content/${contentId}`);
    }

    /**
     * Obtém conteúdo de um criador específico
     */
    async getContentByCreator(creatorId, params = {}) {
        return await this.get(`/content/creator/${creatorId}`, params);
    }

    /**
     * Obtém conteúdo por categoria
     */
    async getContentByCategory(categoryId, params = {}) {
        return await this.get(`/content/category/${categoryId}`, params);
    }

    // =====================================================================================
    // MÉTODOS ESPECÍFICOS PARA CRIADORES
    // =====================================================================================

    /**
     * Lista criadores
     */
    async getCreators(params = {}) {
        return await this.get('/creators', params);
    }

    /**
     * Obtém criador por ID
     */
    async getCreatorById(creatorId) {
        return await this.get(`/creators/${creatorId}`);
    }

    /**
     * Registra como criador
     */
    async becomeCreator(creatorData) {
        return await this.post('/creators', creatorData);
    }

    /**
     * Atualiza perfil de criador
     */
    async updateCreator(creatorData) {
        return await this.put('/creators/profile', creatorData);
    }

    // =====================================================================================
    // MÉTODOS ESPECÍFICOS PARA ASSINATURAS
    // =====================================================================================

    /**
     * Lista assinaturas do usuário
     */
    async getSubscriptions() {
        return await this.get('/subscriptions');
    }

    /**
     * Assina um criador
     */
    async subscribe(creatorId, subscriptionData = {}) {
        return await this.post(`/subscriptions/${creatorId}`, subscriptionData);
    }

    /**
     * Cancela assinatura
     */
    async unsubscribe(creatorId) {
        return await this.delete(`/subscriptions/${creatorId}`);
    }

    // =====================================================================================
    // MÉTODOS ESPECÍFICOS PARA PAGAMENTOS
    // =====================================================================================

    /**
     * Lista pagamentos do usuário
     */
    async getPayments(params = {}) {
        return await this.get('/payments', params);
    }

    /**
     * Processa pagamento
     */
    async processPayment(paymentData) {
        return await this.post('/payments', paymentData);
    }

    /**
     * Obtém detalhes do pagamento
     */
    async getPaymentById(paymentId) {
        return await this.get(`/payments/${paymentId}`);
    }

    // =====================================================================================
    // MÉTODOS UTILITÁRIOS
    // =====================================================================================

    /**
     * Verifica se o usuário está autenticado
     */
    isAuthenticated() {
        return !!this.getAuthToken();
    }

    /**
     * Testa conexão com a API
     */
    async testConnection() {
        try {
            await this.get('/health');
            return true;
        } catch (error) {
            console.error('Erro na conexão com API:', error);
            return false;
        }
    }
}

// =====================================================================================
// INSTÂNCIA GLOBAL DO SERVIÇO DA API
// =====================================================================================

// Criar instância global do serviço da API
window.apiService = new ApiService();

// Exportar para uso em módulos ES6 (se necessário)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ApiService;
}
