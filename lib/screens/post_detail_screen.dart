import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../models/comment.dart';
import '../constants.dart';
import '../mock_data.dart';
import '../services/content_service.dart';

class PostDetailScreen extends StatefulWidget {
  final ProfileContent post;

  const PostDetailScreen({required this.post, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Estados para interações
  bool _isUpvoted = false;
  bool _isDownvoted = false;
  bool _isSaved = false;
  int _upvotes = 0;
  int _downvotes = 0;
  List<Comment> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final ContentService _contentService = ContentService();

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  void _loadPostData() {
    // Carrega comentários usando dados mock
    setState(() {
      _comments = getCommentsForContent(widget.post.id);
      // Mock upvotes/downvotes baseado em visualizações
      _upvotes = (widget.post.views * 0.1).round();
      _downvotes = (widget.post.views * 0.02).round();
    });
  }

  void _toggleUpvote() {
    setState(() {
      if (_isUpvoted) {
        _isUpvoted = false;
        _upvotes--;
      } else {
        _isUpvoted = true;
        _upvotes++;
        if (_isDownvoted) {
          _isDownvoted = false;
          _downvotes--;
        }
      }
    });
  }

  void _toggleDownvote() {
    setState(() {
      if (_isDownvoted) {
        _isDownvoted = false;
        _downvotes--;
      } else {
        _isDownvoted = true;
        _downvotes++;
        if (_isUpvoted) {
          _isUpvoted = false;
          _upvotes--;
        }
      }
    });
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  void _sharePost() {
    // TODO: Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhar post (não implementado)')),
    );
  }

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      // Usar serviço para adicionar comentário
      final newComment = await _contentService.addComment(
        widget.post.id,
        '1', // ID do usuário mock
        _commentController.text.trim(),
      );

      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar comentário: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _sharePost,
            icon: const Icon(Icons.share, color: AppColors.textGrey),
          ),
          IconButton(
            onPressed: _toggleSave,
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(),
            _buildPostContent(),
            _buildPostActions(),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do criador e data
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.btnSecondary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.post.creatorId ?? 'Anônimo'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (widget.post.isPrivate) ...[
                          const SizedBox(width: 8),
                          _buildTierBadge(),
                        ],
                      ],
                    ),
                    Text(
                      _formatDate(widget.post.createdAt),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Título do post
          Text(
            widget.post.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge() {
    final tier = mockSupportTiers.firstWhere(
      (t) => t.id == widget.post.tierRequired,
      orElse: () => mockSupportTiers.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Color(int.parse('0xFF${tier.color.substring(1)}')).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(int.parse('0xFF${tier.color.substring(1)}')),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            size: 12,
            color: Color(int.parse('0xFF${tier.color.substring(1)}')),
          ),
          const SizedBox(width: 4),
          Text(
            tier.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(int.parse('0xFF${tier.color.substring(1)}')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descrição
          if (widget.post.description != null && widget.post.description!.isNotEmpty)
            Text(
              widget.post.description!,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),
          // Imagens
          if (widget.post.images != null && widget.post.images!.isNotEmpty)
            _buildImages(),
        ],
      ),
    );
  }

  Widget _buildImages() {
    if (widget.post.images!.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.post.images!.first,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: widget.post.images!.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.post.images![index],
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }
  }

  Widget _buildPostActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.cardBg,
      child: Row(
        children: [
          // Upvote/Downvote
          Row(
            children: [
              IconButton(
                onPressed: _toggleUpvote,
                icon: Icon(
                  _isUpvoted ? Icons.arrow_upward : Icons.arrow_upward_outlined,
                  color: _isUpvoted ? Colors.orange : AppColors.textGrey,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '${_upvotes - _downvotes}',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: _toggleDownvote,
                icon: Icon(
                  _isDownvoted ? Icons.arrow_downward : Icons.arrow_downward_outlined,
                  color: _isDownvoted ? Colors.blue : AppColors.textGrey,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Spacer(),
          // Comentários
          Row(
            children: [
              const Icon(
                Icons.comment,
                color: AppColors.textGrey,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${_comments.length}',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Visualizações
          Row(
            children: [
              const Icon(
                Icons.visibility,
                color: AppColors.textGrey,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.post.views}',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de entrada de comentário
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.btnSecondary,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Adicione um comentário...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submitComment,
                child: const Text('Comentar'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Lista de comentários
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return _buildCommentItem(comment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.btnSecondary,
            child: Icon(Icons.person, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${comment.userId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(comment.createdAt),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_upward_outlined,
                        size: 16,
                        color: AppColors.textGrey,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.likes.toString(),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Responder',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'hoje';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
