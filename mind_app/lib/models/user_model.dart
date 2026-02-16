class User {
  int? id;
  String username;
  int? level;

  User({this.id, required this.username, this.level});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      level: map['level'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'level': level,
    };
  }
}