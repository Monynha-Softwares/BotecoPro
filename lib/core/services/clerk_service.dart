// lib/core/services/clerk_service.dart

import 'dart:async';
import 'dart:js' as js;
import 'dart:html' as html;

/// ClerkService - Interface with Clerk JavaScript SDK
///
/// This service provides a Dart wrapper around Clerk's JavaScript SDK
/// for authentication in Flutter Web applications.
///
/// CLERK INTEGRATION:
/// - Interfaces with @clerk/clerk-js loaded in index.html
/// - Handles sign in, sign up, and user session management
/// - Provides session persistence and state management
///
/// USAGE:
/// ```dart
/// final clerkService = ClerkService();
/// await clerkService.initialize();
/// 
/// if (clerkService.isSignedIn) {
///   final user = clerkService.currentUser;
///   print('Signed in as: ${user?['emailAddress']}');
/// }
/// ```
class ClerkService {
  static final ClerkService _instance = ClerkService._internal();
  factory ClerkService() => _instance;
  ClerkService._internal();

  final _authStateController = StreamController<Map<String, dynamic>?>.broadcast();
  Stream<Map<String, dynamic>?> get authStateChanges => _authStateController.stream;

  bool _initialized = false;
  Map<String, dynamic>? _currentUser;

  bool get initialized => _initialized;
  bool get isSignedIn => _currentUser != null;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Initialize Clerk and set up authentication state listener
  Future<void> initialize() async {
    if (_initialized) return;

    // Wait for Clerk to be loaded
    await _waitForClerk();

    try {
      // Load Clerk instance
      final clerkLoaded = js.context.callMethod('eval', ['typeof window.Clerk !== "undefined"']);
      
      if (clerkLoaded) {
        // Initialize Clerk if not already done
        final isReady = js.context.callMethod('eval', ['window.Clerk && window.Clerk.loaded']);
        
        if (!isReady) {
          await _callClerkMethod('load');
        }

        // Get current user if signed in
        await _updateCurrentUser();
        
        // Set up auth state listener via JavaScript callback
        _setupAuthListener();
        
        _initialized = true;
        print('ClerkService: Initialized successfully');
      } else {
        print('ClerkService: Clerk SDK not found');
      }
    } catch (e) {
      print('ClerkService: Initialization error: $e');
    }
  }

  /// Wait for Clerk to be available in the window object
  Future<void> _waitForClerk() async {
    var attempts = 0;
    while (attempts < 50) {
      try {
        final clerkExists = js.context.callMethod('eval', ['typeof window.Clerk !== "undefined"']);
        if (clerkExists) {
          // Wait a bit more for it to be fully initialized
          await Future.delayed(const Duration(milliseconds: 500));
          return;
        }
      } catch (e) {
        // Clerk not yet available
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    print('ClerkService: Timeout waiting for Clerk to load');
  }

  /// Set up listener for auth state changes via JavaScript
  void _setupAuthListener() {
    try {
      // Create a Dart callback that JavaScript can call
      js.context['_clerkAuthCallback'] = js.allowInterop((user) {
        _updateCurrentUser();
      });

      // Set up the listener in JavaScript
      js.context.callMethod('eval', ['''
        if (window.Clerk) {
          window.Clerk.addListener((resources) => {
            if (window._clerkAuthCallback) {
              window._clerkAuthCallback(resources.user);
            }
          });
        }
      ''']);
    } catch (e) {
      print('ClerkService: Error setting up auth listener: $e');
    }
  }

  /// Update current user from Clerk
  Future<void> _updateCurrentUser() async {
    try {
      final userJson = _callClerkMethod('user');
      if (userJson != null) {
        _currentUser = _jsObjectToMap(userJson);
        _authStateController.add(_currentUser);
      } else {
        _currentUser = null;
        _authStateController.add(null);
      }
    } catch (e) {
      print('ClerkService: Error updating user: $e');
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  /// Call a method on the Clerk object
  dynamic _callClerkMethod(String method, [List<dynamic>? args]) {
    try {
      if (args != null && args.isNotEmpty) {
        return js.context.callMethod('eval', [
          'window.Clerk?.$method(${args.map((a) => '"$a"').join(",")})'
        ]);
      } else {
        return js.context.callMethod('eval', ['window.Clerk?.$method']);
      }
    } catch (e) {
      print('ClerkService: Error calling $method: $e');
      return null;
    }
  }

  /// Convert JavaScript object to Dart Map
  Map<String, dynamic> _jsObjectToMap(dynamic jsObject) {
    if (jsObject == null) return {};
    
    try {
      final jsonString = js.context['JSON'].callMethod('stringify', [jsObject]);
      return html.window.localStorage[jsonString] as Map<String, dynamic>? ?? {};
    } catch (e) {
      // Fallback: extract basic properties
      return {
        'id': _getProperty(jsObject, 'id'),
        'emailAddress': _getProperty(jsObject, 'primaryEmailAddress.emailAddress'),
        'firstName': _getProperty(jsObject, 'firstName'),
        'lastName': _getProperty(jsObject, 'lastName'),
        'imageUrl': _getProperty(jsObject, 'imageUrl'),
      };
    }
  }

  /// Get a property from a JavaScript object
  dynamic _getProperty(dynamic jsObject, String path) {
    try {
      final parts = path.split('.');
      dynamic current = jsObject;
      for (final part in parts) {
        current = js.JsObject.fromBrowserObject(current)[part];
        if (current == null) return null;
      }
      return current;
    } catch (e) {
      return null;
    }
  }

  /// Open Clerk sign-in modal
  Future<void> openSignIn() async {
    try {
      js.context.callMethod('eval', ['window.Clerk?.openSignIn()']);
    } catch (e) {
      print('ClerkService: Error opening sign in: $e');
    }
  }

  /// Open Clerk sign-up modal
  Future<void> openSignUp() async {
    try {
      js.context.callMethod('eval', ['window.Clerk?.openSignUp()']);
    } catch (e) {
      print('ClerkService: Error opening sign up: $e');
    }
  }

  /// Open Clerk user profile modal
  Future<void> openUserProfile() async {
    try {
      js.context.callMethod('eval', ['window.Clerk?.openUserProfile()']);
    } catch (e) {
      print('ClerkService: Error opening user profile: $e');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await js.context.callMethod('eval', ['window.Clerk?.signOut()']);
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('ClerkService: Error signing out: $e');
    }
  }

  /// Mount Clerk UI component to a DOM element
  void mountComponent(String componentName, String elementId) {
    try {
      js.context.callMethod('eval', ['''
        if (window.Clerk) {
          const el = document.getElementById('$elementId');
          if (el) {
            window.Clerk.mount$componentName(el);
          }
        }
      ''']);
    } catch (e) {
      print('ClerkService: Error mounting component: $e');
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
