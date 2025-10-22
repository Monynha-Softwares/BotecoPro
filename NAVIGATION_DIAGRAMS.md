# 🗺️ Navigation Flow Diagrams - BotecoPro

## Overview
This document provides visual representations of the navigation flows in BotecoPro after the authentication and navigation improvements.

---

## 1. Application Startup Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     User Opens App                              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                   SplashScreen                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • Shows Boteco PRO logo                                  │ │
│  │  • Loading animation                                      │ │
│  │  • Duration: ~2 seconds                                   │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│            AuthService.isLoggedIn()                             │
│         (Check SharedPreferences)                               │
└─────────────────┬───────────────────────┬───────────────────────┘
                  │                       │
         ┌────────┴────────┐     ┌───────┴────────┐
         │ Yes (logged in) │     │ No (not logged)│
         └────────┬────────┘     └───────┬────────┘
                  │                       │
                  ▼                       ▼
    ┌─────────────────────────┐ ┌────────────────────────┐
    │  Navigate to /home      │ │  Navigate to /login    │
    │  (MainNavigationScreen) │ │  (LoginPage)           │
    └─────────────────────────┘ └────────────────────────┘
```

---

## 2. Login Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        LoginPage                                │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  User enters:                                             │ │
│  │  • Email: admin@boteco.com                                │ │
│  │  • Password: ••••                                         │ │
│  │  • Clicks "Entrar"                                        │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│              Form Validation (Client-side)                      │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • Email contains '@' ?                                   │ │
│  │  • Password length >= 4 ?                                 │ │
│  │  • Both fields filled ?                                   │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────┬───────────────────────┘
                  │                       │
         ┌────────┴────────┐     ┌───────┴────────┐
         │ Valid           │     │ Invalid        │
         └────────┬────────┘     └───────┬────────┘
                  │                       │
                  ▼                       ▼
    ┌─────────────────────────┐ ┌────────────────────────┐
    │ AuthService.login()     │ │ Show error message     │
    │ • Save to SharedPref    │ │ • Stay on LoginPage    │
    │ • Set is_logged_in=true │ └────────────────────────┘
    │ • Save user_email       │
    │ • Save user_name        │
    └─────────┬───────────────┘
              │
              ▼
    ┌─────────────────────────┐
    │ Navigator.push          │
    │ ReplacementNamed        │
    │ ('/home')               │
    └─────────┬───────────────┘
              │
              ▼
    ┌─────────────────────────┐
    │ MainNavigationScreen    │
    │ (Home Page)             │
    └─────────────────────────┘
```

---

## 3. Main Navigation Structure

```
┌─────────────────────────────────────────────────────────────────┐
│              MainNavigationScreen (Authenticated)               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Desktop (width > 800px):                                       │
│  ┌──────────┬──────────────────────────────────────────────┐  │
│  │NavigationRail  │    Content Area (IndexedStack)       │  │
│  │          │     │                                       │  │
│  │🍺 Logo   │     │   [Selected Page Content]            │  │
│  │          │     │                                       │  │
│  │○ Home    │     │   • HomePage                         │  │
│  │○ Mesas   │     │   • TablesPage                       │  │
│  │○ Produtos│     │   • ProductsPage                     │  │
│  │○ Receitas│     │   • RecipesPage                      │  │
│  │○ Produção│     │   • ProductionPage                   │  │
│  │          │     │                                       │  │
│  └──────────┴──────────────────────────────────────────────┘  │
│                                                                 │
│  Mobile (width <= 800px):                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │         Content Area (IndexedStack)                     │  │
│  │                                                         │  │
│  │         [Selected Page Content]                         │  │
│  │                                                         │  │
│  ├─────────────────────────────────────────────────────────┤  │
│  │     Bottom Navigation Bar                               │  │
│  │  [Home] [Mesas] [Produtos] [Receitas] [Produção]       │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Back Button Behavior Flow

### 4a. Browser Back Button - In Secondary Tab

```
Current State: Produtos Tab
     │
     │ Press ⬅️ (Browser Back)
     ▼
┌──────────────────────────┐
│ PopScope.onPopInvoked    │
│ is triggered             │
└─────────┬────────────────┘
          │
          ▼
┌──────────────────────────┐
│ Check: currentTab ==     │
│        NavigationTab.home│
└─────────┬────────────────┘
          │
          │ No (on Produtos)
          ▼
┌──────────────────────────┐
│ _selectTab(              │
│   NavigationTab.home)    │
└─────────┬────────────────┘
          │
          ▼
┌──────────────────────────┐
│ Navigate to Home Tab     │
│ (no dialog, no pop)      │
└──────────────────────────┘
```

### 4b. Browser Back Button - On Home Tab

```
Current State: Home Tab
     │
     │ Press ⬅️ (Browser Back)
     ▼
┌──────────────────────────┐
│ PopScope.onPopInvoked    │
│ is triggered             │
└─────────┬────────────────┘
          │
          ▼
┌──────────────────────────┐
│ Check: currentTab ==     │
│        NavigationTab.home│
└─────────┬────────────────┘
          │
          │ Yes (on Home)
          ▼
┌──────────────────────────┐
│ Show AlertDialog:        │
│ "Sair do aplicativo?"    │
│ [Cancelar] [Sair]        │
└─────────┬────────────────┘
          │
   ┌──────┴────────┐
   │               │
   ▼               ▼
[Cancelar]      [Sair]
   │               │
   │               ▼
   │        ┌─────────────┐
   │        │ Actually    │
   │        │ exit/close  │
   │        └─────────────┘
   ▼
Stay on Home
```

### 4c. CustomAppBar Back Button - Detail Page

```
Current Page: Order Details
     │
     │ Press ⬅️ (AppBar Back)
     ▼
┌──────────────────────────┐
│ CustomAppBar onPressed   │
└─────────┬────────────────┘
          │
          ▼
┌──────────────────────────┐
│ onBackPressed != null?   │
└─────────┬────────────────┘
          │
   ┌──────┴────────┐
   │               │
   ▼ No            ▼ Yes
┌──────────┐  ┌─────────────┐
│Navigator │  │ Execute     │
│.canPop() │  │ custom      │
└────┬─────┘  │ callback    │
     │        └─────────────┘
     ▼
┌──────────┐
│ Yes: pop │
│ No: safe │
└──────────┘
```

---

## 5. Logout Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    HomePage (Logged In)                         │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  AppBar                                     [🚪 Logout]   │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────┬───────────────────────────────────────────┘
                      │ User clicks logout icon
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Confirmation Dialog                            │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Title: "Sair"                                            │ │
│  │  Message: "Deseja realmente sair do sistema?"             │ │
│  │  Actions: [Cancelar] [Sair]                               │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────┬───────────────────────┘
                  │                       │
         ┌────────┴────────┐     ┌───────┴────────┐
         │ User clicks     │     │ User clicks    │
         │ "Sair"          │     │ "Cancelar"     │
         └────────┬────────┘     └───────┬────────┘
                  │                       │
                  ▼                       ▼
    ┌─────────────────────────┐ ┌────────────────────────┐
    │ AuthService.logout()    │ │ Close dialog           │
    │ • Clear SharedPref      │ │ Stay on HomePage       │
    │ • Set is_logged_in=false│ └────────────────────────┘
    │ • Remove user_email     │
    │ • Remove user_name      │
    └─────────┬───────────────┘
              │
              ▼
    ┌─────────────────────────┐
    │ Navigator.pushNamed     │
    │ AndRemoveUntil          │
    │ ('/login', false)       │
    └─────────┬───────────────┘
              │
              ▼
    ┌─────────────────────────┐
    │ LoginPage               │
    │ (Session Cleared)       │
    └─────────────────────────┘
```

---

## 6. Navigation Between Pages (Push/Pop)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Navigation Stack                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Route: /home (MainNavigationScreen)                            │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Home Tab                                                 │ │
│  │    │                                                       │ │
│  │    │ User clicks "Fornecedores"                           │ │
│  │    ▼                                                       │ │
│  │  Navigator.push(SuppliersPage)                            │ │
│  │    │                                                       │ │
│  │    ▼                                                       │ │
│  │  ┌───────────────────────────────────────────────────┐   │ │
│  │  │ SuppliersPage                                     │   │ │
│  │  │  • CustomAppBar with back button                  │   │ │
│  │  │  • List of suppliers                              │   │ │
│  │  │  • CRUD operations                                │   │ │
│  │  │    │                                               │   │ │
│  │  │    │ User clicks back                              │   │ │
│  │  │    ▼                                               │   │ │
│  │  │  Navigator.pop()                                  │   │ │
│  │  └───────────────────────────────────────────────────┘   │ │
│  │    │                                                       │ │
│  │    ▼                                                       │ │
│  │  Returns to Home Tab                                      │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Stack Visualization:
┌──────────────────┐
│ SuppliersPage    │ ← Top (current page)
├──────────────────┤
│ MainNavScreen    │ ← Back button goes here
├──────────────────┤
│ LoginPage        │ ← Can't go back (replaced)
└──────────────────┘
```

---

## 7. Session Persistence Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   Session Lifecycle                             │
└─────────────────────────────────────────────────────────────────┘

Time: T0 - User Logs In
├─ AuthService.login()
│  └─ SharedPreferences.setBool('is_logged_in', true)
│     SharedPreferences.setString('user_email', 'admin@test.com')
│     SharedPreferences.setString('user_name', 'admin')
│
│  Browser localStorage now contains:
│  {
│    "flutter.is_logged_in": true,
│    "flutter.user_email": "admin@test.com",
│    "flutter.user_name": "admin"
│  }
│
Time: T1 - User Closes Browser
├─ localStorage persists (not cleared)
│
Time: T2 - User Reopens Browser (same day)
├─ App starts → SplashScreen
├─ AuthService.isLoggedIn()
│  └─ SharedPreferences.getBool('is_logged_in')
│     └─ Returns: true (from localStorage)
├─ Navigate to /home
└─ User still logged in! ✅

Time: T3 - User Logs Out
├─ AuthService.logout()
│  └─ SharedPreferences.setBool('is_logged_in', false)
│     SharedPreferences.remove('user_email')
│     SharedPreferences.remove('user_name')
│
│  Browser localStorage now contains:
│  {
│    "flutter.is_logged_in": false
│  }
│
Time: T4 - User Reopens Browser
├─ App starts → SplashScreen
├─ AuthService.isLoggedIn()
│  └─ Returns: false
└─ Navigate to /login
```

---

## 8. Tab Switching (IndexedStack)

```
┌─────────────────────────────────────────────────────────────────┐
│            MainNavigationScreen State Management                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Current State:                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ _currentTab = NavigationTab.home  (index: 0)           │    │
│  │                                                         │    │
│  │ _screens = {                                            │    │
│  │   [0] home: HomePage,                                   │    │
│  │   [1] tables: TablesPage,                               │    │
│  │   [2] products: ProductsPage,                           │    │
│  │   [3] recipes: RecipesPage,                             │    │
│  │   [4] production: ProductionPage                        │    │
│  │ }                                                        │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  User clicks "Produtos" tab:                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ onTabSelected(NavigationTab.products)                   │    │
│  │   ↓                                                     │    │
│  │ setState(() {                                           │    │
│  │   _currentTab = NavigationTab.products  (index: 2)     │    │
│  │ })                                                      │    │
│  │   ↓                                                     │    │
│  │ IndexedStack rebuilds with index: 2                    │    │
│  │   ↓                                                     │    │
│  │ ProductsPage now visible                               │    │
│  │ (other pages remain in memory but hidden)              │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Memory State (all tabs kept alive):                            │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ Stack Layer 0: HomePage        (hidden)                │    │
│  │ Stack Layer 1: TablesPage      (hidden)                │    │
│  │ Stack Layer 2: ProductsPage    ← VISIBLE               │    │
│  │ Stack Layer 3: RecipesPage     (hidden)                │    │
│  │ Stack Layer 4: ProductionPage  (hidden)                │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 9. Error States & Validation

```
┌─────────────────────────────────────────────────────────────────┐
│                    Login Validation Flow                        │
└─────────────────────────────────────────────────────────────────┘

User Input → Validation Check → Result

Email: ""
   └─→ isEmpty() → ❌ "Por favor, insira seu email"

Email: "notanemail"
   └─→ !contains('@') → ❌ "Por favor, insira um email válido"

Email: "test@example.com" ✅
   └─→ Pass

Password: ""
   └─→ isEmpty() → ❌ "Por favor, insira sua senha"

Password: "123"
   └─→ length < 4 → ❌ "Senha deve ter no mínimo 4 caracteres"

Password: "1234" ✅
   └─→ Pass

Both Valid ✅
   └─→ AuthService.login()
      └─→ Success → Navigate to /home
```

---

## 10. Complete User Journey

```
┌───────────────────────────────────────────────────────────────┐
│              Complete User Journey Flow                       │
└───────────────────────────────────────────────────────────────┘

1. First Visit
   Open App → Splash → Login → Enter Credentials → Home

2. Create Content
   Home → Produtos Tab → Click + → Fill Form → Save → See in List

3. Manage Orders
   Home → Mesas Tab → Click Table → View/Edit Order → Back

4. Close Browser
   [Browser Closed - Session persists in localStorage]

5. Return Later
   Open App → Splash → Auto-Login → Home (same session)

6. Logout
   Home → Click Logout → Confirm → Login Page → Session Cleared

7. Next Visit
   Open App → Splash → Login (must login again) → Home

Flow Diagram:
┌─────────┐
│  Start  │
└────┬────┘
     │
     ▼
┌─────────┐    ┌──────────┐
│ Splash  │───→│  Login   │
└────┬────┘    └────┬─────┘
     │              │
     │ (session)    │ (credentials)
     │              │
     └──────┬───────┘
            ▼
      ┌──────────┐
      │   Home   │←──────────────┐
      └────┬─────┘               │
           │                     │
           ├─→ Products          │
           ├─→ Tables         [Back]
           ├─→ Recipes           │
           ├─→ Production         │
           ├─→ Detail Pages ──────┘
           │
           ├─→ Logout → Login
           │
           └─→ Browser Back (intelligent handling)
```

---

## Legend

```
Symbols Used:
│  │  ┌  ┐  └  ┘  ├  ┤  ┬  ┴  ─  ▼  ▲  ◄  ►  
└──→ Flow direction
┌──┐ Box/Container
 ✅  Success/Completed
 ❌  Error/Failed
 ⏳  Pending/Loading
 🍺  Logo/Icon
 🚪  Logout
 ⬅️  Back button
```

---

**Created:** October 22, 2025  
**Version:** 1.1.0  
**Status:** ✅ Implementation Complete
