const express = require('express');
const router = express.Router();
const SubscriberController = require('../controllers/subscriberController');
const auth = require('../middleware/auth');
const { param, query } = require('express-validator');

// Middleware de autenticação para todas as rotas
router.use(auth);

// Validações
const paginationValidation = [
    query('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número inteiro positivo'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100')
];

const contentTypeValidation = [
    query('type').optional().isIn(['text', 'image', 'video', 'audio', 'live']).withMessage('Tipo de conteúdo inválido')
];

// Feed e conteúdo
router.get('/feed', [...paginationValidation, ...contentTypeValidation], SubscriberController.getFeed);
router.get('/content/premium', paginationValidation, SubscriberController.getPremiumContent);
router.get('/content/:contentId/access', [
    param('contentId').isInt().withMessage('ID do conteúdo deve ser um número inteiro')
], SubscriberController.checkContentAccess);

// Assinaturas
router.get('/subscriptions', SubscriberController.getSubscriptions);
router.get('/subscriptions/:id', [
    param('id').isInt().withMessage('ID da assinatura deve ser um número inteiro')
], SubscriberController.getSubscriptionDetails);
router.put('/subscriptions/:id/cancel', [
    param('id').isInt().withMessage('ID da assinatura deve ser um número inteiro')
], SubscriberController.cancelSubscription);
router.put('/subscriptions/:id/reactivate', [
    param('id').isInt().withMessage('ID da assinatura deve ser um número inteiro')
], SubscriberController.reactivateSubscription);

// Criadores
router.get('/creators/followed', SubscriberController.getFollowedCreators);
router.get('/creators/search', [
    query('query').notEmpty().withMessage('Parâmetro de busca é obrigatório'),
    query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limite deve ser entre 1 e 50')
], SubscriberController.searchCreators);

// Pagamentos
router.get('/payments', paginationValidation, SubscriberController.getPaymentHistory);

module.exports = router;
