# Testing Guide for Web Navigation and Auth Fixes

## Quick Start Testing

### Prerequisites
1. Flutter SDK installed (3.0+)
2. Web browser (Chrome, Firefox, Safari, or Edge)
3. (Optional) Supabase account for testing auth features

### Build and Run

```bash
# Navigate to project directory
cd BotecoPro

# Get dependencies
flutter pub get

# Run on web
flutter run -d web
```

The app will open in your default browser at `http://localhost:XXXX`

## Test Scenarios

### 1. Back Button Navigation Test
**Objective:** Verify that the browser back button doesn't cause blank pages

**Steps:**
1. Open the app
2. Navigate to "Produtos" tab (click on Products)
3. Click browser back button
4. **Expected:** Return to "Início" (Home) tab
5. Click browser back button again while on Home tab
6. **Expected:** Stay on Home tab (don't leave the app)

**Desktop Navigation Rail Test:**
1. Resize browser to > 800px width
2. Notice navigation changes to left sidebar
3. Click different menu items
4. Use browser back button
5. **Expected:** Same behavior as mobile - return to Home

### 2. Login Flow Test (Without Supabase)
**Objective:** Verify login UI works and local mode is functional

**Steps:**
1. Open app - notice "Login" icon in top-right of home page
2. Click "Perfil" tab at bottom navigation
3. **Expected:** See "Modo Local" card
4. Click "Fazer Login" button
5. **Expected:** See login form
6. Click "Continuar sem login"
7. **Expected:** Return to main app
8. Navigate to other tabs (Mesas, Produtos, etc.)
9. Create some content (e.g., add a product)
10. **Expected:** Content saves successfully in local mode

### 3. Login Flow Test (With Supabase)
**Objective:** Test actual authentication

**Prerequisites:**
- Create `.env` file from `.env.example`
- Add your Supabase URL and anon key

**Steps:**
1. Open app
2. Go to Profile tab
3. Click "Fazer Login"
4. Enter valid email and password
5. Click "Entrar"
6. **Expected:** Return to main app, profile shows user email
7. Create content (add products, tables, etc.)
8. **Expected:** Content saves successfully
9. Refresh browser (F5)
10. **Expected:** Still logged in, content persists

### 4. Signup Flow Test
**Objective:** Test new user registration

**Steps:**
1. Go to Profile → Fazer Login
2. Click "Não tem uma conta? Cadastre-se"
3. Enter email and password (min 6 characters)
4. Click "Criar Conta"
5. **Expected:** Account created, redirect to main app
6. Check email for verification (if required by Supabase)

### 5. Logout Test
**Objective:** Verify logout functionality

**Steps:**
1. While logged in, go to Profile tab
2. Scroll to bottom
3. Click "Sair da Conta" (red card)
4. **Expected:** Confirmation dialog appears
5. Click "Cancelar"
6. **Expected:** Dialog closes, still logged in
7. Click "Sair da Conta" again
8. Click "Sair" in dialog
9. **Expected:** Redirect to login page
10. Navigate back to Profile
11. **Expected:** See "Modo Local" again

### 6. Navigation Between Pages Test
**Objective:** Ensure safe navigation between all pages

**Steps:**
1. From Home, click "Fornecedores" menu card
2. **Expected:** Navigate to Suppliers page with back button
3. Click back button in app
4. **Expected:** Return to Home
5. From Home, click on an active order (if any)
6. **Expected:** Navigate to Order Details page
7. Click back button
8. **Expected:** Return to Home
9. Navigate to Tables tab
10. Click on a table to manage it
11. Add items to the order
12. Click back button
13. **Expected:** Return to Tables page

### 7. Content Creation After Login Test
**Objective:** Verify all CRUD operations work with auth

**Steps:**
1. Login to the app (or use local mode)
2. **Create Product:**
   - Go to Produtos tab
   - Click "Novo Produto" FAB
   - Fill in details, save
   - **Expected:** Product appears in list
3. **Create Table:**
   - Go to Mesas tab
   - Click "Nova Mesa" FAB
   - Set number and capacity, save
   - **Expected:** Table appears in grid
4. **Create Order:**
   - Click on a table
   - Click "Adicionar Item"
   - Add products to order
   - **Expected:** Order items appear
5. **Create Supplier:**
   - From Home, click Fornecedores
   - Click "Novo Fornecedor"
   - Fill details, save
   - **Expected:** Supplier appears in list
6. Refresh browser (F5)
7. **Expected:** All created content persists

### 8. Multi-Tab Test (Same Browser)
**Objective:** Test behavior with multiple tabs

**Steps:**
1. Open app in Tab 1, login if desired
2. Create some content
3. Open same URL in Tab 2
4. **Expected:** See same content (both tabs share localStorage)
5. Create content in Tab 2
6. Refresh Tab 1
7. **Expected:** Tab 1 sees content from Tab 2
8. Logout in Tab 1
9. Refresh Tab 2
10. **Expected:** Tab 2 also logged out (shared session)

### 9. Browser Compatibility Test
**Objective:** Ensure works across browsers

**Browsers to test:**
- [ ] Chrome (Windows/Mac/Linux)
- [ ] Firefox (Windows/Mac/Linux)
- [ ] Safari (Mac/iOS)
- [ ] Edge (Windows)
- [ ] Chrome Mobile (Android)
- [ ] Safari Mobile (iOS)

**For each browser:**
1. Open app
2. Navigate between tabs
3. Test back button
4. Create content
5. Refresh
6. Verify content persists

### 10. Responsive Design Test
**Objective:** Verify UI adapts to screen size

**Steps:**
1. Open app in desktop browser
2. Start with browser maximized (>800px width)
3. **Expected:** See left navigation rail
4. Create content, navigate around
5. Slowly resize browser width to <800px
6. **Expected:** UI switches to mobile view with bottom navigation
7. Continue using app
8. **Expected:** All features work in mobile view
9. Resize back to wide
10. **Expected:** Switch back to desktop view seamlessly

## Common Issues and Solutions

### Issue: "Flutter command not found"
**Solution:** Install Flutter SDK from https://flutter.dev/docs/get-started/install

### Issue: ".env file not found" warning
**Solution:** 
- For local-only usage: Ignore this warning
- For auth features: Copy `.env.example` to `.env` and add credentials

### Issue: "Failed to initialize Supabase"
**Solution:** Check that `.env` has correct URL and anon key from Supabase dashboard

### Issue: Content doesn't persist after refresh
**Solution:** 
- Check browser console for localStorage errors
- Ensure cookies/storage not disabled
- Try incognito mode to rule out extensions

### Issue: Can't login
**Solution:**
- Check network tab for API errors
- Verify email/password are correct
- Check Supabase dashboard for auth errors
- Ensure Supabase project is active

## Success Criteria

All tests pass if:
- ✅ No blank pages when using back button
- ✅ Login UI displays correctly
- ✅ Can continue without login
- ✅ Can create account (with Supabase)
- ✅ Can login with valid credentials
- ✅ Can logout successfully
- ✅ Content creation works in both modes
- ✅ Content persists after refresh
- ✅ Navigation is smooth and predictable
- ✅ No console errors (except .env warning if not configured)
- ✅ Responsive design works
- ✅ Works in major browsers

## Reporting Issues

If you find issues:

1. Note the exact steps to reproduce
2. Take screenshots if applicable
3. Check browser console for errors (F12 → Console)
4. Note your browser and version
5. Create an issue on GitHub with all details

## Next Steps After Testing

Once testing is complete and successful:

1. Deploy to production (Firebase Hosting)
2. Update documentation with production URL
3. Set up monitoring/analytics
4. Gather user feedback
5. Plan next iteration of features
