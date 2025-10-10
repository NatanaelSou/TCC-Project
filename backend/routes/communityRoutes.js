const express = require('express');
const router = express.Router();
const communityController = require('../controllers/communityController');

// Rota para criar canal
router.post('/users/:userId/channels', communityController.createChannel);

// Rota para buscar canais acessíveis ao usuário
router.get('/users/:userId/channels', communityController.getChannels);

// Rota para juntar-se a um canal
router.post('/channels/:channelId/join/:userId', communityController.joinChannel);

// Rota para enviar mensagem em um canal
router.post('/channels/:channelId/messages/:userId', communityController.sendMessage);

// Rota para buscar mensagens de um canal
router.get('/channels/:channelId/messages', communityController.getMessages);

// Rota para criar post de mural em um canal
router.post('/channels/:channelId/posts/:userId', communityController.createMuralPost);

// Rota para buscar posts de mural de um canal
router.get('/channels/:channelId/posts', communityController.getMuralPosts);

module.exports = router;
