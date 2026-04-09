import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── SharedPreferences keys (Still used for local quick-access cache) ────────
  static const _starsKey = 'cache_stars_';
  static const _levelsKey = 'cache_levels_';

  // ── Session helpers ────────────────────────────────────────────────────────

  static Future<String?> getUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Future<void> saveSession(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('auth_token');
    await FirebaseAuth.instance.signOut();
  }

  // ── Cache helpers ──────────────────────────────────────────────────────────
  
  Future<void> _cacheProgress(String subjectId, int stars, List<int> levels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_starsKey$subjectId', stars);
    await prefs.setStringList('$_levelsKey$subjectId', levels.map((e) => e.toString()).toList());
  }

  Future<int> _cachedStars(String subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_starsKey$subjectId') ?? 0;
  }

  Future<List<int>> _cachedLevels(String subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('$_levelsKey$subjectId') ?? []).map(int.parse).toList();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetch stars + completed levels for [subjectId] from Firestore.
  Future<({int stars, List<int> completedLevels})> fetchProgress(String subjectId) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      debugPrint('⚠️ GameService.fetchProgress: No user logged in');
      return (stars: 0, completedLevels: <int>[]);
    }

    try {
      final doc = await _db.collection('users').doc(uid).collection('progress').doc(subjectId).get();

      if (doc.exists) {
        final data = doc.data()!;
        final stars = (data['total_stars'] as num?)?.toInt() ?? 0;
        final rawLevels = data['completed_levels'] as List<dynamic>? ?? [];
        final levels = rawLevels.map((e) => (e as num).toInt()).toList();

        await _cacheProgress(subjectId, stars, levels);
        debugPrint('✅ fetchProgress [$subjectId] from Firestore → $stars stars');
        return (stars: stars, completedLevels: levels);
      }
    } catch (e) {
      debugPrint('⚠️ GameService.fetchProgress Firestore error: $e — using cache');
    }

    return (
      stars: await _cachedStars(subjectId),
      completedLevels: await _cachedLevels(subjectId),
    );
  }

  /// Saves a completed level result to Firestore.
  Future<int> saveLevelResult({
    required String subjectId,
    required int levelNumber,
    required int starsEarned,
    required int quizScore,
    required int totalQuestions,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return -1;

    try {
      final progressRef = _db.collection('users').doc(uid).collection('progress').doc(subjectId);

      return await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(progressRef);
        
        int currentTotalStars = 0;
        List<int> completedLevels = [];

        if (snapshot.exists) {
          final data = snapshot.data()!;
          currentTotalStars = (data['total_stars'] as num?)?.toInt() ?? 0;
          completedLevels = List<int>.from(data['completed_levels'] ?? []);
        }

        // Update total stars (only if level is new or stars improved - simplified here for brevity)
        int newTotalStars = currentTotalStars + starsEarned;
        if (!completedLevels.contains(levelNumber)) {
          completedLevels.add(levelNumber);
        }

        transaction.set(progressRef, {
          'total_stars': newTotalStars,
          'completed_levels': completedLevels,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('✅ saveLevelResult saved to Firestore | Subject: $subjectId | Level: $levelNumber');
        
        // Update local cache as well
        await _cacheProgress(subjectId, newTotalStars, completedLevels);
        
        return newTotalStars;
      });
    } catch (e) {
      debugPrint('❌ GameService.saveLevelResult Firestore error: $e');
      return -1;
    }
  }

  // ── Convenience getters ───────────────

  Future<int> getStars(String subjectId) => _cachedStars(subjectId);

  Future<List<int>> getCompletedLevels(String subjectId) => _cachedLevels(subjectId);

  bool isLevelUnlocked(int starsEarned, int starsRequired) => starsEarned >= starsRequired;

  Future<double> getProgress(String subjectId, int totalLevels) async {
    if (totalLevels == 0) return 0;
    final levels = await _cachedLevels(subjectId);
    return levels.length / totalLevels;
  }
}
