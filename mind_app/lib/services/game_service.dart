// ============================================================
// game_service.dart  (UPDATED — database-backed)
// Place in: lib/services/game_service.dart
//
// All progress is now stored in MySQL via the Go backend.
// SharedPreferences is used only as a short-lived local cache
// so the UI doesn't flicker on every rebuild.
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  // ── Base URL (matches auth_service.dart) ───────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
  }

  // ── Token cache key (stored after login) ───────────────────
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';

  // ── Persist token & userId after login ─────────────────────
  // Call this from your LoginController right after a successful login.
  static Future<void> saveSession(int userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_tokenKey, token);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ── HTTP helpers ───────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Cache helpers (for instant UI) ────────────────────────

  String _cacheStarsKey(String subjectId) => 'cache_stars_$subjectId';
  String _cacheLevelsKey(String subjectId) => 'cache_levels_$subjectId';

  Future<void> _cacheProgress(
      String subjectId, int stars, List<int> levels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheStarsKey(subjectId), stars);
    await prefs.setStringList(
        _cacheLevelsKey(subjectId), levels.map((e) => e.toString()).toList());
  }

  Future<int> _cachedStars(String subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cacheStarsKey(subjectId)) ?? 0;
  }

  Future<List<int>> _cachedLevels(String subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_cacheLevelsKey(subjectId)) ?? [];
    return stored.map(int.parse).toList();
  }

  // ── Public API ─────────────────────────────────────────────

  /// Fetch stars + completed levels for one subject from the backend.
  /// Falls back to local cache on network error.
  Future<({int stars, List<int> completedLevels})> fetchProgress(
      String subjectId) async {
    final userId = await getUserId();
    if (userId == null) {
      return (
        stars: await _cachedStars(subjectId),
        completedLevels: await _cachedLevels(subjectId),
      );
    }

    try {
      final headers = await _authHeaders();
      final uri =
          Uri.parse('$baseUrl/progress?user_id=$userId&subject_id=$subjectId');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>;

        final stars = (data['total_stars'] as num?)?.toInt() ?? 0;
        final rawLevels = (data['completed_levels'] as List<dynamic>?) ?? [];
        final levels = rawLevels.map((e) => (e as num).toInt()).toList();

        await _cacheProgress(subjectId, stars, levels);
        return (stars: stars, completedLevels: levels);
      }
    } catch (e) {
      print('⚠️ GameService.fetchProgress error: $e — using cache');
    }

    return (
      stars: await _cachedStars(subjectId),
      completedLevels: await _cachedLevels(subjectId),
    );
  }

  /// Save a completed level to the database.
  /// Returns updated total stars, or -1 on failure.
  Future<int> saveLevelResult({
    required String subjectId,
    required int levelId,
    required int starsEarned,
    required int quizScore,
    required int totalQuestions,
  }) async {
    final userId = await getUserId();
    if (userId == null) {
      print('❌ GameService.saveLevelResult: no user session');
      return -1;
    }

    try {
      final headers = await _authHeaders();
      final body = jsonEncode({
        'user_id': userId,
        'subject_id': subjectId,
        'level_id': levelId,
        'stars_earned': starsEarned,
        'quiz_score': quizScore,
        'total_questions': totalQuestions,
      });

      final response = await http
          .post(Uri.parse('$baseUrl/progress'), headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
        final newTotal = (data['total_stars'] as num).toInt();

        // Refresh local cache from backend
        await fetchProgress(subjectId);

        print(
            '✅ GameService: saved level $levelId — total stars: $newTotal');
        return newTotal;
      } else {
        print('❌ GameService.saveLevelResult: HTTP ${response.statusCode}');
        return -1;
      }
    } catch (e) {
      print('❌ GameService.saveLevelResult error: $e');
      return -1;
    }
  }

  // ── Convenience wrappers used by existing views ────────────

  Future<int> getStars(String subjectId) async => _cachedStars(subjectId);

  Future<List<int>> getCompletedLevels(String subjectId) async =>
      _cachedLevels(subjectId);

  bool isLevelUnlocked(int starsEarned, int starsRequired) =>
      starsEarned >= starsRequired;

  Future<double> getProgress(String subjectId, int totalLevels) async {
    if (totalLevels == 0) return 0;
    final levels = await _cachedLevels(subjectId);
    return levels.length / totalLevels;
  }

  Future<void> fetchAllProgress() async {
    final subjects = ['science', 'biology', 'history'];
    await Future.wait(subjects.map((s) => fetchProgress(s)));
  }
}
