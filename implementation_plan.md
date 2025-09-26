# Implementation Plan

The overall goal is to create a functional account registration page and integrate login/registration screens into the landing page, connecting them to the existing backend API for authentication.

The project is a Flutter mobile app with a Node.js/Express/MySQL backend. The landing page (lib/screens/landing_page.dart) already includes modal dialogs for login and registration, but they are currently dummy implementations that simply navigate to the home page without actual API calls. A separate LoginScreen (lib/screens/login_screen.dart) exists with basic form validation and AuthService integration for login, but it lacks registration functionality. The AuthService (lib/services/auth_service.dart) has both login and register methods, but the register endpoint needs backend support. The backend has user routes but only for GET users; the POST /register endpoint is missing. The User model (lib/models/user.dart) supports the required fields (id, name, email, etc.). Passwords are stored in plain text, which is insecure, but will be implemented as-is unless specified otherwise. The implementation will connect the landing page modals to AuthService for real authentication, update UserState on success, and navigate to HomePage. Validation will use existing Validators utility. No new dependencies are needed.

The implementation fits into the existing system by leveraging the Provider state management for UserState, HttpService for API calls, and the backend's MySQL 'users' table (fields: id, name, email, password, created_at, etc.). This enables user registration and login from the landing page, protecting routes like HomePage behind authentication checks if needed in future.

[Types]  
No new type system changes are required; existing User model and HttpException are sufficient.

The User class already includes fields for id (int?), name (String), email (String), avatarUrl (String?), createdAt (DateTime?). For registration, we'll use name, email, password (not stored in model, handled by backend). Validation rules: email must be valid format (using Validators.email), password min 6 chars (using Validators.password), name non-empty. Relationships: UserState holds the current User instance after login/register.

[Files]
No new files to be created; modifications to existing files only. No files to be deleted or moved.

- lib/screens/landing_page.dart: Update _buildRegisterModal and _buildLoginModal to include form validation, loading states, error handling, and call AuthService.register/login. Add _handleRegister and _handleLogin methods similar to LoginScreen. Import necessary services (AuthService, UserState, Validators). Ensure modals close on success and update UserState.
- lib/services/auth_service.dart: Update login endpoint from '/worker-login' to '/login' to match backend route /api/login. Register endpoint already updated to '/users/register'.
- backend/routes/userRoutes.js: Add POST '/register' route mapping to userController.registerUser.
- backend/controllers/userController.js: Already has registerUser method; ensure it returns {user: {id, name, email}} to match frontend expectation.
- lib/services/http_service.dart: No changes; baseUrl is 'http://localhost:3000/api', so endpoints resolve correctly.
- pubspec.yaml: No configuration updates needed.

[Functions]
New functions will be added to handle authentication in landing page; modifications to existing backend functions.

- New functions in lib/screens/landing_page.dart:
  - Future<void> _handleRegister(): Calls AuthService.register with form data, handles loading/error, updates UserState, navigates to HomePage on success.
  - Future<void> _handleLogin(): Calls AuthService.login with form data, handles loading/error, updates UserState, navigates to HomePage on success.
- Modified functions:
  - In lib/services/auth_service.dart: login() - change body keys from 'userNameOrEmail' to 'email' and endpoint to '/login'.
  - In backend/routes/userRoutes.js: Add router.post('/register', userController.registerUser); (new route function).
- No functions to be removed.

[Classes]
No new classes; minor modifications to existing StatefulWidgets for state management.

- Modified classes:
  - _LandingPageState in lib/screens/landing_page.dart: Add state variables for loading (bool _registerLoading, _loginLoading) and errors (String? _registerError, _loginError). Add controllers for forms if not present. Integrate Provider.of<UserState> in handlers.
  - AuthService in lib/services/auth_service.dart: Update login method as above; no class-level changes.
- No classes to be removed.

[Dependencies]
No new dependencies or version changes required.

The existing http (^1.1.0) and provider (^6.0.6) packages suffice for API calls and state management. Backend uses express, mysql2, etc., already in package.json. No integration requirements beyond ensuring backend server runs on port 3000.

[Testing]
Unit tests for new functionality using existing test structure; integration tests for API calls.

Create or update test/models/user_test.dart to include register scenarios. Add widget tests in test/ for landing page modals (simulate form submission, mock AuthService). Backend: Add manual tests via Postman for /api/users/register (POST with email/password/name, expect 201 with user). Validation: Test error cases (duplicate email, invalid data). No modifications to existing tests needed, but run flutter test after changes.

[Implementation Order]
Implement backend first, then frontend integration to allow testing API endpoints before UI.

1. Update backend/routes/userRoutes.js to add POST /register route.
2. Verify backend: Run node backend/index.js, test /api/users/register via curl or Postman (ensure users table handles inserts, returns user data).
3. Update lib/services/auth_service.dart login method (endpoint and body).
4. Update lib/screens/landing_page.dart: Add _handleRegister and _handleLogin functions, integrate into modals with validation, loading, error display.
5. Test frontend: Run flutter run, open landing page, test register/login modals (check console for API calls, UserState update, navigation).
6. Add any missing imports (e.g., Provider in landing_page.dart if not present).
7. Run full tests: flutter test, ensure no regressions.
