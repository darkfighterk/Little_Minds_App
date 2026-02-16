class User {
  int? id;
  String name;
  String email;

  User({this.id, required this.name, required this.email});

  // Create a User from JSON / Map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], email: json['email']);
  }

  // Convert User to Map / JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
