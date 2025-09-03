const Tier = require('../models/Tier');
const Content = require('../models/Content');
const Subscription = require('../models/Subscription');
const User = require('../models/User');

class CreatorController {
    // Criar novo tier
    static async createTier(req, res) {
        try {
            const { name, description, price, benefits, max_subscribers } = req.body;
            const creatorId = req.user.id;

            // Validação
            if (!name || !price) {
                return res.status(400).json({ error: 'Nome e preço são obrigatórios' });
            }

            if (price <= 0) {
                return res.status(400).json({ error: 'Preço deve ser maior que zero' });
            }

            // Criar tier
            const tier = await Tier.create({
                creator_id: creatorId,
                name,
                description,
                price,
                benefits: benefits || [],
                max_subscribers
            });

            res.status(201).json({
                message: 'Tier criado com sucesso',
                tier
            });
        } catch (error) {
            console.error('Erro ao criar tier:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Buscar tiers do criador
    static async getTiers(req, res) {
        try {
            const creatorId = req.user.id;
            const tiers = await Tier.findByCreatorId(creatorId);

            res.json({ tiers });
        } catch (error) {
            console.error('Erro ao buscar tiers:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Atualizar tier
    static async updateTier(req, res) {
        try {
            const { id } = req.params;
            const { name, description, price, benefits, max_subscribers } = req.body;
            const creatorId = req.user.id;

            // Buscar tier
            const tier = await Tier.findById(id);
            if (!tier) {
                return res.status(404).json({ error: 'Tier não encontrado' });
            }

            // Verificar se tier pertence ao criador
            if (tier.creator_id !== creatorId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            // Atualizar tier
            const updatedTier = await tier.update({
                name,
                description,
                price,
                benefits,
                max_subscribers
            });

            res.json({
                message: 'Tier atualizado com sucesso',
                tier: updatedTier
            });
        } catch (error) {
            console.error('Erro ao atualizar tier:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Deletar tier
    static async deleteTier(req, res) {
        try {
            const { id } = req.params;
            const creatorId = req.user.id;

            // Buscar tier
            const tier = await Tier.findById(id);
            if (!tier) {
                return res.status(404).json({ error: 'Tier não encontrado' });
            }

            // Verificar se tier pertence ao criador
            if (tier.creator_id !== creatorId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            // Verificar se há assinaturas ativas
            const subscriberCount = await tier.getSubscriberCount();
            if (subscriberCount > 0) {
                return res.status(400).json({
                    error: 'Não é possível deletar tier com assinaturas ativas'
                });
            }

            // Deletar tier
            await tier.delete();

            res.json({ message: 'Tier deletado com sucesso' });
        } catch (error) {
            console.error('Erro ao deletar tier:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Buscar assinaturas do criador
    static async getSubscriptions(req, res) {
        try {
            const creatorId = req.user.id;
            const subscriptions = await Subscription.findByCreatorId(creatorId);

            res.json({ subscriptions });
        } catch (error) {
            console.error('Erro ao buscar assinaturas:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Buscar estatísticas do criador
    static async getStats(req, res) {
        try {
            const creatorId = req.user.id;

            // Buscar estatísticas
            const stats = {
                total_subscribers: 0,
                total_earnings: 0,
                active_subscriptions: 0,
                tiers_count: 0,
                content_count: 0
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

            // Calcular ganhos totais (simplificado)
            stats.total_subscribers = subscriptions.length;

            res.json({ stats });
        } catch (error) {
            console.error('Erro ao buscar estatísticas:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Publicar conteúdo
    static async publishContent(req, res) {
        try {
            const { title, description, type, tier_id, is_premium, file_url } = req.body;
            const creatorId = req.user.id;

            // Validação
            if (!title) {
                return res.status(400).json({ error: 'Título é obrigatório' });
            }

            // Se especificar tier, verificar se tier existe e pertence ao criador
            if (tier_id) {
                const tier = await Tier.findById(tier_id);
                if (!tier || tier.creator_id !== creatorId) {
                    return res.status(400).json({ error: 'Tier inválido' });
                }
            }

            // Criar conteúdo
            const content = await Content.create({
                creator_id: creatorId,
                tier_id,
                title,
                description,
                type,
                file_url,
                is_premium
            });

            res.status(201).json({
                message: 'Conteúdo publicado com sucesso',
                content
            });
        } catch (error) {
            console.error('Erro ao publicar conteúdo:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Buscar conteúdo do criador
    static async getContent(req, res) {
        try {
            const creatorId = req.user.id;
            const { tier_id, type, limit } = req.query;

            const options = {};
            if (tier_id) options.tierId = tier_id;
            if (type) options.type = type;
            if (limit) options.limit = parseInt(limit);

            const content = await Content.findByCreatorId(creatorId, options);

            res.json({ content });
        } catch (error) {
            console.error('Erro ao buscar conteúdo:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Atualizar conteúdo
    static async updateContent(req, res) {
        try {
            const { id } = req.params;
            const { title, description, tier_id, is_premium } = req.body;
            const creatorId = req.user.id;

            // Buscar conteúdo
            const content = await Content.findById(id);
            if (!content) {
                return res.status(404).json({ error: 'Conteúdo não encontrado' });
            }

            // Verificar se conteúdo pertence ao criador
            if (content.creator_id !== creatorId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            // Se especificar tier, verificar se tier existe e pertence ao criador
            if (tier_id) {
                const tier = await Tier.findById(tier_id);
                if (!tier || tier.creator_id !== creatorId) {
                    return res.status(400).json({ error: 'Tier inválido' });
                }
            }

            // Atualizar conteúdo
            const updatedContent = await content.update({
                title,
                description,
                tier_id,
                is_premium
            });

            res.json({
                message: 'Conteúdo atualizado com sucesso',
                content: updatedContent
            });
        } catch (error) {
            console.error('Erro ao atualizar conteúdo:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Deletar conteúdo
    static async deleteContent(req, res) {
        try {
            const { id } = req.params;
            const creatorId = req.user.id;

            // Buscar conteúdo
            const content = await Content.findById(id);
            if (!content) {
                return res.status(404).json({ error: 'Conteúdo não encontrado' });
            }

            // Verificar se conteúdo pertence ao criador
            if (content.creator_id !== creatorId) {
                return res.status(403).json({ error: 'Acesso negado' });
            }

            // Deletar conteúdo
            await Content.delete(id);

            res.json({ message: 'Conteúdo deletado com sucesso' });
        } catch (error) {
            console.error('Erro ao deletar conteúdo:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }
}

module.exports = CreatorController;
