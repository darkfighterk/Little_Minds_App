// ============================================================
// admin_service.dart
// Place in: lib/services/admin_service.dart
// ============================================================
//
// Required pubspec.yaml addition:
//   image_picker: ^1.0.7
//
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdminService {
  // ── The admin secret key — must match const adminSecret in main.go ──
  static const String adminKey = 'LittleMind@Admin2024';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Admin-Key': adminKey,
      };

  // ── Verify key locally (matches the Go constant) ────────────────────
  static bool verifyKey(String key) => key == adminKey;

  // ── SUBJECTS ─────────────────────────────────────────────────────────

  /// Returns a list of all admin-created subjects from the DB.
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/admin/subjects'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('AdminService.getSubjects error: $e');
    }
    return [];
  }

  /// Creates a new quiz subject. Returns true on success.
  Future<bool> createSubject({
    required String id,
    required String name,
    required String emoji,
    String gradientStart = '#4FC3F7',
    String gradientEnd = '#0288D1',
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$baseUrl/admin/subjects'),
            headers: _headers,
            body: jsonEncode({
              'id': id.toLowerCase().replaceAll(' ', '_'),
              'name': name,
              'emoji': emoji,
              'gradient_start': gradientStart,
              'gradient_end': gradientEnd,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return resp.statusCode == 201;
    } catch (e) {
      print('AdminService.createSubject error: $e');
      return false;
    }
  }

  // ── LEVELS ───────────────────────────────────────────────────────────

  /// Returns all levels for a given subject.
  Future<List<Map<String, dynamic>>> getLevels(String subjectId) async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/admin/levels?subject_id=$subjectId'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('AdminService.getLevels error: $e');
    }
    return [];
  }

  /// Creates a level. Returns the new level ID, or null on failure.
  Future<int?> createLevel({
    required String subjectId,
    required int levelNumber,
    required String title,
    required String icon,
    required int starsRequired,
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$baseUrl/admin/levels'),
            headers: _headers,
            body: jsonEncode({
              'subject_id': subjectId,
              'level_number': levelNumber,
              'title': title,
              'icon': icon,
              'stars_required': starsRequired,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 201) {
        final body = jsonDecode(resp.body);
        return (body['data']['id'] as num?)?.toInt();
      }
      print('AdminService.createLevel HTTP ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      print('AdminService.createLevel error: $e');
    }
    return null;
  }

  // ── QUESTIONS ────────────────────────────────────────────────────────

  /// Batch-saves all questions for a level. Returns true on success.
  Future<bool> saveQuestions(
      int levelId, List<Map<String, dynamic>> questions) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$baseUrl/admin/questions'),
            headers: _headers,
            body: jsonEncode({'level_id': levelId, 'questions': questions}),
          )
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) return true;
      print('AdminService.saveQuestions HTTP ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      print('AdminService.saveQuestions error: $e');
    }
    return false;
  }

  // ── IMAGE UPLOAD ─────────────────────────────────────────────────────

  /// Uploads an image file picked by image_picker.
  /// Returns the public URL string, or null on failure.
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['X-Admin-Key'] = adminKey;

      // Read bytes works on both web and mobile
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      ));

      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        return body['data']['url'] as String?;
      }
      print('AdminService.uploadImage HTTP ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      print('AdminService.uploadImage error: $e');
    }
    return null;
  }

  // ── FULL QUIZ (read-back) ─────────────────────────────────────────────

  Future<Map<String, dynamic>?> getFullQuiz(String subjectId) async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/admin/quiz?subject_id=$subjectId'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('AdminService.getFullQuiz error: $e');
    }
    return null;
  }

  // ── PUZZLES ───────────────────────────────────────────────────────────

  /// Returns all puzzles from the DB.
  Future<List<Map<String, dynamic>>> getPuzzles() async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/admin/puzzles'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('AdminService.getPuzzles error: $e');
    }
    return [];
  }

  /// Creates a new puzzle. Returns the created puzzle map or null on failure.
  Future<Map<String, dynamic>?> createPuzzle({
    required String title,
    required String imageUrl,
    required int pieceCount,
    required String category,
    required String difficulty,
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$baseUrl/admin/puzzles'),
            headers: _headers,
            body: jsonEncode({
              'title': title,
              'image_url': imageUrl,
              'piece_count': pieceCount,
              'category': category,
              'difficulty': difficulty,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 201) {
        final body = jsonDecode(resp.body);
        return body['data'] as Map<String, dynamic>?;
      }
      print('AdminService.createPuzzle HTTP ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      print('AdminService.createPuzzle error: $e');
    }
    return null;
  }

  /// Deletes a puzzle by ID. Returns true on success.
  Future<bool> deletePuzzle(int id) async {
    try {
      final resp = await http
          .delete(Uri.parse('$baseUrl/admin/puzzles?id=$id'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      return resp.statusCode == 200;
    } catch (e) {
      print('AdminService.deletePuzzle error: $e');
      return false;
    }
  }
}