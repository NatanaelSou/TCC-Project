const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '512200Balatro@',
  database: 'tcc_project'
});

connection.connect(err => {
  if (err) throw err;
  console.log('Conectado ao MySQL');
});

module.exports = connection.promise();