// Rotas para upload de arquivos
const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const auth = require('../middleware/auth');

// Rotas protegidas (requerem autenticação)
router.post('/single', auth, uploadController.uploadSingle);
router.post('/multiple', auth, uploadController.uploadMultiple);
router.get('/user', auth, uploadController.getUserUploads);
router.delete('/:id', auth, uploadController.deleteUpload);
router.get('/stats', auth, uploadController.getUploadStats);

module.exports = router;
