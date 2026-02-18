class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // Create a User from JSON (from backend response)
  factory User.fromJson(Map<String, dynamic> json) {
    print("📦 Parsing user from JSON: $json");
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Convert User to JSON (for sending to backend if needed)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}
