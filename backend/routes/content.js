// Rotas para gerenciamento de conteúdo/vídeos
// Este arquivo define todas as rotas relacionadas ao conteúdo

const express = require('express');
const { body, validationResult } = require('express-validator');
const { Content, Creator } = require('../models');

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

// Middleware para verificar se usuário é criador
const requireCreator = async (req, res, next) => {
  try {
    const creator = await Creator.findByUserId(req.user.id);
    if (!creator) {
      return res.status(403).json({ error: 'Apenas criadores podem acessar esta funcionalidade' });
    }
    req.creator = creator;
    next();
  } catch (error) {
    console.error('Erro ao verificar criador:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
};

// POST /api/content - Criar novo conteúdo
router.post('/', authenticateToken, requireCreator, [
  body('title').isLength({ min: 1, max: 255 }),
  body('description').optional().isLength({ max: 5000 }),
  body('video_url').isURL(),
  body('thumbnail_url').optional().isURL(),
  body('category_id').isUUID(),
  body('tags').optional().isArray()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Dados de entrada inválidos',
        details: errors.array()
      });
    }

    const { title, description, video_url, thumbnail_url, category_id, tags } = req.body;

    const newContent = await Content.create({
      creator_id: req.creator.id,
      title,
      description: description || null,
      video_url,
      thumbnail_url: thumbnail_url || null,
      category_id,
      tags: tags || []
    });

    res.status(201).json({
      message: 'Conteúdo criado com sucesso',
      content: newContent
    });

  } catch (error) {
    console.error('Erro ao criar conteúdo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/content - Listar conteúdo (com filtros)
router.get('/', async (req, res) => {
  try {
    const { pool } = require('../config/database');
    let query = `
      SELECT c.*, cat.name as category_name, cr.channel_name, u.username, u.avatar_url
      FROM content c
      JOIN categories cat ON c.category_id = cat.id
      JOIN creators cr ON c.creator_id = cr.id
      JOIN users u ON cr.user_id = u.id
      WHERE c.is_published = true
    `;
    const params = [];
    let paramCount = 1;

    // Filtros
    if (req.query.category) {
      query += ` AND c.category_id = $${paramCount}`;
      params.push(req.query.category);
      paramCount++;
    }

    if (req.query.creator) {
      query += ` AND c.creator_id = $${paramCount}`;
      params.push(req.query.creator);
      paramCount++;
    }

    if (req.query.search) {
      query += ` AND (c.title ILIKE $${paramCount} OR c.description ILIKE $${paramCount})`;
      params.push(`%${req.query.search}%`);
      paramCount++;
    }

    // Ordenação
    const sortBy = req.query.sort || 'created_at';
    const sortOrder = req.query.order === 'asc' ? 'ASC' : 'DESC';
    query += ` ORDER BY c.${sortBy} ${sortOrder}`;

    // Paginação
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;
    query += ` LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);
    res.json({ content: result.rows });

  } catch (error) {
    console.error('Erro ao listar conteúdo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/content/featured - Conteúdo em destaque
router.get('/featured', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const featuredContent = await Content.findFeatured(limit);
    res.json({ content: featuredContent });

  } catch (error) {
    console.error('Erro ao obter conteúdo em destaque:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/content/:id - Obter conteúdo por ID
router.get('/:id', async (req, res) => {
  try {
    const content = await Content.findById(req.params.id);
    if (!content) {
      return res.status(404).json({ error: 'Conteúdo não encontrado' });
    }

    // Incrementar visualizações
    await Content.incrementViews(req.params.id);

    res.json({ content });

  } catch (error) {
    console.error('Erro ao obter conteúdo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// PUT /api/content/:id - Atualizar conteúdo
router.put('/:id', authenticateToken, requireCreator, [
  body('title').optional().isLength({ min: 1, max: 255 }),
  body('description').optional().isLength({ max: 5000 }),
  body('thumbnail_url').optional().isURL(),
  body('category_id').optional().isUUID(),
  body('tags').optional().isArray(),
  body('is_published').optional().isBoolean()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Dados de entrada inválidos',
        details: errors.array()
      });
    }

    // Verificar se o conteúdo pertence ao criador
    const content = await Content.findById(req.params.id);
    if (!content) {
      return res.status(404).json({ error: 'Conteúdo não encontrado' });
    }

    if (content.creator_id !== req.creator.id) {
      return res.status(403).json({ error: 'Você não tem permissão para editar este conteúdo' });
    }

    const { title, description, thumbnail_url, category_id, tags, is_published } = req.body;
    const updateData = {};

    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (thumbnail_url !== undefined) updateData.thumbnail_url = thumbnail_url;
    if (category_id !== undefined) updateData.category_id = category_id;
    if (tags !== undefined) updateData.tags = tags;
    if (is_published !== undefined) updateData.is_published = is_published;

    const updatedContent = await Content.update(req.params.id, updateData);
    res.json({
      message: 'Conteúdo atualizado com sucesso',
      content: updatedContent
    });

  } catch (error) {
    console.error('Erro ao atualizar conteúdo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// DELETE /api/content/:id - Deletar conteúdo
router.delete('/:id', authenticateToken, requireCreator, async (req, res) => {
  try {
    // Verificar se o conteúdo pertence ao criador
    const content = await Content.findById(req.params.id);
    if (!content) {
      return res.status(404).json({ error: 'Conteúdo não encontrado' });
    }

    if (content.creator_id !== req.creator.id) {
      return res.status(403).json({ error: 'Você não tem permissão para deletar este conteúdo' });
    }

    const deletedContent = await Content.delete(req.params.id);
    res.json({
      message: 'Conteúdo deletado com sucesso',
      content: deletedContent
    });

  } catch (error) {
    console.error('Erro ao deletar conteúdo:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/content/creator/:creatorId - Conteúdo de um criador específico
router.get('/creator/:creatorId', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;
    const content = await Content.findByCreator(req.params.creatorId, limit, offset);
    res.json({ content });

  } catch (error) {
    console.error('Erro ao obter conteúdo do criador:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// GET /api/content/category/:categoryId - Conteúdo por categoria
router.get('/category/:categoryId', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;
    const content = await Content.findByCategory(req.params.categoryId, limit, offset);
    res.json({ content });

  } catch (error) {
    console.error('Erro ao obter conteúdo por categoria:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;
