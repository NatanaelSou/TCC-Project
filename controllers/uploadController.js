// Controlador para upload de arquivos
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const ffmpeg = require('ffmpeg-static');
const { spawn } = require('child_process');
const db = require('../config/database');

// Configurar multer para upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'public/uploads';

    // Criar diretório se não existir
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    // Criar subdiretórios por tipo
    const typeDir = path.join(uploadDir, getFileType(file.mimetype));
    if (!fs.existsSync(typeDir)) {
      fs.mkdirSync(typeDir, { recursive: true });
    }

    cb(null, typeDir);
  },
  filename: (req, file, cb) => {
    // Gerar nome único para o arquivo
    const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname);
    cb(null, uniqueName);
  }
});

// Filtros de arquivo
const fileFilter = (req, file, cb) => {
  const allowedTypes = {
    image: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
    video: ['video/mp4', 'video/avi', 'video/mov', 'video/wmv', 'video/flv'],
    audio: ['audio/mp3', 'audio/wav', 'audio/ogg', 'audio/m4a'],
    document: ['application/pdf', 'text/plain', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
  };

  const fileType = getFileType(file.mimetype);
  const isAllowed = allowedTypes[fileType] && allowedTypes[fileType].includes(file.mimetype);

  if (isAllowed) {
    cb(null, true);
  } else {
    cb(new Error(`Tipo de arquivo não permitido: ${file.mimetype}`), false);
  }
};

// Configuração do multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB
    files: 10 // Máximo 10 arquivos por vez
  }
});

// Função auxiliar para determinar tipo do arquivo
function getFileType(mimetype) {
  if (mimetype.startsWith('image/')) return 'images';
  if (mimetype.startsWith('video/')) return 'videos';
  if (mimetype.startsWith('audio/')) return 'audio';
  return 'documents';
}

// Upload de arquivo único
exports.uploadSingle = (req, res) => {
  const uploadSingle = upload.single('file');

  uploadSingle(req, res, async (err) => {
    if (err) {
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({ error: 'Arquivo muito grande. Máximo: 100MB' });
        }
        if (err.code === 'LIMIT_FILE_COUNT') {
          return res.status(400).json({ error: 'Muitos arquivos. Máximo: 10' });
        }
      }
      return res.status(400).json({ error: err.message });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'Nenhum arquivo enviado' });
    }

    try {
      // Processar arquivo (redimensionar imagem, converter vídeo, etc.)
      const processedFile = await processFile(req.file);

      // Salvar informações no banco
      const fileData = {
        original_name: req.file.originalname,
        filename: processedFile.filename,
        mimetype: req.file.mimetype,
        size: req.file.size,
        path: processedFile.path,
        type: getFileType(req.file.mimetype),
        user_id: req.user.id,
        processed: processedFile.processed
      };

      db.query('INSERT INTO uploads SET ?', fileData, (err, result) => {
        if (err) {
          console.error('Erro ao salvar upload:', err);
          return res.status(500).json({ error: 'Erro ao salvar arquivo' });
        }

        res.json({
          id: result.insertId,
          filename: processedFile.filename,
          path: processedFile.path,
          type: fileData.type,
          size: fileData.size,
          processed: processedFile.processed
        });
      });
    } catch (error) {
      console.error('Erro ao processar arquivo:', error);
      res.status(500).json({ error: 'Erro ao processar arquivo' });
    }
  });
};

// Upload múltiplo de arquivos
exports.uploadMultiple = (req, res) => {
  const uploadMultiple = upload.array('files', 10);

  uploadMultiple(req, res, async (err) => {
    if (err) {
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({ error: 'Um ou mais arquivos são muito grandes. Máximo: 100MB cada' });
        }
        if (err.code === 'LIMIT_FILE_COUNT') {
          return res.status(400).json({ error: 'Muitos arquivos. Máximo: 10' });
        }
      }
      return res.status(400).json({ error: err.message });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'Nenhum arquivo enviado' });
    }

    try {
      const results = [];

      for (const file of req.files) {
        // Processar cada arquivo
        const processedFile = await processFile(file);

        // Salvar informações no banco
        const fileData = {
          original_name: file.originalname,
          filename: processedFile.filename,
          mimetype: file.mimetype,
          size: file.size,
          path: processedFile.path,
          type: getFileType(file.mimetype),
          user_id: req.user.id,
          processed: processedFile.processed
        };

        const result = await new Promise((resolve, reject) => {
          db.query('INSERT INTO uploads SET ?', fileData, (err, result) => {
            if (err) reject(err);
            else resolve(result);
          });
        });

        results.push({
          id: result.insertId,
          filename: processedFile.filename,
          path: processedFile.path,
          type: fileData.type,
          size: fileData.size,
          processed: processedFile.processed
        });
      }

      res.json({
        message: `${results.length} arquivo(s) enviado(s) com sucesso`,
        files: results
      });
    } catch (error) {
      console.error('Erro ao processar arquivos:', error);
      res.status(500).json({ error: 'Erro ao processar arquivos' });
    }
  });
};

// Processar arquivo (redimensionar, converter, etc.)
async function processFile(file) {
  const fileType = getFileType(file.mimetype);
  const filePath = file.path;
  const fileDir = path.dirname(filePath);
  const fileName = path.basename(filePath, path.extname(filePath));

  let processed = false;
  let finalPath = filePath;

  try {
    if (fileType === 'images') {
      // Processar imagem
      const processedImagePath = path.join(fileDir, `${fileName}_processed${path.extname(filePath)}`);

      await sharp(filePath)
        .resize(1200, 1200, {
          fit: 'inside',
          withoutEnlargement: true
        })
        .jpeg({ quality: 85 })
        .toFile(processedImagePath);

      // Remover arquivo original e usar o processado
      fs.unlinkSync(filePath);
      finalPath = processedImagePath;
      processed = true;
    } else if (fileType === 'videos') {
      // Processar vídeo (converter para MP4 se necessário)
      if (path.extname(filePath).toLowerCase() !== '.mp4') {
        const processedVideoPath = path.join(fileDir, `${fileName}_processed.mp4`);

        await convertVideo(filePath, processedVideoPath);

        // Remover arquivo original e usar o processado
        fs.unlinkSync(filePath);
        finalPath = processedVideoPath;
        processed = true;
      }
    }
  } catch (error) {
    console.error('Erro ao processar arquivo:', error);
    // Se der erro no processamento, manter arquivo original
  }

  return {
    filename: path.basename(finalPath),
    path: finalPath.replace('public/', ''),
    processed: processed
  };
}

// Converter vídeo usando FFmpeg
function convertVideo(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const ffmpegProcess = spawn(ffmpeg, [
      '-i', inputPath,
      '-c:v', 'libx264',
      '-preset', 'medium',
      '-crf', '23',
      '-c:a', 'aac',
      '-b:a', '128k',
      '-movflags', '+faststart',
      '-y',
      outputPath
    ]);

    ffmpegProcess.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`FFmpeg process exited with code ${code}`));
      }
    });

    ffmpegProcess.on('error', (error) => {
      reject(error);
    });
  });
}

// Listar uploads do usuário
exports.getUserUploads = (req, res) => {
  const userId = req.user.id;
  const { type, page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;

  let query = 'SELECT * FROM uploads WHERE user_id = ?';
  let countQuery = 'SELECT COUNT(*) as total FROM uploads WHERE user_id = ?';
  const params = [userId];
  const countParams = [userId];

  if (type) {
    query += ' AND type = ?';
    countQuery += ' AND type = ?';
    params.push(type);
    countParams.push(type);
  }

  query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
  params.push(parseInt(limit), offset);

  // Buscar total
  db.query(countQuery, countParams, (countErr, countResults) => {
    if (countErr) {
      return res.status(500).json({ error: 'Erro ao contar uploads' });
    }

    const totalItems = countResults[0].total;
    const totalPages = Math.ceil(totalItems / limit);

    // Buscar uploads
    db.query(query, params, (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Erro ao buscar uploads' });
      }

      res.json({
        uploads: results,
        pagination: {
          currentPage: parseInt(page),
          totalPages,
          totalItems,
          itemsPerPage: parseInt(limit),
          hasNextPage: page < totalPages,
          hasPrevPage: page > 1
        }
      });
    });
  });
};

// Deletar upload
exports.deleteUpload = (req, res) => {
  const { id } = req.params;
  const userId = req.user.id;

  // Verificar se o upload pertence ao usuário
  db.query('SELECT * FROM uploads WHERE id = ? AND user_id = ?', [id, userId], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Erro ao buscar upload' });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'Upload não encontrado' });
    }

    const upload = results[0];

    // Deletar arquivo do sistema
    const filePath = path.join('public', upload.path);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    // Deletar do banco
    db.query('DELETE FROM uploads WHERE id = ?', [id], (err, result) => {
      if (err) {
        return res.status(500).json({ error: 'Erro ao deletar upload' });
      }

      res.json({ message: 'Upload deletado com sucesso' });
    });
  });
};

// Obter estatísticas de upload
exports.getUploadStats = (req, res) => {
  const userId = req.user.id;

  const queries = [
    'SELECT COUNT(*) as total_uploads FROM uploads WHERE user_id = ?',
    'SELECT SUM(size) as total_size FROM uploads WHERE user_id = ?',
    'SELECT type, COUNT(*) as count FROM uploads WHERE user_id = ? GROUP BY type'
  ];

  Promise.all(
    queries.map(query => new Promise((resolve, reject) => {
      db.query(query, [userId], (err, results) => {
        if (err) reject(err);
        else resolve(results);
      });
    }))
  ).then(([totalResult, sizeResult, typeResult]) => {
    res.json({
      total_uploads: totalResult[0].total_uploads,
      total_size: sizeResult[0].total_size || 0,
      by_type: typeResult
    });
  }).catch(error => {
    console.error('Erro ao buscar estatísticas:', error);
    res.status(500).json({ error: 'Erro ao buscar estatísticas' });
  });
};
