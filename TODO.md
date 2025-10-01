# TODO: Redesign Video Player Screen Layout

## Overview
Redesign `lib/screens/video_player_screen.dart` to have a layout similar to YouTube/Patreon while maintaining the Premiora design style and color scheme from `lib/constants.dart`.

## Goals
- Create a YouTube/Patreon-like layout with video player at top, followed by video info, actions, description, and comments.
- Add sidebar for recommendations on wide screens.
- Ensure responsiveness across mobile, tablet, and desktop.
- Maintain existing functionality and state management.
- Use consistent colors and dimensions from constants.dart.

## Steps
- [x] Analyze current layout structure in `_buildWideScreenLayout` and `_buildNarrowScreenLayout`.
- [x] Refactor `_buildVideoInfo` to include creator information (avatar, name, subscribers) in a YouTube-like row.
- [x] Update `_buildActionButtons` to include share button and rearrange like/dislike/subscribe buttons in YouTube style.
- [x] Modify `_buildDescription` to make it expandable/collapsible like YouTube.
- [x] Adjust `_buildCommentsSection` for better spacing and layout.
- [x] Update `_buildWideScreenLayout` to ensure proper flex ratios and spacing.
- [x] Update `_buildNarrowScreenLayout` to stack sections vertically with appropriate padding.
- [x] Test responsiveness by checking breakpoints and layout behavior.
- [x] Verify color usage matches constants.dart throughout the layout.
- [x] Test video controls and interactions remain functional.
- [x] Final visual check for YouTube/Patreon similarity while maintaining Premiora style.
