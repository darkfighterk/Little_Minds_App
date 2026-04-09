// ============================================================
// user_model.dart  (UPDATED — id is now String)
// ============================================================

class User {
  final String id; // Changed from int to String
  final String name;
  final String email;
  final String? token; // Added token (useful after login)

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  // Create a User from JSON (from backend response)
  factory User.fromJson(Map<String, dynamic> json) {
    print("📦 Parsing user from JSON: $json");

    // Handle 'id' safely - backend sends email as string id
    final dynamic rawId = json['id'];
    String userId;

    if (rawId is String) {
      userId = rawId;
    } else if (rawId is int) {
      userId = rawId.toString();
    } else {
      // Fallback: use email as id if id is missing
      userId = json['email']?.toString() ?? 'unknown';
    }

    return User(
      id: userId,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }

  // Convert User to JSON (for sending to backend if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (token != null) 'token': token,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}
