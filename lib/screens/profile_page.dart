import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_state.dart';
import '../constants.dart';
import '../services/profile_service.dart';
import '../models/profile_models.dart';
import '../models/community_models.dart';
import 'community_chat_screen.dart';
import 'community_mural_screen.dart';

/// Página de perfil do usuário baseada em mistura de YouTube e Patreon
/// Exibe informações do perfil, estatísticas e conteúdo dinâmicos
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();

  ProfileStats? _stats;
  List<ProfileContent> _recentPosts = [];
  final List<ProfileContent> _videos = [];
  List<ProfileContent> _exclusiveContent = [];
  List<SupportTier> _supportTiers = [];
  List<Channel> _channels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Carrega dados dinâmicos do perfil
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userState = Provider.of<UserState>(context, listen: false);
      final userId = userState.user?.id?.toString() ?? '1'; // Fallback para mock

      // Carrega dados em paralelo
      final results = await Future.wait([
        _profileService.getProfileStats(userId),
        _profileService.getProfileContent(userId, 'posts', limit: 5),
        _profileService.getProfileContent(userId, 'exclusive', limit: 5),
        _profileService.getSupportTiers(userId),
        _profileService.getChannels(userId),
      ]);

      setState(() {
        _stats = results[0] as ProfileStats;
        _recentPosts = results[1] as List<ProfileContent>;
        _exclusiveContent = results[2] as List<ProfileContent>;
        _supportTiers = results[3] as List<SupportTier>;
        _channels = results[4] as List<Channel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados do perfil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.btnSecondary),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfileData,
                child: Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        foregroundColor: AppColors.iconDark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.iconDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do perfil (estilo YouTube)
            _buildProfileHeader(userState),
            // Estatísticas (estilo Patreon)
            _buildStatsSection(),
            // Seções de conteúdo
            _buildContentSection('Posts Recentes', _recentPosts),
            _buildContentSection('Conteúdo Exclusivo', _exclusiveContent),
            // Níveis de suporte (estilo Patreon)
            _buildSupportTiers(),
            // Canais de comunidade
            _buildChannelsSection(),
          ],
        ),
      ),
    );
  }

  /// Header do perfil com banner e informações básicas
  Widget _buildProfileHeader(UserState userState) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.btnSecondary, AppColors.btnSecondary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Banner
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
          ),
          // Informações do perfil
          Positioned(
            left: 20,
            top: 80,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: userState.avatarUrl != null
                      ? NetworkImage(userState.avatarUrl!)
                      : null,
                  child: userState.avatarUrl == null
                      ? Icon(Icons.person, size: 40, color: AppColors.btnSecondary)
                      : null,
                ),
                SizedBox(width: 20),
                // Informações
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userState.name ?? 'Nome do Usuário',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '@${userState.email?.split('@').first ?? 'usuario'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Criador de conteúdo no Premiora',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botão editar perfil
          Positioned(
            right: 20,
            top: 100,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.btnSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Editar perfil'),
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de estatísticas
  Widget _buildStatsSection() {
    if (_stats == null) {
      return Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: Center(
          child: Text('Carregando estatísticas...'),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _buildStatItem('Seguidores', _formatNumber(_stats!.followers)),
          _buildStatItem('Posts', _formatNumber(_stats!.posts)),
          _buildStatItem('Assinantes', _formatNumber(_stats!.subscribers)),
          _buildStatItem('Viewers', _formatNumber(_stats!.viewers)),
        ],
      ),
    );
  }

  /// Formata números grandes (K, M, etc.)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }



  /// Item de estatística
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.btnSecondary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Seção de conteúdo
  Widget _buildContentSection(String title, List<ProfileContent> contentList) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          if (contentList.isEmpty)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Nenhum conteúdo disponível',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: contentList.length,
                itemBuilder: (context, index) {
                  final content = contentList[index];
                  return GestureDetector(
                    onTap: null,
                    child: Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        image: content.thumbnailUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(content.thumbnailUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (content.thumbnailUrl.isEmpty)
                            Center(
                              child: Icon(
                                content.type == 'video' ? Icons.play_circle_fill : Icons.article,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      size: 14,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      _formatNumber(content.views),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Níveis de suporte (estilo Patreon)
  Widget _buildSupportTiers() {
    if (_supportTiers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Níveis de Suporte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Text(
                'Nenhum nível de suporte disponível',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Níveis de Suporte',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          ..._supportTiers.map((tier) => Column(
            children: [
              _buildSupportTier(
                tier.name,
                'R\$ ${tier.price.toStringAsFixed(0)}/mês',
                tier.description,
                Color(int.parse(tier.color.replaceFirst('#', '0xFF'))),
              ),
              SizedBox(height: 10),
            ],
          )),
        ],
      ),
    );
  }

  /// Tier de suporte individual
  Widget _buildSupportTier(String name, String price, String description, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Apoiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Seção de canais de comunidade
  Widget _buildChannelsSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meus Canais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          if (_channels.isEmpty)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Nenhum canal disponível',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _channels.length,
                itemBuilder: (context, index) {
                  final channel = _channels[index];
                  return GestureDetector(
                    onTap: () {
                      if (channel.type == 'chat') {
                        Navigator.pushNamed(context, '/community_chat', arguments: channel);
                      } else if (channel.type == 'mural') {
                        Navigator.pushNamed(context, '/community_mural', arguments: channel);
                      }
                    },
                    child: Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          // Conteúdo do canal
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      channel.type == 'chat' ? Icons.chat : Icons.image,
                                      size: 24,
                                      color: AppColors.btnSecondary,
                                    ),
                                    SizedBox(width: 8),
                                    if (channel.isPrivate)
                                      Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: Colors.amber[800],
                                      ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  channel.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                if (channel.description != null)
                                  Text(
                                    channel.description!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                SizedBox(height: 5),
                                Text(
                                  channel.type == 'chat' ? 'Chat' : 'Mural',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.btnSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
