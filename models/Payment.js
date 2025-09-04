const db = require('../config/database');

class Payment {
    constructor(data) {
        this.id = data.id;
        this.subscription_id = data.subscription_id;
        this.amount = data.amount;
        this.currency = data.currency;
        this.gateway = data.gateway;
        this.transaction_id = data.transaction_id;
        this.status = data.status;
        this.created_at = data.created_at;
    }

    // Criar novo pagamento
    static async create(paymentData) {
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO payments (subscription_id, amount, currency, gateway, transaction_id, status) VALUES (?, ?, ?, ?, ?, ?)`;
            const values = [
                paymentData.subscription_id,
                paymentData.amount,
                paymentData.currency || 'BRL',
                paymentData.gateway,
                paymentData.transaction_id || null,
                paymentData.status || 'pending'
            ];

            db.query(sql, values, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                const newPayment = new Payment({
                    id: result.insertId,
                    ...paymentData,
                    currency: paymentData.currency || 'BRL',
                    status: paymentData.status || 'pending'
                });

                resolve(newPayment);
            });
        });
    }

    // Buscar pagamento por ID
    static async findById(id) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM payments WHERE id = ?`;
            db.query(sql, [id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                resolve(new Payment(results[0]));
            });
        });
    }

    // Buscar pagamentos por assinatura
    static async findBySubscriptionId(subscriptionId) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM payments WHERE subscription_id = ? ORDER BY created_at DESC`;
            db.query(sql, [subscriptionId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const payments = results.map(row => new Payment(row));
                resolve(payments);
            });
        });
    }

    // Buscar pagamentos por usuário
    static async findByUserId(userId) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT p.* FROM payments p
                LEFT JOIN subscriptions s ON p.subscription_id = s.id
                WHERE s.user_id = ?
                ORDER BY p.created_at DESC
            `;
            db.query(sql, [userId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const payments = results.map(row => new Payment(row));
                resolve(payments);
            });
        });
    }

    // Atualizar status do pagamento
    async updateStatus(status, transactionId = null) {
        return new Promise((resolve, reject) => {
            let sql = `UPDATE payments SET status = ?`;
            const params = [status];

            if (transactionId) {
                sql += `, transaction_id = ?`;
                params.push(transactionId);
            }

            sql += ` WHERE id = ?`;
            params.push(this.id);

            db.query(sql, params, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.status = status;
                if (transactionId) {
                    this.transaction_id = transactionId;
                }
                resolve(this);
            });
        });
    }

    // Calcular receita total por período
    static async getTotalRevenue(startDate = null, endDate = null) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT SUM(amount) as total FROM payments WHERE status = 'completed'`;
            const params = [];

            if (startDate) {
                sql += ` AND created_at >= ?`;
                params.push(startDate);
            }

            if (endDate) {
                sql += ` AND created_at <= ?`;
                params.push(endDate);
            }

            db.query(sql, params, (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                resolve(results[0].total || 0);
            });
        });
    }

    // Converter para JSON
    toJSON() {
        const { ...paymentData } = this;
        return paymentData;
    }
}

module.exports = Payment;
