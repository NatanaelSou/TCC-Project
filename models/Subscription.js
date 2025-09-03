const db = require('../config/database');

class Subscription {
    constructor(data) {
        this.id = data.id;
        this.user_id = data.user_id;
        this.creator_id = data.creator_id;
        this.tier_id = data.tier_id;
        this.status = data.status;
        this.start_date = data.start_date;
        this.end_date = data.end_date;
        this.auto_renew = data.auto_renew;
        this.created_at = data.created_at;
        this.updated_at = data.updated_at;
    }

    // Criar nova assinatura
    static async create(subscriptionData) {
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO subscriptions (user_id, creator_id, tier_id, status, start_date, end_date, auto_renew) VALUES (?, ?, ?, ?, ?, ?, ?)`;
            const values = [
                subscriptionData.user_id,
                subscriptionData.creator_id,
                subscriptionData.tier_id,
                subscriptionData.status || 'active',
                subscriptionData.start_date || new Date(),
                subscriptionData.end_date || null,
                subscriptionData.auto_renew !== undefined ? subscriptionData.auto_renew : true
            ];

            db.query(sql, values, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                const newSubscription = new Subscription({
                    id: result.insertId,
                    ...subscriptionData,
                    status: subscriptionData.status || 'active',
                    start_date: subscriptionData.start_date || new Date(),
                    end_date: subscriptionData.end_date || null,
                    auto_renew: subscriptionData.auto_renew !== undefined ? subscriptionData.auto_renew : true
                });

                resolve(newSubscription);
            });
        });
    }

    // Buscar assinatura por ID
    static async findById(id) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM subscriptions WHERE id = ?`;
            db.query(sql, [id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                resolve(new Subscription(results[0]));
            });
        });
    }

    // Buscar assinaturas por usuário
    static async findByUserId(userId) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT s.*, t.name as tier_name, t.price, u.name as creator_name
                FROM subscriptions s
                LEFT JOIN tiers t ON s.tier_id = t.id
                LEFT JOIN users u ON s.creator_id = u.id
                WHERE s.user_id = ?
                ORDER BY s.created_at DESC
            `;
            db.query(sql, [userId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const subscriptions = results.map(row => new Subscription(row));
                resolve(subscriptions);
            });
        });
    }

    // Buscar assinaturas por criador
    static async findByCreatorId(creatorId) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT s.*, t.name as tier_name, t.price, u.name as subscriber_name, u.email as subscriber_email
                FROM subscriptions s
                LEFT JOIN tiers t ON s.tier_id = t.id
                LEFT JOIN users u ON s.user_id = u.id
                WHERE s.creator_id = ?
                ORDER BY s.created_at DESC
            `;
            db.query(sql, [creatorId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const subscriptions = results.map(row => new Subscription(row));
                resolve(subscriptions);
            });
        });
    }

    // Verificar se usuário já está inscrito em um tier
    static async isUserSubscribedToTier(userId, tierId) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT COUNT(*) as count FROM subscriptions WHERE user_id = ? AND tier_id = ? AND status = 'active'`;
            db.query(sql, [userId, tierId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                resolve(results[0].count > 0);
            });
        });
    }

    // Verificar se usuário está inscrito em qualquer tier de um criador
    static async isUserSubscribedToCreator(userId, creatorId) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT COUNT(*) as count FROM subscriptions WHERE user_id = ? AND creator_id = ? AND status = 'active'`;
            db.query(sql, [userId, creatorId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                resolve(results[0].count > 0);
            });
        });
    }

    // Atualizar status da assinatura
    async updateStatus(status) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE subscriptions SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?`;
            db.query(sql, [status, this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.status = status;
                this.updated_at = new Date();
                resolve(this);
            });
        });
    }

    // Cancelar assinatura
    async cancel() {
        return this.updateStatus('cancelled');
    }

    // Pausar assinatura
    async pause() {
        return this.updateStatus('paused');
    }

    // Reativar assinatura
    async reactivate() {
        return this.updateStatus('active');
    }

    // Atualizar tier da assinatura
    async updateTier(newTierId) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE subscriptions SET tier_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?`;
            db.query(sql, [newTierId, this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.tier_id = newTierId;
                this.updated_at = new Date();
                resolve(this);
            });
        });
    }
}

module.exports = Subscription;
