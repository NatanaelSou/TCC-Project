const db = require('../config/db');

exports.checkLogin = async (email, password) => {
  console.log('[LoginService] Verificando login para:', email);

  const [rows] = await db.query(
    'SELECT * FROM users WHERE email = ? AND password = ?',
    [email, password]
  );

  console.log('[LoginService] Resultado da consulta:', rows);

  if (rows.length === 0) return null;
  return rows[0]; // Usuário encontrado
};
