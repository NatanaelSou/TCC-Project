import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../models/profile_models.dart';
import '../models/comment.dart';
import '../constants.dart';
import '../mock_data.dart';
import '../user_state.dart';

class VideoPlayerScreen extends StatefulWidget {
  final ProfileContent video;

  const VideoPlayerScreen({required this.video, super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  static const double wideScreenThreshold = 1000;

  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isFollowing = false;
  bool _isNotified = false;
  int _likes = 0;
  int _dislikes = 0;
  List<Comment> _comments = [];
  List<ProfileContent> _similarVideos = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadData();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl!));
    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  void _loadData() {
    // Load comments and similar videos
    setState(() {
      _comments = getCommentsForContent(widget.video.id);
      _similarVideos = getSimilarVideos(widget.video);
      // Mock like/dislike counts based on views
      _likes = (widget.video.views * 0.1).round();
      _dislikes = (widget.video.views * 0.02).round();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likes--;
      } else {
        _isLiked = true;
        _likes++;
        if (_isDisliked) {
          _isDisliked = false;
          _dislikes--;
        }
      }
    });
  }

  void _toggleDislike() {
    setState(() {
      if (_isDisliked) {
        _isDisliked = false;
        _dislikes--;
      } else {
        _isDisliked = true;
        _dislikes++;
        if (_isLiked) {
          _isLiked = false;
          _likes--;
        }
      }
    });
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  void _toggleNotify() {
    setState(() {
      _isNotified = !_isNotified;
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      final userState = Provider.of<UserState>(context, listen: false);
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contentId: widget.video.id,
        userId: userState.user?.id?.toString() ?? '1',
        text: _commentController.text.trim(),
        createdAt: DateTime.now(),
        likes: 0,
      );

      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > wideScreenThreshold;

        if (isWideScreen) {
          // Desktop layout: video + sidebar
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.sidebar,
              foregroundColor: AppColors.iconDark,
              title: Text(
                widget.video.title,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.iconDark),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video and details section
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVideoPlayer(),
                          const SizedBox(height: 16),
                          _buildVideoInfo(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                          const SizedBox(height: 16),
                          _buildDescription(),
                          const SizedBox(height: 24),
                          _buildCommentsSection(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Recommendations section
                    SizedBox(
                      width: 320,
                      child: _buildRecommendations(),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Mobile layout: drawer for recommendations
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.sidebar,
              foregroundColor: AppColors.iconDark,
              title: Text(
                widget.video.title,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.iconDark),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.video_library, color: AppColors.iconDark),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    tooltip: 'Vídeos recomendados',
                  ),
                ),
              ],
            ),
            endDrawer: Drawer(
              backgroundColor: AppColors.background,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.sidebar,
                        border: Border(
                          bottom: BorderSide(color: AppColors.textGrey.withOpacity(0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Vídeos Recomendados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close, color: AppColors.iconDark),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: _similarVideos.take(10).map((video) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop(); // Close drawer
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayerScreen(video: video),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 120,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                        image: NetworkImage(video.thumbnailUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        if (video.duration != null)
                                          Positioned(
                                            bottom: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: Text(
                                                video.duration!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop(); // Close drawer
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => VideoPlayerScreen(video: video),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textDark,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatNumber(video.views)} visualizações • ${_formatDate(video.createdAt)}',
                                          style: TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVideoPlayer(),
                    const SizedBox(height: 16),
                    _buildVideoInfo(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    const SizedBox(height: 24),
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  // Play/Pause overlay
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: Colors.white.withOpacity(0.8),
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  // Progress bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.btnSecondary,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: 250,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.video.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: Text(
                '${_formatNumber(widget.video.views)} visualizações',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(color: AppColors.textGrey),
            ),
            Text(
              _formatDate(widget.video.createdAt),
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Like button
          TextButton.icon(
            onPressed: _toggleLike,
            icon: Icon(
              _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: _isLiked ? AppColors.btnSecondary : AppColors.textGrey,
            ),
            label: Text(
              _formatNumber(_likes),
              style: TextStyle(
                color: _isLiked ? AppColors.btnSecondary : AppColors.textGrey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Dislike button
          TextButton.icon(
            onPressed: _toggleDislike,
            icon: Icon(
              _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: _isDisliked ? Colors.red : AppColors.textGrey,
            ),
            label: Text(
              _formatNumber(_dislikes),
              style: TextStyle(
                color: _isDisliked ? Colors.red : AppColors.textGrey,
              ),
            ),
          ),
          const Spacer(),
          // Follow button
          ElevatedButton.icon(
            onPressed: _toggleFollow,
            icon: Icon(
              _isFollowing ? Icons.person_add : Icons.person_add_outlined,
              size: 18,
            ),
            label: Text(_isFollowing ? 'Seguindo' : 'Seguir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing ? AppColors.btnSecondary : Colors.transparent,
              foregroundColor: _isFollowing ? Colors.white : AppColors.btnSecondary,
              side: BorderSide(color: AppColors.btnSecondary),
            ),
          ),
          const SizedBox(width: 8),
          // Notify button
          IconButton(
            onPressed: _toggleNotify,
            icon: Icon(
              _isNotified ? Icons.notifications : Icons.notifications_outlined,
              color: _isNotified ? AppColors.btnSecondary : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrição',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.video.description ?? 'Sem descrição disponível.',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (widget.video.tags != null && widget.video.tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.video.tags!.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.btnSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: AppColors.btnSecondary,
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vídeos Recomendados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ..._similarVideos.take(5).map((video) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(video: video),
                  ),
                ),
                child: Container(
                  width: 120,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: NetworkImage(video.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (video.duration != null)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              video.duration!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(video: video),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatNumber(video.views)} visualizações • ${_formatDate(video.createdAt)}',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_comments.length} comentários',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        // Add comment input
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.btnSecondary,
              child: Text(
                Provider.of<UserState>(context).name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Adicione um comentário...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.textGrey.withOpacity(0.3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addComment,
              icon: Icon(
                Icons.send,
                color: AppColors.btnSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Comments list
        ..._comments.map((comment) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.btnSecondary.withOpacity(0.2),
                child: Text(
                  comment.userId.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: AppColors.btnSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Usuário ${comment.userId}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(comment.createdAt),
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.text,
                      style: TextStyle(
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
                          icon: Icon(
                            Icons.thumb_up_outlined,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likes.toString(),
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.thumb_down_outlined,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
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
        )),
      ],
    );
  }
}
