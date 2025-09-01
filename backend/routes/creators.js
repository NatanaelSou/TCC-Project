// Rotas para gerenciamento de criadores de conteúdo
// Este arquivo define todas as rotas relacionadas aos criadores

const express = require('express');
const { body, validationResult } = require('express-validator');
const { Creator, User } = require('../models');

const router = express.Router();

// Middleware para verificar token JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token de acesso não fornecido' });
  }

  const jwt = require('jsonwebtoken');
  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Token inválido' });
    }
    req.user = user;
    next();
  });
};

// POST /api/creators/channel - Criar canal de criador
router.post('/channel', authenticateToken, [
  body('channel_name').isLength({ min: 3, max: 100 }),
  body('channel_description').optional().isLength({ max: 1000 }),
  body('custom_url').optional().matches(/^[a-zA-Z0-9_-]+$/)
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Dados de entrada inválidos',
        details: errors.array()
      });
    }

    const { channel_name, channel_description, custom_url } = req.body;
    const userId = req.user.id;

    // Verificar se usuário já é criador
    const existingCreator = await Creator.findByUserId(userId);
    if (existingCreator) {
      return res.status(409).json({ error: 'Usuário já possui um canal' });
    }

    // Criar canal
    const newCreator = await Creator.create({
      user_id: userId,
      channel_name,
      channel_description: channel_description || null,
      custom_url: custom_url || null
    });

    res.status(201).json({
      message: 'Canal criado com sucesso',
      creator: newCreator
    });

  } catch (error) {
    console.error('Erro ao criar canal:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/creators/my-channel - Obter canal do usuário logado
router.get('/my-channel', authenticateToken, async (req, res) => {
  try {
    const creator = await Creator.findByUserId(req.user.id);
    if (!creator) {
      return res.status(404).json({ error: 'Canal não encontrado' });
    }

    res.json({ creator });

  } catch (error) {
    console.error('Erro ao obter canal:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/creators/popular - Obter criadores populares
router.get('/popular', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const creators = await Creator.findPopular(limit);
    res.json({ creators });

  } catch (error) {
    console.error('Erro ao obter criadores populares:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/creators/:id - Obter criador por ID
router.get('/:id', async (req, res) => {
  try {
    const creator = await Creator.findById(req.params.id);
    if (!creator) {
      return res.status(404).json({ error: 'Criador não encontrado' });
    }

    // Obter informações do usuário associado
    const user = await User.findById(creator.user_id);
    const creatorWithUser = {
      ...creator,
      user: {
        username: user.username,
        avatar_url: user.avatar_url,
        is_verified: user.is_verified
      }
    };

    res.json({ creator: creatorWithUser });

  } catch (error) {
    console.error('Erro ao obter criador:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;
