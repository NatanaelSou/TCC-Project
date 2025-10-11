import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  Channel? _selectedChannel;
  List<Message> _messages = [];
  List<MuralPost> _posts = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _contentLoading = false;
  bool _isSending = false;
  bool _isCreating = false;
  String? _contentError;

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

  /// Seleciona um canal e carrega seu conteúdo
  void _selectChannel(Channel channel) {
    setState(() {
      _selectedChannel = channel;
      _messages = [];
      _posts = [];
      _contentLoading = true;
      _contentError = null;
      _isSending = false;
      _isCreating = false;
      _messageController.clear();
      _titleController.clear();
      _descriptionController.clear();
    });

    if (channel.type == 'chat') {
      _loadMessages(channel.id);
    } else if (channel.type == 'mural') {
      _loadPosts(channel.id);
    }
  }

  /// Carrega mensagens do canal de chat
  Future<void> _loadMessages(String channelId) async {
    setState(() {
      _contentLoading = true;
      _contentError = null;
    });

    try {
      final messages = await _communityService.getMessages(channelId);
      setState(() {
        _messages = messages;
        _contentLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _contentError = 'Erro ao carregar mensagens: ${e.toString()}';
        _contentLoading = false;
      });
    }
  }

  /// Envia uma nova mensagem no chat
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final userState = Provider.of<UserState>(context, listen: false);
      final userId = userState.user?.id?.toString() ?? '1';

      await _communityService.sendMessage(userId, _selectedChannel!.id, {'text': text});

      _messageController.clear();
      await _loadMessages(_selectedChannel!.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// Rola para o final da lista de mensagens
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Constrói item de mensagem para o chat
  Widget _buildMessageItem(Message message) {
    final userState = Provider.of<UserState>(context);
    final isOwnMessage = message.senderId == userState.user?.id?.toString();

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isOwnMessage ? AppColors.btnSecondary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isOwnMessage ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isOwnMessage ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carrega posts do mural
  Future<void> _loadPosts(String channelId) async {
    setState(() {
      _contentLoading = true;
      _contentError = null;
    });

    try {
      final posts = await _communityService.getMuralPosts(channelId);
      setState(() {
        _posts = posts;
        _contentLoading = false;
      });
    } catch (e) {
      setState(() {
        _contentError = 'Erro ao carregar posts: ${e.toString()}';
        _contentLoading = false;
      });
    }
  }

  /// Cria um novo post no mural
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

      await _communityService.createMuralPost(userId, _selectedChannel!.id, {
        'title': title,
        'description': description,
      });

      _titleController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop();
      await _loadPosts(_selectedChannel!.id);
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

  /// Constrói item de post para o mural
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
                      ),
                      child: CachedNetworkImage(
                        imageUrl: post.images![index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
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

  /// Constrói item de resposta para o mural
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

  @override
  void dispose() {
    _messageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      floatingActionButton: _selectedChannel?.type == 'mural'
          ? FloatingActionButton(
              onPressed: _showCreatePostModal,
              backgroundColor: AppColors.btnSecondary,
              child: Icon(Icons.add),
            )
          : null,
      body: Row(
        children: [
          Container(
            width: 280,
            color: AppColors.sidebar,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _channels.length,
              itemBuilder: (context, index) {
                final channel = _channels[index];
                return ListTile(
                  leading: Icon(
                    channel.type == 'chat' ? Icons.chat : Icons.image,
                    color: AppColors.btnSecondary,
                  ),
                  title: Text(channel.name),
                  subtitle: Text(channel.type == 'chat' ? 'Chat' : 'Mural'),
                  onTap: () => _selectChannel(channel),
                );
              },
            ),
          ),
          Expanded(
            child: _selectedChannel == null
                ? Center(
                    child: Text(
                      'Selecione um canal',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  )
                : _selectedChannel!.type == 'chat'
                    ? Column(
                        children: [
                          if (_selectedChannel!.isPrivate)
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.amber[100],
                              child: Row(
                                children: [
                                  Icon(Icons.lock, color: Colors.amber[800]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Canal privado - Requer tier: ${_selectedChannel!.tierRequired ?? 'N/A'}',
                                      style: TextStyle(color: Colors.amber[800]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: _contentLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.btnSecondary),
                                    ),
                                  )
                                : _contentError != null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                                            SizedBox(height: 16),
                                            Text(
                                              _contentError!,
                                              style: TextStyle(color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () => _selectChannel(_selectedChannel!),
                                              child: Text('Tentar novamente'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _messages.isEmpty
                                        ? Center(
                                            child: Text(
                                              'Nenhuma mensagem ainda',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                            ),
                                          )
                                        : ListView.builder(
                                            controller: _scrollController,
                                            padding: EdgeInsets.all(16),
                                            itemCount: _messages.length,
                                            itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
                                          ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Digite sua mensagem...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    maxLines: null,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                                SizedBox(width: 8),
                                FloatingActionButton(
                                  onPressed: _isSending ? null : _sendMessage,
                                  mini: true,
                                  child: _isSending
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(Icons.send),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          if (_selectedChannel!.isPrivate)
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.amber[100],
                              child: Row(
                                children: [
                                  Icon(Icons.lock, color: Colors.amber[800]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Canal privado - Requer tier: ${_selectedChannel!.tierRequired ?? 'N/A'}',
                                      style: TextStyle(color: Colors.amber[800]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: _contentLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.btnSecondary),
                                    ),
                                  )
                                : _contentError != null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                                            SizedBox(height: 16),
                                            Text(
                                              _contentError!,
                                              style: TextStyle(color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () => _selectChannel(_selectedChannel!),
                                              child: Text('Tentar novamente'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _posts.isEmpty
                                        ? Center(
                                            child: Text(
                                              'Nenhum post ainda',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: EdgeInsets.all(16),
                                            itemCount: _posts.length,
                                            itemBuilder: (context, index) => _buildPostItem(_posts[index]),
                                          ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
