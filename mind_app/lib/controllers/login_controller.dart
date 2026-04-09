import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../models/user_model.dart';

class LoginController {
  final AuthService _authService = AuthService();

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

    // ✅ FIX: Check error field properly
    final error = response['error']?.toString() ?? '';
    if (error.isNotEmpty) {
      print("❌ LoginController: Error - $error");
      return null;
    }

    // ✅ FIX: data is nested inside 'data' key
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      print("❌ LoginController: No data in response");
      return null;
    }

    final token = data['token']?.toString() ?? '';
    final userId = data['id']?.toString() ?? '';

    if (token.isEmpty || userId.isEmpty) {
      print("❌ LoginController: Missing token or userId");
      return null;
    }

    await GameService.saveSession(userId, token);
    print("✅ Session saved: userId=$userId");
    return User.fromJson(data);
  }

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

    // ✅ FIX: Check error field properly
    final error = response['error']?.toString() ?? '';
    if (error.isNotEmpty) {
      print("❌ LoginController: Error - $error");
      return null;
    }

    // ✅ FIX: data is nested inside 'data' key
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      print("❌ LoginController: No data in response");
      return null;
    }

    final userId = data['id']?.toString() ?? '';
    if (userId.isEmpty) {
      print("❌ LoginController: Missing userId after registration");
      return null;
    }

    // Registration doesn't return token, just save userId
    final token = data['token']?.toString() ?? '';
    if (token.isNotEmpty) {
      await GameService.saveSession(userId, token);
      print("✅ Session saved after registration");
    }

    print("✅ Registration successful: userId=$userId");
    return User.fromJson(data);
  }

  Future<bool> testConnection() async {
    return await _authService.testConnection();
  }
}
