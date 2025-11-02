// lib/core/providers/auth_provider.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/clerk_service.dart';

/// AuthProvider - Gerenciador de Estado de Autenticação
///
/// IMPLEMENTAÇÃO ATUAL:
/// - Usa SharedPreferences como fallback (desenvolvimento)
/// - Persiste usuário localmente
/// - Gerencia estado de autenticação com ChangeNotifier
/// - Pronto para migração para Firebase
///
/// ESTRATÉGIA DE MIGRAÇÃO PARA FIREBASE:
/// 
/// 1. Adicionar dependências no pubspec.yaml:
/// ```yaml
/// dependencies:
///   firebase_core: ^2.24.0
///   firebase_auth: ^4.15.0
///   google_sign_in: ^6.1.5
/// ```
///
/// 2. Inicializar Firebase no main.dart:
/// ```dart
/// import 'package:firebase_core/firebase_core.dart';
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   runApp(const MyApp());
/// }
/// ```
///
/// 3. Trocar flag useFirebase para true
/// 
/// 4. Descomentar imports do Firebase no topo deste arquivo
/// 
/// 5. Implementar métodos seguindo os exemplos comentados abaixo
///
/// INTEGRAÇÃO COM AuthService:
/// - Este Provider pode chamar AuthService para lógica de autenticação
/// - AuthService conterá a implementação Firebase
/// - AuthProvider gerencia o estado da UI
///
/// USO NO APP:
/// ```dart
/// // Wrap o app com Provider no main.dart:
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => AuthProvider()),
///   ],
///   child: MyApp(),
/// )
///
/// // Usar em widgets:
/// final authProvider = context.watch<AuthProvider>();
/// if (authProvider.isSignedIn) {
///   // Usuário autenticado
/// }
///
/// // Fazer login:
/// await context.read<AuthProvider>().signInWithEmail(email, password);
/// ```
///
/// Future-ready AuthProvider with a SharedPreferences fallback.
///
/// To replace the fallback with Firebase, uncomment the Firebase imports
/// and replace the implementation in each method with the commented examples.
///
/// Example Firebase usage (commented below):
///
/// import 'package:firebase_auth/firebase_auth.dart';
/// import 'package:google_sign_in/google_sign_in.dart';
///
/// // Sign in with email:
/// // final userCredential = await FirebaseAuth.instance
/// //     .signInWithEmailAndPassword(email: email, password: password);
/// // final fbUser = userCredential.user;
/// // _user = _toAuthUserFromFirebaseUser(fbUser);
///
/// // Sign out:
/// // await FirebaseAuth.instance.signOut();
///
/// // Google Sign-In:
/// // final googleUser = await GoogleSignIn().signIn();
/// // final googleAuth = await googleUser!.authentication;
/// // final credential = GoogleAuthProvider.credential(
/// //   accessToken: googleAuth.accessToken,
/// //   idToken: googleAuth.idToken,
/// // );
/// // final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

class AuthUser {
    final String id;
    final String? email;
    final String? name;
    final String? photoUrl;

    AuthUser({
        required this.id,
        this.email,
        this.name,
        this.photoUrl,
    });

    AuthUser copyWith({
        String? id,
        String? email,
        String? name,
        String? photoUrl,
    }) {
        return AuthUser(
            id: id ?? this.id,
            email: email ?? this.email,
            name: name ?? this.name,
            photoUrl: photoUrl ?? this.photoUrl,
        );
    }

    Map<String, dynamic> toJson() => {
                'id': id,
                'email': email,
                'name': name,
                'photoUrl': photoUrl,
            };

    factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
                id: json['id'] as String,
                email: json['email'] as String?,
                name: json['name'] as String?,
                photoUrl: json['photoUrl'] as String?,
            );
}

class AuthProvider extends ChangeNotifier {
    static const String _authUserKey = 'auth_user';

    AuthUser? _user;
    bool _initialized = false;
    final ClerkService _clerkService = ClerkService();

    // Use Clerk authentication (web only)
    final bool useClerk = kIsWeb;

    AuthUser? get user => _user;
    bool get isSignedIn => _user != null;
    bool get initialized => _initialized;

    /// Initialize provider (load persisted user if any).
    Future<void> initialize() async {
        if (useClerk) {
            // Initialize Clerk service for web
            await _clerkService.initialize();
            
            // Listen to Clerk auth state changes
            _clerkService.authStateChanges.listen((clerkUser) {
                if (clerkUser != null) {
                    _user = AuthUser(
                        id: clerkUser['id'] as String? ?? '',
                        email: clerkUser['emailAddress'] as String?,
                        name: '${clerkUser['firstName'] ?? ''} ${clerkUser['lastName'] ?? ''}'.trim(),
                        photoUrl: clerkUser['imageUrl'] as String?,
                    );
                } else {
                    _user = null;
                }
                notifyListeners();
            });
            
            // Get initial user state
            if (_clerkService.isSignedIn && _clerkService.currentUser != null) {
                final clerkUser = _clerkService.currentUser!;
                _user = AuthUser(
                    id: clerkUser['id'] as String? ?? '',
                    email: clerkUser['emailAddress'] as String?,
                    name: '${clerkUser['firstName'] ?? ''} ${clerkUser['lastName'] ?? ''}'.trim(),
                    photoUrl: clerkUser['imageUrl'] as String?,
                );
            }
        } else {
            // Fallback: Load from SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final raw = prefs.getString(_authUserKey);
            if (raw != null) {
                try {
                    final Map<String, dynamic> json = jsonDecode(raw);
                    _user = AuthUser.fromJson(json);
                } catch (_) {
                    _user = null;
                }
            }
        }
        
        _initialized = true;
        notifyListeners();
    }

    /// Sign in with email/password.
    ///
    /// For Clerk (web), opens the Clerk sign-in modal.
    /// For fallback, persists a minimal user to SharedPreferences.
    Future<AuthUser?> signInWithEmail(String email, String password) async {
        if (useClerk) {
            // Open Clerk sign-in modal
            await _clerkService.openSignIn();
            // User will be updated via auth state listener
            return null;
        }

        // Fallback behavior: create a lightweight user and persist.
        final id = 'local_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
        _user = AuthUser(id: id, email: email, name: null, photoUrl: null);
        await _persistUser();
        notifyListeners();
        return _user;
    }

    /// Register with email/password.
    Future<AuthUser?> signUpWithEmail(String email, String password) async {
        if (useClerk) {
            // Open Clerk sign-up modal
            await _clerkService.openSignUp();
            // User will be updated via auth state listener
            return null;
        }

        // Fallback: behave like sign-in for local-only mode.
        return signInWithEmail(email, password);
    }

    /// Sign in with Google (placeholder).
    Future<AuthUser?> signInWithGoogle() async {
        if (useClerk) {
            // Clerk handles OAuth providers in its modals
            await _clerkService.openSignIn();
            return null;
        }

        // Fallback: not supported without Firebase; throw to make developer aware.
        throw UnimplementedError('Google Sign-In requires Firebase integration.');
    }

    /// Send password reset (placeholder).
    Future<void> sendPasswordReset(String email) async {
        if (useClerk) {
            // Clerk handles password reset in its UI
            return;
        }

        // Fallback: no-op for local-only mode.
        return;
    }

    /// Sign out current user.
    Future<void> signOut() async {
        if (useClerk) {
            await _clerkService.signOut();
            _user = null;
            notifyListeners();
            return;
        }

        _user = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_authUserKey);
        notifyListeners();
    }

    /// Open user profile (Clerk only)
    Future<void> openUserProfile() async {
        if (useClerk) {
            await _clerkService.openUserProfile();
        }
    }

    Future<void> _persistUser() async {
        final prefs = await SharedPreferences.getInstance();
        if (_user == null) {
            await prefs.remove(_authUserKey);
            return;
        }
        final raw = jsonEncode(_user!.toJson());
        await prefs.setString(_authUserKey, raw);
    }

    // Helper for converting a Firebase User (when migrating) to AuthUser.
    // Uncomment when using Firebase:
    //
    // AuthUser _authUserFromFirebaseUser(User? fbUser) {
    //   if (fbUser == null) {
    //     throw StateError('Firebase user is null');
    //   }
    //   return AuthUser(
    //     id: fbUser.uid,
    //     email: fbUser.email,
    //     name: fbUser.displayName,
    //     photoUrl: fbUser.photoURL,
    //   );
    // }
}