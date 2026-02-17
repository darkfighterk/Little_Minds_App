import '../services/auth_service.dart';
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

    // Check for error in response
    if (response.containsKey('error')) {
      print("❌ LoginController: Error - ${response['error']}");
      return null;
    }

    // Check if we have user data
    // Backend returns: { "message": "Login successful", "data": { "id": 1, "name": "...", "email": "..." } }
    if (response.containsKey('data') && response['data'] != null) {
      print("✅ LoginController: Login successful");
      print("User data: ${response['data']}");
      return User.fromJson(response['data']);
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

    // Check for error in response
    if (response.containsKey('error')) {
      print("❌ LoginController: Error - ${response['error']}");
      return null;
    }

    // Check if we have user data
    // Backend returns: { "message": "User registered successfully", "data": { "id": 1, "name": "...", "email": "..." } }
    if (response.containsKey('data') && response['data'] != null) {
      print("✅ LoginController: Registration successful");
      print("User data: ${response['data']}");
      return User.fromJson(response['data']);
    }

    print("❌ LoginController: Invalid response structure");
    return null;
  }

  // Test backend connection
  Future<bool> testConnection() async {
    print("🔵 Testing backend connection...");
    return await _authService.testConnection();
  }
}
