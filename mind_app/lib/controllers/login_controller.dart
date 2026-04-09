import 'package:flutter/foundation.dart';
// lib/controllers/login_controller.dart
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../models/user_model.dart';

class LoginController {
  final AuthService _authService = AuthService();

  // LOGIN
  Future<User?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      debugPrint("❌ Email or password is empty");
      return null;
    }

    debugPrint("🔵 LoginController: Attempting login...");
    final response = await _authService.loginUser(email, password);

    if (response == null) {
      debugPrint("❌ LoginController: No response");
      return null;
    }

    if (response.containsKey('error') && response['error'] != '') {
      debugPrint("❌ LoginController: Error - ${response['error']}");
      return null;
    }

    if (response.containsKey('data') && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;

      final token = data['token'] as String?;
      final userId = data['id'] as String?;

      if (token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty) {
        await GameService.saveSession(userId, token);
        debugPrint("✅ Session saved: userId=$userId");

        return User.fromJson(data);
      }
    }

    debugPrint("❌ LoginController: Invalid response structure");
    return null;
  }

  // REGISTER
  Future<User?> addUser(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      debugPrint("❌ Name, email, or password is empty");
      return null;
    }

    debugPrint("🔵 LoginController: Attempting registration...");
    final response = await _authService.registerUser(name, email, password);

    if (response == null) {
      debugPrint("❌ LoginController: No response from auth service");
      return null;
    }

    debugPrint("✅ POST /register body: $response");

    if (response.containsKey('error') && response['error'] != '') {
      debugPrint("❌ LoginController: Server error - ${response['error']}");
      return null;
    }

    if (response.containsKey('data') && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;

      final userId = data['id'] as String?;
      final userEmail = data['email'] as String?;

      if (userId != null && userEmail != null) {
        debugPrint("✅ Registration successful: $userId");

        // Auto login after registration
        return await login(email, password);
      }
    }

    debugPrint("❌ LoginController: Invalid response structure: $response");
    return null;
  }

  Future<bool> testConnection() async {
    return await _authService.testConnection();
  }
}
