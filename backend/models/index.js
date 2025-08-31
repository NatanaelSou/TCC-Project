// =====================================================================================
// MODELOS DE DADOS DA APLICAÇÃO
// =====================================================================================
// Este arquivo define e inicializa todos os modelos de dados da aplicação.
// Responsável por:
// - Implementar classe base com métodos CRUD comuns
// - Definir modelos específicos para cada entidade do sistema
// - Fornecer interface de acesso aos dados do PostgreSQL
// - Centralizar toda a lógica de acesso ao banco de dados

const { pool } = require('../config/database'); // Importar pool de conexões do banco

// =====================================================================================
// CLASSE BASE PARA MODELOS DE DADOS
// =====================================================================================
// Classe abstrata que fornece métodos CRUD (Create, Read, Update, Delete) comuns
// para todas as entidades do sistema. Esta classe é herdada por modelos específicos
// e implementa operações básicas de banco de dados de forma genérica e reutilizável.
class BaseModel {
  // Construtor da classe base
  // - Recebe o nome da tabela como parâmetro
  // - Armazena o nome da tabela para uso nos métodos CRUD
  constructor(tableName) {
    this.tableName = tableName; // Nome da tabela no banco de dados
  }

  // =====================================================================================
  // MÉTODOS CRUD BÁSICOS
  // =====================================================================================

  // Método para buscar um registro específico por ID
  // - Recebe o ID do registro como parâmetro
  // - Retorna o registro encontrado ou null se não existir
  // - Usa query parametrizada para prevenir SQL injection
  async findById(id) {
    try {
      const query = `SELECT * FROM ${this.tableName} WHERE id = $1`; // Query SQL parametrizada
      const result = await pool.query(query, [id]); // Executar query com parâmetro seguro
      return result.rows[0] || null; // Retornar primeiro resultado ou null
    } catch (error) {
      console.error(`Erro ao buscar ${this.tableName} por ID:`, error);
      throw error; // Re-throw para tratamento no nível superior
    }
  }

  // Método para buscar todos os registros com paginação
  // - Suporta paginação através de limit e offset
  // - Ordena resultados por data de criação (mais recentes primeiro)
  // - Retorna array de registros
  async findAll(limit = 100, offset = 0) {
    try {
      const query = `SELECT * FROM ${this.tableName} ORDER BY created_at DESC LIMIT $1 OFFSET $2`;
      const result = await pool.query(query, [limit, offset]);
      return result.rows; // Retornar todos os registros encontrados
    } catch (error) {
      console.error(`Erro ao buscar todos os ${this.tableName}:`, error);
      throw error;
    }
  }

  // Método para criar um novo registro
  // - Recebe objeto com dados do novo registro
  // - Constrói query INSERT dinamicamente baseada nas chaves do objeto
  // - Retorna o registro criado com todos os campos (incluindo ID gerado)
  async create(data) {
    try {
      const keys = Object.keys(data); // Extrair nomes das colunas
      const values = Object.values(data); // Extrair valores das colunas
      const placeholders = keys.map((_, index) => `$${index + 1}`); // Criar placeholders ($1, $2, etc.)

      // Construir query INSERT dinamicamente
      const query = `
        INSERT INTO ${this.tableName} (${keys.join(', ')})
        VALUES (${placeholders.join(', ')})
        RETURNING *
      `;

      const result = await pool.query(query, values);
      return result.rows[0]; // Retornar registro criado
    } catch (error) {
      console.error(`Erro ao criar ${this.tableName}:`, error);
      throw error;
    }
  }

  // Método para atualizar um registro existente
  // - Recebe ID do registro e objeto com dados atualizados
  // - Atualiza apenas os campos fornecidos
  // - Define automaticamente updated_at para timestamp atual
  // - Retorna registro atualizado ou null se não encontrado
  async update(id, data) {
    try {
      const keys = Object.keys(data); // Campos a serem atualizados
      const values = Object.values(data); // Novos valores
      const setClause = keys.map((key, index) => `${key} = $${index + 1}`).join(', '); // Cláusula SET

      // Query UPDATE com RETURNING para obter registro atualizado
      const query = `
        UPDATE ${this.tableName}
        SET ${setClause}, updated_at = CURRENT_TIMESTAMP
        WHERE id = $${keys.length + 1}
        RETURNING *
      `;

      const result = await pool.query(query, [...values, id]);
      return result.rows[0] || null; // Retornar registro atualizado ou null
    } catch (error) {
      console.error(`Erro ao atualizar ${this.tableName}:`, error);
      throw error;
    }
  }

  // Método para deletar um registro
  // - Recebe ID do registro a ser deletado
  // - Retorna registro deletado ou null se não encontrado
  // - Usa RETURNING para confirmar qual registro foi deletado
  async delete(id) {
    try {
      const query = `DELETE FROM ${this.tableName} WHERE id = $1 RETURNING *`;
      const result = await pool.query(query, [id]);
      return result.rows[0] || null; // Retornar registro deletado ou null
    } catch (error) {
      console.error(`Erro ao deletar ${this.tableName}:`, error);
      throw error;
    }
  }
}

// =====================================================================================
// MODELO DE USUÁRIO
// =====================================================================================
// Classe responsável por operações específicas relacionadas a usuários.
// Herda métodos CRUD básicos da BaseModel e adiciona métodos especializados
// para autenticação, busca por campos únicos e verificações de perfil.
class User extends BaseModel {
  // Construtor da classe User
  // - Define 'users' como nome da tabela
  // - Herda funcionalidades da BaseModel
  constructor() {
    super('users'); // Chamar construtor da classe pai
  }

  // =====================================================================================
  // MÉTODOS ESPECÍFICOS PARA USUÁRIOS
  // =====================================================================================

  // Método para buscar usuário por email (usado no login)
  // - Recebe email como parâmetro único
  // - Retorna usuário completo ou null se não encontrado
  // - Essencial para processo de autenticação
  async findByEmail(email) {
    try {
      const query = 'SELECT * FROM users WHERE email = $1'; // Query simples e direta
      const result = await pool.query(query, [email]);
      return result.rows[0] || null; // Retornar usuário ou null
    } catch (error) {
      console.error('Erro ao buscar usuário por email:', error);
      throw error; // Re-throw para tratamento superior
    }
  }

  // Método para buscar usuário por username (usado em perfis públicos)
  // - Recebe username como parâmetro único
  // - Retorna usuário completo ou null se não encontrado
  // - Usado para exibir perfis públicos e validação de unicidade
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

  // Método para verificar se um usuário é também um criador de conteúdo
  // - Recebe ID do usuário como parâmetro
  // - Retorna boolean indicando se o usuário tem perfil de criador
  // - Usa EXISTS para consulta eficiente (retorna apenas true/false)
  async isCreator(userId) {
    try {
      const query = 'SELECT EXISTS(SELECT 1 FROM creators WHERE user_id = $1)'; // Query otimizada
      const result = await pool.query(query, [userId]);
      return result.rows[0].exists; // Retornar boolean diretamente
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
