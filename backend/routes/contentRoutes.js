const express = require('express');
const router = express.Router();
const contentController = require('../controllers/contentController');

// Rota para buscar conteúdo do perfil
router.get('/:userId', contentController.getProfileContent);

// Rota para criar conteúdo
router.post('/:userId', contentController.createContent);

// Rota para buscar comentários de um conteúdo
router.get('/:contentId/comments', contentController.getComments);

// Rota para adicionar comentário
router.post('/:contentId/comments', contentController.addComment);

// Rota para buscar vídeos similares
router.post('/:contentId/similar', contentController.getSimilarVideos);

// Rota para buscar recomendações
router.get('/:contentId/recommendations', contentController.getRecommendations);

// Rota para incrementar visualizações
router.post('/:contentId/views', contentController.incrementViews);

module.exports = router;
