const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'passnat',
  database: 'flutter_app'
});

connection.connect(err => {
  if (err) throw err;
  console.log('Conectado ao MySQL');
});

module.exports = connection.promise();