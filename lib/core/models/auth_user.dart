// lib/core/models/auth_user.dart

class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;

  const AuthUser({
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
