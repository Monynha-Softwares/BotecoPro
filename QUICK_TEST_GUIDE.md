# 🚀 Quick Start - Supabase Auth Testing

## Prerequisites

✅ Supabase credentials in `.env`  
✅ Migration 0005 applied  
✅ Flutter dependencies installed

## ⚠️ IMPORTANT: Configure Redirect URLs First

Before testing, add these redirect URLs in Supabase Dashboard:

**Dashboard URL:**  
https://app.supabase.com/project/etpniosbesqydkuelaau/auth/url-configuration

**Redirect URLs to add:**
```
io.supabase.botecopro://login-callback/
http://localhost:3000
http://localhost:8080
```

---

## Test Commands

### Web (Easiest - Start Here!)

```bash
# Run on web
flutter run -d web-server --web-hostname localhost --web-port 3000
```

**Then:**
1. Open http://localhost:3000
2. Enter your email
3. Check email inbox
4. Click magic link
5. Auto-redirected and signed in!

---

### iOS Simulator

```bash
# List available simulators
flutter devices

# Run on iPhone simulator
flutter run -d "iPhone 15 Pro"
```

**Then:**
1. Enter email on login screen
2. Open **Mail app** on simulator
3. Click magic link in email
4. App opens automatically! ✨

---

### Android Emulator

```bash
# Start emulator
flutter emulators --launch Pixel_7_API_34

# Or list available emulators
flutter emulators

# Run on Android
flutter run -d emulator-5554
```

**Then:**
1. Enter email on login screen  
2. Open **Gmail app** on emulator
3. Click magic link in email
4. App opens automatically! ✨

---

## What to Test

### ✅ Authentication Flow

1. **Magic Link Sign-In**
   - Enter email → "Verifique seu email para o link de login!"
   - Check email (including spam folder)
   - Click link → auto-navigates to home screen

2. **Auth State Persistence**
   - Close app
   - Reopen app
   - Should go directly to home screen (session persists)

3. **Sign Out**
   - Navigate to "Perfil" tab
   - Click red "Sair da Conta" button
   - Should return to login screen

### ✅ Profile Management

1. **View Profile**
   - Navigate to "Perfil" tab
   - See email displayed (from auth.currentUser)
   - Username/website fields empty initially

2. **Edit Profile**
   - Enter username (e.g., "boteco_owner")
   - Enter website (e.g., "https://myboteco.com")
   - Click "Atualizar Perfil"
   - See success message: "Perfil atualizado com sucesso!"

3. **Profile Persistence**
   - Sign out
   - Sign back in
   - Navigate to "Perfil" tab
   - Username/website should still be there!

---

## Troubleshooting

### "No email arrives"
- Check spam folder
- Try different email address
- Check Supabase Dashboard > Auth > Logs for errors
- Verify email provider isn't blocking Supabase

### "Deep link doesn't work on mobile"
- Verify redirect URL added to Supabase Dashboard
- Rebuild app: `flutter clean && flutter run`
- Check iOS/Android configuration in docs

### "Erro ao carregar perfil"
- Profile might not exist yet
- Sign out and sign in again (trigger creates it)
- Check Supabase Dashboard > Table Editor > profiles

### "Can't connect to Supabase"
- Verify `.env` credentials are correct
- Check `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Restart Flutter app after changing `.env`

---

## Verify in Supabase Dashboard

### Check Authentication

**Dashboard:** https://app.supabase.com/project/etpniosbesqydkuelaau/auth/users

- Should see your user after sign-in
- Email should match what you entered
- User ID is a UUID

### Check Profiles Table

**Dashboard:** https://app.supabase.com/project/etpniosbesqydkuelaau/editor (select `profiles` table)

- Should have one row per user
- `id` matches auth user ID
- `username` and `website` show what you entered

### Check Logs

**Dashboard:** https://app.supabase.com/project/etpniosbesqydkuelaau/logs/auth-logs

- Shows all auth events (sign-in, sign-out, errors)
- Useful for debugging issues

---

## Clean Slate Testing

If you want to test from scratch:

```bash
# Delete local data
flutter clean

# Reinstall dependencies
flutter pub get

# Delete test user in Supabase Dashboard
# Go to: Authentication > Users > Click user > Delete

# Run fresh
flutter run -d web
```

---

## Success Checklist

- ✅ Magic link email received
- ✅ Link opens app/redirects to web
- ✅ Automatically signed in
- ✅ Can view profile page
- ✅ Can edit username/website
- ✅ Changes persist after sign out/in
- ✅ Sign out works correctly

---

## Next Steps After Testing

Once everything works:

1. **Deploy to Production**
   - Add production URL to Supabase redirect URLs
   - Build release: `flutter build web --release`

2. **Add Avatar Upload**
   - Follow bonus section in docs/SUPABASE_AUTH_INTEGRATION.md
   - Requires `image_picker` package

3. **Enable Email Verification**
   - Turn on in Supabase Dashboard > Auth > Settings
   - Add verification UI flow

4. **Social Sign-In**
   - Configure Google/Apple OAuth
   - Add social login buttons to login page

---

**Ready to test?** → Start with web: `flutter run -d web` 🚀

**Questions?** → Check `docs/SUPABASE_AUTH_INTEGRATION.md` for full guide

**Issues?** → Look at Supabase Dashboard logs first!
