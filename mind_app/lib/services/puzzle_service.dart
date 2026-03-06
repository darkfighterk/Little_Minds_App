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

  /// Rewrites any image URL so the host matches the current platform.
  ///
  /// The backend stores the URL using the host the uploader connected from.
  /// If someone uploaded via web (localhost) and you're now on Android (10.0.2.2),
  /// or vice-versa, the image won't load. This method normalises the host.
  static String normalizeImageUrl(String url) {
    if (url.isEmpty) return url;

    // List of known host variants the backend may have stored
    const mobileHost = '10.0.2.2:8080';
    const webHost = 'localhost:8080';

    if (kIsWeb) {
      // On web replace any mobile-only host with localhost
      return url
          .replaceFirst('http://$mobileHost', 'http://$webHost')
          .replaceFirst('https://$mobileHost', 'http://$webHost');
    } else {
      // On mobile replace localhost with the emulator gateway
      return url
          .replaceFirst('http://$webHost', 'http://$mobileHost')
          .replaceFirst('https://$webHost', 'http://$mobileHost');
    }
  }

  /// Fetches all puzzles from the public /puzzles endpoint.
  /// Optionally filter by [category].
  Future<List<PuzzleItem>> fetchPuzzles({String? category}) async {
    try {
      final uri = (category != null && category.isNotEmpty)
          ? Uri.parse(
              '$baseUrl/puzzles?category=${Uri.encodeComponent(category)}')
          : Uri.parse('$baseUrl/puzzles');

      final resp = await http.get(uri).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>().map((json) {
          // Normalize the image URL before constructing the model
          if (json['image_url'] is String) {
            json['image_url'] = normalizeImageUrl(json['image_url'] as String);
          }
          return PuzzleItem.fromJson(json);
        }).toList();
      }
      print('PuzzleService.fetchPuzzles HTTP ${resp.statusCode}');
    } catch (e) {
      print('PuzzleService.fetchPuzzles error: $e');
    }
    return [];
  }
}
