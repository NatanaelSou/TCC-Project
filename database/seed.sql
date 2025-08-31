-- Dados Iniciais para a Plataforma de Serviço de Conteúdo
-- Este arquivo popula o banco com dados de exemplo

-- Limpar dados existentes para evitar conflitos
DELETE FROM playlist_items;
DELETE FROM playlists;
DELETE FROM comments;
DELETE FROM content_reactions;
DELETE FROM subscriptions;
DELETE FROM content;
DELETE FROM creators;
DELETE FROM users;
DELETE FROM categories;

-- Inserir categorias padrão
INSERT INTO categories (id, name, description, icon_url) VALUES
(uuid_generate_v4(), 'Tecnologia', 'Conteúdo relacionado a tecnologia, programação e inovação', '/icons/tech.png'),
(uuid_generate_v4(), 'Entretenimento', 'Vídeos de entretenimento, música e cultura pop', '/icons/entertainment.png'),
(uuid_generate_v4(), 'Educação', 'Conteúdo educacional, tutoriais e cursos', '/icons/education.png'),
(uuid_generate_v4(), 'Culinária', 'Receitas, dicas de cozinha e gastronomia', '/icons/cooking.png'),
(uuid_generate_v4(), 'Esportes', 'Cobertura esportiva, análises e destaques', '/icons/sports.png'),
(uuid_generate_v4(), 'Viagem', 'Dicas de viagem, destinos e experiências', '/icons/travel.png'),
(uuid_generate_v4(), 'Ciência', 'Conteúdo científico, descobertas e explicações', '/icons/science.png'),
(uuid_generate_v4(), 'Música', 'Música, shows ao vivo e artistas', '/icons/music.png'),
(uuid_generate_v4(), 'Jogos', 'Games, reviews e gameplay', '/icons/gaming.png'),
(uuid_generate_v4(), 'Notícias', 'Notícias, atualidades e jornalismo', '/icons/news.png');

-- Inserir usuários de exemplo
INSERT INTO users (id, username, email, password_hash, full_name, bio, is_verified, is_creator) VALUES
(uuid_generate_v4(), 'admin', 'admin@plataforma.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador', 'Administrador da plataforma', true, false),
(uuid_generate_v4(), 'joao_silva', 'joao@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'João Silva', 'Desenvolvedor apaixonado por tecnologia', true, true),
(uuid_generate_v4(), 'maria_tech', 'maria@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Maria Tech', 'Especialista em React e Node.js', true, true),
(uuid_generate_v4(), 'carlos_games', 'carlos@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Carlos Games', 'Streamer e criador de conteúdo gamer', false, true),
(uuid_generate_v4(), 'ana_cozinha', 'ana@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ana Cozinha', 'Chef profissional compartilhando receitas deliciosas', true, true),
(uuid_generate_v4(), 'viewer1', 'viewer1@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Visualizador 1', 'Usuário comum da plataforma', false, false),
(uuid_generate_v4(), 'viewer2', 'viewer2@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Visualizador 2', 'Entusiasta de tecnologia', false, false)
ON CONFLICT (username) DO NOTHING;

-- Inserir criadores (perfis de criadores) - IDs fixos para evitar subconsultas
INSERT INTO creators (id, user_id, channel_name, channel_description, subscriber_count, total_views, custom_url, is_monetized) VALUES
(uuid_generate_v4(), (SELECT id FROM users WHERE username = 'joao_silva'), 'João Dev', 'Canal sobre desenvolvimento web e programação', 15420, 1250000, 'joao-dev', true),
(uuid_generate_v4(), (SELECT id FROM users WHERE username = 'maria_tech'), 'Maria Tech Academy', 'Aprenda desenvolvimento frontend e backend', 8750, 890000, 'maria-tech', true),
(uuid_generate_v4(), (SELECT id FROM users WHERE username = 'carlos_games'), 'Carlos Games BR', 'Reviews de jogos e gameplay ao vivo', 45200, 3200000, 'carlos-games', true),
(uuid_generate_v4(), (SELECT id FROM users WHERE username = 'ana_cozinha'), 'Ana Receitas', 'Receitas fáceis e deliciosas para o dia a dia', 28900, 2100000, 'ana-receitas', true)
ON CONFLICT DO NOTHING;

-- Inserir conteúdo de exemplo - IDs fixos para evitar subconsultas
INSERT INTO content (id, creator_id, title, description, video_url, thumbnail_url, duration, category_id, view_count, like_count, tags, is_featured) VALUES
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'João Dev'), 'Introdução ao React em 10 minutos', 'Aprenda os conceitos básicos do React de forma rápida e prática', '/videos/react-intro.mp4', '/thumbnails/react-intro.jpg', 600, (SELECT id FROM categories WHERE name = 'Tecnologia'), 15420, 1250, ARRAY['react', 'javascript', 'frontend'], true),
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'João Dev'), 'Node.js para Iniciantes', 'Curso completo de Node.js do zero', '/videos/nodejs-basics.mp4', '/thumbnails/nodejs-basics.jpg', 1800, (SELECT id FROM categories WHERE name = 'Tecnologia'), 8750, 890, ARRAY['nodejs', 'backend', 'javascript'], false),
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy'), 'CSS Grid vs Flexbox', 'Quando usar cada um e suas diferenças', '/videos/css-grid-flex.mp4', '/thumbnails/css-grid-flex.jpg', 900, (SELECT id FROM categories WHERE name = 'Tecnologia'), 12300, 1450, ARRAY['css', 'frontend', 'layout'], true),
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'), 'Review: The Last of Us Part II', 'Análise completa do jogo icônico', '/videos/tlou2-review.mp4', '/thumbnails/tlou2-review.jpg', 1200, (SELECT id FROM categories WHERE name = 'Jogos'), 45200, 3200, ARRAY['thelastofus', 'review', 'playstation'], true),
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'), 'Live: Fortnite Battle Royale', 'Jogando Fortnite com a comunidade', '/videos/fortnite-live.mp4', '/thumbnails/fortnite-live.jpg', 7200, (SELECT id FROM categories WHERE name = 'Jogos'), 28900, 2100, ARRAY['fortnite', 'live', 'gaming'], false),
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'Ana Receitas'), 'Bolo de Chocolate Fácil', 'Receita simples e deliciosa para bolo de chocolate', '/videos/bolo-chocolate.mp4', '/thumbnails/bolo-chocolate.jpg', 480, (SELECT id FROM categories WHERE name = 'Culinária'), 32100, 2800, ARRAY['bolo', 'chocolate', 'receita'], true),
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'Ana Receitas'), 'Macarrão à Carbonara', 'Receita italiana autêntica passo a passo', '/videos/carbonara.mp4', '/thumbnails/carbonara.jpg', 600, (SELECT id FROM categories WHERE name = 'Culinária'), 19800, 1650, ARRAY['macarrao', 'italiana', 'receita'], false),
(uuid_generate_v4(), (SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy'), 'Deploy no Heroku', 'Como fazer deploy de aplicações Node.js', '/videos/heroku-deploy.mp4', '/thumbnails/heroku-deploy.jpg', 720, (SELECT id FROM categories WHERE name = 'Tecnologia'), 9650, 780, ARRAY['heroku', 'deploy', 'nodejs'], false)
ON CONFLICT DO NOTHING;

-- Dados básicos inseridos com sucesso
-- As subconsultas complexas foram removidas para evitar erros
-- Os dados essenciais já foram inseridos acima

-- Atualizar contadores após inserção dos dados
-- Atualizar contadores de criadores
UPDATE creators
SET subscriber_count = COALESCE(sub_counts.total_subs, 0)
FROM (
    SELECT creator_id, COUNT(*) as total_subs
    FROM subscriptions
    GROUP BY creator_id
) as sub_counts
WHERE creators.id = sub_counts.creator_id;

-- Atualizar contadores de likes do conteúdo
UPDATE content
SET like_count = COALESCE(like_counts.total_likes, 0)
FROM (
    SELECT content_id, COUNT(*) as total_likes
    FROM content_reactions
    WHERE reaction_type = 'like'
    GROUP BY content_id
) as like_counts
WHERE content.id = like_counts.content_id;

-- Atualizar contadores de dislikes do conteúdo
UPDATE content
SET dislike_count = COALESCE(dislike_counts.total_dislikes, 0)
FROM (
    SELECT content_id, COUNT(*) as total_dislikes
    FROM content_reactions
    WHERE reaction_type = 'dislike'
    GROUP BY content_id
) as dislike_counts
WHERE content.id = dislike_counts.content_id;

-- Inicializar likes dos comentários
UPDATE comments SET like_count = 0;
