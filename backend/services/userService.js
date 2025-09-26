const db = require('../config/db');

exports.register = async (email, password, name) => {
  console.log('[UserService] Registrando usuário:', email);

  try {
    let query = 'INSERT INTO users (email, password';
    let values = [email, password];
    if (name !== null) {
      query += ', name';
      values.push(name);
    }
    query += ') VALUES (' + values.map(() => '?').join(', ') + ')';

    const [result] = await db.query(query, values);

    console.log('[UserService] Usuário registrado com ID:', result.insertId);

    // Return the created user
    return {
      id: result.insertId,
      email,
      name
    };
  } catch (err) {
    console.error('[UserService] Erro ao registrar usuário:', err);
    throw err;
  }
};
