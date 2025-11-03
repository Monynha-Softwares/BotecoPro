# Supabase Authentication Integration Guide

## Overview

BotecoPro now uses **Supabase Authentication** for user management with magic link email sign-in. This guide covers the complete setup process from database configuration to mobile deep links.

## Table of Contents

1. [Features](#features)
2. [Architecture](#architecture)
3. [Database Setup](#database-setup)
4. [Flutter Configuration](#flutter-configuration)
5. [Deep Links Setup](#deep-links-setup)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## Features

✅ **Magic Link Authentication**
- Email-based sign-in (passwordless)
- Automatic account creation on first login
- Secure token-based sessions

✅ **User Profiles**
- Custom profiles table extending `auth.users`
- Username and website fields
- Avatar support (ready for future implementation)
- Automatic profile creation via database trigger

✅ **Row Level Security**
- All profiles protected with RLS policies
- Users can only edit their own profile
- Public profile viewing enabled

✅ **Deep Links**
- iOS and Android deep link configuration
- Seamless return from email to app
- Web-friendly (no deep links needed)

---

## Architecture

### Authentication Flow

```
┌─────────────┐
│ Login Page  │ ─────┐
└─────────────┘      │
                     │ 1. User enters email
                     ▼
              ┌──────────────┐
              │   Supabase   │
              │     Auth     │
              └──────────────┘
                     │
                     │ 2. Sends magic link
                     ▼
              ┌──────────────┐
              │  User Email  │
              └──────────────┘
                     │
                     │ 3. Clicks link
                     ▼
        ┌────────────────────────┐
        │  Deep Link / Web URL   │
        └────────────────────────┘
                     │
                     │ 4. Returns to app
                     ▼
              ┌──────────────┐
              │  Auth State  │
              │   Listener   │
              └──────────────┘
                     │
                     │ 5. Navigates to home
                     ▼
              ┌──────────────┐
              │  Main App    │
              └──────────────┘
```

### Database Schema

**profiles table:**
```sql
CREATE TABLE public.profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id),
    username text UNIQUE,
    website text,
    avatar_url text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
```

**Automatic trigger:**
- On user signup → creates profile row automatically
- Links to `auth.users` table via `id` foreign key

---

## Database Setup

### Step 1: Apply Profiles Migration

The migration file is already created at: `db/migrations/0005_profiles_table.sql`

**✅ Already Applied** (confirmed during setup)

To verify:
```sql
-- Check if profiles table exists
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'profiles';

-- Check RLS policies
SELECT * FROM pg_policies 
WHERE tablename = 'profiles';
```

### Step 2: Configure Redirect URLs in Supabase Dashboard

1. Go to https://app.supabase.com/project/YOUR_PROJECT/auth/url-configuration
2. Add these redirect URLs:
   ```
   io.supabase.botecopro://login-callback/
   http://localhost:3000
   http://localhost:8080
   ```

3. For web deployment, also add your production URL:
   ```
   https://yourdomain.com
   ```

---

## Flutter Configuration

### Environment Variables

Your `.env` file should contain (already configured):

```properties
SUPABASE_URL=https://etpniosbesqydkuelaau.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Main App Initialization

✅ **Already configured** in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MyApp());
}

// Global client instance
final supabase = Supabase.instance.client;
```

### Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Supabase initialization + global client |
| `lib/presentation/pages/login_page.dart` | Magic link sign-in UI |
| `lib/presentation/pages/account_page.dart` | User profile management |
| `lib/presentation/pages/profile_page.dart` | Wrapper (redirects to AccountPage) |

---

## Deep Links Setup

### iOS Configuration

**File:** `ios/Runner/Info.plist`

✅ **Already configured:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.botecopro</string>
        </array>
    </dict>
</array>
```

### Android Configuration

**File:** `android/app/src/main/AndroidManifest.xml`

✅ **Already configured:**

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="io.supabase.botecopro"
        android:host="login-callback" />
</intent-filter>
```

### Web Configuration

**No deep links needed for web!** 

When running on web, the magic link redirects to the same URL (e.g., `http://localhost:3000`), and the Supabase client automatically handles the authentication callback.

---

## Testing

### Test on Web (Easiest)

1. **Run the app:**
   ```bash
   flutter run -d web-server --web-hostname localhost --web-port 3000
   ```

2. **Sign in:**
   - Open http://localhost:3000
   - Enter your email address
   - Check your email for the magic link
   - Click the link
   - You'll be redirected back to `http://localhost:3000` and automatically signed in

3. **Verify:**
   - Should see the main app screen
   - Navigate to "Perfil" tab
   - Edit your username/website
   - Click "Atualizar Perfil"

### Test on iOS Simulator

1. **Run the app:**
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

2. **Sign in:**
   - Enter email on login screen
   - Open **Mail app** on simulator
   - Click magic link
   - App should open automatically via deep link

### Test on Android Emulator

1. **Run the app:**
   ```bash
   flutter run -d emulator-5554
   ```

2. **Sign in:**
   - Enter email on login screen
   - Open **Gmail app** on emulator
   - Click magic link
   - App should open automatically

### Verify Database

Check that profile was created:

```sql
-- View all profiles
SELECT 
    p.id,
    p.username,
    p.website,
    u.email
FROM public.profiles p
JOIN auth.users u ON p.id = u.id;
```

---

## Troubleshooting

### Issue: "Verifique seu email para o link de login!" but no email arrives

**Solutions:**
1. Check Supabase email rate limits (Dashboard > Auth > Rate Limits)
2. Verify email provider isn't blocking Supabase
3. Check spam folder
4. Try a different email address
5. Check Supabase Dashboard > Auth > Logs for errors

### Issue: Deep link doesn't open app on mobile

**iOS Solutions:**
- Verify `CFBundleURLSchemes` in Info.plist
- Rebuild the app: `flutter clean && flutter run`
- Check iOS simulator is using latest build

**Android Solutions:**
- Verify intent-filter in AndroidManifest.xml
- Check scheme/host match exactly: `io.supabase.botecopro://login-callback`
- Rebuild: `flutter clean && flutter run`

### Issue: "Erro ao carregar perfil" on Account page

**Cause:** Profile wasn't created automatically

**Solution:**
```sql
-- Manually create profile for existing user
INSERT INTO public.profiles (id, username)
VALUES ('YOUR_USER_ID_HERE', 'your_username');
```

Get your user ID from Supabase Dashboard > Authentication > Users

### Issue: Web auth works but mobile doesn't

**Cause:** Redirect URL mismatch

**Solution:**
1. Add `io.supabase.botecopro://login-callback/` to Supabase Dashboard > Auth > URL Configuration
2. Ensure trailing slash is present
3. Wait 1-2 minutes for Supabase to update

### Issue: "PostgrestException" when updating profile

**Cause:** RLS policy blocking update

**Verify RLS:**
```sql
-- Check policies on profiles table
SELECT * FROM pg_policies WHERE tablename = 'profiles';

-- Should see:
-- - "Public profiles are viewable by everyone" (SELECT)
-- - "Users can insert their own profile" (INSERT)
-- - "Users can update own profile" (UPDATE)
```

---

## Next Steps

### Recommended Enhancements

1. **Avatar Upload** (bonus from tutorial):
   - Create `avatars` bucket in Supabase Storage
   - Add avatar upload widget to AccountPage
   - Use `image_picker` package

2. **Social Sign-In**:
   - Enable Google/Apple sign-in in Supabase Dashboard
   - Add buttons to LoginPage
   - Configure OAuth apps

3. **Email Verification**:
   - Enable "Confirm email" in Supabase Dashboard > Auth
   - Add email verification flow

4. **Password Sign-In** (optional):
   - Add password fields to LoginPage
   - Use `supabase.auth.signInWithPassword()`

5. **Multi-tenant Support**:
   - Add `organization_id` to profiles
   - Link bar_tables, products, etc. to organizations
   - Update RLS policies to filter by organization

---

## Resources

- [Supabase Flutter Quickstart](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

## Support

For issues specific to this implementation:
1. Check this guide's troubleshooting section
2. Review Supabase Dashboard > Auth > Logs
3. Check browser/Flutter console for errors
4. Verify .env credentials are correct

**Last Updated:** November 3, 2025  
**Version:** 1.0.0  
**Migration Applied:** 0005_profiles_table.sql
