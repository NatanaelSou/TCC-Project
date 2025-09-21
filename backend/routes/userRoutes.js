const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Rota principal para listar usuários
router.get('/', userController.getUsers);

module.exports = router;