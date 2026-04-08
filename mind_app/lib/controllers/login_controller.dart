// lib/controllers/login_controller.dart
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../models/user_model.dart';

class LoginController {
  final AuthService _authService = AuthService();

  // LOGIN
  Future<User?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      print("❌ Email or password is empty");
      return null;
    }

    print("🔵 LoginController: Attempting login...");
    final response = await _authService.loginUser(email, password);

    if (response == null) {
      print("❌ LoginController: No response");
      return null;
    }

    if (response.containsKey('error') && response['error'] != '') {
      print("❌ LoginController: Error - ${response['error']}");
      return null;
    }

    if (response.containsKey('data') && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;

      final token = data['token'] as String?;
      final userId = data['id'] as String?;
      final userEmail = data['email'] as String?;

      if (token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty) {
        await GameService.saveSession(userId, token);
        print("✅ Session saved: userId=$userId");

        return User.fromJson(data);
      }
    }

    print("❌ LoginController: Invalid response structure");
    return null;
  }

  // REGISTER
  Future<User?> addUser(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      print("❌ Name, email, or password is empty");
      return null;
    }

    print("🔵 LoginController: Attempting registration...");
    final response = await _authService.registerUser(name, email, password);

    if (response == null) {
      print("❌ LoginController: No response from auth service");
      return null;
    }

    print("✅ POST /register body: $response");

    if (response.containsKey('error') && response['error'] != '') {
      print("❌ LoginController: Server error - ${response['error']}");
      return null;
    }

    if (response.containsKey('data') && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;

      final userId = data['id'] as String?;
      final userEmail = data['email'] as String?;
      final userName = data['name'] as String? ?? name;

      if (userId != null && userEmail != null) {
        print("✅ Registration successful: $userId");

        // Auto login after registration
        return await login(email, password);
      }
    }

    print("❌ LoginController: Invalid response structure: $response");
    return null;
  }

  Future<bool> testConnection() async {
    return await _authService.testConnection();
  }
}
