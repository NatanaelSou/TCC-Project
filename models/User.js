const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

class User {
    constructor(data) {
        this.id = data.id;
        this.name = data.name;
        this.email = data.email;
        this.password = data.password;
        this.role = data.role || 'subscriber';
        this.avatar = data.avatar;
        this.bio = data.bio;
        this.created_at = data.created_at;
        this.updated_at = data.updated_at;
    }

    // Hash password before saving
    static async hashPassword(password) {
        return await bcrypt.hash(password, 12);
    }

    // Verify password
    static async verifyPassword(password, hashedPassword) {
        return await bcrypt.compare(password, hashedPassword);
    }

    // Generate JWT token
    generateToken() {
        return jwt.sign(
            { id: this.id, email: this.email, role: this.role },
            process.env.JWT_SECRET || 'your-secret-key',
            { expiresIn: '7d' }
        );
    }

    // Create new user
    static async create(userData) {
        const hashedPassword = await this.hashPassword(userData.password);

        return new Promise((resolve, reject) => {
            const sql = `INSERT INTO users (name, email, password) VALUES (?, ?, ?)`;
            db.query(sql, [userData.name, userData.email, hashedPassword], (err, result) => {
                if (err) {
                    if (err.code === 'ER_DUP_ENTRY') {
                        reject(new Error('Email already exists'));
                    } else {
                        reject(err);
                    }
                    return;
                }

                const newUser = new User({
                    id: result.insertId,
                    name: userData.name,
                    email: userData.email,
                    password: hashedPassword
                });

                resolve(newUser);
            });
        });
    }

    // Find user by email
    static async findByEmail(email) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM users WHERE email = ?`;
            db.query(sql, [email], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                resolve(new User(results[0]));
            });
        });
    }

    // Find user by ID
    static async findById(id) {
        return new Promise((resolve, reject) => {
            const sql = `SELECT * FROM users WHERE id = ?`;
            db.query(sql, [id], (err, results) => {
                if (err) {
                    reject(err);
                    return;
                }

                if (results.length === 0) {
                    resolve(null);
                    return;
                }

                resolve(new User(results[0]));
            });
        });
    }

    // Update user
    async update(updateData) {
        return new Promise((resolve, reject) => {
            const sql = `UPDATE users SET ? WHERE id = ?`;
            db.query(sql, [updateData, this.id], (err, result) => {
                if (err) {
                    reject(err);
                    return;
                }

                // Update instance properties
                Object.assign(this, updateData);
                resolve(this);
            });
        });
    }

    // Convert to JSON (exclude password)
    toJSON() {
        const { password, ...userData } = this;
        return userData;
    }
}

module.exports = User;
