import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register a new user
  Future<Map<String, dynamic>?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      debugPrint("🔵 Attempting to register user with Firebase...");
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Create user document in Firestore
        await _db.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'id': user.uid,
          'isAdmin': false, // Default to non-admin
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': null,
        });

        debugPrint("✅ User registered in Firebase: ${user.uid}");
        return {
          'data': {
            'id': user.uid,
            'email': email,
            'name': name,
          }
        };
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Firebase Registration Error: ${e.code}");
      return {'error': e.message ?? 'Registration failed'};
    } catch (e) {
      debugPrint("❌ Error registering user: $e");
      return {'error': 'An unexpected error occurred'};
    }
    return null;
  }

  // Login an existing user
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      debugPrint("🔵 Attempting to login user with Firebase...");
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Fetch extra user data from Firestore
        DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>? ?? {};

        debugPrint("✅ Login successful for: ${user.uid}");
        return {
          'data': {
            'id': user.uid,
            'email': email,
            'name': userData['name'] ?? '',
            'photoUrl': userData['photoUrl'],
            'token': 'firebase_token',
          }
        };
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Firebase Login Error: ${e.code}");
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return {'error': 'Invalid email or password'};
      }
      return {'error': e.message ?? 'Login failed'};
    } catch (e) {
      debugPrint("❌ Error logging in user: $e");
      return {'error': 'Network error'};
    }
    return null;
  }

  // ── PROFILE UPDATES ───────────────────────────────────────────────────

  /// Updates user profile in Firestore
  Future<bool> updateUserProfile(String userId, {String? name, String? photoUrl}) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isEmpty) return true;

      await _db.collection('users').doc(userId).update(updates);
      debugPrint("✅ Profile updated in Firestore for: $userId");
      return true;
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
      return false;
    }
  }

  /// Uploads a profile picture to Cloudinary
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    try {
      const String cloudName = "dwjc0mxyx";
      const String uploadPreset = "ml_default";
      
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      
      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
        
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = jsonDecode(responseString);
      
      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        debugPrint('Cloudinary upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      debugPrint('AuthService.uploadProfilePicture error: $e');
    }
    return null;
  }

  // Test connection (Always true for Firebase if internet is on)
  Future<bool> testConnection() async {
    return true;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
