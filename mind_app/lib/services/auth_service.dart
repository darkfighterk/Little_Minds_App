import 'db_service.dart';
import '../models/user_model.dart';

class AuthService {
  final DBService _db = DBService();

  // LOGIN METHOD
  Future<User?> login(String username, String password) async {
    final userMap = await _db.getUser(username, password);
    if (userMap != null) {
      return User.fromMap(userMap);
    }
    return null;
  }

  // REGISTER METHOD (optional)
  Future<bool> register(String username, String password) async {
    return await _db.insertUser(username, password);
  }
}
