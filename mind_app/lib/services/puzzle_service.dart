// lib/services/puzzle_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/puzzle_model.dart';

class PuzzleService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
  }

  /// Fetches all puzzles from the public /puzzles endpoint.
  /// Optionally filter by [category].
  Future<List<PuzzleItem>> fetchPuzzles({String? category}) async {
    try {
      final uri = (category != null && category.isNotEmpty)
          ? Uri.parse('$baseUrl/puzzles?category=${Uri.encodeComponent(category)}')
          : Uri.parse('$baseUrl/puzzles');

      final resp = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data
            .cast<Map<String, dynamic>>()
            .map(PuzzleItem.fromJson)
            .toList();
      }
      print('PuzzleService.fetchPuzzles HTTP ${resp.statusCode}');
    } catch (e) {
      print('PuzzleService.fetchPuzzles error: $e');
    }
    return [];
  }
}