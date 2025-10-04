const db = require('./config/db');

async function insertSampleData() {
  try {
    // Users already exist, skip inserting them

    // Insert support tiers
    await db.query(
      `INSERT INTO support_tiers (user_id, name, price, description, color, subscriber_count) VALUES
      (1, 'Bronze', 5.00, 'Acesso a posts semanais e suporte básico', '#CD7F32', 45),
      (1, 'Prata', 15.00, 'Conteúdo exclusivo mensal + acesso antecipado', '#C0C0C0', 23),
      (1, 'Ouro', 30.00, 'Tudo do Prata + sessões Q&A mensais + merch digital', '#FFD700', 12)`
    );

    // Insert content
    await db.query(
      `INSERT INTO content (user_id, title, type, thumbnail_url, views, category, created_at) VALUES
      (1, 'Meu primeiro post sobre Flutter', 'post', 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Post+1', 234, '[\\"Tutoriais de arte\\"]', '2024-01-10 00:00:00'),
      (1, 'Dicas para desenvolvimento mobile', 'post', 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Post+2', 567, '[\\"Jogos de RPG\\"]', '2024-01-08 00:00:00'),
      (1, 'Análise de mercado de apps', 'post', 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Post+3', 123, '[\\"Crimes reais\\"]', '2024-01-05 00:00:00'),
      (1, 'Tutorial: Criando seu primeiro app Flutter', 'video', 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Video+1', 1543, '[\\"Desenvolvimento\\"]', '2024-01-12 00:00:00'),
      (1, 'Integração com APIs REST', 'video', 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Video+2', 892, '[\\"Desenvolvimento\\"]', '2024-01-09 00:00:00'),
      (1, 'Conteúdo exclusivo: Arquitetura avançada', 'exclusive', 'https://via.placeholder.com/300x200/FFD93D/000000?text=Exclusive+1', 45, '[\\"Ilustração\\"]', '2024-01-07 00:00:00'),
      (1, 'Acesso antecipado: Novos recursos', 'exclusive', 'https://via.placeholder.com/300x200/6BCF7F/FFFFFF?text=Exclusive+2', 23, '[\\"Música\\"]', '2024-01-04 00:00:00')`
    );

    // Update content with video URLs and tags
    await db.query(
      `UPDATE content SET video_url = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', tags = '[\\"flutter\\", \\"tutorial\\", \\"mobile\\"]', duration = '10:30' WHERE id = 39`
    );
    await db.query(
      `UPDATE content SET video_url = 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', tags = '[\\"api\\", \\"rest\\", \\"integration\\"]', duration = '8:45' WHERE id = 40`
    );

    // Insert comments
    await db.query(
      `INSERT INTO comments (content_id, user_id, text, likes) VALUES
      (39, 1, 'Ótimo tutorial! Aprendi muito.', 5),
      (39, 3, 'Poderia explicar mais sobre state management?', 2),
      (40, 4, 'Exemplo prático ajudou bastante!', 3),
      (40, 1, 'Funcionou perfeitamente no meu projeto.', 1)`
    );

    // Insert recommendations
    await db.query(
      `INSERT INTO recommendations (content_id, recommended_content_ids, based_on) VALUES
      (39, '[40]', 'category'),
      (40, '[39]', 'views')`
    );

    console.log('Dados de exemplo inseridos com sucesso!');
  } catch (err) {
    console.error('Erro ao inserir dados:', err);
  } finally {
    process.exit();
  }
}

insertSampleData();
