// lib/services/puzzle_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/puzzle_model.dart';

class PuzzleService {
  // ── Base URL ───────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
    // For real device use your PC IP: 'http://192.168.x.x:8080'
  }

  // ── Image URL normaliser (keeps URLs working on both Web & Mobile) ─────────
  static String normalizeImageUrl(String url) {
    if (url.isEmpty) return url;
    const mobileHost = '10.0.2.2:8080';
    const webHost = 'localhost:8080';
    if (kIsWeb) {
      return url.replaceFirst('http://$mobileHost', 'http://$webHost');
    } else {
      return url.replaceFirst('http://$webHost', 'http://$mobileHost');
    }
  }

  // ── Fetch all jigsaw puzzles ───────────────────────────────────────────────
  // Backend response shape: { "data": { "puzzles": [ {...}, ... ] } }
  Future<List<PuzzleItem>> fetchPuzzles({String? category}) async {
    try {
      final uri = (category != null && category.isNotEmpty)
          ? Uri.parse(
              '$baseUrl/puzzles?category=${Uri.encodeComponent(category)}')
          : Uri.parse('$baseUrl/puzzles');

      print('🔵 PuzzleService: GET $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;

        // Unwrap: { data: { puzzles: [...] } }
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final rawList = data['puzzles'] as List<dynamic>? ?? [];

        print('✅ PuzzleService: ${rawList.length} puzzles received');

        return rawList.map((e) {
          final json = Map<String, dynamic>.from(e as Map);

          // Normalise image URL for current platform
          if (json['image_url'] is String) {
            json['image_url'] = normalizeImageUrl(json['image_url'] as String);
          }

          return PuzzleItem.fromJson(json);
        }).toList();
      }

      print('⚠️ PuzzleService: HTTP ${response.statusCode} — ${response.body}');
    } catch (e, st) {
      print('❌ PuzzleService.fetchPuzzles error: $e\n$st');
    }

    return [];
  }

  // ── Utility: filter locally ────────────────────────────────────────────────
  static List<PuzzleItem> filterByCategory(
    List<PuzzleItem> puzzles,
    String category,
  ) {
    if (category.toLowerCase() == 'all') return puzzles;
    return puzzles
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  static List<PuzzleItem> filterByDifficulty(
    List<PuzzleItem> puzzles,
    String difficulty,
  ) {
    return puzzles
        .where((p) => p.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }
}
