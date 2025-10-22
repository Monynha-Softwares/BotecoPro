# Quick Task Checklist: Login/Logout Implementation

## 📝 Quick Overview
Implement Supabase authentication UI for BotecoPro Flutter app.

## ✅ Implementation Checklist

### Phase 1: Setup & Preparation
- [ ] Review existing Supabase service at `lib/services/supabase_auth_service.dart`
- [ ] Ensure `.env` file exists with Supabase credentials
- [ ] Create directory structure: `lib/pages/auth/` and `lib/utils/`

### Phase 2: Authentication Pages
- [ ] **Create Login Page** (`lib/pages/auth/login_page.dart`)
  - Email/password form
  - Validation
  - Error handling
  - Loading state
  - Navigation to signup/forgot password
  
- [ ] **Create Signup Page** (`lib/pages/auth/signup_page.dart`)
  - Name, email, password, confirm password fields
  - Validation (password match, email format)
  - Error handling
  - Navigation to login
  
- [ ] **Create Forgot Password Page** (`lib/pages/auth/forgot_password_page.dart`)
  - Email input
  - Success message
  - Navigation back to login

### Phase 3: Auth State Management
- [ ] **Create Auth Wrapper** (`lib/widgets/auth_wrapper.dart`)
  - Check authentication state on load
  - Listen to auth state changes
  - Route to login or main navigation
  
- [ ] **Update Main Entry Point** (`lib/main.dart`)
  - Change splash screen to navigate to AuthWrapper
  - Maintain existing splash animation

### Phase 4: Logout Functionality
- [ ] **Add Logout to HomePage** (`lib/pages/home_page.dart`)
  - Add logout menu item to AppBar
  - Confirmation dialog
  - Call signOut()
  - Navigate to login page
  - Clear navigation stack

### Phase 5: Error Handling
- [ ] **Create Error Message Utility** (`lib/utils/auth_error_messages.dart`)
  - Translate Supabase errors to Portuguese
  - Cover common error scenarios

### Phase 6: Testing & Validation
- [ ] Test complete signup flow
- [ ] Test login with valid credentials
- [ ] Test login with invalid credentials
- [ ] Test logout flow
- [ ] Test password reset request
- [ ] Test auth state persistence (restart app)
- [ ] Test all error messages in Portuguese
- [ ] Verify loading states work
- [ ] Check UI matches Boteco theme
- [ ] Take screenshots of all auth pages

## 🎯 Quick Test Commands

```bash
# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Format code
dart format lib/

# Analyze
dart analyze
```

## 📸 Required Screenshots
1. Login page (empty)
2. Login page (with errors)
3. Signup page
4. Forgot password page
5. Home with logout option
6. Logout confirmation dialog

## ⚡ Key Points to Remember

1. **Use existing service**: `SupabaseAuthService()` - don't recreate
2. **Portuguese locale**: All text in Portuguese (pt_BR)
3. **Theme colors**: Wine (#8B1E3F) primary, mustard secondary
4. **Validation**: Email format, password min 6 chars
5. **Loading states**: Disable forms while processing
6. **Error messages**: Use helper function for translation
7. **Navigation**: Use `pushAndRemoveUntil` for auth changes
8. **Session**: Handled automatically by Supabase

## 🚫 Common Mistakes to Avoid

- ❌ Don't recreate auth service - use singleton
- ❌ Don't forget to dispose controllers
- ❌ Don't commit `.env` file
- ❌ Don't use English error messages
- ❌ Don't forget loading states
- ❌ Don't skip form validation

## 📚 Reference Files

- `lib/services/supabase_auth_service.dart` - Auth methods
- `lib/theme.dart` - Colors and typography
- `lib/widgets/shared_widgets.dart` - Reusable widgets
- `lib/main.dart` - App structure
- `AGENT_TASK_LOGIN_LOGOUT.md` - Full detailed guide

## 🎉 Done!
When all checkboxes are complete, you're ready to commit and test!
