const communityService = require('../services/communityService');

exports.createChannel = async (req, res) => {
  const creatorId = req.params.userId;
  const channelData = req.body;
  try {
    const channel = await communityService.createChannel(creatorId, channelData);
    res.status(201).json(channel);
  } catch (err) {
    console.error('[CommunityController] Erro ao criar canal:', err);
    res.status(500).json({ message: 'Erro ao criar canal' });
  }
};

exports.getChannels = async (req, res) => {
  const userId = req.params.userId;
  try {
    const channels = await communityService.getChannels(userId);
    res.json(channels);
  } catch (err) {
    console.error('[CommunityController] Erro ao buscar canais:', err);
    res.status(500).json({ message: 'Erro ao buscar canais' });
  }
};

exports.joinChannel = async (req, res) => {
  const userId = req.params.userId;
  const channelId = req.params.channelId;
  try {
    await communityService.joinChannel(userId, channelId);
    res.json({ message: 'Ingresso no canal realizado com sucesso' });
  } catch (err) {
    console.error('[CommunityController] Erro ao juntar-se ao canal:', err);
    res.status(500).json({ message: err.message || 'Erro ao juntar-se ao canal' });
  }
};

exports.sendMessage = async (req, res) => {
  const senderId = req.params.userId;
  const channelId = req.params.channelId;
  const messageData = req.body;
  try {
    const message = await communityService.sendMessage(senderId, channelId, messageData);
    res.status(201).json(message);
  } catch (err) {
    console.error('[CommunityController] Erro ao enviar mensagem:', err);
    res.status(500).json({ message: err.message || 'Erro ao enviar mensagem' });
  }
};

exports.getMessages = async (req, res) => {
  const channelId = req.params.channelId;
  const limit = req.query.limit || 50;
  try {
    const messages = await communityService.getMessages(channelId, limit);
    res.json(messages);
  } catch (err) {
    console.error('[CommunityController] Erro ao buscar mensagens:', err);
    res.status(500).json({ message: 'Erro ao buscar mensagens' });
  }
};

exports.createMuralPost = async (req, res) => {
  const creatorId = req.params.userId;
  const channelId = req.params.channelId;
  const postData = req.body;
  try {
    const post = await communityService.createMuralPost(creatorId, channelId, postData);
    res.status(201).json(post);
  } catch (err) {
    console.error('[CommunityController] Erro ao criar post de mural:', err);
    res.status(500).json({ message: err.message || 'Erro ao criar post de mural' });
  }
};

exports.getMuralPosts = async (req, res) => {
  const channelId = req.params.channelId;
  try {
    const posts = await communityService.getMuralPosts(channelId);
    res.json(posts);
  } catch (err) {
    console.error('[CommunityController] Erro ao buscar posts de mural:', err);
    res.status(500).json({ message: 'Erro ao buscar posts de mural' });
  }
};
