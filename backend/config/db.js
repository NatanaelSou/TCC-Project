const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: '192.168.1.7',          // Coloque o IPv4 referente ao seu wifi* - use o comando `ipconfig` no terminal
  user: 'tcc_user',             // Coloque o usuário remoto do seu MySQL* - crie o usario remoto no MySQL via terminal
  password: 'sua_senha_forte',  // Coloque a senha do seu MySQL caso via root* - se nao coloque a senha do usuario remoto.
  database: 'tcc_project'
});

connection.connect(err => {
  if (err) throw err;
  console.log('Conectado ao MySQL');
});

module.exports = connection.promise();