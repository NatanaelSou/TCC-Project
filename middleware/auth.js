const jwt = require('jsonwebtoken');
const User = require('../models/User');

const auth = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');

        if (!token) {
            return res.status(401).json({ error: 'Token de autenticação necessário' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        const user = await User.findById(decoded.id);

        if (!user) {
            return res.status(401).json({ error: 'Usuário não encontrado' });
        }

        req.user = user;
        req.token = token;
        next();
    } catch (error) {
        res.status(401).json({ error: 'Token inválido' });
    }
};

// Middleware para verificar se é criador
const requireCreator = (req, res, next) => {
    if (req.user.role !== 'creator') {
        return res.status(403).json({ error: 'Acesso negado. Apenas criadores podem acessar esta funcionalidade.' });
    }
    next();
};

// Middleware opcional para autenticação
const optionalAuth = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');

        if (token) {
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
            const user = await User.findById(decoded.id);
            if (user) {
                req.user = user;
                req.token = token;
            }
        }
        next();
    } catch (error) {
        next();
    }
};

module.exports = { auth, requireCreator, optionalAuth };
