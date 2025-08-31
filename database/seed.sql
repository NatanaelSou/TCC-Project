-- Dados Iniciais para a Plataforma de Serviço de Conteúdo
-- Este arquivo popula o banco com dados de exemplo

-- Inserir categorias padrão
INSERT INTO categories (name, description, icon_url) VALUES
('Tecnologia', 'Conteúdo relacionado a tecnologia, programação e inovação', '/icons/tech.png'),
('Entretenimento', 'Vídeos de entretenimento, música e cultura pop', '/icons/entertainment.png'),
('Educação', 'Conteúdo educacional, tutoriais e cursos', '/icons/education.png'),
('Culinária', 'Receitas, dicas de cozinha e gastronomia', '/icons/cooking.png'),
('Esportes', 'Cobertura esportiva, análises e destaques', '/icons/sports.png'),
('Viagem', 'Dicas de viagem, destinos e experiências', '/icons/travel.png'),
('Ciência', 'Conteúdo científico, descobertas e explicações', '/icons/science.png'),
('Música', 'Música, shows ao vivo e artistas', '/icons/music.png'),
('Jogos', 'Games, reviews e gameplay', '/icons/gaming.png'),
('Notícias', 'Notícias, atualidades e jornalismo', '/icons/news.png')
ON CONFLICT (name) DO NOTHING;

-- Inserir usuários de exemplo
INSERT INTO users (username, email, password_hash, full_name, bio, is_verified, is_creator) VALUES
('admin', 'admin@plataforma.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador', 'Administrador da plataforma', true, false),
('joao_silva', 'joao@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'João Silva', 'Desenvolvedor apaixonado por tecnologia', true, true),
('maria_tech', 'maria@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Maria Tech', 'Especialista em React e Node.js', true, true),
('carlos_games', 'carlos@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Carlos Games', 'Streamer e criador de conteúdo gamer', false, true),
('ana_cozinha', 'ana@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ana Cozinha', 'Chef profissional compartilhando receitas deliciosas', true, true),
('viewer1', 'viewer1@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Visualizador 1', 'Usuário comum da plataforma', false, false),
('viewer2', 'viewer2@email.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Visualizador 2', 'Entusiasta de tecnologia', false, false)
ON CONFLICT (username) DO NOTHING;

-- Inserir criadores (perfis de criadores)
INSERT INTO creators (user_id, channel_name, channel_description, subscriber_count, total_views, custom_url, is_monetized) VALUES
((SELECT id FROM users WHERE username = 'joao_silva'), 'João Dev', 'Canal sobre desenvolvimento web e programação', 15420, 1250000, 'joao-dev', true),
((SELECT id FROM users WHERE username = 'maria_tech'), 'Maria Tech Academy', 'Aprenda desenvolvimento frontend e backend', 8750, 890000, 'maria-tech', true),
((SELECT id FROM users WHERE username = 'carlos_games'), 'Carlos Games BR', 'Reviews de jogos e gameplay ao vivo', 45200, 3200000, 'carlos-games', true),
((SELECT id FROM users WHERE username = 'ana_cozinha'), 'Ana Receitas', 'Receitas fáceis e deliciosas para o dia a dia', 28900, 2100000, 'ana-receitas', true)
ON CONFLICT (user_id) DO NOTHING;

-- Inserir conteúdo de exemplo
INSERT INTO content (creator_id, title, description, video_url, thumbnail_url, duration, category_id, view_count, like_count, tags, is_featured) VALUES
((SELECT id FROM creators WHERE channel_name = 'João Dev'), 'Introdução ao React em 10 minutos', 'Aprenda os conceitos básicos do React de forma rápida e prática', '/videos/react-intro.mp4', '/thumbnails/react-intro.jpg', 600, (SELECT id FROM categories WHERE name = 'Tecnologia'), 15420, 1250, ARRAY['react', 'javascript', 'frontend'], true),
((SELECT id FROM creators WHERE channel_name = 'João Dev'), 'Node.js para Iniciantes', 'Curso completo de Node.js do zero', '/videos/nodejs-basics.mp4', '/thumbnails/nodejs-basics.jpg', 1800, (SELECT id FROM categories WHERE name = 'Tecnologia'), 8750, 890, ARRAY['nodejs', 'backend', 'javascript'], false),
((SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy'), 'CSS Grid vs Flexbox', 'Quando usar cada um e suas diferenças', '/videos/css-grid-flex.mp4', '/thumbnails/css-grid-flex.jpg', 900, (SELECT id FROM categories WHERE name = 'Tecnologia'), 12300, 1450, ARRAY['css', 'frontend', 'layout'], true),
((SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'), 'Review: The Last of Us Part II', 'Análise completa do jogo icônico', '/videos/tlou2-review.mp4', '/thumbnails/tlou2-review.jpg', 1200, (SELECT id FROM categories WHERE name = 'Jogos'), 45200, 3200, ARRAY['thelastofus', 'review', 'playstation'], true),
((SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'), 'Live: Fortnite Battle Royale', 'Jogando Fortnite com a comunidade', '/videos/fortnite-live.mp4', '/thumbnails/fortnite-live.jpg', 7200, (SELECT id FROM categories WHERE name = 'Jogos'), 28900, 2100, ARRAY['fortnite', 'live', 'gaming'], false),
((SELECT id FROM creators WHERE channel_name = 'Ana Receitas'), 'Bolo de Chocolate Fácil', 'Receita simples e deliciosa para bolo de chocolate', '/videos/bolo-chocolate.mp4', '/thumbnails/bolo-chocolate.jpg', 480, (SELECT id FROM categories WHERE name = 'Culinária'), 32100, 2800, ARRAY['bolo', 'chocolate', 'receita'], true),
((SELECT id FROM creators WHERE channel_name = 'Ana Receitas'), 'Macarrão à Carbonara', 'Receita italiana autêntica passo a passo', '/videos/carbonara.mp4', '/thumbnails/carbonara.jpg', 600, (SELECT id FROM categories WHERE name = 'Culinária'), 19800, 1650, ARRAY['macarrao', 'italiana', 'receita'], false),
((SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy'), 'Deploy no Heroku', 'Como fazer deploy de aplicações Node.js', '/videos/heroku-deploy.mp4', '/thumbnails/heroku-deploy.jpg', 720, (SELECT id FROM categories WHERE name = 'Tecnologia'), 9650, 780, ARRAY['heroku', 'deploy', 'nodejs'], false)
ON CONFLICT DO NOTHING;

-- Inserir inscrições de exemplo
INSERT INTO subscriptions (subscriber_id, creator_id) VALUES
((SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM creators WHERE channel_name = 'João Dev')),
((SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM creators WHERE channel_name = 'Carlos Games BR')),
((SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM creators WHERE channel_name = 'Maria Tech Academy')),
((SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM creators WHERE channel_name = 'Ana Receitas')),
((SELECT id FROM users WHERE username = 'joao_silva'), (SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'))
ON CONFLICT DO NOTHING;

-- Inserir reações de exemplo
INSERT INTO content_reactions (user_id, content_id, reaction_type) VALUES
((SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title = 'Introdução ao React em 10 minutos'), 'like'),
((SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM content WHERE title = 'Introdução ao React em 10 minutos'), 'like'),
((SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title = 'Review: The Last of Us Part II'), 'like'),
((SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM content WHERE title = 'CSS Grid vs Flexbox'), 'like')
ON CONFLICT DO NOTHING;

-- Inserir comentários de exemplo
INSERT INTO comments (user_id, content_id, comment_text) VALUES
((SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title = 'Introdução ao React em 10 minutos'), 'Excelente explicação! Muito obrigado pelo tutorial.'),
((SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM content WHERE title = 'Introdução ao React em 10 minutos'), 'Perfeito para iniciantes. Parabéns!'),
((SELECT id FROM users WHERE username = 'viewer1'), (SELECT id FROM content WHERE title = 'Review: The Last of Us Part II'), 'Concordo com a análise. Jogo incrível!'),
((SELECT id FROM users WHERE username = 'viewer2'), (SELECT id FROM content WHERE title = 'Bolo de Chocolate Fácil'), 'Vou testar essa receita no fim de semana!')
ON CONFLICT DO NOTHING;

-- Inserir playlists de exemplo
INSERT INTO playlists (creator_id, title, description, is_public) VALUES
((SELECT id FROM creators WHERE channel_name = 'João Dev'), 'Curso React Completo', 'Playlist completa para aprender React do zero', true),
((SELECT id FROM creators WHERE channel_name = 'Carlos Games BR'), 'Melhores Reviews 2024', 'As melhores análises de jogos do ano', true),
((SELECT id FROM creators WHERE channel_name = 'Ana Receitas'), 'Receitas Rápidas', 'Receitas que você faz em menos de 30 minutos', true)
ON CONFLICT DO NOTHING;

-- Inserir itens da playlist
INSERT INTO playlist_items (playlist_id, content_id, position) VALUES
((SELECT id FROM playlists WHERE title = 'Curso React Completo'), (SELECT id FROM content WHERE title = 'Introdução ao React em 10 minutos'), 1),
((SELECT id FROM playlists WHERE title = 'Curso React Completo'), (SELECT id FROM content WHERE title = 'CSS Grid vs Flexbox'), 2),
((SELECT id FROM playlists WHERE title = 'Melhores Reviews 2024'), (SELECT id FROM content WHERE title = 'Review: The Last of Us Part II'), 1),
((SELECT id FROM playlists WHERE title = 'Receitas Rápidas'), (SELECT id FROM content WHERE title = 'Bolo de Chocolate Fácil'), 1),
((SELECT id FROM playlists WHERE title = 'Receitas Rápidas'), (SELECT id FROM content WHERE title = 'Macarrão à Carbonara'), 2)
ON CONFLICT DO NOTHING;

-- Atualizar contadores após inserção dos dados
UPDATE creators SET subscriber_count = (
    SELECT COUNT(*) FROM subscriptions WHERE subscriptions.creator_id = creators.id
);

UPDATE content SET like_count = (
    SELECT COUNT(*) FROM content_reactions
    WHERE content_reactions.content_id = content.id
    AND content_reactions.reaction_type = 'like'
);

UPDATE content SET dislike_count = (
    SELECT COUNT(*) FROM content_reactions
    WHERE content_reactions.content_id = content.id
    AND content_reactions.reaction_type = 'dislike'
);

UPDATE comments SET like_count = 0; -- Inicializar likes dos comentários
