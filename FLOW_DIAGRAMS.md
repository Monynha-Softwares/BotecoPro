# Navigation and Authentication Flow Diagram

## Before the Fix

```
┌─────────────────┐
│  SplashScreen   │
│   (2 seconds)   │
└────────┬────────┘
         │ pushReplacement()
         ▼
┌─────────────────┐
│ MainNavigation  │
│     Screen      │
└────────┬────────┘
         │ Browser Back Button
         ▼
┌─────────────────┐
│   BLANK PAGE    │◄── ❌ PROBLEM
│   (No route)    │
└─────────────────┘
```

## After the Fix

```
┌─────────────────┐
│  SplashScreen   │
│   (2 seconds)   │
└────────┬────────┘
         │ pushNamedAndRemoveUntil('/main')
         │ Clears entire stack
         ▼
┌─────────────────────────────────────────┐
│         MainNavigation Screen           │
│         (Wrapped in WillPopScope)       │
│  ┌──────────────────────────────────┐   │
│  │  HomePage with Account Menu      │   │
│  │  • Login option                  │   │
│  │  • Logout option                 │   │
│  │  • User email display            │   │
│  └──────────────────────────────────┘   │
└────────┬────────────────────────────────┘
         │ Browser Back Button
         ▼
┌─────────────────┐
│ Exit Dialog     │◄── ✅ FIXED
│ "Sair do app?"  │
│ [Cancel] [Exit] │
└─────────────────┘
```

## Authentication Flow

```
┌──────────────────┐
│   HomePage       │
│   (Anonymous)    │
└────────┬─────────┘
         │ Click Account Icon
         ▼
┌──────────────────┐
│  Popup Menu      │
│  • Login         │
└────────┬─────────┘
         │ Select Login
         ▼
┌──────────────────────────────────┐
│        LoginPage                 │
│  ┌────────────────────────────┐  │
│  │ Email: [_______________]   │  │
│  │ Password: [___________]    │  │
│  │                            │  │
│  │ [    Entrar    ]          │  │
│  │ [Continuar sem login]     │  │
│  │                            │  │
│  │ Não tem conta? Cadastre-se│  │
│  └────────────────────────────┘  │
└────────┬─────────────────────────┘
         │
         ├─ Skip Login ──────────────┐
         │                           │
         │ Valid Login               │
         ▼                           ▼
┌──────────────────┐      ┌──────────────────┐
│   HomePage       │      │   HomePage       │
│ (Authenticated)  │      │  (Anonymous)     │
│                  │      │                  │
│ Account Menu:    │      │ Account Menu:    │
│ • user@email.com │      │ • Login          │
│ • Logout         │      │                  │
└──────────────────┘      └──────────────────┘
```

## Signup Flow

```
┌──────────────────┐
│   LoginPage      │
└────────┬─────────┘
         │ Click "Cadastre-se"
         ▼
┌──────────────────────────────────┐
│        SignUpPage                │
│  ┌────────────────────────────┐  │
│  │ Nome: [_______________]    │  │
│  │ Email: [_______________]   │  │
│  │ Senha: [___________]       │  │
│  │ Confirmar: [___________]   │  │
│  │                            │  │
│  │ [    Cadastrar    ]       │  │
│  │                            │  │
│  │ Já tem conta? Faça login  │  │
│  └────────────────────────────┘  │
└────────┬─────────────────────────┘
         │ Submit
         ▼
┌──────────────────┐
│   Success        │
│   SnackBar       │
│   → Back to      │
│     LoginPage    │
└──────────────────┘
```

## Component Interactions

```
┌─────────────────────────────────────────────────────────┐
│                    main.dart                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ SplashScreen │→│MainNavigation│→│  WillPopScope│  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└──────────────────────────┬──────────────────────────────┘
                           │
                 ┌─────────┴─────────┐
                 │                   │
                 ▼                   ▼
    ┌────────────────────┐  ┌────────────────────┐
    │   home_page.dart   │  │  Other Pages       │
    │  ┌──────────────┐  │  │  • tables_page     │
    │  │ Account Menu │  │  │  • products_page   │
    │  │   ┌─────┐    │  │  │  • recipes_page    │
    │  │   │Icon │    │  │  │  • production_page │
    │  │   └──┬──┘    │  │  └────────────────────┘
    │  └──────┼───────┘  │
    └─────────┼──────────┘
              │
    ┌─────────┴──────────┐
    │                    │
    ▼                    ▼
┌──────────┐      ┌──────────┐
│LoginPage │      │LogoutFunc│
└────┬─────┘      └──────────┘
     │
     ▼
┌──────────┐
│SignUpPage│
└──────────┘
         │
         ▼
┌─────────────────────────┐
│ supabase_auth_service   │
│  ┌───────────────────┐  │
│  │ • signInWithEmail │  │
│  │ • signUpWithEmail │  │
│  │ • signOut         │  │
│  │ • currentUser     │  │
│  │ • isAuthenticated │  │
│  └───────────────────┘  │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│    Supabase Backend     │
│  (Optional - via .env)  │
└─────────────────────────┘
```

## Error Handling Flow

```
┌─────────────────────────┐
│  Supabase Configured?   │
└──────────┬──────────────┘
           │
     ┌─────┴─────┐
     │           │
    YES         NO
     │           │
     ▼           ▼
┌─────────┐  ┌──────────────────────┐
│ Full    │  │ Graceful Degradation │
│ Auth    │  │ • isAuthenticated    │
│ Features│  │   returns false      │
└─────────┘  │ • currentUser = null │
             │ • Login skippable    │
             │ • App works normally │
             └──────────────────────┘
```

## State Management

```
┌──────────────────────────────────────────────┐
│           HomePage State                     │
│  ┌────────────────────────────────────────┐  │
│  │  _authService = SupabaseAuthService()  │  │
│  │                                        │  │
│  │  • isAuthenticated (computed)         │  │
│  │  • currentUser (from service)         │  │
│  │                                        │  │
│  │  Methods:                             │  │
│  │  • _navigateToLogin()                 │  │
│  │  • _handleLogout()                    │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
                     │
                     │ UI reflects state
                     ▼
┌──────────────────────────────────────────────┐
│              App Bar Menu                    │
│                                              │
│  if (isAuthenticated) {                      │
│    • Display user email                      │
│    • Show "Sair" button                      │
│  } else {                                    │
│    • Show "Fazer Login" button               │
│  }                                           │
└──────────────────────────────────────────────┘
```

## Key Features

### ✅ Fixed
1. **Back Button Navigation**: No more blank pages
2. **Login UI**: Complete email/password form
3. **Signup UI**: User registration flow
4. **Logout**: Accessible from app bar
5. **Optional Auth**: Works without Supabase

### 🔒 Security
1. Password validation (min 6 chars)
2. Email format validation
3. Secure password fields
4. Error handling without system exposure
5. Session management via Supabase

### 🎨 UX Improvements
1. Animated page transitions
2. Loading states
3. Success/error feedback
4. Skip login option
5. Context-aware menus
6. Exit confirmation dialog

---

**Legend:**
- `┌─┐` = Component/Page
- `→` = Navigation/Flow
- `▼` = Next step
- `✅` = Fixed/Implemented
- `❌` = Problem/Issue
