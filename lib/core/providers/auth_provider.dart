// lib/core/providers/auth_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

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
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? FirebaseAuthService();

  final AuthService _authService;
  StreamSubscription<AuthUser?>? _authSubscription;
  AuthUser? _user;
  bool _initialized = false;
  String? _lastError;
  final bool useFirebase = true;

  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get initialized => _initialized;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      _user = await _authService.getCurrentUser();
      _authSubscription = _authService.authStateChanges().listen(
        (AuthUser? authUser) {
          _user = authUser;
          notifyListeners();
        },
        onError: (Object error, StackTrace stackTrace) {
          _lastError = error.toString();
          notifyListeners();
        },
      );
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<AuthUser?> signInWithEmail(String email, String password) async {
    try {
      _lastError = null;
      final AuthUser? authUser =
          await _authService.signInWithEmail(email, password);
      _user = authUser;
      notifyListeners();
      return _user;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    }
  }

  Future<AuthUser?> signUpWithEmail(String email, String password,
      {String? name}) async {
    try {
      _lastError = null;
      final AuthUser? authUser = await _authService.signUpWithEmail(
        email,
        password,
        name: name,
      );
      _user = authUser;
      notifyListeners();
      return _user;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    }
  }

  Future<AuthUser?> signInWithGoogle() async {
    try {
      _lastError = null;
      final AuthUser? authUser = await _authService.signInWithGoogle();
      _user = authUser;
      notifyListeners();
      return _user;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      _lastError = null;
      await _authService.sendPasswordReset(email);
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _lastError = null;
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
