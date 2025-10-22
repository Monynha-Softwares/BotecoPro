# Authentication Flow Diagram

## 📊 Visual Flow Documentation

### 1. App Startup Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        App Startup                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   main() - Initialize App                        │
│  • Load .env file                                               │
│  • Initialize Supabase                                          │
│  • Initialize locale (pt_BR)                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      SplashScreen                                │
│  • Show Boteco logo                                             │
│  • 2 second animation                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                       AuthWrapper                                │
│  • Check authentication state                                   │
│  • Show loading indicator                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────┴─────────┐
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │  Not Logged In   │  │    Logged In     │
          └──────────────────┘  └──────────────────┘
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │   LoginPage      │  │ MainNavigation   │
          └──────────────────┘  └──────────────────┘
```

### 2. Login Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         LoginPage                                │
│  [Email Input Field]                                            │
│  [Password Input Field]                                         │
│  [Login Button]                                                 │
│  [Forgot Password Link] [Sign Up Link]                         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    User Enters Credentials
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Form Validation                               │
│  • Email format check                                           │
│  • Password not empty                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────┴─────────┐
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │  Validation      │  │  Validation      │
          │     Fails        │  │    Passes        │
          └──────────────────┘  └──────────────────┘
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │ Show Error       │  │ Show Loading     │
          │ Message          │  │ State            │
          └──────────────────┘  └──────────────────┘
                                        ↓
                         ┌──────────────────────────┐
                         │ SupabaseAuthService      │
                         │ .signInWithEmail()       │
                         └──────────────────────────┘
                                        ↓
                         ┌──────────────┴──────────────┐
                         ↓                             ↓
               ┌──────────────────┐         ┌──────────────────┐
               │  Auth Success    │         │   Auth Failed    │
               └──────────────────┘         └──────────────────┘
                         ↓                             ↓
               ┌──────────────────┐         ┌──────────────────┐
               │ Navigate to      │         │ Show Error       │
               │ MainNavigation   │         │ Message          │
               │ (Clear Stack)    │         │ (Translated)     │
               └──────────────────┘         └──────────────────┘
```

### 3. Signup Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        SignupPage                                │
│  [Name Input Field]                                             │
│  [Email Input Field]                                            │
│  [Password Input Field]                                         │
│  [Confirm Password Field]                                       │
│  [Sign Up Button]                                               │
│  [Already have account? Login Link]                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    User Enters Information
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Form Validation                               │
│  • Email format check                                           │
│  • Password min 6 characters                                    │
│  • Passwords match                                              │
│  • Name not empty                                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    Validation Passes
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    SupabaseAuthService                           │
│  .signUpWithEmail(email, password, metadata: {name: name})      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────┴─────────┐
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │  Signup Success  │  │  Signup Failed   │
          └──────────────────┘  └──────────────────┘
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │ Navigate to      │  │ Show Error       │
          │ MainNavigation   │  │ Message          │
          │ (Auto Login)     │  │ (e.g., email     │
          │                  │  │  already exists) │
          └──────────────────┘  └──────────────────┘
```

### 4. Logout Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        HomePage                                  │
│  [AppBar with Menu]                                             │
│    └─ [Logout Option]                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    User Clicks Logout
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Confirmation Dialog                             │
│  "Tem certeza que deseja sair?"                                 │
│  [Cancelar] [Sair]                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────┴─────────┐
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │  User Cancels    │  │ User Confirms    │
          └──────────────────┘  └──────────────────┘
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │ Close Dialog     │  │ SupabaseAuth     │
          │ Stay on Page     │  │ .signOut()       │
          └──────────────────┘  └──────────────────┘
                                        ↓
                         ┌──────────────────────────┐
                         │ Clear Session            │
                         │ Clear Local Auth State   │
                         └──────────────────────────┘
                                        ↓
                         ┌──────────────────────────┐
                         │ Navigate to LoginPage    │
                         │ (Remove All Routes)      │
                         └──────────────────────────┘
```

### 5. Password Reset Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    ForgotPasswordPage                            │
│  [Email Input Field]                                            │
│  [Send Reset Link Button]                                       │
│  [Back to Login Link]                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    User Enters Email
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     Email Validation                             │
│  • Valid email format                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  SupabaseAuthService                             │
│  .resetPassword(email)                                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────┴─────────┐
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │  Email Sent      │  │    Error         │
          └──────────────────┘  └──────────────────┘
                    ↓                   ↓
          ┌──────────────────┐  ┌──────────────────┐
          │ Show Success     │  │ Show Error       │
          │ Message          │  │ Message          │
          │ "Email enviado!" │  │ (Translated)     │
          └──────────────────┘  └──────────────────┘
                    ↓
          ┌──────────────────┐
          │ Wait 3 seconds   │
          └──────────────────┘
                    ↓
          ┌──────────────────┐
          │ Navigate back to │
          │ LoginPage        │
          └──────────────────┘
```

### 6. Auth State Listener Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      AuthWrapper                                 │
│  Listens to: SupabaseAuthService.authStateChanges               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    Stream<AuthState> Events
                              ↓
          ┌───────────────────┴───────────────────┐
          ↓                                       ↓
┌──────────────────────────┐         ┌──────────────────────────┐
│   AuthChangeEvent        │         │   AuthChangeEvent        │
│   .signedIn              │         │   .signedOut             │
└──────────────────────────┘         └──────────────────────────┘
          ↓                                       ↓
┌──────────────────────────┐         ┌──────────────────────────┐
│ Navigate to              │         │ Navigate to              │
│ MainNavigationScreen     │         │ LoginPage                │
│ (User is authenticated)  │         │ (Session ended)          │
└──────────────────────────┘         └──────────────────────────┘
```

### 7. Session Persistence Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    App First Launch                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                Supabase Auto-Initialization                      │
│  • Checks local storage for existing session                    │
│  • Validates token expiry                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
          ┌───────────────────┴───────────────────┐
          ↓                                       ↓
┌──────────────────────────┐         ┌──────────────────────────┐
│   Valid Session Found    │         │   No Valid Session       │
└──────────────────────────┘         └──────────────────────────┘
          ↓                                       ↓
┌──────────────────────────┐         ┌──────────────────────────┐
│ currentUser != null      │         │ currentUser == null      │
│ isAuthenticated = true   │         │ isAuthenticated = false  │
└──────────────────────────┘         └──────────────────────────┘
          ↓                                       ↓
┌──────────────────────────┐         ┌──────────────────────────┐
│ Route to                 │         │ Route to                 │
│ MainNavigationScreen     │         │ LoginPage                │
└──────────────────────────┘         └──────────────────────────┘
```

## 🎨 Page Structure Diagrams

### Login Page Layout

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│                          [Logo Icon]                             │
│                         🍺 (sports_bar)                          │
│                                                                  │
│                        Boteco PRO                                │
│                   Faça login para continuar                      │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ 📧 Email                                                   │ │
│  │ [________________________]                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ 🔒 Senha                                          👁️        │ │
│  │ [________________________]                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│                                       Esqueceu a senha?          │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                        ENTRAR                              │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│              Não tem uma conta? Cadastre-se                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Signup Page Layout

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│                          [Logo Icon]                             │
│                                                                  │
│                        Criar Conta                               │
│                 Preencha os dados abaixo                         │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ 👤 Nome                                                    │ │
│  │ [________________________]                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ 📧 Email                                                   │ │
│  │ [________________________]                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ 🔒 Senha                                          👁️        │ │
│  │ [________________________]                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ 🔒 Confirmar Senha                                👁️        │ │
│  │ [________________________]                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                      CADASTRAR                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│           Já tem uma conta? Faça login                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### HomePage with Logout

```
┌─────────────────────────────────────────────────────────────────┐
│  Boteco PRO                                              ⋮      │
│  ═══════════════════════════════════════════════════════════    │
│                                                           ↓      │
│                                                  ┌──────────────┐│
│                                                  │ Perfil      ││
│                                                  │ Configurações││
│  [Mesas Ativas]     [Vendas Hoje]              │ ──────────  ││
│  [Produtos]         [Receitas]                  │ Sair        ││
│                                                  └──────────────┘│
│  [Pedidos Ativos]                                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 🔐 Security Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      Security Layers                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  1. Environment Variables (.env)                                │
│     • SUPABASE_URL                                              │
│     • SUPABASE_ANON_KEY                                         │
│     • Gitignored - not committed                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  2. Supabase Client Initialization                              │
│     • HTTPS only communication                                  │
│     • Secure token storage                                      │
│     • Automatic token refresh                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  3. Authentication Service                                      │
│     • Email validation                                          │
│     • Password minimum length (6 chars)                         │
│     • Error handling                                            │
│     • Session management                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. Row Level Security (Supabase)                               │
│     • Database policies (to be configured)                      │
│     • User-based access control                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 📱 Navigation Stack Management

### Login Success Navigation
```
Before Login:
Stack: [SplashScreen, AuthWrapper, LoginPage]

After Login:
Stack: [MainNavigationScreen]
↑ All previous routes cleared
```

### Logout Navigation
```
Before Logout:
Stack: [MainNavigationScreen, HomePage]

After Logout:
Stack: [LoginPage]
↑ All previous routes cleared
```

## 🔄 State Management

```
┌─────────────────────────────────────────────────────────────────┐
│                    Authentication State                          │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ↓                     ↓                     ↓
┌──────────────┐    ┌──────────────┐      ┌──────────────┐
│   Supabase   │    │    Local     │      │     UI       │
│   Session    │ ←→ │  Auth State  │  ←→  │    State     │
│   (Server)   │    │  (Service)   │      │   (Pages)    │
└──────────────┘    └──────────────┘      └──────────────┘
        ↓                     ↓                     ↓
   Auto-synced          isAuthenticated        Loading UI
   via Stream           currentUser           Error Display
   Events               currentSession        Form States
```

---

## 📖 Legend

- `[ ]` : Button or input field
- `→` : Flow direction
- `↓` : Vertical flow
- `⋮` : Menu icon
- `🔒` : Password/security
- `📧` : Email
- `👤` : User/profile
- `👁️` : Visibility toggle

---

## 💡 Notes

1. All flows assume Portuguese (pt_BR) locale
2. Error messages should be user-friendly and translated
3. Loading states prevent multiple submissions
4. Navigation stack is cleared on auth state changes
5. Supabase handles token refresh automatically
6. Session persistence works across app restarts
