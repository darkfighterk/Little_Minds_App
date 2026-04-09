import 'package:flutter/foundation.dart';
// lib/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint("📦 Parsing user from JSON: $json");

    final dynamic rawId = json['id'];
    String userId = '';
    if (rawId is String) {
      userId = rawId;
    } else if (rawId is int) {
      userId = rawId.toString();
    } else {
      userId = json['email']?.toString() ?? 'unknown';
    }

    return User(
      id: userId,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
