// File: auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Android Emulator → use 10.0.2.2
  static const String baseUrl = "http://10.0.2.2:8080";

  // Register a new user
  Future<Map<String, dynamic>?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      print("POST /register status: ${response.statusCode}");
      print("POST /register body: ${response.body}");

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Registration failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }

  // Login an existing user
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("POST /login status: ${response.statusCode}");
      print("POST /login body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Login failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error logging in user: $e");
      return null;
    }
  }
}
