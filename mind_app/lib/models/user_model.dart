class User {
  int? id;
  String username;

  User({this.id, required this.username});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'], username: map['username']);
  }
}
