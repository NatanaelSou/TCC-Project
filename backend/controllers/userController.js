const db = require('../config/db');
const UserService = require('../services/userService');

// Lista todos os usuários
exports.getUsers = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT id, email, name FROM users');
    console.log('[UserController] Usuários encontrados:', rows);
    res.json(rows);
  } catch (err) {
    console.error('[UserController] Erro ao buscar usuários:', err);
    res.status(500).json({ error: err.message });
  }
};

// Registra um novo usuário
exports.registerUser = async (req, res) => {
  try {
    console.log('[UserController] Requisição de registro recebida:', req.body);
    const { email, password, name } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email e senha são obrigatórios' });
    }

    const user = await UserService.register(email, password, name || null);

    console.log('[UserController] Usuário registrado com sucesso:', user);
    res.status(201).json({ message: 'Usuário registrado com sucesso', user });
  } catch (err) {
    console.error('[UserController] Erro no registro:', err);
    if (err.code === 'ER_DUP_ENTRY') {
      res.status(409).json({ message: 'Email já cadastrado' });
    } else {
      res.status(500).json({ error: err.message });
    }
  }
};
