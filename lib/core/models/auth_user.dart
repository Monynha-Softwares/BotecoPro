// lib/core/models/auth_user.dart

import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;

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

  Map<String, dynamic> toJson() => <String, dynamic>{
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

  @override
  List<Object?> get props => <Object?>[id, email, name, photoUrl];
}
