const CreatorProfile = require('../models/CreatorProfile');
const Content = require('../models/Content');
const Tier = require('../models/Tier');
const Subscription = require('../models/Subscription');
const Payment = require('../models/Payment');
const Notification = require('../models/Notification');

class DashboardController {
    // Obter estatísticas do dashboard do criador
    static async getStats(req, res) {
        try {
            const creatorId = req.user.id;

            // Verificar se usuário é criador
            const isCreator = await CreatorProfile.isCreator(creatorId);
            if (!isCreator) {
                return res.status(403).json({ error: 'Acesso negado. Você não é um criador.' });
            }

            // Buscar estatísticas
            const stats = {
                total_subscribers: 0,
                total_earnings: 0,
                active_subscriptions: 0,
                tiers_count: 0,
                content_count: 0,
                recent_subscriptions: [],
                recent_payments: [],
                monthly_revenue: 0
            };

            // Contar tiers
            const tiers = await Tier.findByCreatorId(creatorId);
            stats.tiers_count = tiers.length;

            // Contar conteúdo
            const content = await Content.findByCreatorId(creatorId);
            stats.content_count = content.length;

            // Buscar assinaturas ativas
            const subscriptions = await Subscription.findByCreatorId(creatorId);
            stats.active_subscriptions = subscriptions.filter(sub => sub.status === 'active').length;
            stats.total_subscribers = subscriptions.length;

            // Calcular ganhos totais
            const payments = await Payment.findByUserId(creatorId);
            stats.total_earnings = payments
                .filter(payment => payment.status === 'completed')
                .reduce((total, payment) => total + parseFloat(payment.amount), 0);

            // Assinaturas recentes (últimos 30 dias)
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
            stats.recent_subscriptions = subscriptions
                .filter(sub => new Date(sub.created_at) > thirtyDaysAgo)
                .slice(0, 5);

            // Pagamentos recentes
            stats.recent_payments = payments
                .filter(payment => payment.status === 'completed')
                .slice(0, 5);

            // Receita mensal (últimos 30 dias)
            const monthlyPayments = payments.filter(payment => {
                return payment.status === 'completed' &&
                       new Date(payment.created_at) > thirtyDaysAgo;
            });
            stats.monthly_revenue = monthlyPayments
                .reduce((total, payment) => total + parseFloat(payment.amount), 0);

            res.json({ stats });
        } catch (error) {
            console.error('Erro ao buscar estatísticas:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter conteúdo do criador para o dashboard
    static async getContent(req, res) {
        try {
            const creatorId = req.user.id;
            const { page = 1, limit = 10, type, tier_id } = req.query;

            const options = {
                limit: parseInt(limit),
                offset: (parseInt(page) - 1) * parseInt(limit)
            };

            if (type) options.type = type;
            if (tier_id) options.tierId = tier_id;

            const content = await Content.findByCreatorId(creatorId, options);

            res.json({
                content,
                page: parseInt(page),
                limit: parseInt(limit)
            });
        } catch (error) {
            console.error('Erro ao buscar conteúdo:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter assinaturas do criador
    static async getSubscriptions(req, res) {
        try {
            const creatorId = req.user.id;
            const { page = 1, limit = 10, status } = req.query;

            const subscriptions = await Subscription.findByCreatorId(creatorId);

            // Filtrar por status se especificado
            let filteredSubscriptions = subscriptions;
            if (status) {
                filteredSubscriptions = subscriptions.filter(sub => sub.status === status);
            }

            // Paginação
            const startIndex = (parseInt(page) - 1) * parseInt(limit);
            const endIndex = startIndex + parseInt(limit);
            const paginatedSubscriptions = filteredSubscriptions.slice(startIndex, endIndex);

            res.json({
                subscriptions: paginatedSubscriptions,
                total: filteredSubscriptions.length,
                page: parseInt(page),
                limit: parseInt(limit)
            });
        } catch (error) {
            console.error('Erro ao buscar assinaturas:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter perfil do criador
    static async getProfile(req, res) {
        try {
            const creatorId = req.user.id;

            const profile = await CreatorProfile.findByUserId(creatorId);
            if (!profile) {
                return res.status(404).json({ error: 'Perfil de criador não encontrado' });
            }

            res.json({ profile });
        } catch (error) {
            console.error('Erro ao buscar perfil:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Atualizar perfil do criador
    static async updateProfile(req, res) {
        try {
            const creatorId = req.user.id;
            const { display_name, bio, website, social_links } = req.body;

            let profile = await CreatorProfile.findByUserId(creatorId);
            if (!profile) {
                // Criar perfil se não existir
                profile = await CreatorProfile.create({
                    user_id: creatorId,
                    display_name,
                    bio,
                    website,
                    social_links
                });
            } else {
                // Atualizar perfil existente
                await profile.update({
                    display_name,
                    bio,
                    website,
                    social_links
                });
            }

            res.json({
                message: 'Perfil atualizado com sucesso',
                profile
            });
        } catch (error) {
            console.error('Erro ao atualizar perfil:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter notificações do criador
    static async getNotifications(req, res) {
        try {
            const creatorId = req.user.id;
            const { unread_only = false } = req.query;

            const options = {};
            if (unread_only === 'true') {
                options.unreadOnly = true;
            }

            const notifications = await Notification.findByUserId(creatorId, options);

            res.json({ notifications });
        } catch (error) {
            console.error('Erro ao buscar notificações:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Marcar notificação como lida
    static async markNotificationAsRead(req, res) {
        try {
            const { id } = req.params;
            const creatorId = req.user.id;

            const notification = await Notification.findById(id);
            if (!notification) {
                return res.status(404).json({ error: 'Notificação não encontrada' });
            }

            if (notification.user_id !== creatorId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            await notification.markAsRead();

            res.json({ message: 'Notificação marcada como lida' });
        } catch (error) {
            console.error('Erro ao marcar notificação como lida:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter análise de receita
    static async getRevenueAnalytics(req, res) {
        try {
            const creatorId = req.user.id;
            const { period = '30' } = req.query; // período em dias

            const days = parseInt(period);
            const startDate = new Date();
            startDate.setDate(startDate.getDate() - days);

            const totalRevenue = await Payment.getTotalRevenue(
                startDate.toISOString().split('T')[0],
                new Date().toISOString().split('T')[0]
            );

            // Aqui poderia implementar análise mais detalhada por período
            res.json({
                total_revenue: totalRevenue,
                period_days: days
            });
        } catch (error) {
            console.error('Erro ao buscar análise de receita:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }
}

module.exports = DashboardController;
