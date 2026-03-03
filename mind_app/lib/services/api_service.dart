import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:http/http.dart' as http;

import '../models/puzzle.dart';

class ApiService {
  // ── Base URL ────────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080';
  }

  static void _log(String message) {
    if (kDebugMode) print('API: $message');
  }

  /// Builds headers with the admin key attached
  static Map<String, String> adminHeaders(String adminKey) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Admin-Key': adminKey,
      };

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC: Jigsaw puzzles
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetch list of all jigsaw puzzles (public)
  Future<List<Map<String, dynamic>>> getPuzzles() async {
    final uri = Uri.parse('$baseUrl/puzzles');
    _log('GET puzzles → $uri');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      _log('GET puzzles ← ${response.statusCode}');
      if (response.statusCode == 200) {
        final envelope = jsonDecode(response.body);
        if (envelope == null) return [];
        // Unwrap { message, data } envelope
        final data =
            envelope is Map<String, dynamic> ? envelope['data'] : envelope;
        if (data == null) return [];
        if (data is List) return data.cast<Map<String, dynamic>>();
        return [];
      }
      return [];
    } catch (e) {
      _log('GET puzzles error: $e');
      return [];
    }
  }

  /// Fetch single jigsaw puzzle by ID (public)
  Future<Map<String, dynamic>> getPuzzle(int id) async {
    final uri = Uri.parse('$baseUrl/puzzles/$id');
    _log('GET puzzle $id → $uri');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      _log(
          'GET puzzle ← ${response.statusCode} - ${response.body.length} bytes');
      if (response.statusCode == 200) {
        final envelope = jsonDecode(response.body);
        if (envelope == null) throw Exception('Server returned null response');
        // Unwrap the { message, data } envelope
        final raw = envelope is Map<String, dynamic>
            ? (envelope['data'] ?? envelope)
            : envelope;
        if (raw is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return raw;
      }
      throw Exception('Failed to load puzzle $id (${response.statusCode})');
    } catch (e) {
      _log('GET puzzle error: $e');
      rethrow;
    }
  }

  /// Save new jigsaw puzzle (admin)
  Future<void> createPuzzle(Puzzle puzzle, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/puzzles');
    _log('POST create puzzle → $uri');
    try {
      final bodyJson = puzzle.toJson();
      bodyJson['gridData'] ??= [];
      final bodyString = jsonEncode(bodyJson);
      final response = await http
          .post(
            uri,
            headers: adminHeaders(adminKey),
            body: bodyString,
          )
          .timeout(const Duration(seconds: 15));
      _log('POST puzzle ← ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) return;
      throw Exception(
          'Failed to save - status ${response.statusCode}\n${response.body}');
    } catch (e) {
      _log('POST puzzle error: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ADMIN: Crosswords
  // ──────────────────────────────────────────────────────────────────────────

  /// List all crosswords (admin key required)
  Future<List<Map<String, dynamic>>> adminGetCrosswords(String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords');
    _log('GET admin crosswords → $uri');
    try {
      final response = await http
          .get(uri, headers: adminHeaders(adminKey))
          .timeout(const Duration(seconds: 10));
      _log('GET admin crosswords ← ${response.statusCode}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
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

  /// Get one crossword with full grid (admin key required)
  Future<Map<String, dynamic>> adminGetCrossword(
      int id, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords/$id');
    _log('GET admin crossword $id → $uri');
    try {
      final response = await http
          .get(uri, headers: adminHeaders(adminKey))
          .timeout(const Duration(seconds: 10));
      _log('GET admin crossword ← ${response.statusCode}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>;
      }
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      if (response.statusCode == 404) throw Exception('Crossword not found');
      throw Exception('Server error ${response.statusCode}');
    } catch (e) {
      _log('GET admin crossword error: $e');
      rethrow;
    }
  }

  /// Create new crossword (admin key required)
  Future<Map<String, dynamic>> adminCreateCrossword(
      Puzzle puzzle, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords');
    _log('POST admin create crossword → $uri');
    try {
      final bodyJson = puzzle.toJson();
      bodyJson['gridData'] ??= [];
      bodyJson['acrossClues'] ??= [];
      bodyJson['downClues'] ??= [];
      final bodyString = jsonEncode(bodyJson);
      _log('Sending ${bodyString.length} chars');

      final response = await http
          .post(uri, headers: adminHeaders(adminKey), body: bodyString)
          .timeout(const Duration(seconds: 20));
      _log('POST admin crossword ← ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>? ?? {};
      }
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      try {
        final errBody = jsonDecode(response.body);
        throw Exception(
            errBody['error'] ?? 'Server error ${response.statusCode}');
      } catch (_) {
        throw Exception('Failed to create crossword (${response.statusCode})');
      }
    } catch (e) {
      _log('POST admin crossword error: $e');
      rethrow;
    }
  }

  /// Update existing crossword (admin key required)
  Future<void> adminUpdateCrossword(
      int id, Puzzle puzzle, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords/$id');
    _log('PUT admin update crossword $id → $uri');
    try {
      final bodyJson = puzzle.toJson();
      bodyJson['gridData'] ??= [];
      bodyJson['acrossClues'] ??= [];
      bodyJson['downClues'] ??= [];
      final response = await http
          .put(uri, headers: adminHeaders(adminKey), body: jsonEncode(bodyJson))
          .timeout(const Duration(seconds: 20));
      _log('PUT admin crossword ← ${response.statusCode}');
      if (response.statusCode == 200) return;
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      throw Exception('Failed to update (${response.statusCode})');
    } catch (e) {
      _log('PUT admin crossword error: $e');
      rethrow;
    }
  }

  /// Delete crossword (admin key required)
  Future<void> adminDeleteCrossword(int id, String adminKey) async {
    final uri = Uri.parse('$baseUrl/admin/crosswords/$id');
    _log('DELETE admin crossword $id → $uri');
    try {
      final response = await http
          .delete(uri, headers: adminHeaders(adminKey))
          .timeout(const Duration(seconds: 10));
      _log('DELETE admin crossword ← ${response.statusCode}');
      if (response.statusCode == 200) return;
      if (response.statusCode == 403) throw Exception('Invalid admin key');
      throw Exception('Failed to delete (${response.statusCode})');
    } catch (e) {
      _log('DELETE admin crossword error: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  dynamic _safeList(dynamic value) {
    if (value == null || value == 'null' || value == '"null"') return [];
    if (value is List) return value;
    if (value is String && value.trim().isEmpty) return [];
    return [];
  }
}
