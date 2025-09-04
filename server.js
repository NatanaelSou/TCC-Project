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
const paymentRoutes = require('./routes/payments');
const uploadRoutes = require('./routes/uploads');

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

// Conteúdo filtrado com paginação
app.get('/api/content/filtered', (req, res) => {
  const { page = 1, limit = 12, search = '', sortBy = 'newest' } = req.query;
  const offset = (page - 1) * limit;

  // Construir query base
  let query = 'SELECT * FROM content WHERE 1=1';
  let countQuery = 'SELECT COUNT(*) as total FROM content WHERE 1=1';
  const params = [];
  const countParams = [];

  // Adicionar filtro de busca
  if (search) {
    const searchCondition = ' (title LIKE ? OR description LIKE ?)';
    query += searchCondition;
    countQuery += searchCondition;
    const searchParam = `%${search}%`;
    params.push(searchParam, searchParam);
    countParams.push(searchParam, searchParam);
  }

  // Adicionar ordenação
  let orderBy = 'created_at DESC'; // newest
  switch (sortBy) {
    case 'oldest':
      orderBy = 'created_at ASC';
      break;
    case 'popular':
      orderBy = 'created_at DESC'; // TODO: implementar campo de popularidade
      break;
    case 'price_low':
      orderBy = 'price ASC';
      break;
    case 'price_high':
      orderBy = 'price DESC';
      break;
  }
  query += ` ORDER BY ${orderBy}`;

  // Adicionar paginação
  query += ' LIMIT ? OFFSET ?';
  params.push(parseInt(limit), offset);

  // Executar query de contagem
  db.query(countQuery, countParams, (countErr, countResults) => {
    if (countErr) {
      return res.status(500).json({ error: 'Erro ao contar conteúdo' });
    }

    const totalItems = countResults[0].total;
    const totalPages = Math.ceil(totalItems / limit);

    // Executar query principal
    db.query(query, params, (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Erro ao buscar conteúdo filtrado' });
      }

      res.json({
        content: results,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems,
          itemsPerPage: parseInt(limit),
          hasNextPage: page < totalPages,
          hasPrevPage: page > 1
        }
      });
    });
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

// Usar rotas de pagamentos
app.use('/api/payments', paymentRoutes);

// Usar rotas de upload
app.use('/api/uploads', uploadRoutes);

// Usar rotas de dashboard
const dashboardRoutes = require('./routes/dashboard');
app.use('/api/dashboard', dashboardRoutes);

// Usar rotas de assinante
const subscriberRoutes = require('./routes/subscriber');
app.use('/api/subscriber', subscriberRoutes);

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
