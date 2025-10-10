# Implementation Plan

## Overview
The goal of this implementation is to complete the MVP features outlined in README.md by adding the missing "Comunidade inicial (chat/mural)" functionality, which includes basic chat and mural (discussion board) features for creators and users to interact. This fits into the existing Premiora platform by providing a dedicated community space that integrates with user authentication, content publication, and simulated tier-based access restrictions. The current codebase has solid foundations for auth, content creation, and tiers, but lacks real-time or basic chat/mural interactions, which are essential for community building as described in the app's core concept of uniting content and community.

The scope includes creating a simple chat system for direct messaging or group chats restricted by tiers, and a mural as a threaded discussion board for posts and replies. This will use mock data initially for simplicity, with backend endpoints for persistence. High-level approach: Extend existing services and screens with new widgets for chat/mural, integrate with auth for access control, and ensure tier simulation restricts private chats/murals. This addresses the MVP gap without overcomplicating the initial version, allowing creators to open channels and users to participate.

## Types
Introduce new data models for chat messages, mural posts, and community channels, extending existing profile and content models with relationships for tier access.

- **ChatMessage**: Represents a single message in a chat.
  - Fields: id (String, unique identifier), senderId (String, user ID), channelId (String, chat/channel ID), text (String, message content, required, max 1000 chars), timestamp (DateTime, creation time), isPrivate (bool, tier-restricted), tierRequired (String?, ID of required tier for access).
  - Validation: text non-empty, senderId matches authenticated user.
  - Relationships: Belongs to User (sender), ChatChannel; references SupportTier if private.

- **MuralPost**: Extends ProfileContent for discussion board posts (like a simplified post with replies).
  - Fields: Inherits from ProfileContent (title, description, images, etc.); adds parentId (String?, for threading/replies), channelId (String, mural/channel ID), likes (int, default 0), replies (List<MuralPost>, nested for threads).
  - Validation: title or description required; respects tierRequired for private posts.
  - Relationships: Belongs to User (creator), CommunityChannel; can have child MuralPost (replies).

- **CommunityChannel**: Represents a chat room or mural board created by a creator.
  - Fields: id (String, unique), creatorId (String, creator user ID), name (String, channel name, required, max 50 chars), description (String?, optional), type (enum: 'chat' or 'mural'), isPrivate (bool, default false), tierRequired (String?, for private channels), members (List<String>, user IDs subscribed).
  - Validation: name unique per creator; tierRequired references valid SupportTier if private.
  - Relationships: Belongs to User (creator); has many ChatMessage or MuralPost; many-to-many with User (members).

Update existing SupportTier to include channelAccess (bool, whether tier grants access to private channels). No changes to User or ProfileContent beyond adding channelSubscriptions (List<String>, subscribed channel IDs).

## Files
Create new files for community features, modify existing services/screens for integration, and update configurations for dependencies.

- New files:
  - lib/models/community_models.dart: Define ChatMessage, MuralPost, CommunityChannel models with JSON serialization (using dart:convert patterns from profile_models.dart).
  - lib/services/community_service.dart: Handle API calls for channels, messages, posts (similar to content_service.dart).
  - lib/screens/community_page.dart: Main screen for browsing/joining channels, integrated into home navigation.
  - lib/screens/chat_screen.dart: Screen for chat interface, showing messages and input.
  - lib/screens/mural_screen.dart: Screen for mural discussion board, with post/reply UI.
  - lib/widgets/chat_message_bubble.dart: Reusable widget for displaying messages with tier badges.
  - lib/widgets/mural_post_card.dart: Widget for mural posts, extending content_section patterns.
  - backend/models/community.js: Sequelize models for Channel, Message, MuralPost (extend existing user/content models).
  - backend/services/communityService.js: Business logic for creating/joining channels, sending messages (mock tier checks).
  - backend/controllers/communityController.js: Handle CRUD for channels/messages.
  - backend/routes/communityRoutes.js: API routes (/channels, /channels/:id/messages, /murals/:id/posts).

- Existing files to modify:
  - lib/services/auth_service.dart: Add method to check user tier access for private channels (integrate with profile_service.getSupportTiers).
  - lib/screens/home_page.dart: Add 'Comunidade' tab to bottom navigation, routing to community_page.dart.
  - lib/screens/profile_page.dart: Add section for creator to create/manage channels (button to open channel creation modal).
  - backend/services/profileService.js: Add getChannels(userId) to fetch creator's channels.
  - backend/routes/profileRoutes.js: Add /profiles/:id/channels endpoint.
  - backend/index.js: Mount new communityRoutes at /api/community.
  - pubspec.yaml: Add dependency 'web_socket_channel: ^2.4.0' for real-time chat (if beyond mock; start with polling).
  - backend/package.json: Add 'socket.io' for real-time if needed (simulate with HTTP polling initially).

- No files to delete or move.
- Configuration updates: Update backend/config/db.js to include community tables in schema; add to schema.sql for migrations.

## Functions
Add new functions for community operations, modify existing auth/content functions for integration.

- New functions:
  - lib/services/community_service.dart: createChannel(creatorId, channelData) -> Future<CommunityChannel?> (POST /channels); joinChannel(userId, channelId) -> Future<bool> (PUT /channels/:id/members); sendMessage(channelId, messageData) -> Future<ChatMessage?> (POST /channels/:id/messages); getMessages(channelId, limit) -> Future<List<ChatMessage>> (GET /channels/:id/messages); createMuralPost(channelId, postData) -> Future<MuralPost?> (POST /murals/:id/posts); getMuralPosts(channelId) -> Future<List<MuralPost>> (GET /murals/:id/posts).
  - backend/services/communityService.js: createChannel(req, res) (validate tier, save to DB); addMessage(channelId, message) (check access, save); similar for mural posts.
  - lib/screens/community_page.dart: _loadChannels() (fetch and display channels); _createChannel() (modal for new channel).

- Modified functions:
  - lib/services/content_service.dart.createContent(creatorId, data): Add check if content is for a channel (if channelId present, route to community service).
  - backend/services/profileService.js.getProfile(userId): Include channels array in response.
  - lib/screens/profile_page.dart._buildSupportTiers(): Add channel creation button if user is creator.

- No functions to remove.

## Classes
Introduce new StatefulWidgets for community screens, extend existing providers if needed.

- New classes:
  - lib/screens/community_page.dart.CommunityPage (StatefulWidget): Lists channels, filters by type/private; key methods: buildChannelList(), _joinChannel().
  - lib/screens/chat_screen.dart.ChatScreen (StatefulWidget, extends StatefulWidget): Displays messages, handles input/send; key methods: _loadMessages(), _sendMessage(), inherits from post_detail_screen patterns.
  - lib/screens/mural_screen.dart.MuralScreen (StatefulWidget): Shows threaded posts; key methods: _loadPosts(), _createReply(); uses ListView.builder like post_detail_screen.
  - lib/services/community_service.dart.CommunityService (class): Singleton-like service with http methods; no inheritance.

- Modified classes:
  - lib/screens/home_page.dart.HomePage (_HomePageState): Add index 3 for CommunityPage in _pages list; update _onItemTapped() to navigate to community.
  - lib/screens/profile_page.dart.ProfilePage (_ProfilePageState): Add _channels list and buildChannelsSection() method.

- No classes to remove.

## Dependencies
Add WebSocket support for real-time chat updates, but start with HTTP polling to keep MVP simple; no major version changes.

- New packages (Flutter): web_socket_channel ^2.4.0 (for future real-time); sqflite ^2.3.0 if local caching needed (optional).
- Backend: socket.io ^4.7.2 (if real-time; simulate with setInterval polling initially). Update package.json and npm install.
- No version changes to existing (http, provider, file_picker remain).

## Testing
Implement unit tests for new models/services and widget tests for screens; manual verification for MVP flows.

- New test files: test/models/community_models_test.dart (JSON serialization, validation); test/services/community_service_test.dart (mock HTTP responses for create/send); test/widgets/chat_message_bubble_test.dart (rendering with tier badge).
- Modify existing: test/models/profile_models_test.dart to include channelSubscriptions; add integration test in test/integration/community_flow_test.dart (login -> create channel -> send message).
- Validation: Manual testing - create channel as creator, join/subscribe as user, post message/reply, verify tier restriction (mock user without tier can't access private). Use flutter test and backend unit tests with Jest.

## Implementation Order
Implement in sequence to build incrementally: models first, then backend, services, UI, integration.

1. Create community models in lib/models/community_models.dart and backend/models/community.js; update schema.sql with new tables (channels, messages, mural_posts); run migrations via execute_command 'node backend/insert_data.js' or SQL.
2. Implement backend services/controllers/routes for community (communityService.js, communityController.js, communityRoutes.js); add to index.js; test endpoints with curl (e.g., POST /api/community/channels).
3. Add lib/services/community_service.dart; integrate with auth_service for tier checks; update profile_service for channels.
4. Create widgets (chat_message_bubble.dart, mural_post_card.dart).
5. Implement screens (community_page.dart, chat_screen.dart, mural_screen.dart); integrate into home_page and profile_page.
6. Add tests and manual verification: Run flutter test, test chat flow, ensure tier simulation works (mock private channel access denied).
7. Update pubspec.yaml/backend package.json; run flutter pub get / npm install; final integration test.
