// Rotas para processamento de pagamentos
const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const auth = require('../middleware/auth');

// Rotas protegidas (requerem autenticação)
router.post('/mercadopago', auth, paymentController.createMercadoPagoPreference);
router.post('/paypal', auth, paymentController.createPayPalPayment);
router.post('/paypal/execute', auth, paymentController.executePayPalPayment);
router.get('/user', auth, paymentController.getUserPayments);
router.get('/creator', auth, paymentController.getCreatorPayments);

// Webhooks (não requerem autenticação)
router.post('/webhook/mercadopago', paymentController.handleMercadoPagoWebhook);

module.exports = router;
