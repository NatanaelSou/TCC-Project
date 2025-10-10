import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_state.dart';
import '../constants.dart';
import '../services/community_service.dart';
import '../models/community_models.dart';

/// Página principal da comunidade
/// Lista canais disponíveis e permite navegação para chat ou mural
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final CommunityService _communityService = CommunityService(baseUrl: 'http://localhost:3000/api');
  List<Channel> _channels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  /// Carrega canais disponíveis para o usuário
  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userState = Provider.of<UserState>(context, listen: false);
      final userId = userState.user?.id?.toString() ?? '1';

      final channels = await _communityService.getChannels(userId);
      setState(() {
        _channels = channels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar canais: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _loadChannels,
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
        title: Text('Comunidade'),
      ),
      body: _channels.isEmpty
          ? Center(
              child: Text(
                'Nenhum canal disponível',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _channels.length,
              itemBuilder: (context, index) {
                final channel = _channels[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      channel.type == 'chat' ? Icons.chat : Icons.image,
                      color: AppColors.btnSecondary,
                    ),
                    title: Text(channel.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (channel.description != null) Text(channel.description!),
                        Text(
                          channel.type == 'chat' ? 'Chat' : 'Mural',
                          style: TextStyle(color: AppColors.btnSecondary, fontWeight: FontWeight.bold),
                        ),
                        if (channel.isPrivate) Text('Canal privado', style: TextStyle(color: Colors.amber[800])),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (channel.type == 'chat') {
                        Navigator.pushNamed(context, '/community_chat', arguments: channel);
                      } else if (channel.type == 'mural') {
                        Navigator.pushNamed(context, '/community_mural', arguments: channel);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
