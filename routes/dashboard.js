const express = require('express');
const router = express.Router();
const DashboardController = require('../controllers/dashboardController');
const auth = require('../middleware/auth');
const { body, param, query } = require('express-validator');

// Middleware de autenticação para todas as rotas
router.use(auth);

// Validações
const profileValidation = [
    body('display_name').optional().isLength({ min: 1, max: 100 }).withMessage('Nome de exibição deve ter entre 1 e 100 caracteres'),
    body('bio').optional().isLength({ max: 500 }).withMessage('Bio deve ter no máximo 500 caracteres'),
    body('website').optional().isURL().withMessage('Website deve ser uma URL válida'),
    body('social_links').optional().isObject().withMessage('Links sociais devem ser um objeto')
];

const contentQueryValidation = [
    query('page').optional().isInt({ min: 1 }).withMessage('Página deve ser um número inteiro positivo'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limite deve ser entre 1 e 100'),
    query('type').optional().isIn(['text', 'image', 'video', 'audio', 'live']).withMessage('Tipo inválido'),
    query('tier_id').optional().isInt().withMessage('ID do tier deve ser um número inteiro')
];

// Rotas do dashboard
router.get('/stats', DashboardController.getStats);
router.get('/content', contentQueryValidation, DashboardController.getContent);
router.get('/subscriptions', [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 }),
    query('status').optional().isIn(['active', 'cancelled', 'paused'])
], DashboardController.getSubscriptions);

// Perfil do criador
router.get('/profile', DashboardController.getProfile);
router.put('/profile', profileValidation, DashboardController.updateProfile);

// Notificações
router.get('/notifications', [
    query('unread_only').optional().isBoolean()
], DashboardController.getNotifications);
router.put('/notifications/:id/read', [
    param('id').isInt().withMessage('ID da notificação deve ser um número inteiro')
], DashboardController.markNotificationAsRead);

// Análises
router.get('/analytics/revenue', [
    query('period').optional().isInt({ min: 1, max: 365 }).withMessage('Período deve ser entre 1 e 365 dias')
], DashboardController.getRevenueAnalytics);

module.exports = router;
