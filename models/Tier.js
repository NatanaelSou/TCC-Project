const db = require('../config/database');

class Tier {
    constructor(data) {
        this.id = data.id;
        this.creator_id = data.creator_id;
        this.name = data.name;
        this.description = data.description;
        this.price = data.price;
        this.benefits = data.benefits;
        this.max_subscribers = data.max_subscribers;
        this.is_active = data.is_active;
        this.created_at = data.created_at;
        this.updated_at = data.updated_at;
    }

    // Criar novo tier
    static async create(tierData) {
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO tiers (creator_id, name, description, price, benefits, max_subscribers, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)`;
            const values = [
                tierData.creator_id,
                tierData.name,
                tierData.description,
                tierData.price,
                JSON.stringify(tierData.benefits || []),
                tierData.max_subscribers || null,
                tierData.is_active !== undefined ? tierData.is_active : true
            ];

            db.query(sql, values, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                const newTier = new Tier({
                    id: result.insertId,
                    ...tierData,
                    benefits: tierData.benefits || [],
                    is_active: tierData.is_active !== undefined ? tierData.is_active : true
                });

                resolve(newTier);
            });
        });
    }

    // Buscar tier por ID
    static async findById(id) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM tiers WHERE id = ?`;
            db.query(sql, [id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                const tier = new Tier(results[0]);
                tier.benefits = JSON.parse(tier.benefits || '[]');
                resolve(tier);
            });
        });
    }

    // Buscar tiers por creator
    static async findByCreatorId(creatorId) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM tiers WHERE creator_id = ? AND is_active = true ORDER BY price ASC`;
            db.query(sql, [creatorId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const tiers = results.map(row => {
                    const tier = new Tier(row);
                    tier.benefits = JSON.parse(tier.benefits || '[]');
                    return tier;
                });

                resolve(tiers);
            });
        });
    }

    // Atualizar tier
    async update(updateData) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE tiers SET ? WHERE id = ?`;
            const updateObj = { ...updateData };

            if (updateData.benefits) {
                updateObj.benefits = JSON.stringify(updateData.benefits);
            }

            db.query(sql, [updateObj, this.id], (err, result) => {
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

    // Deletar tier (soft delete)
    async delete() {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE tiers SET is_active = false WHERE id = ?`;
            db.query(sql, [this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.is_active = false;
                resolve(this);
            });
        });
    }

    // Verificar se tier atingiu limite de subscribers
    async isAtCapacity() {
        if (!this.max_subscribers) return false;

        return new Promise((resolve, reject) => {
            const sql = `SELECT COUNT(*) as count FROM subscriptions WHERE tier_id = ? AND status = 'active'`;
            db.query(sql, [this.id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                resolve(results[0].count >= this.max_subscribers);
            });
        });
    }

    // Contar subscribers ativos
    async getSubscriberCount() {
        return new Promise((resolve, reject) => {
            const sql = `SELECT COUNT(*) as count FROM subscriptions WHERE tier_id = ? AND status = 'active'`;
            db.query(sql, [this.id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                resolve(results[0].count);
            });
        });
    }
}

module.exports = Tier;
