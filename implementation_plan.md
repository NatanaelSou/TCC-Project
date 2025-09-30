# Implementation Plan

[Overview]
The goal is to modify the home page top bar to reduce the search field size, add a "+" button next to the avatar for content creation, implement a bottom sheet for content type selection, and create a new page for adding content with fields like title, description, categories, keywords, 18+ flag, privacy, quality (for videos), thumbnail/images, following the Premiora platform's content creation parameters from README.md, ensuring new content is reflected in the home page sections.

This implementation enhances user experience by providing an intuitive way for creators to add content directly from the home page, aligning with the platform's focus on flexible content creation (posts, videos, live streams, etc.) and monetization tiers. It fits into the existing Flutter app structure, extending the ProfileContent model and integrating with mock data or future backend services for persistence. The changes will maintain the app's UI/UX consistency using existing constants and widgets.

[Types]  
Extend the ProfileContent model to support new fields for content creation, including categories, keywords, is18Plus, isPrivate, quality, and media-specific fields.

- ProfileContent (updated in lib/models/profile_models.dart):
  - Existing fields: id (String), title (String, required, max 200 chars), type (String: 'post', 'video', 'live', 'podcast', etc., required), thumbnailUrl (String, optional for videos/live), createdAt (DateTime), views (int, default 0), category (String, optional).
  - New fields: description (String, required, max 1000 chars), keywords (List<String>, optional, comma-separated input), is18Plus (bool, default false), isPrivate (bool, default false, only for subscribers), quality (String: 'low', 'medium', 'high', optional for video/live), images (List<String>, optional for posts, up to 5 URLs or file uploads), tierRequired (String, optional, links to SupportTier id for exclusive content).
  - Validation rules: Title and description non-empty, keywords max 10 items, images valid URLs or local files, type-specific validations (e.g., thumbnail required for video/live).
  - Relationships: Links to User model via creatorId (add to model), SupportTier for exclusive content.

- New enum ContentType in lib/models/profile_models.dart:
  enum ContentType { post, video, live, podcast, course, other }
  - Used for bottom sheet selection and type validation.

[Files]
Modify existing files for UI updates and create new files for content creation flow.

- New files to be created:
  - lib/screens/content_creation_page.dart: New StatefulWidget for the content addition form page, handling form fields, validation, and submission.
  - lib/widgets/content_type_bottom_sheet.dart: StatelessWidget for the bottom sheet to select content type (Post, Video, Live Stream, etc.), with buttons navigating to ContentCreationPage with pre-set type.
  - lib/services/content_service.dart: New service for handling content creation API calls (mock or real), including createContent method returning Future<ProfileContent>.

- Existing files to be modified:
  - lib/screens/home_page.dart: Reduce search TextField width (e.g., flex 2 instead of Expanded), add IconButton with "+" icon next to avatar GestureDetector, onPressed opens content_type_bottom_sheet. Update _buildHomePage to refresh content lists after addition using setState or Provider notifier.
  - lib/models/profile_models.dart: Update ProfileContent class with new fields and fromJson/toJson methods to handle them.
  - lib/mock_data.dart: Add function to append new content to mock lists (mockRecentPosts, mockVideos, etc.) for immediate reflection.
  - lib/constants.dart: Add new constants if needed, e.g., maxDescriptionLength = 1000.

- No files to be deleted or moved.
- Configuration file updates: None required, but pubspec.yaml may need image_picker or file_picker if handling local uploads (add dependencies if confirmed).

[Functions]
Add new functions for UI interaction and content handling, modify existing ones for refresh.

- New functions:
  - void _openContentTypeBottomSheet(BuildContext context) in lib/screens/home_page.dart: Shows bottom sheet with ContentType options, navigates to ContentCreationPage on selection.
  - Future<ProfileContent?> createContent(Map<String, dynamic> data) in lib/services/content_service.dart: Validates and creates content (mock: returns new ProfileContent; real: POST to /api/content).
  - void _addContentToMocks(ProfileContent content) in lib/mock_data.dart: Appends to appropriate mock list based on type and refreshes home page via Provider or callback.

- Modified functions:
  - Widget build in lib/screens/home_page.dart: Update top bar Row to include sized search (Container with width: MediaQuery.of(context).size.width * 0.6 or flex), add + button as IconButton(icon: Icon(Icons.add, color: AppColors.btnSecondary), onPressed: _openContentTypeBottomSheet).
  - List<ProfileContent> filterContents in _buildHomePage of home_page.dart: No change, but call setState after addition to refresh.
  - No removed functions.

[Classes]
Introduce new classes for the creation flow, update existing model class.

- New classes:
  - ContentCreationPage (StatefulWidget) in lib/screens/content_creation_page.dart: Form with TextFormField for title/description/keywords, DropdownButton for type/category/tier, Switch for is18Plus/isPrivate, Slider or Dropdown for quality, image picker for thumbnail/images. Key methods: buildForm, _submitForm (validates, calls createContent, pops with result).
  - ContentTypeBottomSheet (StatelessWidget) in lib/widgets/content_type_bottom_sheet.dart: Builds BottomSheet with ListView of buttons for each ContentType, onTap navigates to ContentCreationPage(type: selectedType).

- Modified classes:
  - ProfileContent in lib/models/profile_models.dart: Add new fields, update constructors, fromJson/toJson to parse new fields (e.g., keywords: List<String>.from(json['keywords'] ?? [])).
  - HomePageState in lib/screens/home_page.dart: Add method to handle content addition callback, refresh UI.

- No removed classes.

[Dependencies]
No new dependencies for basic implementation; use existing Provider and http. If file uploads needed, add image_picker: ^1.0.4 and file_picker: ^6.1.1 to pubspec.yaml under dependencies, then run flutter pub get.

[Testing]
Create unit and widget tests to verify form validation, UI components, and content reflection.

- New test files: test/screens/content_creation_page_test.dart (widget tests for form submission, validation errors), test/services/content_service_test.dart (unit tests for createContent mock/real).
- Existing test modifications: Update test/models/profile_models_test.dart to test new ProfileContent fields.
- Validation strategies: Mock form inputs, assert on successful creation and UI refresh; test edge cases like empty fields, invalid images.

[Implementation Order]
Implement in sequence to build incrementally and test at each step.

1. Update ProfileContent model in lib/models/profile_models.dart with new fields and serialization.
2. Create lib/services/content_service.dart with mock createContent function.
3. Create lib/widgets/content_type_bottom_sheet.dart and test bottom sheet navigation.
4. Create lib/screens/content_creation_page.dart with form fields, validation, and submission calling content_service.
5. Modify lib/mock_data.dart to support adding new content to lists.
6. Update lib/screens/home_page.dart: Resize search bar, add + button, integrate bottom sheet and refresh logic.
7. Add tests in test/ directory and run flutter test to verify.
8. If backend integration needed, add routes/controllers in backend/ for /api/content (POST), but keep MVP mock-based.
