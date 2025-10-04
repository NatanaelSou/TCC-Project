CREATE TABLE IF NOT EXISTS users (
	id INT AUTO_INCREMENT PRIMARY KEY,
	email VARCHAR(255) NOT NULL UNIQUE,
	password VARCHAR(255) NOT NULL,
	name VARCHAR(100),
	avatar_url VARCHAR(500),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela para estatísticas do perfil
CREATE TABLE IF NOT EXISTS profile_stats (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL UNIQUE,
	followers INT DEFAULT 0,
	posts INT DEFAULT 0,
	subscribers INT DEFAULT 0,
	viewers INT DEFAULT 0,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabela para tiers de suporte
CREATE TABLE IF NOT EXISTS support_tiers (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	name VARCHAR(100) NOT NULL,
	price DECIMAL(10,2) NOT NULL,
	description TEXT,
	color VARCHAR(7), -- Hex color
	subscriber_count INT DEFAULT 0,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabela para conteúdo (posts, videos, exclusive)
CREATE TABLE IF NOT EXISTS content (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	title VARCHAR(255) NOT NULL,
	type ENUM('post', 'video', 'exclusive') NOT NULL,
	thumbnail_url VARCHAR(500),
	video_url VARCHAR(500),
	category JSON, -- Array de categorias
	tags JSON, -- Array de tags
	duration VARCHAR(10), -- Para videos
	views INT DEFAULT 0,
	tier_id INT NULL, -- Para conteúdo exclusivo vinculado a um tier
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (tier_id) REFERENCES support_tiers(id) ON DELETE SET NULL
);

-- Tabela para comentários
CREATE TABLE IF NOT EXISTS comments (
	id INT AUTO_INCREMENT PRIMARY KEY,
	content_id INT NOT NULL,
	user_id INT NOT NULL,
	text TEXT NOT NULL,
	likes INT DEFAULT 0,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabela para recomendações
CREATE TABLE IF NOT EXISTS recommendations (
	id INT AUTO_INCREMENT PRIMARY KEY,
	content_id INT NOT NULL,
	recommended_content_ids JSON, -- Array de IDs recomendados
	based_on VARCHAR(50), -- 'category', 'views', etc.
	FOREIGN KEY (content_id) REFERENCES content(id) ON DELETE CASCADE
);

-- Tabela para seguidores (relacionamento many-to-many)
CREATE TABLE IF NOT EXISTS followers (
	id INT AUTO_INCREMENT PRIMARY KEY,
	follower_id INT NOT NULL,
	followed_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (followed_id) REFERENCES users(id) ON DELETE CASCADE,
	UNIQUE KEY unique_follow (follower_id, followed_id)
);

-- Tabela para apoiadores dos tiers
CREATE TABLE IF NOT EXISTS tier_supporters (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	tier_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (tier_id) REFERENCES support_tiers(id) ON DELETE CASCADE,
	UNIQUE KEY unique_support (user_id, tier_id)
);

-- Inserir usuário teste
INSERT INTO users (email, password, name) VALUES ('teste@teste.com', '$2b$10$ezdIRs1gSKdMv2iMhB3te.vvlfTOCogOwgUykEyUDlfA5WdAPOGam', 'Usuário Teste')
	ON DUPLICATE KEY UPDATE email=email;

-- Inserir dados de exemplo para o usuário teste
INSERT INTO profile_stats (user_id, followers, posts, subscribers, viewers) VALUES (1, 1250, 45, 89, 15420)
	ON DUPLICATE KEY UPDATE followers=VALUES(followers);

INSERT INTO support_tiers (user_id, name, price, description, color, subscriber_count) VALUES
(1, 'Bronze', 5.00, 'Acesso a posts semanais e suporte básico', '#CD7F32', 45),
(1, 'Prata', 15.00, 'Conteúdo exclusivo mensal + acesso antecipado', '#C0C0C0', 23),
(1, 'Ouro', 30.00, 'Tudo do Prata + sessões Q&A mensais + merch digital', '#FFD700', 12)
	ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO content (user_id, title, type, thumbnail_url, views, category, created_at) VALUES
(1, 'Meu primeiro post sobre Flutter', 'post', 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Post+1', 234, '["Tutoriais de arte"]', '2024-01-10 00:00:00'),
(1, 'Dicas para desenvolvimento mobile', 'post', 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Post+2', 567, '["Jogos de RPG"]', '2024-01-08 00:00:00'),
(1, 'Análise de mercado de apps', 'post', 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Post+3', 123, '["Crimes reais"]', '2024-01-05 00:00:00'),
(1, 'Tutorial: Criando seu primeiro app Flutter', 'video', 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Video+1', 1543, '["Desenvolvimento"]', '2024-01-12 00:00:00'),
(1, 'Integração com APIs REST', 'video', 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Video+2', 892, '["Desenvolvimento"]', '2024-01-09 00:00:00'),
(1, 'Conteúdo exclusivo: Arquitetura avançada', 'exclusive', 'https://via.placeholder.com/300x200/FFD93D/000000?text=Exclusive+1', 45, '["Ilustração"]', '2024-01-07 00:00:00'),
(1, 'Acesso antecipado: Novos recursos', 'exclusive', 'https://via.placeholder.com/300x200/6BCF7F/FFFFFF?text=Exclusive+2', 23, '["Música"]', '2024-01-04 00:00:00')
	ON DUPLICATE KEY UPDATE title=VALUES(title);

UPDATE content SET video_url = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', tags = '["flutter", "tutorial", "mobile"]', duration = '10:30' WHERE id = 4;
UPDATE content SET video_url = 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', tags = '["api", "rest", "integration"]', duration = '8:45' WHERE id = 5;

INSERT INTO comments (content_id, user_id, text, likes, created_at) VALUES
(4, 1, 'Ótimo tutorial! Aprendi muito.', 5, '2024-01-13 00:00:00'),
(4, 2, 'Poderia explicar mais sobre state management?', 2, '2024-01-12 00:00:00'),
(5, 3, 'Exemplo prático ajudou bastante!', 3, '2024-01-10 00:00:00'),
(5, 1, 'Funcionou perfeitamente no meu projeto.', 1, '2024-01-09 00:00:00')
	ON DUPLICATE KEY UPDATE text=VALUES(text);

INSERT INTO recommendations (content_id, recommended_content_ids, based_on) VALUES
(4, '[5]', 'category'),
(5, '[4]', 'views')
	ON DUPLICATE KEY UPDATE recommended_content_ids=VALUES(recommended_content_ids);
