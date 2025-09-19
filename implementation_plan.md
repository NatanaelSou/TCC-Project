# Implementation Plan for Frontend Modularization

## Overview
Refactor the current single-page application (SPA) in `root/index.html` into a multi-page application with separate HTML files for landing page, login, register, and dashboard. Implement clean navigation flow: landing page → login/register → dashboard. Use the provided image as inspiration for a clean, modern landing page design. Maintain existing backend API integration and session management.

## Information Gathered
- Current `root/index.html` mixes landing/dashboard content with modal-based login/register.
- `root/scripts/index.js` handles dynamic content switching within the same page, user session via localStorage, and API calls to localhost:3000.
- `root/css/styles.css` provides styling for the current layout, including sidebar, main content, modals, and responsive design.
- No separate pages exist; all UI is managed dynamically in one HTML file.
- User session is stored in localStorage; login/register redirects to dashboard view.
- Backend APIs: /api/users (GET/POST), /api/content, /api/subscriptions.

## Plan
### File Structure Changes
- **New Files to Create:**
  - `root/landing.html` - Clean, modern landing page with hero section, features, and call-to-action buttons for login/register.
  - `root/login.html` - Dedicated login page with form and link to register.
  - `root/register.html` - Dedicated register page with form and link to login.
  - `root/dashboard.html` - Main dashboard page with sidebar, creator sections, and navigation (replaces current index.html content).
  - `root/scripts/landing.js` - JavaScript for landing page interactions (e.g., button clicks to navigate to login/register).
  - `root/scripts/auth.js` - Shared authentication logic for login/register pages (handleLogin, handleRegister, session management).
  - `root/scripts/dashboard.js` - JavaScript for dashboard page (content loading, sidebar navigation, community features).
  - `root/css/landing.css` - Styles specific to landing page (hero, features, etc.).
  - `root/css/auth.css` - Styles for login/register pages (forms, modals if needed).
  - `root/css/dashboard.css` - Styles for dashboard (sidebar, main content, community).

- **Existing Files to Modify:**
  - `root/index.html` - Redirect to landing.html or dashboard.html based on session; or remove and use as template.
  - `root/scripts/index.js` - Split into landing.js, auth.js, dashboard.js; remove dynamic switching logic.
  - `root/css/styles.css` - Split into landing.css, auth.css, dashboard.css; keep shared styles in a common file if needed.

- **Removed Files (if applicable):**
  - None; keep current files as backup or reference.

### UI/UX Flow
1. **Landing Page (`landing.html`):** Clean, modern design inspired by provided image. Hero section with app description, features list, testimonials, and prominent "Login" and "Register" buttons. No sidebar or dashboard elements.
2. **Login Page (`login.html`):** Simple form with email/password, "Login" button, and link to register. On success, redirect to dashboard.html.
3. **Register Page (`register.html`):** Form with name/email/password, "Register" button, and link to login. On success, redirect to dashboard.html.
4. **Dashboard Page (`dashboard.html`):** Current main content with sidebar navigation, creator sections, community features. Accessible only if logged in; otherwise redirect to landing.html.

- **Navigation Flow:** landing.html → login.html/register.html → dashboard.html. Use window.location.href for page transitions. Check session on page load to redirect appropriately.

### State Management and Session Handling
- Use localStorage for user session (currentUser object).
- On each page load, check if currentUser exists:
  - If yes and on landing/login/register, redirect to dashboard.html.
  - If no and on dashboard, redirect to landing.html.
- Shared auth.js handles login/register API calls and session storage.
- Logout clears localStorage and redirects to landing.html.

### Backend API Integration Points
- `/api/users` (GET for login verification, POST for registration).
- `/api/content` (GET for loading creators/content).
- `/api/subscriptions` (GET for user subscriptions).
- No changes needed to backend; reuse existing endpoints.

### Testing Strategy
- **Unit Tests:** Test individual functions in auth.js, dashboard.js (e.g., handleLogin, loadContent).
- **Integration Tests:** Test full flows: landing → register → dashboard; login → dashboard; logout → landing.
- **UI Tests:** Verify responsive design on mobile/desktop; form validations; modal behaviors (if kept).
- **Browser Compatibility:** Test on Chrome, Firefox, Safari.
- **Tools:** Use browser dev tools for debugging; consider Jest for JS tests if expanding.

## Dependent Files to be Edited
- `root/index.html` (modify or replace)
- `root/scripts/index.js` (split)
- `root/css/styles.css` (split)

## Followup Steps
- Implement new files and split existing ones.
- Test navigation flow and session handling.
- Ensure responsive design across pages.
- Optimize for performance (lazy load scripts/CSS).
- Add comments in Portuguese as per user instructions.
