const db = require('../config/database');

class Content {
    constructor(data) {
        this.id = data.id;
        this.creator_id = data.creator_id;
        this.tier_id = data.tier_id;
        this.title = data.title;
        this.description = data.description;
        this.type = data.type;
        this.file_url = data.file_url;
        this.is_premium = data.is_premium;
        this.created_at = data.created_at;
        this.updated_at = data.updated_at;
    }

    // Criar novo conteúdo
    static async create(contentData) {
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO content (creator_id, tier_id, title, description, type, file_url, is_premium) VALUES (?, ?, ?, ?, ?, ?, ?)`;
            const values = [
                contentData.creator_id,
                contentData.tier_id || null,
                contentData.title,
                contentData.description,
                contentData.type || 'text',
                contentData.file_url || null,
                contentData.is_premium !== undefined ? contentData.is_premium : false
            ];

            db.query(sql, values, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                const newContent = new Content({
                    id: result.insertId,
                    ...contentData,
                    type: contentData.type || 'text',
                    file_url: contentData.file_url || null,
                    is_premium: contentData.is_premium !== undefined ? contentData.is_premium : false
                });

                resolve(newContent);
            });
        });
    }

    // Buscar conteúdo por ID
    static async findById(id) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM content WHERE id = ?`;
            db.query(sql, [id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                resolve(new Content(results[0]));
            });
        });
    }

    // Buscar conteúdo por criador
    static async findByCreatorId(creatorId, options = {}) {
        return new Promise((resolve, reject) => {
            let sql = `
                SELECT c.*, t.name as tier_name, u.name as creator_name
                FROM content c
                LEFT JOIN tiers t ON c.tier_id = t.id
                LEFT JOIN users u ON c.creator_id = u.id
                WHERE c.creator_id = ?
            `;
            const params = [creatorId];

            if (options.tierId) {
                sql += ` AND c.tier_id = ?`;
                params.push(options.tierId);
            }

            if (options.type) {
                sql += ` AND c.type = ?`;
                params.push(options.type);
            }

            if (options.isPremium !== undefined) {
                sql += ` AND c.is_premium = ?`;
                params.push(options.isPremium);
            }

            sql += ` ORDER BY c.created_at DESC`;

            if (options.limit) {
                sql += ` LIMIT ?`;
                params.push(options.limit);
            }

            db.query(sql, params, (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const content = results.map(row => new Content(row));
                resolve(content);
            });
        });
    }

    // Buscar conteúdo público (não premium)
    static async findPublicContent(options = {}) {
        return new Promise((resolve, reject) => {
            let sql = `
                SELECT c.*, t.name as tier_name, u.name as creator_name
                FROM content c
                LEFT JOIN tiers t ON c.tier_id = t.id
                LEFT JOIN users u ON c.creator_id = u.id
                WHERE c.is_premium = false
            `;
            const params = [];

            if (options.creatorId) {
                sql += ` AND c.creator_id = ?`;
                params.push(options.creatorId);
            }

            if (options.type) {
                sql += ` AND c.type = ?`;
                params.push(options.type);
            }

            sql += ` ORDER BY c.created_at DESC`;

            if (options.limit) {
                sql += ` LIMIT ?`;
                params.push(options.limit);
            }

            db.query(sql, params, (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const content = results.map(row => new Content(row));
                resolve(content);
            });
        });
    }

    // Buscar conteúdo acessível para um usuário (baseado em assinaturas)
    static async findAccessibleContent(userId, options = {}) {
        return new Promise((resolve, reject) => {
            // Primeiro, buscar tiers que o usuário está inscrito
            const sql = `
                SELECT DISTINCT c.*
                FROM content c
                LEFT JOIN subscriptions s ON c.tier_id = s.tier_id AND s.user_id = ? AND s.status = 'active'
                WHERE (c.is_premium = false OR s.id IS NOT NULL)
                ORDER BY c.created_at DESC
                LIMIT ?
            `;

            const limit = options.limit || 50;

            db.query(sql, [userId, limit], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const content = results.map(row => new Content(row));
                resolve(content);
            });
        });
    }

    // Atualizar conteúdo
    async update(updateData) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE content SET ? WHERE id = ?`;
            db.query(sql, [updateData, this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                // Atualizar propriedades da instância
                Object.assign(this, updateData);
                resolve(this);
            });
        });
    }

    // Deletar conteúdo
    static async delete(id) {
        return new Promise((resolve, reject) => {
            const sql = `DELETE FROM content WHERE id = ?`;
            db.query(sql, [id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                resolve(result.affectedRows > 0);
            });
        });
    }

    // Verificar se usuário tem acesso ao conteúdo
    static async canUserAccess(userId, contentId) {
        return new Promise((resolve, reject) => {
            // Primeiro, verificar se o conteúdo é público
            const sql1 = `SELECT is_premium, tier_id, creator_id FROM content WHERE id = ?`;
            db.query(sql1, [contentId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(false);
                    return;
                }

                const content = results[0];

                // Se não é premium, qualquer um pode acessar
                if (!content.is_premium) {
                    resolve(true);
                    return;
                }

                // Se o usuário é o criador do conteúdo, permitir acesso
                if (content.creator_id === userId) {
                    resolve(true);
                    return;
                }

                // Se é premium, verificar se usuário está inscrito no tier
                if (content.tier_id) {
                    const sql2 = `SELECT COUNT(*) as count FROM subscriptions WHERE user_id = ? AND tier_id = ? AND status = 'active'`;
                    db.query(sql2, [userId, content.tier_id], (err, results) => {
                        if (err) {
                            reject(err);
                            return;
                        }

                        resolve(results[0].count > 0);
                    });
                } else {
                    resolve(false);
                }
            });
        });
    }

    // Buscar conteúdo acessível para um usuário (baseado em assinaturas e conteúdo público)
    static async findAccessibleContent(userId, options = {}) {
        return new Promise((resolve, reject) => {
            // Buscar conteúdo público + conteúdo premium onde usuário tem assinatura ativa
            const sql = `
                SELECT DISTINCT c.*, t.name as tier_name, u.name as creator_name
                FROM content c
                LEFT JOIN tiers t ON c.tier_id = t.id
                LEFT JOIN users u ON c.creator_id = u.id
                LEFT JOIN subscriptions s ON c.tier_id = s.tier_id AND s.user_id = ? AND s.status = 'active'
                WHERE (c.is_premium = false OR s.id IS NOT NULL OR c.creator_id = ?)
                ORDER BY c.created_at DESC
                LIMIT ?
            `;

            const limit = options.limit || 50;

            db.query(sql, [userId, userId, limit], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const content = results.map(row => new Content(row));
                resolve(content);
            });
        });
    }

    // Buscar conteúdo premium disponível para um usuário
    static async findPremiumContentForUser(userId, options = {}) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT c.*, t.name as tier_name, u.name as creator_name
                FROM content c
                LEFT JOIN tiers t ON c.tier_id = t.id
                LEFT JOIN users u ON c.creator_id = u.id
                LEFT JOIN subscriptions s ON c.tier_id = s.tier_id AND s.user_id = ? AND s.status = 'active'
                WHERE c.is_premium = true AND (s.id IS NOT NULL OR c.creator_id = ?)
                ORDER BY c.created_at DESC
                LIMIT ?
            `;

            const limit = options.limit || 50;

            db.query(sql, [userId, userId, limit], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const content = results.map(row => new Content(row));
                resolve(content);
            });
        });
    }
}

module.exports = Content;
