-- Fix database schema issues

-- Drop problematic tables
DROP TABLE IF EXISTS contents;
DROP TABLE IF EXISTS subscriptions;

-- Recreate support_tiers with proper INT id
DROP TABLE IF EXISTS support_tiers;
CREATE TABLE support_tiers (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	name VARCHAR(100) NOT NULL,
	price DECIMAL(10,2) NOT NULL,
	description TEXT,
	color VARCHAR(7),
	subscriber_count INT DEFAULT 0,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Recreate content table
CREATE TABLE content (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	title VARCHAR(255) NOT NULL,
	type ENUM('post', 'video', 'exclusive') NOT NULL,
	thumbnail_url VARCHAR(500),
	video_url VARCHAR(500),
	category JSON,
	tags JSON,
	duration VARCHAR(10),
	views INT DEFAULT 0,
	tier_id INT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (tier_id) REFERENCES support_tiers(id) ON DELETE SET NULL
);

-- Insert sample data
INSERT INTO support_tiers (user_id, name, price, description, color, subscriber_count) VALUES
(1, 'Bronze', 5.00, 'Acesso a posts semanais e suporte básico', '#CD7F32', 45),
(1, 'Prata', 15.00, 'Conteúdo exclusivo mensal + acesso antecipado', '#C0C0C0', 23),
(1, 'Ouro', 30.00, 'Tudo do Prata + sessões Q&A mensais + merch digital', '#FFD700', 12);

INSERT INTO content (user_id, title, type, thumbnail_url, views, category, created_at) VALUES
(1, 'Meu primeiro post sobre Flutter', 'post', 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Post+1', 234, '["Tutoriais de arte"]', '2024-01-10 00:00:00'),
(1, 'Dicas para desenvolvimento mobile', 'post', 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Post+2', 567, '["Jogos de RPG"]', '2024-01-08 00:00:00'),
(1, 'Análise de mercado de apps', 'post', 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Post+3', 123, '["Crimes reais"]', '2024-01-05 00:00:00'),
(1, 'Tutorial: Criando seu primeiro app Flutter', 'video', 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Video+1', 1543, '["Desenvolvimento"]', '2024-01-12 00:00:00'),
(1, 'Integração com APIs REST', 'video', 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Video+2', 892, '["Desenvolvimento"]', '2024-01-09 00:00:00'),
(1, 'Conteúdo exclusivo: Arquitetura avançada', 'exclusive', 'https://via.placeholder.com/300x200/FFD93D/000000?text=Exclusive+1', 45, '["Ilustração"]', '2024-01-07 00:00:00'),
(1, 'Acesso antecipado: Novos recursos', 'exclusive', 'https://via.placeholder.com/300x200/6BCF7F/FFFFFF?text=Exclusive+2', 23, '["Música"]', '2024-01-04 00:00:00');

UPDATE content SET video_url = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', tags = '["flutter", "tutorial", "mobile"]', duration = '10:30' WHERE id = 4;
UPDATE content SET video_url = 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', tags = '["api", "rest", "integration"]', duration = '8:45' WHERE id = 5;
