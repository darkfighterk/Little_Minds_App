import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AuthService {
  // Automatically detect platform and use correct URL
  // Web: http://localhost:8080
  // Android Emulator: http://10.0.2.2:8080
  // iOS Simulator: http://localhost:8080
  // Physical Device: You'll need to manually set your IP

  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web (Chrome/Browser)
      return "http://localhost:8080";
    } else {
      // Mobile (Android/iOS)
      // Android Emulator uses 10.0.2.2 to access host machine
      // iOS Simulator uses localhost
      // For physical device, replace with your computer's IP address
      return "http://10.0.2.2:8080"; // Default for Android Emulator
    }
  }

  // Register a new user
  Future<Map<String, dynamic>?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      print("🔵 Attempting to register user...");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      print("URL: $baseUrl/register");
      print("Data: name=$name, email=$email");

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout - Check if backend is running',
              );
            },
          );

      print("✅ POST /register status: ${response.statusCode}");
      print("✅ POST /register body: ${response.body}");

      if (response.statusCode == 201) {
        // Success - parse the response
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 409) {
        // Email already exists
        print("⚠️ Email already exists");
        return {'error': 'Email already exists'};
      } else {
        print("❌ Registration failed: ${response.body}");
        final errorData = jsonDecode(response.body);
        return {'error': errorData['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      print("❌ Error registering user: $e");
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Connection timeout')) {
        return {
          'error':
              'Cannot connect to server at $baseUrl. Is the backend running?',
        };
      }
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  // Login an existing user
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
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout - Check if backend is running',
              );
            },
          );

      print("✅ POST /login status: ${response.statusCode}");
      print("✅ POST /login body: ${response.body}");

      if (response.statusCode == 200) {
        // Success - parse the response
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        // Invalid credentials
        print("⚠️ Invalid credentials");
        return {'error': 'Invalid email or password'};
      } else {
        print("❌ Login failed: ${response.body}");
        final errorData = jsonDecode(response.body);
        return {'error': errorData['error'] ?? 'Login failed'};
      }
    } catch (e) {
      print("❌ Error logging in user: $e");
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Connection timeout')) {
        return {
          'error':
              'Cannot connect to server at $baseUrl. Is the backend running?',
        };
      }
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      print("🔵 Testing connection to backend...");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      print("Testing URL: $baseUrl");

      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));

      print("✅ Connection test status: ${response.statusCode}");
      print("✅ Backend is reachable at $baseUrl");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Connection test failed: $e");
      print("❌ Cannot reach backend at $baseUrl");
      return false;
    }
  }
}
