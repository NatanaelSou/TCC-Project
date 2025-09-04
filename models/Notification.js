const db = require('../config/database');

class Notification {
    constructor(data) {
        this.id = data.id;
        this.user_id = data.user_id;
        this.type = data.type;
        this.message = data.message;
        this.is_read = data.is_read;
        this.created_at = data.created_at;
    }

    // Criar nova notificação
    static async create(notificationData) {
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO notifications (user_id, type, message, is_read) VALUES (?, ?, ?, ?)`;
            const values = [
                notificationData.user_id,
                notificationData.type,
                notificationData.message,
                notificationData.is_read || false
            ];

            db.query(sql, values, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                const newNotification = new Notification({
                    id: result.insertId,
                    ...notificationData,
                    is_read: notificationData.is_read || false
                });

                resolve(newNotification);
            });
        });
    }

    // Buscar notificações por usuário
    static async findByUserId(userId, options = {}) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM notifications WHERE user_id = ?`;
            const params = [userId];

            if (options.unreadOnly) {
                sql += ` AND is_read = false`;
            }

            sql += ` ORDER BY created_at DESC`;

            if (options.limit) {
                sql += ` LIMIT ?`;
                params.push(options.limit);
            }

            db.query(sql, params, (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const notifications = results.map(row => new Notification(row));
                resolve(notifications);
            });
        });
    }

    // Marcar notificação como lida
    async markAsRead() {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE notifications SET is_read = true WHERE id = ?`;
            db.query(sql, [this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.is_read = true;
                resolve(this);
            });
        });
    }

    // Converter para JSON
    toJSON() {
        const { ...notificationData } = this;
        return notificationData;
    }
}

module.exports = Notification;
