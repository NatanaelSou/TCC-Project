const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');

// Rota para buscar estatísticas do perfil
router.get('/:userId/stats', profileController.getProfileStats);

// Rota para buscar tiers de suporte
router.get('/:userId/tiers', profileController.getSupportTiers);

// Rota para criar tier de suporte
router.post('/:userId/tiers', profileController.createSupportTier);

// Rota para apoiar um tier
router.post('/:userId/support', profileController.supportTier);

// Rota para seguir/deixar de seguir
router.post('/follow', profileController.toggleFollow);

module.exports = router;
