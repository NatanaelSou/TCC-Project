// Arquivo de inicialização dos modelos de dados
// Este arquivo importa e exporta todos os modelos da aplicação

const { pool } = require('../config/database');

// Modelo base com métodos comuns
class BaseModel {
  constructor(tableName) {
    this.tableName = tableName;
  }

  // Método para encontrar por ID
  async findById(id) {
    try {
      const query = `SELECT * FROM ${this.tableName} WHERE id = $1`;
      const result = await pool.query(query, [id]);
      return result.rows[0] || null;
    } catch (error) {
      console.error(`Erro ao buscar ${this.tableName} por ID:`, error);
      throw error;
    }
  }

  // Método para encontrar todos
  async findAll(limit = 100, offset = 0) {
    try {
      const query = `SELECT * FROM ${this.tableName} ORDER BY created_at DESC LIMIT $1 OFFSET $2`;
      const result = await pool.query(query, [limit, offset]);
      return result.rows;
    } catch (error) {
      console.error(`Erro ao buscar todos os ${this.tableName}:`, error);
      throw error;
    }
  }

  // Método para criar novo registro
  async create(data) {
    try {
      const keys = Object.keys(data);
      const values = Object.values(data);
      const placeholders = keys.map((_, index) => `$${index + 1}`);

      const query = `
        INSERT INTO ${this.tableName} (${keys.join(', ')})
        VALUES (${placeholders.join(', ')})
        RETURNING *
      `;

      const result = await pool.query(query, values);
      return result.rows[0];
    } catch (error) {
      console.error(`Erro ao criar ${this.tableName}:`, error);
      throw error;
    }
  }

  // Método para atualizar registro
  async update(id, data) {
    try {
      const keys = Object.keys(data);
      const values = Object.values(data);
      const setClause = keys.map((key, index) => `${key} = $${index + 1}`).join(', ');

      const query = `
        UPDATE ${this.tableName}
        SET ${setClause}, updated_at = CURRENT_TIMESTAMP
        WHERE id = $${keys.length + 1}
        RETURNING *
      `;

      const result = await pool.query(query, [...values, id]);
      return result.rows[0] || null;
    } catch (error) {
      console.error(`Erro ao atualizar ${this.tableName}:`, error);
      throw error;
    }
  }

  // Método para deletar registro
  async delete(id) {
    try {
      const query = `DELETE FROM ${this.tableName} WHERE id = $1 RETURNING *`;
      const result = await pool.query(query, [id]);
      return result.rows[0] || null;
    } catch (error) {
      console.error(`Erro ao deletar ${this.tableName}:`, error);
      throw error;
    }
  }
}

// Modelo de Usuário
class User extends BaseModel {
  constructor() {
    super('users');
  }

  // Buscar usuário por email
  async findByEmail(email) {
    try {
      const query = 'SELECT * FROM users WHERE email = $1';
      const result = await pool.query(query, [email]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Erro ao buscar usuário por email:', error);
      throw error;
    }
  }

  // Buscar usuário por username
  async findByUsername(username) {
    try {
      const query = 'SELECT * FROM users WHERE username = $1';
      const result = await pool.query(query, [username]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Erro ao buscar usuário por username:', error);
      throw error;
    }
  }

  // Verificar se usuário é criador
  async isCreator(userId) {
    try {
      const query = 'SELECT EXISTS(SELECT 1 FROM creators WHERE user_id = $1)';
      const result = await pool.query(query, [userId]);
      return result.rows[0].exists;
    } catch (error) {
      console.error('Erro ao verificar se usuário é criador:', error);
      throw error;
    }
  }
}

// Modelo de Criador
class Creator extends BaseModel {
  constructor() {
    super('creators');
  }

  // Buscar criador por user_id
  async findByUserId(userId) {
    try {
      const query = 'SELECT * FROM creators WHERE user_id = $1';
      const result = await pool.query(query, [userId]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Erro ao buscar criador por user_id:', error);
      throw error;
    }
  }

  // Buscar criadores populares
  async findPopular(limit = 10) {
    try {
      const query = `
        SELECT c.*, u.username, u.avatar_url
        FROM creators c
        JOIN users u ON c.user_id = u.id
        ORDER BY c.subscriber_count DESC
        LIMIT $1
      `;
      const result = await pool.query(query, [limit]);
      return result.rows;
    } catch (error) {
      console.error('Erro ao buscar criadores populares:', error);
      throw error;
    }
  }
}

// Modelo de Conteúdo
class Content extends BaseModel {
  constructor() {
    super('content');
  }

  // Buscar conteúdo por criador
  async findByCreator(creatorId, limit = 20, offset = 0) {
    try {
      const query = `
        SELECT c.*, cat.name as category_name, cr.channel_name
        FROM content c
        JOIN categories cat ON c.category_id = cat.id
        JOIN creators cr ON c.creator_id = cr.id
        WHERE c.creator_id = $1
        ORDER BY c.created_at DESC
        LIMIT $2 OFFSET $3
      `;
      const result = await pool.query(query, [creatorId, limit, offset]);
      return result.rows;
    } catch (error) {
      console.error('Erro ao buscar conteúdo por criador:', error);
      throw error;
    }
  }

  // Buscar conteúdo por categoria
  async findByCategory(categoryId, limit = 20, offset = 0) {
    try {
      const query = `
        SELECT c.*, cat.name as category_name, cr.channel_name
        FROM content c
        JOIN categories cat ON c.category_id = cat.id
        JOIN creators cr ON c.creator_id = cr.id
        WHERE c.category_id = $1
        ORDER BY c.created_at DESC
        LIMIT $2 OFFSET $3
      `;
      const result = await pool.query(query, [categoryId, limit, offset]);
      return result.rows;
    } catch (error) {
      console.error('Erro ao buscar conteúdo por categoria:', error);
      throw error;
    }
  }

  // Buscar conteúdo em destaque
  async findFeatured(limit = 10) {
    try {
      const query = `
        SELECT c.*, cat.name as category_name, cr.channel_name
        FROM content c
        JOIN categories cat ON c.category_id = cat.id
        JOIN creators cr ON c.creator_id = cr.id
        WHERE c.is_featured = true AND c.is_published = true
        ORDER BY c.created_at DESC
        LIMIT $1
      `;
      const result = await pool.query(query, [limit]);
      return result.rows;
    } catch (error) {
      console.error('Erro ao buscar conteúdo em destaque:', error);
      throw error;
    }
  }

  // Incrementar visualizações
  async incrementViews(contentId) {
    try {
      const query = `
        UPDATE content
        SET view_count = view_count + 1
        WHERE id = $1
        RETURNING view_count
      `;
      const result = await pool.query(query, [contentId]);
      return result.rows[0];
    } catch (error) {
      console.error('Erro ao incrementar visualizações:', error);
      throw error;
    }
  }
}

// Modelo de Inscrições
class Subscription extends BaseModel {
  constructor() {
    super('subscriptions');
  }

  // Buscar inscrições por assinante
  async findBySubscriber(subscriberId) {
    try {
      const query = `
        SELECT s.*, c.channel_name, c.custom_url, u.username
        FROM subscriptions s
        JOIN creators c ON s.creator_id = c.id
        JOIN users u ON c.user_id = u.id
        WHERE s.subscriber_id = $1
        ORDER BY s.subscribed_at DESC
      `;
      const result = await pool.query(query, [subscriberId]);
      return result.rows;
    } catch (error) {
      console.error('Erro ao buscar inscrições por assinante:', error);
      throw error;
    }
  }

  // Buscar inscrição específica
  async findBySubscriberAndCreator(subscriberId, creatorId) {
    try {
      const query = 'SELECT * FROM subscriptions WHERE subscriber_id = $1 AND creator_id = $2';
      const result = await pool.query(query, [subscriberId, creatorId]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Erro ao buscar inscrição específica:', error);
      throw error;
    }
  }
}

// Modelo de Pagamentos
class Payment extends BaseModel {
  constructor() {
    super('payments');
  }

  // Buscar pagamentos por usuário
  async findByUser(userId) {
    try {
      const query = 'SELECT * FROM payments WHERE user_id = $1 ORDER BY created_at DESC';
      const result = await pool.query(query, [userId]);
      return result.rows;
    } catch (error) {
      console.error('Erro ao buscar pagamentos por usuário:', error);
      throw error;
    }
  }
}

// Instâncias dos modelos
const userModel = new User();
const creatorModel = new Creator();
const contentModel = new Content();
const subscriptionModel = new Subscription();
const paymentModel = new Payment();

module.exports = {
  User: userModel,
  Creator: creatorModel,
  Content: contentModel,
  Subscription: subscriptionModel,
  Payment: paymentModel,
  BaseModel
};
