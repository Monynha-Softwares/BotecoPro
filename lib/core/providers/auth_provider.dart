// lib/core/providers/auth_provider.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _authUserKey = 'auth_user';

  AuthProvider({
    BaseAuthService? authService,
    bool? useFirebase,
  })  : useFirebase = useFirebase ?? true,
        _authService = authService ??
            ((useFirebase ?? true)
                ? AuthService()
                : const _DisabledAuthService());

  final BaseAuthService _authService;
  final bool useFirebase;

  AuthUser? _user;
  bool _initialized = false;
  StreamSubscription<AuthUser?>? _authSubscription;

  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get initialized => _initialized;

  /// Initialize provider (load persisted user if any).
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (useFirebase) {
      _user = await _authService.getCurrentUser();
      _authSubscription?.cancel();
      _authSubscription =
          _authService.authStateChanges.listen((AuthUser? authUser) {
        _user = authUser;
        notifyListeners();
      });
    } else {
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
  /// Future implementation using Firebase is shown in file comments.
  /// Current fallback persists a minimal user to SharedPreferences.
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    if (useFirebase) {
      try {
        _user = await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        notifyListeners();
        return _user;
      } on AuthServiceException catch (error) {
        throw AuthProviderException(error.message);
      }
    }

    final id =
        'local_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    _user = AuthUser(id: id, email: email, name: null, photoUrl: null);
    await _persistUser();
    notifyListeners();
    return _user;
  }

  /// Register with email/password.
  Future<AuthUser?> signUpWithEmail(String email, String password,
      {String? name}) async {
    if (useFirebase) {
      try {
        _user = await _authService.registerWithEmailAndPassword(
          email: email,
          password: password,
          name: name,
        );
        notifyListeners();
        return _user;
      } on AuthServiceException catch (error) {
        throw AuthProviderException(error.message);
      }
    }

    // Fallback: behave like sign-in for local-only mode.
    return signInWithEmail(email, password);
  }

  /// Sign in with Google (placeholder).
  Future<AuthUser?> signInWithGoogle() async {
    if (useFirebase) {
      try {
        _user = await _authService.signInWithGoogle();
        if (_user != null) {
          notifyListeners();
        }
        return _user;
      } on AuthServiceException catch (error) {
        throw AuthProviderException(error.message);
      }
    }

    // Fallback: not supported without Firebase; throw to make developer aware.
    throw UnimplementedError('Google Sign-In requires Firebase integration.');
  }

  /// Send password reset (placeholder).
  Future<void> sendPasswordReset(String email) async {
    if (useFirebase) {
      try {
        await _authService.sendPasswordResetEmail(email);
      } on AuthServiceException catch (error) {
        throw AuthProviderException(error.message);
      }
      return;
    }

    // Fallback: no-op for local-only mode.
    return;
  }

  /// Sign out current user.
  Future<void> signOut() async {
    if (useFirebase) {
      try {
        await _authService.signOut();
      } on AuthServiceException catch (error) {
        throw AuthProviderException(error.message);
      }
      _user = null;
      notifyListeners();
      return;
    }

    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authUserKey);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authService.dispose();
    super.dispose();
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
}

class AuthProviderException implements Exception {
  AuthProviderException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _DisabledAuthService implements BaseAuthService {
  const _DisabledAuthService();

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<AuthUser?> getCurrentUser() async => null;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Firebase authentication is disabled.');
  }

  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    throw UnimplementedError('Firebase authentication is disabled.');
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    throw UnimplementedError('Firebase authentication is disabled.');
  }

  @override
  Future<void> signOut() async {}

  @override
  void dispose() {}
}
