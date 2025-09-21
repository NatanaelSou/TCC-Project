const db = require('../config/db');

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
