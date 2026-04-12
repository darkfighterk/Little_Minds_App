import 'package:flutter/foundation.dart';
import '../helpers/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      final subjectDoc = await _db.collection('quiz_subjects').doc(subjectId).get();
      if (!subjectDoc.exists) return null;

      final levelsSnapshot = await _db
          .collection('quiz_subjects')
          .doc(subjectId)
          .collection('levels')
          .orderBy('level_number')
          .get();

      final List<Map<String, dynamic>> levels = [];
      for (var levelDoc in levelsSnapshot.docs) {
        final questionsSnapshot = await levelDoc.reference.collection('questions').get();
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
      };
    } catch (e) {
      debugPrint('AdminService.getFullQuiz error: $e');
    }
    return null;
  }

  // ── SUBJECTS ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final snapshot = await _db.collection('quiz_subjects').get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('AdminService.getSubjects error: $e');
    }
    return [];
  }

  Future<bool> createSubject({
    required String id,
    required String name,
    required String emoji,
    String gradientStart = '#4FC3F7',
    String gradientEnd = '#0288D1',
  }) async {
    try {
      final subjectId = id.toLowerCase().replaceAll(' ', '_');
      await _db.collection('quiz_subjects').doc(subjectId).set({
        'name': name,
        'emoji': emoji,
        'gradient_start': gradientStart,
        'gradient_end': gradientEnd,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('AdminService.createSubject error: $e');
      return false;
    }
  }

  // ── LEVELS ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLevels(String subjectId) async {
    try {
      final snapshot = await _db
          .collection('quiz_subjects')
          .doc(subjectId)
          .collection('levels')
          .orderBy('level_number')
          .get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('AdminService.getLevels error: $e');
    }
    return [];
  }

  Future<String?> createLevel({
    required String subjectId,
    required int levelNumber,
    required String title,
    required String icon,
    required int starsRequired,
  }) async {
    try {
      final docRef = _db
          .collection('quiz_subjects')
          .doc(subjectId)
          .collection('levels')
          .doc(levelNumber.toString()); // Use level number as ID for consistency
      
      await docRef.set({
        'level_number': levelNumber,
        'title': title,
        'icon': icon,
        'stars_required': starsRequired,
      });
      return docRef.id;
    } catch (e) {
      debugPrint('AdminService.createLevel error: $e');
    }
    return null;
  }

  // ── QUESTIONS ────────────────────────────────────────────────────────

  Future<bool> saveQuestions(
      String subjectId, String levelId, List<Map<String, dynamic>> questions) async {
    try {
      final batch = _db.batch();
      final levelRef = _db
          .collection('quiz_subjects')
          .doc(subjectId)
          .collection('levels')
          .doc(levelId);

      // Delete existing questions first (simplified: just overwrite in a subcollection)
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
    } catch (e) {
      debugPrint('AdminService.saveQuestions error: $e');
    }
    return false;
  }

  // ── IMAGE UPLOAD ─────────────────────────────────────────────────────

  /// Uploads an image to Cloudinary. Returns the secure download URL.
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final String cloudName = Config.cloudinaryCloudName;
      final String uploadPreset = Config.cloudinaryUploadPreset;
      
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
      debugPrint('AdminService.uploadImage Cloudinary error: $e');
    }
    return null;
  }

  // ── PUZZLES ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPuzzles() async {
    try {
      final snapshot = await _db.collection('puzzles').get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('AdminService.getPuzzles error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> createPuzzle({
    required String title,
    required String imageUrl,
    required int pieceCount,
    required String category,
    required String difficulty,
  }) async {
    try {
      final docRef = await _db.collection('puzzles').add({
        'title': title,
        'image_url': imageUrl,
        'piece_count': pieceCount,
        'category': category,
        'difficulty': difficulty,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final doc = await docRef.get();
      return {...doc.data()!, 'id': doc.id};
    } catch (e) {
      debugPrint('AdminService.createPuzzle error: $e');
    }
    return null;
  }

  Future<bool> deletePuzzle(String id) async {
    try {
      await _db.collection('puzzles').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('AdminService.deletePuzzle error: $e');
      return false;
    }
  }

  // ── STORIES ──────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStories() async {
    try {
      final snapshot = await _db.collection('stories').get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('AdminService.getStories error: $e');
    }
    return [];
  }

  Future<String?> createStory({
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
      final storyRef = await _db.collection('stories').add({
        'title': title,
        'author': author,
        'description': description,
        'cover_url': coverUrl,
        'category': category,
        'difficulty': difficulty,
        'age_range': ageRange,
        'cover_emoji': coverEmoji,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add pages as subcollection
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
    } catch (e) {
      debugPrint('AdminService.createStory error: $e');
    }
    return null;
  }

  Future<bool> deleteStory(String id) async {
    try {
      await _db.collection('stories').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('AdminService.deleteStory error: $e');
      return false;
    }
  }
}
