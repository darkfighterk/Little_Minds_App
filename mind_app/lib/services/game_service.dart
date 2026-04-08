// lib/services/game_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  // ── Base URL ───────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
  }

  // ── SharedPreferences keys ─────────────────────────────────────────────────
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id'; // stored as String (email)

  // ── Session helpers ────────────────────────────────────────────────────────

  /// Call this right after a successful login.
  /// [userId] is the user's email (your backend uses email as the ID).
  static Future<void> saveSession(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_tokenKey, token);
    print('✅ GameService: session saved | userId=$userId');
  }

  /// Call on logout — removes token, userId and cached progress.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);

    // Clear cached progress for all known subjects
    for (final subject in _knownSubjects) {
      await prefs.remove(_starsKey(subject));
      await prefs.remove(_levelsKey(subject));
    }

    print('👋 GameService: session cleared');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ── Auth headers ───────────────────────────────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Cache keys & known subjects ────────────────────────────────────────────
  static const _knownSubjects = ['science', 'biology', 'history'];
  static String _starsKey(String subjectId) => 'cache_stars_$subjectId';
  static String _levelsKey(String subjectId) => 'cache_levels_$subjectId';

  Future<void> _cacheProgress(
      String subjectId, int stars, List<int> levels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_starsKey(subjectId), stars);
    await prefs.setStringList(
      _levelsKey(subjectId),
      levels.map((e) => e.toString()).toList(),
    );
  }

  Future<int> _cachedStars(String subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_starsKey(subjectId)) ?? 0;
  }

  Future<List<int>> _cachedLevels(String subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_levelsKey(subjectId)) ?? [])
        .map(int.parse)
        .toList();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetch stars + completed levels for [subjectId] from the backend.
  /// Falls back to local cache on any error.
  Future<({int stars, List<int> completedLevels})> fetchProgress(
      String subjectId) async {
    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      print('⚠️ GameService.fetchProgress: no userId in session');
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
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>? ?? {};

        final stars = (data['total_stars'] as num?)?.toInt() ?? 0;
        final rawLevels = data['completed_levels'] as List<dynamic>? ?? [];
        final levels = rawLevels.map((e) => (e as num).toInt()).toList();

        await _cacheProgress(subjectId, stars, levels);
        print('✅ fetchProgress [$subjectId] → $stars stars');
        return (stars: stars, completedLevels: levels);
      }

      print('⚠️ fetchProgress HTTP ${response.statusCode}');
    } catch (e) {
      print('⚠️ GameService.fetchProgress error: $e — using cache');
    }

    return (
      stars: await _cachedStars(subjectId),
      completedLevels: await _cachedLevels(subjectId),
    );
  }

  /// POST a completed level result to the backend.
  /// Returns the user's new total star count, or -1 on failure.
  Future<int> saveLevelResult({
    required String subjectId,
    required int levelNumber,
    required int starsEarned,
    required int quizScore,
    required int totalQuestions,
  }) async {
    final userId = await getUserId();
    if (userId == null || userId.isEmpty) {
      print('❌ GameService.saveLevelResult: no user session');
      return -1;
    }

    try {
      final headers = await _authHeaders();
      final payload = jsonEncode({
        'user_id': userId, // String (email)
        'subject_id': subjectId,
        'level_number': levelNumber,
        'stars_earned': starsEarned,
        'quiz_score': quizScore,
        'total_questions': totalQuestions,
      });

      final response = await http
          .post(Uri.parse('$baseUrl/progress'), headers: headers, body: payload)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final newTotal = (data['total_stars'] as num?)?.toInt() ?? 0;

        // Refresh cache
        await fetchProgress(subjectId);
        print('✅ saveLevelResult: level $levelNumber — total stars: $newTotal');
        return newTotal;
      }

      print('❌ saveLevelResult HTTP ${response.statusCode}');
      return -1;
    } catch (e) {
      print('❌ GameService.saveLevelResult error: $e');
      return -1;
    }
  }

  // ── Convenience getters (read from cache — no network call) ───────────────

  Future<int> getStars(String subjectId) => _cachedStars(subjectId);

  Future<List<int>> getCompletedLevels(String subjectId) =>
      _cachedLevels(subjectId);

  bool isLevelUnlocked(int starsEarned, int starsRequired) =>
      starsEarned >= starsRequired;

  Future<double> getProgress(String subjectId, int totalLevels) async {
    if (totalLevels == 0) return 0;
    final levels = await _cachedLevels(subjectId);
    return levels.length / totalLevels;
  }

  /// Warm up the cache for all known subjects at app start.
  Future<void> fetchAllProgress() async {
    await Future.wait(_knownSubjects.map(fetchProgress));
  }
}
