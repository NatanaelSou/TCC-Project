const Content = require('../models/Content');
const Subscription = require('../models/Subscription');
const Tier = require('../models/Tier');
const CreatorProfile = require('../models/CreatorProfile');
const Payment = require('../models/Payment');

class SubscriberController {
    // Obter feed de conteúdo para o assinante
    static async getFeed(req, res) {
        try {
            const userId = req.user.id;
            const { page = 1, limit = 20, type } = req.query;

            const options = {
                limit: parseInt(limit)
            };

            if (type) options.type = type;

            // Buscar conteúdo acessível para o usuário
            const content = await Content.findAccessibleContent(userId, options);

            res.json({
                content,
                page: parseInt(page),
                limit: parseInt(limit)
            });
        } catch (error) {
            console.error('Erro ao buscar feed:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter conteúdo premium disponível para o usuário
    static async getPremiumContent(req, res) {
        try {
            const userId = req.user.id;
            const { page = 1, limit = 20 } = req.query;

            const options = {
                limit: parseInt(limit)
            };

            const content = await Content.findPremiumContentForUser(userId, options);

            res.json({
                content,
                page: parseInt(page),
                limit: parseInt(limit)
            });
        } catch (error) {
            console.error('Erro ao buscar conteúdo premium:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Verificar acesso a conteúdo específico
    static async checkContentAccess(req, res) {
        try {
            const userId = req.user.id;
            const { contentId } = req.params;

            const hasAccess = await Content.canUserAccess(userId, parseInt(contentId));

            res.json({
                has_access: hasAccess,
                content_id: parseInt(contentId)
            });
        } catch (error) {
            console.error('Erro ao verificar acesso:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter assinaturas do usuário
    static async getSubscriptions(req, res) {
        try {
            const userId = req.user.id;

            const subscriptions = await Subscription.findByUserId(userId);

            res.json({ subscriptions });
        } catch (error) {
            console.error('Erro ao buscar assinaturas:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter detalhes de uma assinatura específica
    static async getSubscriptionDetails(req, res) {
        try {
            const userId = req.user.id;
            const { id } = req.params;

            const subscription = await Subscription.findById(parseInt(id));
            if (!subscription) {
                return res.status(404).json({ error: 'Assinatura não encontrada' });
            }

            if (subscription.user_id !== userId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            // Buscar informações adicionais
            const tier = await Tier.findById(subscription.tier_id);
            const payments = await Payment.findBySubscriptionId(subscription.id);

            res.json({
                subscription,
                tier,
                payments
            });
        } catch (error) {
            console.error('Erro ao buscar detalhes da assinatura:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Cancelar assinatura
    static async cancelSubscription(req, res) {
        try {
            const userId = req.user.id;
            const { id } = req.params;

            const subscription = await Subscription.findById(parseInt(id));
            if (!subscription) {
                return res.status(404).json({ error: 'Assinatura não encontrada' });
            }

            if (subscription.user_id !== userId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            await subscription.cancel();

            res.json({
                message: 'Assinatura cancelada com sucesso',
                subscription
            });
        } catch (error) {
            console.error('Erro ao cancelar assinatura:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Reativar assinatura
    static async reactivateSubscription(req, res) {
        try {
            const userId = req.user.id;
            const { id } = req.params;

            const subscription = await Subscription.findById(parseInt(id));
            if (!subscription) {
                return res.status(404).json({ error: 'Assinatura não encontrada' });
            }

            if (subscription.user_id !== userId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            await subscription.reactivate();

            res.json({
                message: 'Assinatura reativada com sucesso',
                subscription
            });
        } catch (error) {
            console.error('Erro ao reativar assinatura:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter criadores seguidos
    static async getFollowedCreators(req, res) {
        try {
            const userId = req.user.id;

            const subscriptions = await Subscription.findByUserId(userId);
            const creatorIds = [...new Set(subscriptions.map(sub => sub.creator_id))];

            const creators = [];
            for (const creatorId of creatorIds) {
                const profile = await CreatorProfile.findByUserId(creatorId);
                if (profile) {
                    creators.push(profile);
                }
            }

            res.json({ creators });
        } catch (error) {
            console.error('Erro ao buscar criadores seguidos:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Buscar criadores
    static async searchCreators(req, res) {
        try {
            const { query, limit = 10 } = req.query;

            if (!query) {
                return res.status(400).json({ error: 'Parâmetro de busca é obrigatório' });
            }

            // Buscar perfis de criadores que contenham a query
            const profiles = await CreatorProfile.findPopular(parseInt(limit));

            // Filtrar por nome ou display_name
            const filteredProfiles = profiles.filter(profile =>
                profile.display_name?.toLowerCase().includes(query.toLowerCase()) ||
                profile.bio?.toLowerCase().includes(query.toLowerCase())
            );

            res.json({
                creators: filteredProfiles,
                query,
                count: filteredProfiles.length
            });
        } catch (error) {
            console.error('Erro ao buscar criadores:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter histórico de pagamentos
    static async getPaymentHistory(req, res) {
        try {
            const userId = req.user.id;
            const { page = 1, limit = 10 } = req.query;

            const payments = await Payment.findByUserId(userId);

            // Paginação
            const startIndex = (parseInt(page) - 1) * parseInt(limit);
            const endIndex = startIndex + parseInt(limit);
            const paginatedPayments = payments.slice(startIndex, endIndex);

            res.json({
                payments: paginatedPayments,
                total: payments.length,
                page: parseInt(page),
                limit: parseInt(limit)
            });
        } catch (error) {
            console.error('Erro ao buscar histórico de pagamentos:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }
}

module.exports = SubscriberController;
