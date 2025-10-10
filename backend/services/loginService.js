const db = require('../config/db');
const bcrypt = require('bcrypt');

exports.checkLogin = async (email, password) => {
  console.log('[LoginService] Verificando login para:', email);

  const [rows] = await db.query(
    'SELECT * FROM users WHERE email = ?',
    [email]
  );

  console.log('[LoginService] Resultado da consulta:', rows.length > 0 ? 'Usuário encontrado' : 'Usuário não encontrado');

  if (rows.length === 0) return null;

  const user = rows[0];

  // Verificar senha
  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    console.log('[LoginService] Senha inválida');
    return null;
  }

  return user; // Usuário encontrado
};
