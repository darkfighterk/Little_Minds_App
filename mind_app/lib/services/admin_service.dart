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

import '../models/crossword.dart'; // ← මේක අනිවාර්යයෙන් import කරන්න!

class AdminService {
  // ── The admin secret key — must match const adminSecret in main.go ──
  static const String adminKey = 'LittleMind@Admin2024';

<<<<<<< Updated upstream
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Admin-Key': adminKey,
=======
  // ── Authorization check ───────────────────────────────────────────
  /// Checks if the current user has admin privileges in Firestore.
  Future<bool> isCurrentUserAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['isAdmin'] == true;
  }

  static bool verifyKey(String key) {
    return key == Config.adminGateKey;
  }

  /// Fetches the entire quiz structure for a subject.
  Future<Map<String, dynamic>?> getFullQuiz(String subjectId) async {
    try {
      final subjectDoc =
          await _db.collection('quiz_subjects').doc(subjectId).get();
      if (!subjectDoc.exists) return null;

      final levelsSnapshot = await _db
          .collection('quiz_subjects')
          .doc(subjectId)
          .collection('levels')
          .orderBy('level_number')
          .get();

      final List<Map<String, dynamic>> levels = [];
      for (var levelDoc in levelsSnapshot.docs) {
        final questionsSnapshot =
            await levelDoc.reference.collection('questions').get();
        final questions = questionsSnapshot.docs
            .map((q) => {...q.data(), 'id': q.id})
            .toList();

        levels.add({
          ...levelDoc.data(),
          'id': levelDoc.id,
          'questions': questions,
        });
      }

      return {
        ...subjectDoc.data()!,
        'id': subjectDoc.id,
        'levels': levels,
>>>>>>> Stashed changes
      };

  // ── Verify key locally (matches the Go constant) ────────────────────
  static bool verifyKey(String key) => key == adminKey;

  // ── SUBJECTS ─────────────────────────────────────────────────────────
<<<<<<< Updated upstream

  /// Returns a list of all admin-created subjects from the DB.
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

  /// Returns all levels for a given subject.
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
      final docRef = _db
          .collection('quiz_subjects')
          .doc(subjectId)
          .collection('levels')
          .doc(levelNumber.toString());

      await docRef.set({
        'level_number': levelNumber,
        'title': title,
        'icon': icon,
        'stars_required': starsRequired,
      });
      return docRef.id;
>>>>>>> Stashed changes
    } catch (e) {
      print('AdminService.createLevel error: $e');
    }
    return null;
  }

  // ── QUESTIONS ────────────────────────────────────────────────────────
<<<<<<< Updated upstream

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
=======
  Future<bool> saveQuestions(String subjectId, String levelId,
      List<Map<String, dynamic>> questions) async {
    try {
      final batch = _db.batch();
      final levelRef = _db
          .collection('quiz_subjects')
          .doc(subjectId)
          .collection('levels')
          .doc(levelId);

      // Delete existing questions first
      final existingQs = await levelRef.collection('questions').get();
      for (var doc in existingQs.docs) {
        batch.delete(doc.reference);
      }

      // Add new questions
      for (var i = 0; i < questions.length; i++) {
        final qRef = levelRef.collection('questions').doc((i + 1).toString());
        batch.set(qRef, {
          ...questions[i],
          'sort_order': i,
        });
      }

      await batch.commit();
      return true;
>>>>>>> Stashed changes
    } catch (e) {
      print('AdminService.saveQuestions error: $e');
    }
    return false;
  }

  // ── IMAGE UPLOAD ─────────────────────────────────────────────────────
<<<<<<< Updated upstream

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
=======
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final String cloudName = Config.cloudinaryCloudName;
      final String uploadPreset = Config.cloudinaryUploadPreset;

      final url =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

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
        debugPrint(
            'Cloudinary upload failed: ${jsonResponse['error']['message']}');
>>>>>>> Stashed changes
      }
    } catch (e) {
      print('AdminService.getFullQuiz error: $e');
    }
    return null;
  }

  // ── PUZZLES ───────────────────────────────────────────────────────────
<<<<<<< Updated upstream

  /// Returns all puzzles from the DB.
=======
>>>>>>> Stashed changes
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

  // ── STORIES ──────────────────────────────────────────────────────────
<<<<<<< Updated upstream

  /// Returns all stories from the DB.
=======
>>>>>>> Stashed changes
  Future<List<Map<String, dynamic>>> getStories() async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/admin/stories'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('AdminService.getStories error: $e');
    }
    return [];
  }

  /// Creates a story with its pages in one call.
  /// Returns the new story ID, or null on failure.
  Future<int?> createStory({
    required String title,
    required String author,
    required String description,
    required String coverUrl,
    required String category,
    required String difficulty,
    required String ageRange,
    required String coverEmoji,
    required List<Map<String, dynamic>> pages,
  }) async {
    try {
      final payload = jsonEncode({
        'title': title,
        'author': author,
        'description': description,
        'cover_url': coverUrl,
        'category': category,
        'difficulty': difficulty,
        'age_range': ageRange,
        'cover_emoji': coverEmoji,
        'pages': pages,
      });
<<<<<<< Updated upstream
      final resp = await http
          .post(
            Uri.parse('$baseUrl/admin/stories'),
            headers: _headers,
            body: payload,
          )
          .timeout(const Duration(seconds: 30));
      if (resp.statusCode == 201) {
        final body = jsonDecode(resp.body);
        return (body['data']['id'] as num?)?.toInt();
      }
      print('AdminService.createStory HTTP ${resp.statusCode}: ${resp.body}');
=======

      final batch = _db.batch();
      for (var i = 0; i < pages.length; i++) {
        final pageRef = storyRef.collection('pages').doc((i + 1).toString());
        batch.set(pageRef, {
          ...pages[i],
          'page_number': i + 1,
        });
      }
      await batch.commit();

      return storyRef.id;
>>>>>>> Stashed changes
    } catch (e) {
      print('AdminService.createStory error: $e');
    }
    return null;
  }

  /// Deletes a story and all its pages by ID. Returns true on success.
  Future<bool> deleteStory(int id) async {
    try {
      final resp = await http
          .delete(Uri.parse('$baseUrl/admin/stories?id=$id'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      return resp.statusCode == 200;
    } catch (e) {
      print('AdminService.deleteStory error: $e');
      return false;
    }
  }

<<<<<<< Updated upstream
  /// Returns a single story with all its pages.
  Future<Map<String, dynamic>?> getStory(int id) async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/admin/stories/$id'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('AdminService.getStory error: $e');
    }
    return null;
=======
  // ── CROSSWORD PUZZLES ─────────────────────────────────────────────
  static const String _crosswordCollection = 'crossword_puzzles';

  /// Returns all crossword puzzles for admin list screen
  Future<List<Map<String, dynamic>>> getCrosswordPuzzles() async {
    try {
      final snapshot = await _db
          .collection(_crosswordCollection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .toList();
    } catch (e) {
      debugPrint('AdminService.getCrosswordPuzzles error: $e');
      return [];
    }
  }

  /// Creates a new crossword puzzle
  Future<String?> createCrosswordPuzzle(Puzzle puzzle) async {
    try {
      final docRef = await _db.collection(_crosswordCollection).add({
        ...puzzle.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Crossword created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('AdminService.createCrosswordPuzzle error: $e');
      return null;
    }
  }

  /// Updates an existing crossword puzzle
  Future<bool> updateCrosswordPuzzle(String docId, Puzzle puzzle) async {
    try {
      await _db.collection(_crosswordCollection).doc(docId).update({
        ...puzzle.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Crossword updated: $docId');
      return true;
    } catch (e) {
      debugPrint('AdminService.updateCrosswordPuzzle error: $e');
      return false;
    }
  }

  /// Deletes a crossword puzzle
  Future<bool> deleteCrosswordPuzzle(String docId) async {
    try {
      await _db.collection(_crosswordCollection).doc(docId).delete();
      debugPrint('✅ Crossword deleted: $docId');
      return true;
    } catch (e) {
      debugPrint('AdminService.deleteCrosswordPuzzle error: $e');
      return false;
    }
  }

  /// Fetches a single crossword puzzle by document ID (for editing)
  Future<Puzzle?> getCrosswordPuzzleById(String docId) async {
    try {
      final doc = await _db.collection(_crosswordCollection).doc(docId).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = {...doc.data()!, 'id': docId};
      return Puzzle.fromJson(data);
    } catch (e) {
      debugPrint('AdminService.getCrosswordPuzzleById error: $e');
      return null;
    }
>>>>>>> Stashed changes
  }
}
