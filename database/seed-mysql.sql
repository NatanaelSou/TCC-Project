-- Dados Iniciais para a Plataforma de Serviço de Conteúdo
-- Versão MySQL - Migrado do PostgreSQL
-- Este arquivo popula o banco com dados de exemplo

-- Limpar dados existentes para evitar conflitos
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM playlist_items;
DELETE FROM playlists;
DELETE FROM comments;
DELETE FROM content_reactions;
DELETE FROM subscriptions;
DELETE FROM content;
DELETE FROM creators;
DELETE FROM users;
DELETE FROM categories;
DELETE FROM payments;
DELETE FROM notifications;
SET FOREIGN_KEY_CHECKS = 1;

-- Inserir categorias padrão
INSERT INTO categories (id, name, description, icon_url) VALUES
(UUID(), 'Tecnologia', 'Conteúdo relacionado a tecnologia, programação e inovação', '/icons/tech.png'),
(UUID(), 'Entretenimento', 'Vídeos de entretenimento, música e cultura pop', '/icons/entertainment.png'),
(UUID(), 'Educação', 'Conteúdo educacional, tutoriais e cursos', '/icons/education.png'),
(UUID(), 'Culinária', 'Receitas, dicas de cozinha e gastronomia', '/icons/cooking.png'),
(UUID(), 'Esportes', 'Cobertura esportiva, análises e destaques', '/icons/sports.png'),
(UUID(), 'Viagem', 'Dicas de viagem, destinos e experiências', '/icons/travel.png'),
(UUID(), 'Ciência', 'Conteúdo científico, descobertas e explicações', '/icons/science.png'),
(UUID(), 'Música', 'Música, shows ao vivo e artistas', '/icons/music.png'),
(UUID(), 'Jogos', 'Games, reviews e gameplay', '/icons/gaming.png'),
(UUID(), 'Notícias', 'Notícias, atualidades e jornalismo', '/icons/news.png');

-- Inserir usuários de exemplo
INSERT INTO users (id, username, email, password_hash, full_name, bio, is_verified, is_creator) VALUES
(UUID(), 'admin', 'admin@plataforma.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador', 'Administrador da plataforma', true, false),
(UUID(), 'joao_silva', 'joao@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'João Silva', 'Desenvolvedor apaixonado por tecnologia', true, true),
(UUID(), 'maria_tech', 'maria@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Maria Tech', 'Especialista em React e Node.js', true, true),
(UUID(), 'carlos_games', 'carlos@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Carlos Games', 'Streamer e criador de conteúdo gamer', false, true),
(UUID(), 'ana_cozinha', 'ana@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ana Cozinha', 'Chef profissional compartilhando receitas deliciosas', true, true),
(UUID(), 'viewer1', 'viewer1@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Visualizador 1', 'Usuário comum da plataforma', false, false),
(UUID(), 'viewer2', 'viewer2@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Visualizador 2', 'Entusiasta de tecnologia', false, false);

-- Inserir criadores (perfis de criadores) - Usando IDs fixos para referência
INSERT INTO creators (id, user_id, channel_name, channel_description, subscriber_count, total_views, custom_url, is_monetized) VALUES
(UUID(), (SELECT id FROM users WHERE username = 'joao_silva'), 'João Dev', 'Canal sobre desenvolvimento web e programação', 15420, 1250000, 'joao-dev', true),
(UUID(), (SELECT id FROM users WHERE username = 'maria_tech'), 'Maria Tech Academy', 'Aprenda desenvolvimento frontend e backend', 8750, 890000, 'maria-tech', true),
(UUID(), (SELECT id FROM users WHERE username = 'carlos_games'), 'Carlos Games BR', 'Reviews de jogos e gameplay ao vivo', 45200, 3200000, 'carlos-games', true),
(UUID(), (SELECT id FROM users WHERE username = 'ana_cozinha'), 'Ana Receitas', 'Receitas fáceis e deliciosas para o dia a dia', 28900, 2100000, 'ana-receitas', true);

-- Inserir conteúdo de exemplo
INSERT INTO content (id, creator_id, title, description, video_url, thumbnail_url, duration, category_id, view_count, like_count, tags, is_featured) VALUES
(UUID(), (SELECT id FROM creators WHERE channel_name = 'João Dev'), 'Introdução ao React em 10 minutos', 'Aprenda os conceitos básicos do React de forma rápida e prática', '/videos/react-intro.mp4', '/thumbnails/react-intro.jpg', 600, (SELECT id FROM categories WHERE name = 'Tecnologia'), 15420, 1250, JSON_ARRAY('react', 'javascript', 'frontend'), true),
(UUID(), (SELECT id FROM creators WHERE channel_name = 'João Dev'), 'Node.js para Iniciantes', 'Curso completo de Node.js do zero', '/videos/nodejs-basics.mp4', '/thumbnails/nodejs-basics.jpg', 1800, (SELECT id FROM categories WHERE name = 'Tecnologia'), 8750, 890, JSON_ARRAY('nodejs', 'backend', 'javascript'), false),
(UUID(), (SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy'), 'CSS Grid vs Flexbox', 'Quando usar cada um e suas diferenças', '/videos/css-grid-flex.mp4', '/thumbnails/css-grid-flex.jpg', 900, (SELECT id FROM categories WHERE name = 'Tecnologia'), 12300, 1450, JSON_ARRAY('css', 'frontend', 'layout'), true),
(UUID(), (SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'), 'Review: The Last of Us Part II', 'Análise completa do jogo icônico', '/videos/tlou2-review.mp4', '/thumbnails/tlou2-review.jpg', 1200, (SELECT id FROM categories WHERE name = 'Jogos'), 45200, 3200, JSON_ARRAY('thelastofus', 'review', 'playstation'), true),
(UUID(), (SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'), 'Live: Fortnite Battle Royale', 'Jogando Fortnite com a comunidade', '/videos/fortnite-live.mp4', '/thumbnails/fortnite-live.jpg', 7200, (SELECT id FROM categories WHERE name = 'Jogos'), 28900, 2100, JSON_ARRAY('fortnite', 'live', 'gaming'), false),
(UUID(), (SELECT id FROM creators WHERE channel_name = 'Ana Receitas'), 'Bolo de Chocolate Fácil', 'Receita simples e deliciosa para bolo de chocolate', '/videos/bolo-chocolate.mp4', '/thumbnails/bolo-chocolate.jpg', 480, (SELECT id FROM categories WHERE name = 'Culinária'), 32100, 2800, JSON_ARRAY('bolo', 'chocolate', 'receita'), true),
(UUID(), (SELECT id FROM creators WHERE channel_name = 'Ana Receitas'), 'Macarrão à Carbonara', 'Receita italiana autêntica passo a passo', '/videos/carbonara.mp4', '/thumbnails/carbonara.jpg', 600, (SELECT id FROM categories WHERE name = 'Culinária'), 19800, 1650, JSON_ARRAY('macarrao', 'italiana', 'receita'), false),
(UUID(), (SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy'), 'Deploy no Heroku', 'Como fazer deploy de aplicações Node.js', '/videos/heroku-deploy.mp4', '/thumbnails/heroku-deploy.jpg', 720, (SELECT id FROM categories WHERE name = 'Tecnologia'), 9650, 780, JSON_ARRAY('heroku', 'deploy', 'nodejs'), false);

-- Inserir algumas inscrições de exemplo
INSERT INTO subscriptions (id, subscriber_id, creator_id) VALUES
(UUID(), (SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM creators WHERE channel_name = 'João Dev')),
(UUID(), (SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy')),
(UUID(), (SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM creators WHERE channel_name = 'Carlos Games BR')),
(UUID(), (SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM creators WHERE channel_name = 'Ana Receitas'));

-- Inserir algumas reações de exemplo
INSERT INTO content_reactions (id, user_id, content_id, reaction_type) VALUES
(UUID(), (SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title LIKE '%React%' LIMIT 1), 'like'),
(UUID(), (SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM content WHERE title LIKE '%React%' LIMIT 1), 'like'),
(UUID(), (SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title LIKE '%Node.js%' LIMIT 1), 'like');

-- Inserir alguns comentários de exemplo
INSERT INTO comments (id, user_id, content_id, comment_text) VALUES
(UUID(), (SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title LIKE '%React%' LIMIT 1), 'Excelente tutorial! Muito didático.'),
(UUID(), (SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM content WHERE title LIKE '%React%' LIMIT 1), 'Obrigado pelo conteúdo!'),
(UUID(), (SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title LIKE '%Node.js%' LIMIT 1), 'Perfeito para iniciantes!');

-- Atualizar contadores após inserção dos dados
-- Atualizar contadores de criadores
UPDATE creators
SET subscriber_count = COALESCE((
    SELECT COUNT(*) FROM subscriptions WHERE subscriptions.creator_id = creators.id
), 0);

-- Atualizar contadores de likes do conteúdo
UPDATE content
SET like_count = COALESCE((
    SELECT COUNT(*) FROM content_reactions
    WHERE content_reactions.content_id = content.id AND reaction_type = 'like'
), 0);

-- Atualizar contadores de dislikes do conteúdo
UPDATE content
SET dislike_count = COALESCE((
    SELECT COUNT(*) FROM content_reactions
    WHERE content_reactions.content_id = content.id AND reaction_type = 'dislike'
), 0);

-- Inicializar likes dos comentários
UPDATE comments SET like_count = 0;

-- Dados básicos inseridos com sucesso
-- As queries foram adaptadas para sintaxe MySQL
-- Contadores foram atualizados corretamente
