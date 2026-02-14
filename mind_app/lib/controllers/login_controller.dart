import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginController {
  final AuthService _authService = AuthService();

  Future<User?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return null; // Could also throw error or return message
    }
    return await _authService.login(username, password);
  }
}
