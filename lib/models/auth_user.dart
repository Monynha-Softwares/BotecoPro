import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

enum AuthProviderType { email, google, anonymous }

class AuthUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool emailVerified;
  final AuthProviderType providerType;

  AuthUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.emailVerified = false,
    this.providerType = AuthProviderType.email,
  });

  // Factory method for Firebase compatibility (legacy support)
  factory AuthUser.fromFirebase(Map<String, dynamic> userData) {
    // Determine provider type
    AuthProviderType provider = AuthProviderType.email;
    if (userData['providerId'] == 'google.com') {
      provider = AuthProviderType.google;
    } else if (userData['isAnonymous'] == true) {
      provider = AuthProviderType.anonymous;
    }

    return AuthUser(
      uid: userData['uid'] ?? '',
      displayName: userData['displayName'],
      email: userData['email'],
      photoUrl: userData['photoURL'],
      emailVerified: userData['emailVerified'] ?? false,
      providerType: provider,
    );
  }

  // Factory method for Supabase User
  factory AuthUser.fromSupabase(supabase.User supabaseUser) {
    // Determine provider type from Supabase user metadata
    AuthProviderType provider = AuthProviderType.email;
    final appMetadata = supabaseUser.appMetadata;
    final providers = appMetadata['providers'] as List<dynamic>?;
    
    if (providers != null && providers.contains('google')) {
      provider = AuthProviderType.google;
    }

    // Get display name from user metadata or email
    String? displayName = supabaseUser.userMetadata?['display_name'] as String?;
    displayName ??= supabaseUser.userMetadata?['full_name'] as String?;
    displayName ??= supabaseUser.email?.split('@').first;

    return AuthUser(
      uid: supabaseUser.id,
      displayName: displayName,
      email: supabaseUser.email,
      photoUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      emailVerified: supabaseUser.emailConfirmedAt != null,
      providerType: provider,
    );
  }

  bool get isEmailProvider => providerType == AuthProviderType.email;
  bool get isGoogleProvider => providerType == AuthProviderType.google;
  bool get isAnonymous => providerType == AuthProviderType.anonymous;

  // Used for displaying user information
  String get displayNameOrEmail => displayName ?? email ?? 'Usuário';
  String get initials => (displayName?.isNotEmpty ?? false)
      ? displayName!.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
      : email?.isNotEmpty ?? false
          ? email![0].toUpperCase()
          : 'U';
}