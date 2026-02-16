import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginController {
  final AuthService _authService = AuthService();

  // Login user
  Future<User?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return null; // Could also throw an error or return a message
    }

    final response = await _authService.loginUser(email, password);
    if (response != null && response['user'] != null) {
      return User.fromJson(response['user']);
    }
    return null;
  }

  // Register user
  Future<User?> addUser(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return null;
    }

    final response = await _authService.registerUser(name, email, password);
    if (response != null) {
      // You can adjust depending on what your Go backend returns
      return User(
        id: 0, // Backend should return ID ideally
        name: name,
        email: email,
      );
    }
    return null;
  }
}
