import 'models/user.dart';
import 'models/profile_models.dart';

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
    category: 'Tutoriais de arte',
  ),
  ProfileContent(
    id: '2',
    title: 'Dicas para desenvolvimento mobile',
    type: 'post',
    thumbnailUrl: 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Post+2',
    createdAt: DateTime(2024, 1, 8),
    views: 567,
    category: 'Jogos de RPG',
  ),
  ProfileContent(
    id: '3',
    title: 'Análise de mercado de apps',
    type: 'post',
    thumbnailUrl: 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Post+3',
    createdAt: DateTime(2024, 1, 5),
    views: 123,
    category: 'Crimes reais',
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
    category: 'Comédia',
  ),
  ProfileContent(
    id: 'v2',
    title: 'Integração com APIs REST',
    type: 'video',
    thumbnailUrl: 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Video+2',
    createdAt: DateTime(2024, 1, 9),
    views: 892,
    category: 'Cultura pop',
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
    category: 'Ilustração',
  ),
  ProfileContent(
    id: 'e2',
    title: 'Acesso antecipado: Novos recursos',
    type: 'exclusive',
    thumbnailUrl: 'https://via.placeholder.com/300x200/6BCF7F/FFFFFF?text=Exclusive+2',
    createdAt: DateTime(2024, 1, 4),
    views: 23,
    category: 'Música',
  ),
];

/// Níveis de suporte mock
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
