import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';
import '../user_state.dart';
import '../constants.dart';

/// Tela de chat para canais de comunidade
/// Exibe mensagens e permite enviar novas mensagens
class CommunityChatScreen extends StatefulWidget {
  final Channel channel;

  const CommunityChatScreen({super.key, required this.channel});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final CommunityService _communityService = CommunityService(baseUrl: 'http://localhost:3000/api');
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Carrega mensagens do canal
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final messages = await _communityService.getMessages(widget.channel.id);
      setState(() {
        _messages = messages; // Ordem cronológica: antigas no topo, recentes no final
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar mensagens: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Envia uma nova mensagem
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final userState = Provider.of<UserState>(context, listen: false);
      final userId = userState.user?.id?.toString() ?? '1';

      await _communityService.sendMessage(userId, widget.channel.id, {'text': text});

      _messageController.clear();
      await _loadMessages(); // Recarrega mensagens após enviar
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

  /// Rola para o final da lista de mensagens (mais recentes)
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
            onPressed: _loadMessages,
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

          // Lista de mensagens
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
                              onPressed: _loadMessages,
                              child: Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                        : _messages.isEmpty
                            ? Center(child: Text('Nenhuma mensagem ainda'))
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return _buildMessageItem(message);
                                },
                              ),
          ),

          // Campo de entrada de mensagem
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
                  child: _isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói item de mensagem
  Widget _buildMessageItem(Message message) {
    final userState = Provider.of<UserState>(context);
    final isOwnMessage = message.senderId == userState.user?.id?.toString();

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
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
            SizedBox(height: 4),
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
