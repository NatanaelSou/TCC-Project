const db = require('../config/db');

exports.createChannel = async (creatorId, channelData) => {
  console.log('[CommunityService] Criando canal:', channelData.name);

  try {
    const [result] = await db.query(
      'INSERT INTO channels (creator_id, name, description, type, is_private, tier_required) VALUES (?, ?, ?, ?, ?, ?)',
      [creatorId, channelData.name, channelData.description, channelData.type, channelData.isPrivate || false, channelData.tierRequired]
    );
    return { id: result.insertId, ...channelData, creatorId };
  } catch (err) {
    console.error('[CommunityService] Erro ao criar canal:', err);
    throw err;
  }
};

exports.getChannels = async (userId) => {
  console.log('[CommunityService] Buscando canais para usuário:', userId);

  try {
    // Buscar canais públicos ou onde o usuário é membro
    const [rows] = await db.query(
      'SELECT * FROM channels WHERE is_private = FALSE OR creator_id = ? OR JSON_CONTAINS(members, ?)',
      [userId, JSON.stringify(userId)]
    );
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
    console.error('[CommunityService] Erro ao buscar canais:', err);
    throw err;
  }
};

exports.joinChannel = async (userId, channelId) => {
  console.log('[CommunityService] Usuário juntando-se ao canal:', userId, channelId);

  try {
    // Verificar se canal existe e é acessível
    const [channels] = await db.query('SELECT * FROM channels WHERE id = ?', [channelId]);
    if (channels.length === 0) {
      throw new Error('Canal não encontrado');
    }
    const channel = channels[0];

    // Verificar acesso ao tier se privado
    if (channel.is_private && channel.tier_required) {
      const [supporters] = await db.query('SELECT id FROM tier_supporters WHERE user_id = ? AND tier_id = ?', [userId, channel.tier_required]);
      if (supporters.length === 0) {
        throw new Error('Acesso negado: tier necessário não suportado');
      }
    }

    // Adicionar usuário aos membros
    const members = JSON.parse(channel.members || '[]');
    if (!members.includes(userId)) {
      members.push(userId);
      await db.query('UPDATE channels SET members = ? WHERE id = ?', [JSON.stringify(members), channelId]);
    }

    return true;
  } catch (err) {
    console.error('[CommunityService] Erro ao juntar-se ao canal:', err);
    throw err;
  }
};

exports.sendMessage = async (senderId, channelId, messageData) => {
  console.log('[CommunityService] Enviando mensagem:', senderId, channelId);

  try {
    // Verificar acesso ao canal
    const [channels] = await db.query('SELECT * FROM channels WHERE id = ?', [channelId]);
    if (channels.length === 0) {
      throw new Error('Canal não encontrado');
    }
    const channel = channels[0];

    // Verificar se usuário é membro ou criador
    const members = JSON.parse(channel.members || '[]');
    if (channel.creator_id !== senderId && !members.includes(senderId)) {
      throw new Error('Acesso negado ao canal');
    }

    // Verificar tier se mensagem privada
    if (messageData.isPrivate && messageData.tierRequired) {
      const [supporters] = await db.query('SELECT id FROM tier_supporters WHERE user_id = ? AND tier_id = ?', [senderId, messageData.tierRequired]);
      if (supporters.length === 0) {
        throw new Error('Acesso negado: tier necessário não suportado');
      }
    }

    const [result] = await db.query(
      'INSERT INTO messages (sender_id, channel_id, text, is_private, tier_required) VALUES (?, ?, ?, ?, ?)',
      [senderId, channelId, messageData.text, messageData.isPrivate || false, messageData.tierRequired]
    );

    return {
      id: result.insertId,
      senderId,
      channelId,
      text: messageData.text,
      timestamp: new Date(),
      isPrivate: messageData.isPrivate || false,
      tierRequired: messageData.tierRequired
    };
  } catch (err) {
    console.error('[CommunityService] Erro ao enviar mensagem:', err);
    throw err;
  }
};

exports.getMessages = async (channelId, limit = 50) => {
  console.log('[CommunityService] Buscando mensagens do canal:', channelId);

  try {
    const [rows] = await db.query(
      'SELECT m.*, u.name as sender_name FROM messages m JOIN users u ON m.sender_id = u.id WHERE m.channel_id = ? ORDER BY m.timestamp DESC LIMIT ?',
      [channelId, limit]
    );
    return rows.map(row => ({
      id: row.id,
      senderId: row.sender_id,
      senderName: row.sender_name,
      channelId: row.channel_id,
      text: row.text,
      timestamp: row.timestamp,
      isPrivate: row.is_private,
      tierRequired: row.tier_required
    })).reverse(); // Ordem cronológica
  } catch (err) {
    console.error('[CommunityService] Erro ao buscar mensagens:', err);
    throw err;
  }
};

exports.createMuralPost = async (creatorId, channelId, postData) => {
  console.log('[CommunityService] Criando post de mural:', creatorId, channelId);

  try {
    // Verificar acesso ao canal
    const [channels] = await db.query('SELECT * FROM channels WHERE id = ?', [channelId]);
    if (channels.length === 0) {
      throw new Error('Canal não encontrado');
    }
    const channel = channels[0];

    // Verificar se usuário é membro ou criador
    const members = JSON.parse(channel.members || '[]');
    if (channel.creator_id !== creatorId && !members.includes(creatorId)) {
      throw new Error('Acesso negado ao canal');
    }

    // Verificar tier se post privado
    if (postData.isPrivate && postData.tierRequired) {
      const [supporters] = await db.query('SELECT id FROM tier_supporters WHERE user_id = ? AND tier_id = ?', [creatorId, postData.tierRequired]);
      if (supporters.length === 0) {
        throw new Error('Acesso negado: tier necessário não suportado');
      }
    }

    const [result] = await db.query(
      'INSERT INTO mural_posts (creator_id, channel_id, title, description, images, parent_id, is_private, tier_required) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [creatorId, channelId, postData.title, postData.description, JSON.stringify(postData.images || []), postData.parentId, postData.isPrivate || false, postData.tierRequired]
    );

    return {
      id: result.insertId,
      creatorId,
      channelId,
      title: postData.title,
      description: postData.description,
      images: postData.images || [],
      parentId: postData.parentId,
      createdAt: new Date(),
      likes: 0,
      replies: [],
      isPrivate: postData.isPrivate || false,
      tierRequired: postData.tierRequired
    };
  } catch (err) {
    console.error('[CommunityService] Erro ao criar post de mural:', err);
    throw err;
  }
};

exports.getMuralPosts = async (channelId) => {
  console.log('[CommunityService] Buscando posts de mural do canal:', channelId);

  try {
    const [rows] = await db.query(
      'SELECT mp.*, u.name as creator_name FROM mural_posts mp JOIN users u ON mp.creator_id = u.id WHERE mp.channel_id = ? ORDER BY mp.created_at DESC',
      [channelId]
    );
    return rows.map(row => ({
      id: row.id,
      creatorId: row.creator_id,
      creatorName: row.creator_name,
      channelId: row.channel_id,
      title: row.title,
      description: row.description,
      images: JSON.parse(row.images || '[]'),
      parentId: row.parent_id,
      createdAt: row.created_at,
      likes: row.likes,
      replies: JSON.parse(row.replies || '[]'),
      isPrivate: row.is_private,
      tierRequired: row.tier_required
    }));
  } catch (err) {
    console.error('[CommunityService] Erro ao buscar posts de mural:', err);
    throw err;
  }
};
