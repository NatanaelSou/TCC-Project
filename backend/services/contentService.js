const db = require('../config/db');

exports.getProfileContent = async (userId, type, limit = 10) => {
  console.log('[ContentService] Buscando conteúdo do perfil:', userId, type);

  try {
    let query = 'SELECT * FROM content WHERE user_id = ?';
    let params = [userId];

    if (type !== 'all') {
      // Map plural types to singular
      let dbType = type;
      if (type === 'posts') dbType = 'post';
      else if (type === 'videos') dbType = 'video';
      else if (type === 'exclusive') dbType = 'exclusive';

      query += ' AND type = ?';
      params.push(dbType);
    }

    query += ' ORDER BY created_at DESC LIMIT ?';
    params.push(limit);

    const [rows] = await db.query(query, params);

    return rows.map(row => {
      return {
        id: row.id.toString(),
        title: row.title,
        type: row.type,
        thumbnailUrl: row.thumbnail_url,
        videoUrl: row.video_url,
        category: Array.isArray(row.category) ? row.category : [],
        tags: Array.isArray(row.tags) ? row.tags : [],
        duration: row.duration,
        views: row.views,
        createdAt: row.created_at
      };
    });
  } catch (err) {
    console.error('[ContentService] Erro ao buscar conteúdo:', err);
    throw err;
  }
};

exports.createContent = async (userId, contentData) => {
  console.log('[ContentService] Criando conteúdo:', contentData.title);

  try {
    const [result] = await db.query(
      'INSERT INTO content (user_id, title, type, thumbnail_url, video_url, category, tags, duration, tier_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        userId,
        contentData.title,
        contentData.type,
        contentData.thumbnailUrl,
        contentData.videoUrl,
        JSON.stringify(contentData.category || []),
        JSON.stringify(contentData.tags || []),
        contentData.duration,
        contentData.tierId
      ]
    );

    // Atualizar contador de posts no perfil
    await db.query('UPDATE profile_stats SET posts = posts + 1 WHERE user_id = ?', [userId]);

    return {
      id: result.insertId.toString(),
      ...contentData,
      createdAt: new Date()
    };
  } catch (err) {
    console.error('[ContentService] Erro ao criar conteúdo:', err);
    throw err;
  }
};

exports.getCommentsForContent = async (contentId) => {
  console.log('[ContentService] Buscando comentários:', contentId);

  try {
    const [rows] = await db.query(`
      SELECT c.*, u.name as user_name, u.avatar_url
      FROM comments c
      JOIN users u ON c.user_id = u.id
      WHERE c.content_id = ?
      ORDER BY c.created_at DESC
    `, [contentId]);

    return rows.map(row => ({
      id: row.id.toString(),
      contentId: row.content_id.toString(),
      userId: row.user_id.toString(),
      text: row.text,
      likes: row.likes,
      createdAt: row.created_at,
      userName: row.user_name,
      userAvatar: row.avatar_url
    }));
  } catch (err) {
    console.error('[ContentService] Erro ao buscar comentários:', err);
    throw err;
  }
};

exports.addComment = async (contentId, userId, text) => {
  console.log('[ContentService] Adicionando comentário:', contentId);

  try {
    const [result] = await db.query(
      'INSERT INTO comments (content_id, user_id, text) VALUES (?, ?, ?)',
      [contentId, userId, text]
    );

    return {
      id: result.insertId.toString(),
      contentId: contentId.toString(),
      userId: userId.toString(),
      text,
      likes: 0,
      createdAt: new Date()
    };
  } catch (err) {
    console.error('[ContentService] Erro ao adicionar comentário:', err);
    throw err;
  }
};

exports.getSimilarVideos = async (contentId, categories) => {
  console.log('[ContentService] Buscando vídeos similares:', contentId);

  try {
    // Buscar vídeos com categorias similares
    const [rows] = await db.query(`
      SELECT * FROM content
      WHERE type = 'video' AND id != ?
      AND JSON_OVERLAPS(category, ?)
      ORDER BY views DESC
      LIMIT 5
    `, [contentId, JSON.stringify(categories)]);

    return rows.map(row => ({
      id: row.id.toString(),
      title: row.title,
      type: row.type,
      thumbnailUrl: row.thumbnail_url,
      videoUrl: row.video_url,
      category: row.category ? JSON.parse(row.category) : [],
      tags: row.tags ? JSON.parse(row.tags) : [],
      duration: row.duration,
      views: row.views,
      createdAt: row.created_at
    }));
  } catch (err) {
    console.error('[ContentService] Erro ao buscar vídeos similares:', err);
    throw err;
  }
};

exports.getRecommendations = async (contentId) => {
  console.log('[ContentService] Buscando recomendações:', contentId);

  try {
    const [rows] = await db.query('SELECT * FROM recommendations WHERE content_id = ?', [contentId]);
    if (rows.length === 0) return [];

    const recommendedIds = JSON.parse(rows[0].recommended_content_ids);
    if (recommendedIds.length === 0) return [];

    const [contentRows] = await db.query(`SELECT * FROM content WHERE id IN (${recommendedIds.map(() => '?').join(',')})`, recommendedIds);

    return contentRows.map(row => ({
      id: row.id.toString(),
      title: row.title,
      type: row.type,
      thumbnailUrl: row.thumbnail_url,
      videoUrl: row.video_url,
      category: row.category ? JSON.parse(row.category) : [],
      tags: row.tags ? JSON.parse(row.tags) : [],
      duration: row.duration,
      views: row.views,
      createdAt: row.created_at
    }));
  } catch (err) {
    console.error('[ContentService] Erro ao buscar recomendações:', err);
    throw err;
  }
};

exports.incrementViews = async (contentId) => {
  console.log('[ContentService] Incrementando visualizações:', contentId);

  try {
    await db.query('UPDATE content SET views = views + 1 WHERE id = ?', [contentId]);
    return true;
  } catch (err) {
    console.error('[ContentService] Erro ao incrementar visualizações:', err);
    throw err;
  }
};
