const express = require('express');
const router = express.Router();
const loginController = require('../controllers/loginController');

router.post('/', loginController.loginUser);

// Rota de debug para acesso sem credenciais (apenas para teste)
router.post('/debug', loginController.debugLogin);

module.exports = router;
