import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AuthService {
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8080";
    return "http://10.0.2.2:8080";
  }

  Future<Map<String, dynamic>?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      print("🔵 Attempting to register user...");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      print("URL: $baseUrl/register");

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(
                {"name": name, "email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      print("✅ POST /register status: ${response.statusCode}");
      print("✅ POST /register body: ${response.body}");

      // ✅ FIX: Backend always returns 200, parse body to check success/error
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final error = data['error']?.toString() ?? '';
      final message = data['message']?.toString() ?? '';

      if (error.isNotEmpty) {
        print("❌ Registration error: $error");
        return {'error': error};
      }

      // Success
      print("✅ Registration successful: $message");
      return data;
    } catch (e) {
      print("❌ Error registering user: $e");
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('timeout')) {
        return {
          'error':
              'Cannot connect to server at $baseUrl. Is the backend running?'
        };
      }
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      print("🔵 Attempting to login user...");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      print("URL: $baseUrl/login");
      print("Email: $email");

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      print("✅ POST /login status: ${response.statusCode}");
      print("✅ POST /login body: ${response.body}");

      // ✅ FIX: Backend always returns 200, parse body to check success/error
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final error = data['error']?.toString() ?? '';
      final message = data['message']?.toString() ?? '';

      if (error.isNotEmpty) {
        print("❌ Login error: $error");
        return {'error': error};
      }

      print("✅ Login successful: $message");
      return data;
    } catch (e) {
      print("❌ Error logging in user: $e");
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('timeout')) {
        return {
          'error':
              'Cannot connect to server at $baseUrl. Is the backend running?'
        };
      }
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  Future<bool> testConnection() async {
    try {
      print("🔵 Testing connection to backend at $baseUrl...");
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));
      print("✅ Connection test status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Connection test failed: $e");
      return false;
    }
  }
}
