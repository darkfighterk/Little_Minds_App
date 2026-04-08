// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:http/http.dart' as http;
import '../models/puzzle.dart';

class ApiService {
  // ── Base URL ───────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
    // Real device → 'http://192.168.x.x:8080'
  }

  static void _log(String msg) {
    if (kDebugMode) print('ApiService: $msg');
  }

  // ── Headers ────────────────────────────────────────────────────────────────
  static Map<String, String> adminHeaders(String adminKey) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Admin-Key': adminKey,
      };

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Envelope unwrapper ─────────────────────────────────────────────────────
  // Backend wraps everything as { "message": "...", "data": {...} }
  static dynamic _unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC — Jigsaw Puzzles  →  /puzzles
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getPuzzles() async {
    final uri = Uri.parse('$baseUrl/puzzles');
    _log('GET $uri');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = _unwrap(jsonDecode(response.body));
        // Backend returns { data: { puzzles: [...] } }
        if (data is Map<String, dynamic>) {
          final list = data['puzzles'];
          if (list is List) return list.cast<Map<String, dynamic>>();
        }
        if (data is List) return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _log('GET puzzles error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPuzzle(int id) async {
    final uri = Uri.parse('$baseUrl/puzzles/$id');
    _log('GET $uri');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final raw = _unwrap(jsonDecode(response.body));
        if (raw is Map<String, dynamic>) return raw;
      }
      throw Exception('Failed to load puzzle $id (${response.statusCode})');
    } catch (e) {
      _log('GET puzzle error: $e');
      rethrow;
    }
  }

  Future<void> createPuzzle(Puzzle puzzle, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/puzzles');
    _log('POST $uri');
    try {
      final bodyJson = puzzle.toJson();
      bodyJson['gridData'] ??= [];
      final response = await http
          .post(uri,
              headers: adminHeaders(adminKey), body: jsonEncode(bodyJson))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 201 || response.statusCode == 200) return;
      throw Exception('Failed to save puzzle (${response.statusCode})');
    } catch (e) {
      _log('POST puzzle error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADMIN — Crosswords  →  /admin/crosswords
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> adminGetCrosswords(String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords');
    _log('GET $uri');
    try {
      final response = await http
          .get(uri, headers: adminHeaders(adminKey))
          .timeout(const Duration(seconds: 10));
      _log('← ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = _unwrap(jsonDecode(response.body));
        if (data == null) return [];
        if (data is List) return data.cast<Map<String, dynamic>>();
        return [];
      }
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      throw Exception('Server error ${response.statusCode}');
    } catch (e) {
      _log('GET admin crosswords error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> adminGetCrossword(
      int id, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords/$id');
    _log('GET $uri');
    try {
      final response = await http
          .get(uri, headers: adminHeaders(adminKey))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return _unwrap(jsonDecode(response.body)) as Map<String, dynamic>;
      }
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      if (response.statusCode == 404) throw Exception('Crossword not found');
      throw Exception('Server error ${response.statusCode}');
    } catch (e) {
      _log('GET admin crossword error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> adminCreateCrossword(
      Puzzle puzzle, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords');
    _log('POST $uri');
    try {
      final bodyJson = puzzle.toJson();
      bodyJson['gridData'] ??= [];
      bodyJson['acrossClues'] ??= [];
      bodyJson['downClues'] ??= [];
      final response = await http
          .post(uri,
              headers: adminHeaders(adminKey), body: jsonEncode(bodyJson))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return (body['data'] as Map<String, dynamic>?) ?? {};
      }
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      final errBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
          errBody['error'] ?? 'Server error ${response.statusCode}');
    } catch (e) {
      _log('POST admin crossword error: $e');
      rethrow;
    }
  }

  Future<void> adminUpdateCrossword(
      int id, Puzzle puzzle, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords/$id');
    _log('PUT $uri');
    try {
      final bodyJson = puzzle.toJson();
      bodyJson['gridData'] ??= [];
      bodyJson['acrossClues'] ??= [];
      bodyJson['downClues'] ??= [];
      final response = await http
          .put(uri, headers: adminHeaders(adminKey), body: jsonEncode(bodyJson))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) return;
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      throw Exception('Failed to update (${response.statusCode})');
    } catch (e) {
      _log('PUT admin crossword error: $e');
      rethrow;
    }
  }

  Future<void> adminDeleteCrossword(int id, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords/$id');
    _log('DELETE $uri');
    try {
      final response = await http
          .delete(uri, headers: adminHeaders(adminKey))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return;
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      throw Exception('Failed to delete (${response.statusCode})');
    } catch (e) {
      _log('DELETE admin crossword error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC — Crosswords  →  /crosswords
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getCrosswords(
      {String? category, String? difficulty}) async {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (difficulty != null && difficulty.isNotEmpty) {
      params['difficulty'] = difficulty;
    }
    final uri = Uri.parse('$baseUrl/crosswords')
        .replace(queryParameters: params.isEmpty ? null : params);
    _log('GET $uri');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = _unwrap(jsonDecode(response.body));
        if (data is List) return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _log('GET crosswords error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getCrossword(int id) async {
    final uri = Uri.parse('$baseUrl/crosswords/$id');
    _log('GET $uri');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final raw = _unwrap(jsonDecode(response.body));
        if (raw is Map<String, dynamic>) return raw;
      }
      throw Exception('Failed to load crossword $id (${response.statusCode})');
    } catch (e) {
      _log('GET crossword error: $e');
      rethrow;
    }
  }
}
