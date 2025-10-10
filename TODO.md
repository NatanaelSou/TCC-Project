# TODO: Implement Community Features

## Overview
Implement community screens for chat and mural channels, update profile page to display user's channels, add navigation routes, and ensure tier-based access control.

## Goals
- Create community_chat_screen.dart for chat channels with message display and sending.
- Create community_mural_screen.dart for mural channels with post creation and display.
- Update profile_page.dart to show user's created channels with navigation.
- Add routes in main.dart for community screens.
- Ensure UI is responsive and integrates with Material Design.
- Add comments in Portuguese for new code.
- Test community features including tier restrictions.

## Steps
- [x] Update ProfileService.getChannels to return List<Channel>
- [x] Update profile_page.dart to add channels section with navigation
- [x] Create lib/screens/community_chat_screen.dart
- [x] Create lib/screens/community_mural_screen.dart
- [x] Update lib/main.dart to add routes for community screens
- [ ] Test community features: create channels, join, send messages, create mural posts, ensure tier restrictions work
- [ ] Ensure UI responsiveness and Material Design integration
