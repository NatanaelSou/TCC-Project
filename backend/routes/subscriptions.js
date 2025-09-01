// Rotas para gerenciamento de inscrições (subscriptions)

const express = require('express');
const { Subscription, Creator, User } = require('../models');
const router = express.Router();

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token de acesso não fornecido' });

  const jwt = require('jsonwebtoken');
  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) return res.status(403).json({ error: 'Token inválido' });
    req.user = user;
    next();
  });
};

// POST /api/subscriptions - Inscrever usuário em um criador
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { creator_id } = req.body;
    if (!creator_id) {
      return res.status(400).json({ error: 'creator_id é obrigatório' });
    }

    // Verificar se criador existe
    const creator = await Creator.findById(creator_id);
    if (!creator) {
      return res.status(404).json({ error: 'Criador não encontrado' });
    }

    // Verificar se já está inscrito
    const existing = await Subscription.findBySubscriberAndCreator(req.user.id, creator_id);
    if (existing) {
      return res.status(409).json({ error: 'Já inscrito neste criador' });
    }

    // Criar inscrição
    const subscription = await Subscription.create({
      subscriber_id: req.user.id,
      creator_id
    });

    // Atualizar contador de inscritos
    await Creator.incrementSubscriberCount(creator_id);

    res.status(201).json({
      message: 'Inscrição realizada com sucesso',
      subscription
    });
  } catch (error) {
    console.error('Erro ao criar inscrição:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// DELETE /api/subscriptions/:id - Cancelar inscrição
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const subscription = await Subscription.findById(req.params.id);
    if (!subscription) {
      return res.status(404).json({ error: 'Inscrição não encontrada' });
    }

    if (subscription.subscriber_id !== req.user.id) {
      return res.status(403).json({ error: 'Você não tem permissão para cancelar esta inscrição' });
    }

    await Subscription.delete(req.params.id);

    // Atualizar contador de inscritos
    await Creator.decrementSubscriberCount(subscription.creator_id);

    res.json({ message: 'Inscrição cancelada com sucesso' });
  } catch (error) {
    console.error('Erro ao cancelar inscrição:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/subscriptions/my - Listar inscrições do usuário logado
router.get('/my', authenticateToken, async (req, res) => {
  try {
    const subscriptions = await Subscription.findBySubscriber(req.user.id);
    res.json({ subscriptions });
  } catch (error) {
    console.error('Erro ao listar inscrições:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;
