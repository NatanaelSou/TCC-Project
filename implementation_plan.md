# Implementation Plan

Create a comprehensive YouTube-like video player screen with likes/dislikes, follow functionality, description, comments section, recommended videos, and similar videos. This screen will replace the previous malfunctioning video player and integrate seamlessly with the existing content navigation system.

The implementation will enhance the video viewing experience by providing interactive features similar to popular video platforms, while maintaining the app's existing architecture and design patterns. It will include proper state management for user interactions, video playback controls, and responsive layout for different screen sizes.

[Types]
Add new data structures to support video player interactions and state management.

- VideoInteractionState: A class to track user interactions with videos including like/dislike status, follow status, and notification preferences. Fields: videoId (String), isLiked (bool), isDisliked (bool), isFollowing (bool), isNotified (bool), likeCount (int), dislikeCount (int).

- VideoRecommendation: Extend existing Recommendation model to include similarity scores and recommendation types. Add fields: similarityScore (double), recommendationType ('similar', 'recommended', 'trending').

- CommentReply: New model for nested comment replies. Fields: id (String), parentCommentId (String), userId (String), text (String), createdAt (DateTime), likes (int).

[Files]
Create new video player screen and modify existing files to support video functionality.

- New file: lib/screens/video_player_screen.dart - Main video player screen with YouTube-like layout including video player, controls, description, comments, and recommendations.

- New file: lib/widgets/video_player_controls.dart - Custom video player controls widget with play/pause, progress bar, volume, and fullscreen toggle.

- New file: lib/widgets/comment_section.dart - Comments display and input widget with replies support.

- New file: lib/widgets/video_recommendations.dart - Recommended and similar videos sidebar widget.

- New file: lib/widgets/like_dislike_buttons.dart - Like/dislike and follow buttons with state management.

- Modify: lib/widgets/content_section.dart - Re-enable video navigation by adding back the GestureDetector for video content and play icon overlay.

- Modify: lib/services/profile_service.dart - Add back video content fetching and add new methods for video interactions (like, dislike, follow, get recommendations).

- Modify: lib/mock_data.dart - Add mock data for video interactions and ensure video URLs are valid for testing.

- Modify: pubspec.yaml - Add video_player dependency (^2.8.1) for video playback functionality.

[Functions]
Implement new functions for video interactions and data fetching.

- New function: VideoPlayerScreen._toggleLike() - Handle like button press, update state and send to backend.

- New function: VideoPlayerScreen._toggleDislike() - Handle dislike button press, update state and send to backend.

- New function: VideoPlayerScreen._toggleFollow() - Handle follow/unfollow creator, update state and send to backend.

- New function: VideoPlayerScreen._loadVideoData() - Load video metadata, comments, and recommendations on screen initialization.

- New function: VideoPlayerScreen._submitComment() - Submit new comment and refresh comments list.

- New function: ContentService.likeVideo(String videoId) - API call to like a video.

- New function: ContentService.dislikeVideo(String videoId) - API call to dislike a video.

- New function: ContentService.followCreator(String creatorId) - API call to follow/unfollow a creator.

- New function: ContentService.getVideoRecommendations(String videoId) - Fetch recommended videos for a given video.

- New function: ContentService.getVideoComments(String videoId) - Fetch comments for a video.

- Modify function: ContentSection._navigateToVideoPlayer() - Restore video navigation functionality.

[Classes]
Extend existing classes and create new ones for video player functionality.

- New class: VideoPlayerControls - Stateful widget for video playback controls with custom UI.

- New class: CommentSection - Stateful widget for displaying and managing comments with replies.

- New class: VideoRecommendations - Stateless widget for displaying recommended and similar videos.

- New class: LikeDislikeButtons - Stateful widget for like/dislike/follow buttons with state management.

- Modify class: VideoPlayerScreen - Complete rewrite with YouTube-like layout, state management for interactions, and integration with new widgets.

- Modify class: ContentService - Add methods for video interactions and data fetching.

[Dependencies]
Add video_player package for video playback functionality.

- Add dependency: video_player: ^2.8.1 - Official Flutter package for video playback with network and asset support.

[Testing]
Test video player functionality across different scenarios.

- Unit tests: Test video interaction state management and API calls in ContentService.

- Widget tests: Test VideoPlayerScreen, VideoPlayerControls, CommentSection, and VideoRecommendations widgets.

- Integration tests: Test full video viewing flow from content section to video player, including navigation, playback, and interactions.

- Manual testing: Verify video playback on different devices, test like/dislike/follow functionality, comment submission, and recommendation loading.

[Implementation Order]
Implement in logical sequence to ensure dependencies are met.

1. Add video_player dependency to pubspec.yaml and run flutter pub get.

2. Create VideoInteractionState and CommentReply models in appropriate files.

3. Implement ContentService methods for video interactions and data fetching.

4. Create VideoPlayerControls widget.

5. Create LikeDislikeButtons widget.

6. Create CommentSection widget.

7. Create VideoRecommendations widget.

8. Implement VideoPlayerScreen with YouTube-like layout.

9. Modify ContentSection to re-enable video navigation.

10. Update mock data to support video interactions.

11. Test video player functionality and fix any issues.
