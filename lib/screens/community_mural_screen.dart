import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';
import '../user_state.dart';
import '../constants.dart';

/// Tela de mural para canais de comunidade
/// Exibe posts e permite criar novos posts
class CommunityMuralScreen extends StatefulWidget {
  final Channel channel;

  const CommunityMuralScreen({super.key, required this.channel});

  @override
  State<CommunityMuralScreen> createState() => _CommunityMuralScreenState();
}

class _CommunityMuralScreenState extends State<CommunityMuralScreen> {
  final CommunityService _communityService = CommunityService(baseUrl: 'http://localhost:3000/api');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<MuralPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Carrega posts do mural
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await _communityService.getMuralPosts(widget.channel.id);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar posts: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Cria um novo post
  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || _isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final userState = Provider.of<UserState>(context, listen: false);
      final userId = userState.user?.id?.toString() ?? '1';

      await _communityService.createMuralPost(userId, widget.channel.id, {
        'title': title,
        'description': description,
      });

      _titleController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop(); // Fecha o modal
      await _loadPosts(); // Recarrega posts
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar post: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  /// Mostra modal para criar post
  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Criar novo post',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createPost,
                    child: _isCreating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Criar'),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        foregroundColor: AppColors.iconDark,
        title: Text(widget.channel.name),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de acesso
          if (widget.channel.isPrivate)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.amber[100],
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.amber[800]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Canal privado - Requer tier: ${widget.channel.tierRequired ?? 'N/A'}',
                      style: TextStyle(color: Colors.amber[800]),
                    ),
                  ),
                ],
              ),
            ),

          // Lista de posts
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadPosts,
                              child: Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : _posts.isEmpty
                        ? Center(child: Text('Nenhum post ainda'))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return _buildPostItem(post);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostModal,
        child: Icon(Icons.add),
        backgroundColor: AppColors.btnSecondary,
      ),
    );
  }

  /// Constrói item de post
  Widget _buildPostItem(MuralPost post) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            if (post.title != null)
              Text(
                post.title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 8),

            // Descrição
            if (post.description != null)
              Text(
                post.description!,
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 8),

            // Imagens (se houver)
            if (post.images != null && post.images!.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(post.images![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 8),

            // Metadados
            Row(
              children: [
                Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('${post.likes} likes'),
                SizedBox(width: 16),
                Text(
                  _formatTimestamp(post.createdAt),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            // Respostas
            if (post.replies.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Respostas (${post.replies.length})',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...post.replies.map((reply) => _buildReplyItem(reply)),
            ],
          ],
        ),
      ),
    );
  }

  /// Constrói item de resposta
  Widget _buildReplyItem(MuralPost reply) {
    return Container(
      margin: EdgeInsets.only(left: 16, bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reply.title != null)
            Text(
              reply.title!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          if (reply.description != null)
            Text(reply.description!),
          SizedBox(height: 4),
          Text(
            _formatTimestamp(reply.createdAt),
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Formata timestamp para exibição
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'Agora';
    }
  }
}
