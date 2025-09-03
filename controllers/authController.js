const User = require('../models/User');

class AuthController {
    // Registrar novo usuário
    static async register(req, res) {
        try {
            const { name, email, password, role } = req.body;

            // Validação básica
            if (!name || !email || !password) {
                return res.status(400).json({ error: 'Nome, email e senha são obrigatórios' });
            }

            if (password.length < 6) {
                return res.status(400).json({ error: 'A senha deve ter pelo menos 6 caracteres' });
            }

            // Criar usuário
            const user = await User.create({ name, email, password, role });

            // Gerar token
            const token = user.generateToken();

            res.status(201).json({
                message: 'Usuário registrado com sucesso',
                user: user.toJSON(),
                token
            });
        } catch (error) {
            console.error('Erro no registro:', error);
            if (error.message === 'Email already exists') {
                return res.status(409).json({ error: 'Email já cadastrado' });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Fazer login
    static async login(req, res) {
        try {
            const { email, password } = req.body;

            // Validação básica
            if (!email || !password) {
                return res.status(400).json({ error: 'Email e senha são obrigatórios' });
            }

            // Buscar usuário
            const user = await User.findByEmail(email);
            if (!user) {
                return res.status(401).json({ error: 'Email ou senha incorretos' });
            }

            // Verificar senha
            const isPasswordValid = await User.verifyPassword(password, user.password);
            if (!isPasswordValid) {
                return res.status(401).json({ error: 'Email ou senha incorretos' });
            }

            // Gerar token
            const token = user.generateToken();

            res.json({
                message: 'Login realizado com sucesso',
                user: user.toJSON(),
                token
            });
        } catch (error) {
            console.error('Erro no login:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter perfil do usuário atual
    static async getProfile(req, res) {
        try {
            res.json({
                user: req.user.toJSON()
            });
        } catch (error) {
            console.error('Erro ao obter perfil:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Atualizar perfil
    static async updateProfile(req, res) {
        try {
            const allowedFields = ['name', 'bio', 'avatar'];
            const updateData = {};

            allowedFields.forEach(field => {
                if (req.body[field] !== undefined) {
                    updateData[field] = req.body[field];
                }
            });

            if (Object.keys(updateData).length === 0) {
                return res.status(400).json({ error: 'Nenhum campo para atualizar' });
            }

            const updatedUser = await req.user.update(updateData);

            res.json({
                message: 'Perfil atualizado com sucesso',
                user: updatedUser.toJSON()
            });
        } catch (error) {
            console.error('Erro ao atualizar perfil:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Logout (cliente deve remover o token)
    static async logout(req, res) {
        try {
            res.json({ message: 'Logout realizado com sucesso' });
        } catch (error) {
            console.error('Erro no logout:', error);
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }
}

module.exports = AuthController;
