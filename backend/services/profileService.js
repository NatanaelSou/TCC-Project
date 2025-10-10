const db = require('../config/db');

exports.getProfileStats = async (userId) => {
  console.log('[ProfileService] Buscando estatísticas do perfil:', userId);

  try {
    const [rows] = await db.query('SELECT * FROM profile_stats WHERE user_id = ?', [userId]);
    if (rows.length === 0) {
      // Criar estatísticas padrão se não existir
      await db.query('INSERT INTO profile_stats (user_id) VALUES (?)', [userId]);
      return { followers: 0, posts: 0, subscribers: 0, viewers: 0 };
    }
    return {
      followers: rows[0].followers,
      posts: rows[0].posts,
      subscribers: rows[0].subscribers,
      viewers: rows[0].viewers
    };
  } catch (err) {
    console.error('[ProfileService] Erro ao buscar estatísticas:', err);
    throw err;
  }
};

exports.updateProfileStats = async (userId, stats) => {
  console.log('[ProfileService] Atualizando estatísticas do perfil:', userId);

  try {
    await db.query(
      'UPDATE profile_stats SET followers = ?, posts = ?, subscribers = ?, viewers = ? WHERE user_id = ?',
      [stats.followers, stats.posts, stats.subscribers, stats.viewers, userId]
    );
    return true;
  } catch (err) {
    console.error('[ProfileService] Erro ao atualizar estatísticas:', err);
    throw err;
  }
};

exports.getSupportTiers = async (userId) => {
  console.log('[ProfileService] Buscando tiers de suporte:', userId);

  try {
    const [rows] = await db.query('SELECT * FROM support_tiers WHERE user_id = ? ORDER BY price ASC', [userId]);
    return rows.map(row => ({
      id: row.id,
      name: row.name,
      price: parseFloat(row.price),
      description: row.description,
      color: row.color,
      subscriberCount: row.subscriber_count
    }));
  } catch (err) {
    console.error('[ProfileService] Erro ao buscar tiers:', err);
    throw err;
  }
};

exports.createSupportTier = async (userId, tierData) => {
  console.log('[ProfileService] Criando tier de suporte:', tierData.name);

  try {
    const [result] = await db.query(
      'INSERT INTO support_tiers (user_id, name, price, description, color) VALUES (?, ?, ?, ?, ?)',
      [userId, tierData.name, tierData.price, tierData.description, tierData.color]
    );
    return { id: result.insertId, ...tierData };
  } catch (err) {
    console.error('[ProfileService] Erro ao criar tier:', err);
    throw err;
  }
};

exports.supportTier = async (userId, tierId) => {
  console.log('[ProfileService] Apoiar tier:', userId, tierId);

  try {
    // Verificar se já apoia
    const [existing] = await db.query('SELECT id FROM tier_supporters WHERE user_id = ? AND tier_id = ?', [userId, tierId]);
    if (existing.length > 0) {
      throw new Error('Usuário já apoia este tier');
    }

    // Adicionar apoio
    await db.query('INSERT INTO tier_supporters (user_id, tier_id) VALUES (?, ?)', [userId, tierId]);

    // Incrementar contador de apoiadores
    await db.query('UPDATE support_tiers SET subscriber_count = subscriber_count + 1 WHERE id = ?', [tierId]);

    return true;
  } catch (err) {
    console.error('[ProfileService] Erro ao apoiar tier:', err);
    throw err;
  }
};

exports.toggleFollow = async (followerId, followedId) => {
  console.log('[ProfileService] Toggle follow:', followerId, followedId);

  try {
    const [existing] = await db.query('SELECT id FROM followers WHERE follower_id = ? AND followed_id = ?', [followerId, followedId]);

    if (existing.length > 0) {
      // Deixar de seguir
      await db.query('DELETE FROM followers WHERE id = ?', [existing[0].id]);
      await db.query('UPDATE profile_stats SET followers = followers - 1 WHERE user_id = ?', [followedId]);
      return false; // Não está seguindo
    } else {
      // Seguir
      await db.query('INSERT INTO followers (follower_id, followed_id) VALUES (?, ?)', [followerId, followedId]);
      await db.query('UPDATE profile_stats SET followers = followers + 1 WHERE user_id = ?', [followedId]);
      return true; // Está seguindo
    }
  } catch (err) {
    console.error('[ProfileService] Erro no toggle follow:', err);
    throw err;
  }
};

exports.getChannels = async (userId) => {
  console.log('[ProfileService] Buscando canais do usuário:', userId);

  try {
    const [rows] = await db.query('SELECT * FROM channels WHERE creator_id = ? ORDER BY created_at DESC', [userId]);
    return rows.map(row => ({
      id: row.id,
      creatorId: row.creator_id,
      name: row.name,
      description: row.description,
      type: row.type,
      isPrivate: row.is_private,
      tierRequired: row.tier_required,
      members: JSON.parse(row.members || '[]'),
      createdAt: row.created_at
    }));
  } catch (err) {
    console.error('[ProfileService] Erro ao buscar canais:', err);
    throw err;
  }
};
