const express = require('express');
const mysql = require('mysql');
const cors = require('cors');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Servir arquivos estáticos da pasta root
app.use(express.static('root'));

// Conexão com MySQL (placeholder)
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '512200Balatro@',
  database: 'tcc_project'
});

db.connect((err) => {
  if (err) {
    console.error('Erro ao conectar ao MySQL:', err);
  } else {
    console.log('Conectado ao MySQL');
  }
});

// Rotas básicas
app.get('/', (req, res) => {
  res.send('API do Serviço de Conteúdo Premium');
});

// Endpoints da API

// Usuários
app.get('/api/users', (req, res) => {
  // Buscar usuários do banco
  db.query('SELECT * FROM users', (err, results) => {
    if (err) {
      res.status(500).json({ error: 'Erro ao buscar usuários' });
    } else {
      res.json(results);
    }
  });
});

app.post('/api/users', (req, res) => {
  const { name, email, password } = req.body;
  // Verificar se o email já está cadastrado
  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err) {
      res.status(500).json({ error: 'Erro ao verificar usuário' });
    } else if (results.length > 0) {
      // Email já cadastrado
      res.status(409).json({ error: 'Conta já cadastrada com este email' }); // Statement para conta já cadastrada
    } else {
      // Inserir usuário
      db.query('INSERT INTO users (name, email, password) VALUES (?, ?, ?)', [name, email, password], (err, result) => {
        if (err) {
          res.status(500).json({ error: 'Erro ao criar usuário' });
        } else {
          res.json({ id: result.insertId, message: 'Usuário criado' });
        }
      });
    }
  });
});

// Conteúdo
app.get('/api/content', (req, res) => {
  db.query('SELECT * FROM content', (err, results) => {
    if (err) {
      res.status(500).json({ error: 'Erro ao buscar conteúdo' });
    } else {
      res.json(results);
    }
  });
});

app.post('/api/content', (req, res) => {
  const { title, description, price, user_id } = req.body;
  db.query('INSERT INTO content (title, description, price, user_id) VALUES (?, ?, ?, ?)', [title, description, price, user_id], (err, result) => {
    if (err) {
      res.status(500).json({ error: 'Erro ao criar conteúdo' });
    } else {
      res.json({ id: result.insertId, message: 'Conteúdo criado' });
    }
  });
});

// Assinaturas
app.get('/api/subscriptions', (req, res) => {
  db.query('SELECT * FROM subscriptions', (err, results) => {
    if (err) {
      res.status(500).json({ error: 'Erro ao buscar assinaturas' });
    } else {
      res.json(results);
    }
  });
});

app.post('/api/subscriptions', (req, res) => {
  const { user_id, creator_id } = req.body;
  db.query('INSERT INTO subscriptions (user_id, creator_id) VALUES (?, ?)', [user_id, creator_id], (err, result) => {
    if (err) {
      res.status(500).json({ error: 'Erro ao criar assinatura' });
    } else {
      res.json({ id: result.insertId, message: 'Assinatura criada' });
    }
  });
});

// Iniciar servidor
app.listen(port, () => {
  console.log(`Servidor rodando em http://localhost:${port}`);
});
