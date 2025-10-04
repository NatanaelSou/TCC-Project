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

INSERT INTO comments (content_id, user_id, text, likes, created_at) VALUES
(4, 1, 'Ótimo tutorial! Aprendi muito.', 5, '2024-01-13 00:00:00'),
(4, 2, 'Poderia explicar mais sobre state management?', 2, '2024-01-12 00:00:00'),
(5, 3, 'Exemplo prático ajudou bastante!', 3, '2024-01-10 00:00:00'),
(5, 1, 'Funcionou perfeitamente no meu projeto.', 1, '2024-01-09 00:00:00');

INSERT INTO recommendations (content_id, recommended_content_ids, based_on) VALUES
(4, '[5]', 'category'),
(5, '[4]', 'views');
