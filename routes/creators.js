const express = require('express');
const router = express.Router();
const CreatorController = require('../controllers/creatorController');
const { auth, requireCreator } = require('../middleware/auth');

// Todas as rotas requerem autenticação
router.use(auth);

// Tiers
router.post('/tiers', CreatorController.createTier);
router.get('/tiers', CreatorController.getTiers);
router.put('/tiers/:id', CreatorController.updateTier);
router.delete('/tiers/:id', CreatorController.deleteTier);

// Assinaturas
router.get('/subscriptions', CreatorController.getSubscriptions);

// Estatísticas
router.get('/stats', CreatorController.getStats);

// Conteúdo
router.post('/content', CreatorController.publishContent);
router.get('/content', CreatorController.getContent);
router.put('/content/:id', CreatorController.updateContent);
router.delete('/content/:id', CreatorController.deleteContent);

module.exports = router;
