const profileService = require('../services/profileService');

exports.getProfileStats = async (req, res) => {
  const userId = req.params.userId;
  try {
    const stats = await profileService.getProfileStats(userId);
    res.json(stats);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar estatísticas do perfil' });
  }
};

exports.getSupportTiers = async (req, res) => {
  const userId = req.params.userId;
  try {
    const tiers = await profileService.getSupportTiers(userId);
    res.json(tiers);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar tiers de suporte' });
  }
};

exports.createSupportTier = async (req, res) => {
  const userId = req.params.userId;
  const tierData = req.body;
  try {
    const tier = await profileService.createSupportTier(userId, tierData);
    res.status(201).json(tier);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao criar tier de suporte' });
  }
};

exports.supportTier = async (req, res) => {
  const userId = req.params.userId;
  const tierId = req.body.tierId;
  try {
    await profileService.supportTier(userId, tierId);
    res.json({ message: 'Apoio realizado com sucesso' });
  } catch (err) {
    res.status(500).json({ message: 'Erro ao apoiar tier' });
  }
};

exports.toggleFollow = async (req, res) => {
  const followerId = req.body.followerId;
  const followedId = req.body.followedId;
  try {
    const isFollowing = await profileService.toggleFollow(followerId, followedId);
    res.json({ isFollowing });
  } catch (err) {
    res.status(500).json({ message: 'Erro ao alternar follow' });
  }
};

exports.getChannels = async (req, res) => {
  const userId = req.params.userId;
  try {
    const channels = await profileService.getChannels(userId);
    res.json(channels);
  } catch (err) {
    console.error('[ProfileController] Erro ao buscar canais:', err);
    res.status(500).json({ message: 'Erro ao buscar canais' });
  }
};
