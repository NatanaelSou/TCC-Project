const contentService = require('../services/contentService');

exports.getProfileContent = async (req, res) => {
  const userId = req.params.userId;
  const type = req.query.type || 'all';
  const limit = parseInt(req.query.limit) || 10;

  try {
    const content = await contentService.getProfileContent(userId, type, limit);
    res.json(content);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar conteúdo do perfil' });
  }
};

exports.createContent = async (req, res) => {
  const userId = req.params.userId;
  const contentData = req.body;

  try {
    const newContent = await contentService.createContent(userId, contentData);
    res.status(201).json(newContent);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao criar conteúdo' });
  }
};

exports.getComments = async (req, res) => {
  const contentId = req.params.contentId;

  try {
    const comments = await contentService.getCommentsForContent(contentId);
    res.json(comments);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar comentários' });
  }
};

exports.addComment = async (req, res) => {
  const contentId = req.params.contentId;
  const { userId, text } = req.body;

  try {
    const comment = await contentService.addComment(contentId, userId, text);
    res.status(201).json(comment);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao adicionar comentário' });
  }
};

exports.getSimilarVideos = async (req, res) => {
  const contentId = req.params.contentId;
  const categories = req.body.categories || [];

  try {
    const videos = await contentService.getSimilarVideos(contentId, categories);
    res.json(videos);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar vídeos similares' });
  }
};

exports.getRecommendations = async (req, res) => {
  const contentId = req.params.contentId;

  try {
    const recommendations = await contentService.getRecommendations(contentId);
    res.json(recommendations);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar recomendações' });
  }
};

exports.incrementViews = async (req, res) => {
  const contentId = req.params.contentId;

  try {
    await contentService.incrementViews(contentId);
    res.json({ message: 'Visualizações incrementadas' });
  } catch (err) {
    res.status(500).json({ message: 'Erro ao incrementar visualizações' });
  }
};
