const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Rota principal para listar usuários
router.get('/', userController.getUsers);

// Rota para registrar novo usuário
router.post('/register', userController.registerUser);

module.exports = router;
