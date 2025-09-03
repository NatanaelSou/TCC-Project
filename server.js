const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});
const port = process.env.PORT || 3000;

// Importar rotas
const authRoutes = require('./routes/auth');
const creatorRoutes = require('./routes/creators');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir arquivos estáticos da pasta root
app.use(express.static('root'));
app.use('/uploads', express.static('public/uploads'));

// Conexão com MySQL
const db = require('./config/database');

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

// Usar rotas de autenticação
app.use('/api/auth', authRoutes);

// Usar rotas de criadores
app.use('/api/creators', creatorRoutes);

// Socket.io para funcionalidades em tempo real
io.on('connection', (socket) => {
  console.log('Novo cliente conectado:', socket.id);

  // Entrar em sala de criador
  socket.on('join-creator-room', (creatorId) => {
    socket.join(`creator-${creatorId}`);
    console.log(`Cliente ${socket.id} entrou na sala do criador ${creatorId}`);
  });

  // Entrar em transmissão ao vivo
  socket.on('join-live-stream', (streamId) => {
    socket.join(`stream-${streamId}`);
    console.log(`Cliente ${socket.id} entrou na transmissão ${streamId}`);
  });

  // Notificações em tempo real
  socket.on('send-notification', (data) => {
    io.to(`creator-${data.creatorId}`).emit('new-notification', data);
  });

  // Chat em tempo real
  socket.on('send-message', (data) => {
    io.to(`creator-${data.creatorId}`).emit('new-message', data);
  });

  socket.on('disconnect', () => {
    console.log('Cliente desconectado:', socket.id);
  });
});

// Iniciar servidor
server.listen(port, () => {
  console.log(`Servidor rodando em http://localhost:${port}`);
});
