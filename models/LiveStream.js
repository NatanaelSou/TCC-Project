const db = require('../config/database');

class LiveStream {
    constructor(data) {
        this.id = data.id;
        this.creator_id = data.creator_id;
        this.title = data.title;
        this.stream_url = data.stream_url;
        this.is_live = data.is_live;
        this.viewer_count = data.viewer_count;
        this.started_at = data.started_at;
        this.ended_at = data.ended_at;
        this.created_at = data.created_at;
    }

    // Criar nova transmissão ao vivo
    static async create(streamData) {
        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO live_streams (creator_id, title, stream_url, is_live, viewer_count, started_at, ended_at) VALUES (?, ?, ?, ?, ?, ?, ?)`;
            const values = [
                streamData.creator_id,
                streamData.title,
                streamData.stream_url || null,
                streamData.is_live || false,
                streamData.viewer_count || 0,
                streamData.started_at || null,
                streamData.ended_at || null
            ];

            db.query(sql, values, (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                const newStream = new LiveStream({
                    id: result.insertId,
                    ...streamData,
                    is_live: streamData.is_live || false,
                    viewer_count: streamData.viewer_count || 0
                });

                resolve(newStream);
            });
        });
    }

    // Buscar transmissão por ID
    static async findById(id) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM live_streams WHERE id = ?`;
            db.query(sql, [id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                resolve(new LiveStream(results[0]));
            });
        });
    }

    // Buscar transmissões por criador
    static async findByCreatorId(creatorId, options = {}) {
        return new Promise((resolve, reject) => {
            let sql = `SELECT * FROM live_streams WHERE creator_id = ?`;
            const params = [creatorId];

            if (options.isLive !== undefined) {
                sql += ` AND is_live = ?`;
                params.push(options.isLive);
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

                const streams = results.map(row => new LiveStream(row));
                resolve(streams);
            });
        });
    }

    // Buscar transmissões ao vivo
    static async findLiveStreams(limit = 20) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT ls.*, u.name as creator_name, cp.display_name, cp.profile_image
                FROM live_streams ls
                LEFT JOIN users u ON ls.creator_id = u.id
                LEFT JOIN creator_profiles cp ON ls.creator_id = cp.user_id
                WHERE ls.is_live = true
                ORDER BY ls.viewer_count DESC
                LIMIT ?
            `;
            db.query(sql, [limit], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                const streams = results.map(row => new LiveStream(row));
                resolve(streams);
            });
        });
    }

    // Iniciar transmissão
    async start() {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE live_streams SET is_live = true, started_at = CURRENT_TIMESTAMP WHERE id = ?`;
            db.query(sql, [this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.is_live = true;
                this.started_at = new Date();
                resolve(this);
            });
        });
    }

    // Encerrar transmissão
    async end() {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE live_streams SET is_live = false, ended_at = CURRENT_TIMESTAMP WHERE id = ?`;
            db.query(sql, [this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.is_live = false;
                this.ended_at = new Date();
                resolve(this);
            });
        });
    }

    // Atualizar contagem de espectadores
    async updateViewerCount(count) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE live_streams SET viewer_count = ? WHERE id = ?`;
            db.query(sql, [count, this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                this.viewer_count = count;
                resolve(this);
            });
        });
    }

    // Converter para JSON
    toJSON() {
        const { ...streamData } = this;
        return streamData;
    }
}

module.exports = LiveStream;
