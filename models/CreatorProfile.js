const db = require('../config/database');

class CreatorProfile {
    constructor(data) {
        this.id = data.id;
        this.user_id = data.user_id;
        this.display_name = data.display_name;
        this.bio = data.bio;
        this.banner_image = data.banner_image;
        this.profile_image = data.profile_image;
        this.website = data.website;
        this.social_links = data.social_links;
        this.total_earnings = data.total_earnings;
        this.subscriber_count = data.subscriber_count;
        this.is_verified = data.is_verified;
        this.created_at = data.created_at;
        this.updated_at = data.updated_at;
    }

    // Criar perfil de criador
    static async create(profileData) {
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO creator_profiles (user_id, display_name, bio, banner_image, profile_image, website, social_links, is_verified) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
            const values = [
                profileData.user_id,
                profileData.display_name || null,
                profileData.bio || null,
                profileData.banner_image || null,
                profileData.profile_image || null,
                profileData.website || null,
                JSON.stringify(profileData.social_links || {}),
                profileData.is_verified || false
            ];

            db.query(sql, values, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                const newProfile = new CreatorProfile({
                    id: result.insertId,
                    ...profileData,
                    social_links: profileData.social_links || {},
                    is_verified: profileData.is_verified || false
                });

                resolve(newProfile);
            });
        });
    }

    // Buscar perfil por user_id
    static async findByUserId(userId) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM creator_profiles WHERE user_id = ?`;
            db.query(sql, [userId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                const profile = new CreatorProfile(results[0]);
                profile.social_links = JSON.parse(profile.social_links || '{}');
                resolve(profile);
            });
        });
    }

    // Buscar perfil por ID
    static async findById(id) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM creator_profiles WHERE id = ?`;
            db.query(sql, [id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                const profile = new CreatorProfile(results[0]);
                profile.social_links = JSON.parse(profile.social_links || '{}');
                resolve(profile);
            });
        });
    }

    // Buscar perfis de criadores populares
    static async findPopular(limit = 10) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT cp.*, u.name as user_name, u.email
                FROM creator_profiles cp
                LEFT JOIN users u ON cp.user_id = u.id
                ORDER BY cp.subscriber_count DESC
                LIMIT ?
            `;
            db.query(sql, [limit], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const profiles = results.map(row => {
                    const profile = new CreatorProfile(row);
                    profile.social_links = JSON.parse(profile.social_links || '{}');
                    return profile;
                });

                resolve(profiles);
            });
        });
    }

    // Atualizar perfil
    async update(updateData) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE creator_profiles SET ? WHERE id = ?`;
            const updateObj = { ...updateData };

            if (updateData.social_links) {
                updateObj.social_links = JSON.stringify(updateData.social_links);
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

    // Atualizar contagem de assinantes
    async updateSubscriberCount() {
        return new Promise((resolve, reject) => {
            const sql = `
                UPDATE creator_profiles
                SET subscriber_count = (
                    SELECT COUNT(*) FROM subscriptions
                    WHERE creator_id = creator_profiles.user_id
                    AND status = 'active'
                )
                WHERE id = ?
            `;

            db.query(sql, [this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                // Buscar nova contagem
                const countSql = `SELECT subscriber_count FROM creator_profiles WHERE id = ?`;
                db.query(countSql, [this.id], (err, results) => {
                    if (err) {
                        reject(err);
                        return;
                    }

                    this.subscriber_count = results[0].subscriber_count;
                    resolve(this);
                });
            });
        });
    }

    // Atualizar ganhos totais
    async updateEarnings(amount) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE creator_profiles SET total_earnings = total_earnings + ? WHERE id = ?`;
            db.query(sql, [amount, this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.total_earnings += amount;
                resolve(this);
            });
        });
    }

    // Verificar se usuário é criador
    static async isCreator(userId) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT COUNT(*) as count FROM creator_profiles WHERE user_id = ?`;
            db.query(sql, [userId], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                resolve(results[0].count > 0);
            });
        });
    }

    // Converter para JSON (excluir dados sensíveis)
    toJSON() {
        const { ...profileData } = this;
        return profileData;
    }
}

module.exports = CreatorProfile;
