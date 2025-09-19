# TODO List for Frontend Modularization

## Step 1: Create New HTML Files
- [ ] Create `root/landing.html` with clean, modern landing page design (hero section, features, login/register buttons)
- [ ] Create `root/login.html` with login form and link to register
- [ ] Create `root/register.html` with register form and link to login
- [ ] Create `root/dashboard.html` with sidebar, main content, and navigation (based on current index.html)

## Step 2: Create New JavaScript Files
- [ ] Create `root/scripts/landing.js` for landing page interactions (button clicks to navigate)
- [ ] Create `root/scripts/auth.js` for shared authentication logic (handleLogin, handleRegister, session management)
- [ ] Create `root/scripts/dashboard.js` for dashboard functionality (content loading, sidebar navigation, community)

## Step 3: Create New CSS Files
- [ ] Create `root/css/landing.css` for landing page styles (hero, features, etc.)
- [ ] Create `root/css/auth.css` for login/register page styles (forms)
- [ ] Create `root/css/dashboard.css` for dashboard styles (sidebar, main content)

## Step 4: Modify Existing Files
- [ ] Modify `root/index.html` to redirect to landing.html or dashboard.html based on session
- [ ] Split `root/scripts/index.js` into landing.js, auth.js, dashboard.js; remove dynamic switching
- [ ] Split `root/css/styles.css` into landing.css, auth.css, dashboard.css; keep shared styles if needed

## Step 5: Implement Page Content and Logic
- [ ] Implement landing page content and interactions
- [ ] Implement login/register forms and validation
- [ ] Implement dashboard content loading and navigation
- [ ] Add session checks and redirects on each page

## Step 6: Testing and Polish
- [ ] Test navigation flow: landing → login/register → dashboard
- [ ] Test session handling and logout
- [ ] Ensure responsive design across pages
- [ ] Add Portuguese comments to code
- [ ] Optimize performance (lazy load if needed)
