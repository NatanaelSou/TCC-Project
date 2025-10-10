import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/profile_models.dart';
import '../models/comment.dart';
import '../constants.dart';
import '../mock_data.dart';

class VideoPlayerScreen extends StatefulWidget {
  final ProfileContent video;

  const VideoPlayerScreen({required this.video, super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Breakpoints responsivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1000;
  static const double desktopBreakpoint = 1400;

  late VideoPlayerController _controller;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isFollowing = false;
  bool _isMuted = false;
  bool _isFullscreen = false;
  bool _isDescriptionExpanded = false;
  int _likes = 0;
  int _dislikes = 0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  List<Comment> _comments = [];
  List<ProfileContent> _similarVideos = [];
  List<ProfileContent> _recommendedVideos = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
    _loadVideoData();
  }

  Future<void> _initializeVideo() async {
    if (widget.video.videoUrl == null) {
      throw Exception('O vídeo não possui uma URL válida.');
    }
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl!));
    await _controller.initialize();

    // Initialize animation controller for controls
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlsAnimationController, curve: Curves.easeInOut),
    );

    setState(() {
      _isInitialized = true;
      _totalDuration = _controller.value.duration;
    });
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        _currentPosition = _controller.value.position;
        _totalDuration = _controller.value.duration;
      });
    }
  }

  void _onVideoTap() {
    _controlsTimer?.cancel();
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _controlsAnimationController.forward();
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
          _controlsAnimationController.reverse();
        }
      });
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void _seekToPosition(Duration position) {
    _controller.seekTo(position);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    // TODO: Implement fullscreen mode
  }

  void _loadVideoData() {
    // Load comments and similar videos
    setState(() {
      _comments = getCommentsForContent(widget.video.id);
      _similarVideos = getSimilarVideos(widget.video);
      _recommendedVideos = mockVideos.where((v) => v.id != widget.video.id).take(5).toList();
      // Mock like/dislike counts based on views
      _likes = (widget.video.views * 0.1).round();
      _dislikes = (widget.video.views * 0.02).round();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _controlsAnimationController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    _controlsTimer?.cancel();
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

  void _toggleDescriptionExpanded() {
    setState(() {
      _isDescriptionExpanded = !_isDescriptionExpanded;
    });
  }



  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contentId: widget.video.id,
      userId: '1', // Mock user ID
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
      likes: 0,
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > tabletBreakpoint;
    final isMobile = screenWidth <= mobileBreakpoint;
    final isTablet = screenWidth > mobileBreakpoint && screenWidth <= tabletBreakpoint;
    final isDesktop = screenWidth > tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isWideScreen ? _buildWideScreenLayout() : _buildNarrowScreenLayout(),
      ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Row(
      children: [
        // Main video area
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildVideoPlayer(),
                _buildVideoInfo(),
                _buildActionButtons(),
                _buildDescription(),
                _buildCommentsSection(),
              ],
            ),
          ),
        ),
        // Recommendations sidebar
        Container(
          width: 400,
          height: double.infinity,
          color: AppColors.cardBg,
          child: _buildRecommendations(),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          _buildVideoPlayer(),
          _buildVideoInfo(),
          _buildActionButtons(),
          _buildDescription(),
          _buildCommentsSection(),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isInitialized) {
      return Container(
        height: 250,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: GestureDetector(
        onTap: _onVideoTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller),
            _buildVideoControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= mobileBreakpoint;

    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: screenWidth <= tabletBreakpoint ? 1.0 : _controlsAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isMobile ? [
                  Colors.black.withOpacity(0.98),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.6),
                ] : [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top controls (mute, fullscreen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _toggleMute,
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleFullscreen,
                      icon: Icon(
                        _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Center play/pause button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        final newPosition = _currentPosition - const Duration(seconds: 10);
                        _seekToPosition(newPosition < Duration.zero ? Duration.zero : newPosition);
                      },
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        final newPosition = _currentPosition + const Duration(seconds: 10);
                        _seekToPosition(newPosition > _totalDuration ? _totalDuration : newPosition);
                      },
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Bottom progress bar and time
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Progress bar
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: Colors.red,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.red,
                          overlayColor: Colors.red.withOpacity(0.3),
                        ),
                        child: Slider(
                          value: _currentPosition.inSeconds.toDouble(),
                          max: _totalDuration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _seekToPosition(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      // Time display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_totalDuration),
                            style: const TextStyle(
                              color: Colors.white,
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
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video title
          Text(
            widget.video.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          // Creator info row
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.btnSecondary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criador ${widget.video.creatorId ?? 'Anônimo'}', // Mock creator name
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '1.2M inscritos', // Mock subscriber count
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: ElevatedButton.icon(
                  onPressed: _toggleFollow,
                  icon: Icon(
                    _isFollowing ? Icons.notifications : Icons.notifications_outlined,
                    size: 16,
                  ),
                  label: Text(_isFollowing ? 'Inscrito' : 'Inscrever-se'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? AppColors.btnSecondary : Colors.transparent,
                    foregroundColor: _isFollowing ? Colors.white : AppColors.btnSecondary,
                    side: BorderSide(color: AppColors.btnSecondary),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Views and date
          Row(
            children: [
              Text(
                '${widget.video.views} visualizações',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _formatDate(widget.video.createdAt),
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

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= mobileBreakpoint;
    final textFontSize = isMobile ? 10.0 : 14.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.start,
        children: [
          // Like button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: _isLiked ? Colors.blue : AppColors.textGrey,
                ),
              ),
              Text(
                _likes.toString(),
                style: TextStyle(color: AppColors.textGrey, fontSize: textFontSize),
              ),
            ],
          ),
          // Dislike button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _toggleDislike,
                icon: Icon(
                  _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  color: _isDisliked ? Colors.red : AppColors.textGrey,
                ),
              ),
              Text(
                _dislikes.toString(),
                style: TextStyle(color: AppColors.textGrey, fontSize: textFontSize),
              ),
            ],
          ),
          // Share button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implement share functionality
                },
                icon: const Icon(
                  Icons.share,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                'Compartilhar',
                style: TextStyle(color: AppColors.textGrey, fontSize: textFontSize),
              ),
            ],
          ),
          // Spacer equivalent in Wrap
          const SizedBox(width: double.infinity),
          // Save button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implement save functionality
                },
                icon: const Icon(
                  Icons.bookmark_border,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                'Salvar',
                style: TextStyle(color: AppColors.textGrey, fontSize: textFontSize),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    const int maxDescriptionLength = 100;
    final description = widget.video.description ?? 'Sem descrição disponível.';
    final isLongDescription = description.length > maxDescriptionLength;
    final displayText = isLongDescription && !_isDescriptionExpanded
        ? '${description.substring(0, maxDescriptionLength)}...'
        : description;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descrição',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayText,
            style: const TextStyle(
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          if (isLongDescription)
            TextButton(
              onPressed: _toggleDescriptionExpanded,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isDescriptionExpanded ? 'Mostrar menos' : 'Mostrar mais',
                style: const TextStyle(
                  color: AppColors.btnSecondary,
                  fontSize: 14,
                ),
              ),
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
          Text(
            '${_comments.length} comentários',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Comment input
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.btnSecondary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Adicione um comentário...',
                    border: OutlineInputBorder(),
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
          const SizedBox(height: 16),
          // Comments list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.btnSecondary,
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usuário ${comment.userId}', // Mock username
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              fontSize: 14,
                            ),
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
            },
          ),
        ],
      ),
    );
  }



  Widget _buildRecommendations() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > tabletBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Vídeos recomendados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (isWideScreen)
          Expanded(
            child: ListView.builder(
              itemCount: _recommendedVideos.length,
              itemBuilder: (context, index) {
                final video = _recommendedVideos[index];
                return _buildRecommendedVideoItem(video);
              },
            ),
          )
        else
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: _recommendedVideos.length,
              itemBuilder: (context, index) {
                final video = _recommendedVideos[index];
                return _buildRecommendedVideoItem(video);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedVideoItem(ProfileContent video) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(video: video),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(video.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.views} visualizações',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      return '${date.day}/${date.month}';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;
    if (state == AppLifecycleState.paused) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _controller.play();
      }
    }
  }
}
