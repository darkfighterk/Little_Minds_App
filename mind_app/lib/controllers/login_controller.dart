// ============================================================
// login_controller.dart  (UPDATED — saves JWT session)
// Place in: lib/controllers/login_controller.dart
// ============================================================

import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../models/user_model.dart';

class LoginController {
  final AuthService _authService = AuthService();

  // Login user
  Future<User?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      print("❌ Email or password is empty");
      return null;
    }

    print("🔵 LoginController: Attempting login...");
    final response = await _authService.loginUser(email, password);

    if (response == null) {
      print("❌ LoginController: No response from auth service");
      return null;
    }

    if (response.containsKey('error')) {
      print("❌ LoginController: Error - ${response['error']}");
      return null;
    }

    if (response.containsKey('data') && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;

      // ── SAVE SESSION (user_id + JWT token) ──────────────────
      // This lets GameService authenticate progress API calls.
      final userId = (data['id'] as num?)?.toInt() ?? 0;
      final token = (data['token'] as String?) ?? '';

      if (userId > 0 && token.isNotEmpty) {
        await GameService.saveSession(userId, token);
        print("✅ Session saved: userId=$userId");
      }

      print("✅ LoginController: Login successful");
      return User.fromJson(data);
    }

    print("❌ LoginController: Invalid response structure");
    return null;
  }

  // Register user
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

    if (response.containsKey('error')) {
      print("❌ LoginController: Error - ${response['error']}");
      return null;
    }

    if (response.containsKey('data') && response['data'] != null) {
      print("✅ LoginController: Registration successful");
      return User.fromJson(response['data']);
    }

    print("❌ LoginController: Invalid response structure");
    return null;
  }

  Future<bool> testConnection() async {
    return await _authService.testConnection();
  }
}
