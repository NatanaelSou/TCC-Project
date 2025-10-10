import 'models/user.dart';
import 'models/profile_models.dart';
import 'models/comment.dart';
import 'models/recommendation.dart';
import 'models/community_models.dart';

/// Dados mock estáticos para o app funcionar sem APIs ou banco de dados

/// Usuários mock
final List<User> mockUsers = [
  User(
    id: 1,
    name: 'João Silva',
    email: 'joao@example.com',
    avatarUrl: 'https://via.placeholder.com/150/FF6B6B/FFFFFF?text=JS',
    createdAt: DateTime(2023, 1, 15),
  ),
  User(
    id: 2,
    name: 'Maria Santos',
    email: 'maria@example.com',
    avatarUrl: 'https://via.placeholder.com/150/4ECDC4/FFFFFF?text=MS',
    createdAt: DateTime(2023, 2, 20),
  ),
  User(
    id: 3,
    name: 'Pedro Oliveira',
    email: 'pedro@example.com',
    avatarUrl: 'https://via.placeholder.com/150/45B7D1/FFFFFF?text=PO',
    createdAt: DateTime(2023, 3, 10),
  ),
];

/// Usuário logado mock
final User mockLoggedInUser = mockUsers[0];

/// Estatísticas do perfil mock
final ProfileStats mockProfileStats = ProfileStats(
  followers: 1250,
  posts: 45,
  subscribers: 89,
  viewers: 15420,
);

/// Posts recentes mock
final List<ProfileContent> mockRecentPosts = [
  ProfileContent(
    id: '1',
    title: 'Meu primeiro post sobre Flutter',
    type: 'post',
    thumbnailUrl: 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Post+1',
    createdAt: DateTime(2024, 1, 10),
    views: 234,
    category: ['Tutoriais de arte'],
    description: 'Olá comunidade! Hoje quero compartilhar minha jornada inicial com Flutter. Comecei há algumas semanas e já consegui criar meu primeiro app funcional. O framework é incrível para desenvolvimento cross-platform. Aqui vão algumas dicas que aprendi no caminho: 1) Comece com widgets básicos, 2) Use hot reload para iterar rapidamente, 3) Estude state management desde cedo. O que vocês acham? Alguma dica para iniciantes?',
    images: [
      'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Flutter+App+Screenshot',
      'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Widget+Tree',
    ],
  ),
  ProfileContent(
    id: '2',
    title: 'Dicas para desenvolvimento mobile',
    type: 'post',
    thumbnailUrl: 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Post+2',
    createdAt: DateTime(2024, 1, 8),
    views: 567,
    category: ['Jogos de RPG'],
    description: 'Depois de trabalhar em vários projetos mobile, compilei uma lista de melhores práticas que todo desenvolvedor deveria conhecer. Performance é chave em apps mobile - otimize suas imagens, use lazy loading, minimize rebuilds desnecessários. Também é crucial testar em dispositivos reais, não só emuladores. E lembrem-se: UX vem antes de tudo! O que vocês fazem para manter seus apps performáticos?',
    images: [
      'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=Mobile+Dev+Tips',
    ],
  ),
  ProfileContent(
    id: '3',
    title: 'Análise de mercado de apps',
    type: 'post',
    thumbnailUrl: 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Post+3',
    createdAt: DateTime(2024, 1, 5),
    views: 123,
    category: ['Crimes reais'],
    description: 'Analisando os dados do mercado de apps em 2024, vejo algumas tendências interessantes. O crescimento de apps de IA continua forte, com ferramentas como ChatGPT integradas em diversos serviços. Monetização por assinatura está superando compras in-app em muitas categorias. E o foco em privacidade está mudando como coletamos dados. Que nicho vocês veem oportunidade para novos apps?',
    images: [
      'https://via.placeholder.com/400x300/45B7D1/FFFFFF?text=Market+Chart',
      'https://via.placeholder.com/400x300/45B7D1/FFFFFF?text=App+Trends',
      'https://via.placeholder.com/400x300/45B7D1/FFFFFF?text=Revenue+Stats',
    ],
  ),
  ProfileContent(
    id: '4',
    title: 'Design System no Flutter',
    type: 'post',
    thumbnailUrl: 'https://via.placeholder.com/300x200/FFD93D/FFFFFF?text=Post+4',
    createdAt: DateTime(2024, 1, 3),
    views: 89,
    category: ['Ilustração'],
    description: 'Implementei um design system completo para meu projeto Flutter. Inclui cores, tipografia, espaçamentos e componentes reutilizáveis. O resultado? Consistência visual perfeita e desenvolvimento muito mais rápido. Compartilho aqui alguns componentes chave: botões customizados, cards responsivos e um sistema de ícones. Como vocês organizam seus design systems?',
    images: [
      'https://via.placeholder.com/400x300/FFD93D/FFFFFF?text=Design+System+Components',
      'https://via.placeholder.com/400x300/FFD93D/FFFFFF?text=Color+Palette',
    ],
  ),
  ProfileContent(
    id: '5',
    title: 'Experiência com Firebase',
    type: 'post',
    thumbnailUrl: 'https://via.placeholder.com/300x200/6BCF7F/FFFFFF?text=Post+5',
    createdAt: DateTime(2024, 1, 1),
    views: 156,
    category: ['Música'],
    description: 'Integração com Firebase foi mais fácil do que esperava! Authentication, Firestore e Storage funcionando perfeitamente. O real-time database é incrível para apps colaborativos. Só preciso melhorar a estrutura de dados. Algum de vocês tem experiências ruins com Firebase? Como lidaram com limitações de quota?',
    images: [
      'https://via.placeholder.com/400x300/6BCF7F/FFFFFF?text=Firebase+Dashboard',
    ],
  ),
];

/// Vídeos mock
final List<ProfileContent> mockVideos = [
  ProfileContent(
    id: 'v1',
    title: 'Tutorial: Criando seu primeiro app Flutter',
    type: 'video',
    thumbnailUrl: 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Video+1',
    createdAt: DateTime(2024, 1, 12),
    views: 1543,
    category: ['Desenvolvimento'],
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    tags: ['flutter', 'tutorial', 'mobile'],
    duration: '10:30',
  ),
  ProfileContent(
    id: 'v2',
    title: 'Integração com APIs REST',
    type: 'video',
    thumbnailUrl: 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Video+2',
    createdAt: DateTime(2024, 1, 9),
    views: 892,
    category: ['Desenvolvimento'],
    videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
    tags: ['api', 'rest', 'integration'],
    duration: '8:45',
  ),
];

/// Conteúdo exclusivo mock
final List<ProfileContent> mockExclusiveContent = [
  ProfileContent(
    id: 'e1',
    title: 'Conteúdo exclusivo: Arquitetura avançada',
    type: 'exclusive',
    thumbnailUrl: 'https://via.placeholder.com/300x200/FFD93D/000000?text=Exclusive+1',
    createdAt: DateTime(2024, 1, 7),
    views: 45,
    category: ['Ilustração'],
  ),
  ProfileContent(
    id: 'e2',
    title: 'Acesso antecipado: Novos recursos',
    type: 'exclusive',
    thumbnailUrl: 'https://via.placeholder.com/300x200/6BCF7F/FFFFFF?text=Exclusive+2',
    createdAt: DateTime(2024, 1, 4),
    views: 23,
    category: ['Música'],
  ),
];

final List<SupportTier> mockSupportTiers = [
  SupportTier(
    id: 't1',
    name: 'Bronze',
    price: 5.0,
    description: 'Acesso a posts semanais e suporte básico',
    color: '#CD7F32',
    subscriberCount: 45,
  ),
  SupportTier(
    id: 't2',
    name: 'Prata',
    price: 15.0,
    description: 'Conteúdo exclusivo mensal + acesso antecipado',
    color: '#C0C0C0',
    subscriberCount: 23,
  ),
  SupportTier(
    id: 't3',
    name: 'Ouro',
    price: 30.0,
    description: 'Tudo do Prata + sessões Q&A mensais + merch digital',
    color: '#FFD700',
    subscriberCount: 12,
  ),
];

/// Comentários mock
final List<Comment> mockComments = [
  Comment(
    id: 'c1',
    contentId: 'v1',
    userId: '1',
    text: 'Ótimo tutorial! Aprendi muito.',
    createdAt: DateTime(2024, 1, 13),
    likes: 5,
  ),
  Comment(
    id: 'c2',
    contentId: 'v1',
    userId: '2',
    text: 'Poderia explicar mais sobre state management?',
    createdAt: DateTime(2024, 1, 12),
    likes: 2,
  ),
  Comment(
    id: 'c3',
    contentId: 'v2',
    userId: '3',
    text: 'Exemplo prático ajudou bastante!',
    createdAt: DateTime(2024, 1, 10),
    likes: 3,
  ),
  Comment(
    id: 'c4',
    contentId: 'v2',
    userId: '1',
    text: 'Funcionou perfeitamente no meu projeto.',
    createdAt: DateTime(2024, 1, 9),
    likes: 1,
  ),
  Comment(
    id: 'c5',
    contentId: '1',
    userId: '2',
    text: 'Parabéns pelo primeiro post! Flutter é mesmo incrível. Recomendo começar com Provider para state management.',
    createdAt: DateTime(2024, 1, 11),
    likes: 8,
  ),
  Comment(
    id: 'c6',
    contentId: '1',
    userId: '3',
    text: 'Boas dicas! Também gosto de usar GetX, é mais simples para iniciantes.',
    createdAt: DateTime(2024, 1, 10),
    likes: 3,
  ),
  Comment(
    id: 'c7',
    contentId: '2',
    userId: '1',
    text: 'Concordo totalmente sobre performance. Como vocês otimizam imagens? Uso Image.asset com cache.',
    createdAt: DateTime(2024, 1, 9),
    likes: 6,
  ),
  Comment(
    id: 'c8',
    contentId: '2',
    userId: '3',
    text: 'Excelente pontos! Também adicionaria testes unitários desde o início.',
    createdAt: DateTime(2024, 1, 8),
    likes: 4,
  ),
  Comment(
    id: 'c9',
    contentId: '3',
    userId: '2',
    text: 'Interessante análise. Vejo oportunidade em apps de saúde mental com IA.',
    createdAt: DateTime(2024, 1, 6),
    likes: 7,
  ),
  Comment(
    id: 'c10',
    contentId: '4',
    userId: '1',
    text: 'Design system é fundamental! Como você organiza as cores no código?',
    createdAt: DateTime(2024, 1, 4),
    likes: 5,
  ),
  Comment(
    id: 'c11',
    contentId: '5',
    userId: '3',
    text: 'Firebase é ótimo mas cuidado com custos. Já passei por isso.',
    createdAt: DateTime(2024, 1, 2),
    likes: 9,
  ),
];

/// Recomendações mock
final List<Recommendation> mockRecommendations = [
  Recommendation(
    contentId: 'v1',
    recommendedContentIds: ['v2'],
    basedOn: 'category',
  ),
  Recommendation(
    contentId: 'v2',
    recommendedContentIds: ['v1'],
    basedOn: 'views',
  ),
];

/// Criadores mock para seções
final List<Map<String, dynamic>> mockCreators = [
  {
    'name': 'João Silva',
    'avatar': 'https://via.placeholder.com/100/FF6B6B/FFFFFF?text=JS',
    'category': 'Desenvolvimento',
    'followers': 1250,
    'isOnline': true,
  },
  {
    'name': 'Maria Santos',
    'avatar': 'https://via.placeholder.com/100/4ECDC4/FFFFFF?text=MS',
    'category': 'Arte Digital',
    'followers': 890,
    'isOnline': false,
  },
  {
    'name': 'Pedro Oliveira',
    'avatar': 'https://via.placeholder.com/100/45B7D1/FFFFFF?text=PO',
    'category': 'Música',
    'followers': 2100,
    'isOnline': true,
  },
  {
    'name': 'Ana Costa',
    'avatar': 'https://via.placeholder.com/100/FFA07A/FFFFFF?text=AC',
    'category': 'Fotografia',
    'followers': 675,
    'isOnline': false,
  },
];

/// Obtém comentários para um conteúdo específico
List<Comment> getCommentsForContent(String contentId) {
  return mockComments.where((c) => c.contentId == contentId).toList();
}

/// Obtém vídeos similares baseado na categoria
List<ProfileContent> getSimilarVideos(ProfileContent content) {
  if (content.type != 'video') return [];
  return mockVideos
    .where((v) => v.id != content.id && 
      (v.category?.any((cat) => content.category?.contains(cat) ?? false) ?? false))
    .toList();
}

/// Canais de comunidade mock
final List<Channel> mockChannels = [
  Channel(
    id: 'chat1',
    creatorId: '1',
    name: 'Chat Geral',
    description: 'Discussões gerais sobre desenvolvimento e tecnologia',
    type: 'chat',
    isPrivate: false,
    members: ['1', '2', '3'],
  ),
  Channel(
    id: 'mural1',
    creatorId: '1',
    name: 'Mural de Projetos',
    description: 'Compartilhe seus projetos e receba feedback',
    type: 'mural',
    isPrivate: false,
    members: ['1', '2'],
  ),
  Channel(
    id: 'chat2',
    creatorId: '1',
    name: 'Chat Premium',
    description: 'Acesso exclusivo para apoiadores',
    type: 'chat',
    isPrivate: true,
    tierRequired: 't3',
    members: ['1'],
  ),
];

/// Mensagens mock para canais
final List<Message> mockMessages = [
  Message(
    id: 'msg1',
    senderId: '1',
    channelId: 'chat1',
    text: 'Olá pessoal! Alguém trabalhando em projetos Flutter hoje?',
    timestamp: DateTime.now().subtract(Duration(hours: 2)),
    isPrivate: false,
  ),
  Message(
    id: 'msg2',
    senderId: '2',
    channelId: 'chat1',
    text: 'Sim! Estou implementando um sistema de autenticação. Qual biblioteca vocês recomendam?',
    timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 45)),
    isPrivate: false,
  ),
  Message(
    id: 'msg3',
    senderId: '3',
    channelId: 'chat1',
    text: 'Uso Firebase Auth, é bem integrado com Flutter. Fácil de configurar.',
    timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
    isPrivate: false,
  ),
  Message(
    id: 'msg4',
    senderId: '1',
    channelId: 'chat1',
    text: 'Valeu pela dica! Vou testar. Alguém já usou Supabase?',
    timestamp: DateTime.now().subtract(Duration(minutes: 20)),
    isPrivate: false,
  ),
  Message(
    id: 'msg5',
    senderId: '2',
    channelId: 'chat2',
    text: 'Conteúdo premium: Dicas avançadas de performance no Flutter.',
    timestamp: DateTime.now().subtract(Duration(hours: 5)),
    isPrivate: true,
    tierRequired: 't3',
  ),
];

/// Posts de mural mock
final List<MuralPost> mockMuralPosts = [
  MuralPost(
    id: 'post1',
    creatorId: '1',
    channelId: 'mural1',
    title: 'Meu novo app de gerenciamento de tarefas',
    description: 'Criei um app completo com Flutter e Firebase. Inclui autenticação, CRUD de tarefas e notificações push. O design é clean e responsivo. Gostaria de feedback sobre a UX e possíveis melhorias. Link do repositório no GitHub na bio!',
    images: [
      'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=App+Screenshot+1',
      'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=App+Screenshot+2',
    ],
    createdAt: DateTime.now().subtract(Duration(days: 3)),
    likes: 12,
    replies: [
      MuralPost(
        id: 'reply1',
        creatorId: '2',
        channelId: 'mural1',
        description: 'App ficou ótimo! A navegação é fluida. Sugestão: adicionar dark mode.',
        parentId: 'post1',
        createdAt: DateTime.now().subtract(Duration(days: 2, hours: 4)),
        likes: 3,
      ),
      MuralPost(
        id: 'reply2',
        creatorId: '3',
        channelId: 'mural1',
        description: 'Concordo com o dark mode. Também adorei a integração com Firebase!',
        parentId: 'post1',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        likes: 2,
      ),
    ],
  ),
  MuralPost(
    id: 'post2',
    creatorId: '2',
    channelId: 'mural1',
    title: 'Tutorial: Animações customizadas no Flutter',
    description: 'Compartilhando um tutorial completo sobre como criar animações suaves e performáticas. Uso Hero animations, implicit animations e custom painters. Incluo código fonte e exemplos práticos. Perfeito para elevar o nível do seu app!',
    images: [
      'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Animation+Demo',
    ],
    createdAt: DateTime.now().subtract(Duration(days: 1)),
    likes: 8,
    replies: [
      MuralPost(
        id: 'reply3',
        creatorId: '1',
        channelId: 'mural1',
        description: 'Excelente tutorial! As animações ficaram incríveis. Vou implementar no meu projeto.',
        parentId: 'post2',
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
        likes: 1,
      ),
    ],
  ),
];

/// Adiciona conteúdo recém-criado às listas mock apropriadas
/// Baseado no tipo do conteúdo
void addContentToMock(ProfileContent content) {
  switch (content.type) {
    case 'post':
      mockRecentPosts.insert(0, content);
      break;
    case 'video':
      mockVideos.insert(0, content);
      break;
    case 'exclusive':
      mockExclusiveContent.insert(0, content);
      break;
    default:
      mockRecentPosts.insert(0, content);
      break;
  }
}
