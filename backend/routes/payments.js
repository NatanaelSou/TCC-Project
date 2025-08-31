// Rotas para gerenciamento de pagamentos

const express = require('express');
const { body, validationResult } = require('express-validator');
const { Payment, User } = require('../models');

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

// POST /api/payments - Criar novo pagamento
router.post('/', authenticateToken, [
  body('amount').isFloat({ min: 0.01 }),
  body('currency').isLength({ min: 3, max: 3 }),
  body('payment_type').isIn(['subscription', 'donation', 'purchase']),
  body('description').optional().isLength({ max: 255 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Dados de entrada inválidos',
        details: errors.array()
      });
    }

    const { amount, currency, payment_type, description } = req.body;

    const payment = await Payment.create({
      user_id: req.user.id,
      amount,
      currency: currency || 'BRL',
      payment_type,
      description: description || null
    });

    res.status(201).json({
      message: 'Pagamento criado com sucesso',
      payment
    });
  } catch (error) {
    console.error('Erro ao criar pagamento:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/payments/my - Listar pagamentos do usuário
router.get('/my', authenticateToken, async (req, res) => {
  try {
    const payments = await Payment.findByUser(req.user.id);
    res.json({ payments });
  } catch (error) {
    console.error('Erro ao listar pagamentos:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/payments/:id - Obter pagamento por ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id);
    if (!payment) {
      return res.status(404).json({ error: 'Pagamento não encontrado' });
    }

    if (payment.user_id !== req.user.id) {
      return res.status(403).json({ error: 'Você não tem permissão para acessar este pagamento' });
    }

    res.json({ payment });
  } catch (error) {
    console.error('Erro ao obter pagamento:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;
