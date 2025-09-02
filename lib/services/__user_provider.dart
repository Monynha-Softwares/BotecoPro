import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProfile {
  final String name;
  final String email;
  final String establishment;
  final String position;

  UserProfile({
    required this.name,
    required this.email,
    required this.establishment,
    required this.position,
  });

  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'Administrador',
      email: 'admin@boteco.pro',
      establishment: 'Boteco do Zé',
      position: 'Gerente',
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? establishment,
    String? position,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      establishment: establishment ?? this.establishment,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'establishment': establishment,
      'position': position,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Administrador',
      email: json['email'] ?? 'admin@boteco.pro',
      establishment: json['establishment'] ?? 'Boteco do Zé',
      position: json['position'] ?? 'Gerente',
    );
  }
}

class UserProvider with ChangeNotifier {
  static const String _userProfileKey = 'user_profile';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _languageKey = 'app_language';

  UserProfile _userProfile = UserProfile.defaultProfile();
  bool _notificationsEnabled = true;
  String _language = 'Português (Brasil)';

  UserProvider() {
    _loadUserPreferences();
  }

  UserProfile get userProfile => _userProfile;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load user profile
    final profileJson = prefs.getString(_userProfileKey);
    if (profileJson != null) {
      try {
        _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(
          json.decode(profileJson),
        ));
      } catch (e) {
        _userProfile = UserProfile.defaultProfile();
      }
    }
    
    // Load notifications setting
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    
    // Load language
    _language = prefs.getString(_languageKey) ?? 'Português (Brasil)';
    
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, json.encode(profile.toJson()));
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }
}