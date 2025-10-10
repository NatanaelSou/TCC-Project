const db = require('../config/db');
const bcrypt = require('bcrypt');

exports.register = async (email, password, name) => {
  console.log('[UserService] Registrando usuário:', email);

  // Validações básicas
  if (!email || !password) {
    throw new Error('Email e senha são obrigatórios');
  }
  if (password.length < 6) {
    throw new Error('Senha deve ter pelo menos 6 caracteres');
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new Error('Email inválido');
  }

  try {
    // Hash da senha
    const hashedPassword = await bcrypt.hash(password, 10);

    let query = 'INSERT INTO users (email, password';
    let values = [email, hashedPassword];
    if (name !== null && name.trim() !== '') {
      query += ', name';
      values.push(name.trim());
    }
    query += ') VALUES (' + values.map(() => '?').join(', ') + ')';

    const [result] = await db.query(query, values);

    console.log('[UserService] Usuário registrado com ID:', result.insertId);

    // Return the created user
    return {
      id: result.insertId,
      email,
      name: name || null
    };
  } catch (err) {
    console.error('[UserService] Erro ao registrar usuário:', err);
    throw err;
  }
};
