// ============================================================
// story_service.dart
// Place in: lib/services/story_service.dart
//
// Public story endpoints — no admin key required.
// Uses GET /stories          → list of stories (no pages)
// Uses GET /stories/{id}     → full story with pages
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// ── Models ────────────────────────────────────────────────────────────

class Story {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String coverEmoji;
  final String category;
  final String difficulty;
  final String ageRange;
  final int pageCount;

  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.coverEmoji,
    required this.category,
    required this.difficulty,
    required this.ageRange,
    required this.pageCount,
  });

  factory Story.fromJson(Map<String, dynamic> j) => Story(
        id:          (j['id'] as num?)?.toInt() ?? 0,
        title:       j['title'] as String? ?? '',
        author:      j['author'] as String? ?? '',
        description: j['description'] as String? ?? '',
        coverUrl:    j['cover_url'] as String? ?? '',
        coverEmoji:  j['cover_emoji'] as String? ?? '📖',
        category:    j['category'] as String? ?? 'General',
        difficulty:  j['difficulty'] as String? ?? 'Easy',
        ageRange:    j['age_range'] as String? ?? '',
        pageCount:   (j['page_count'] as num?)?.toInt() ?? 0,
      );
}

class StoryPage {
  final int id;
  final int pageNumber;
  final String title;
  final String body;
  final String imageUrl;

  const StoryPage({
    required this.id,
    required this.pageNumber,
    required this.title,
    required this.body,
    required this.imageUrl,
  });

  factory StoryPage.fromJson(Map<String, dynamic> j) => StoryPage(
        id:         (j['id'] as num?)?.toInt() ?? 0,
        pageNumber: (j['page_number'] as num?)?.toInt() ?? 0,
        title:      j['title'] as String? ?? '',
        body:       j['body'] as String? ?? '',
        imageUrl:   j['image_url'] as String? ?? '',
      );
}

class StoryDetail {
  final Story story;
  final List<StoryPage> pages;
  const StoryDetail({required this.story, required this.pages});
}

// ── Service ────────────────────────────────────────────────────────────

class StoryService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080'; // Android emulator
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Fetches all stories (no pages). Optionally filter by [category] or [difficulty].
  static Future<List<Story>> getStories({
    String? category,
    String? difficulty,
  }) async {
    try {
      var url = '$baseUrl/stories';
      final params = <String>[];
      if (category != null && category.isNotEmpty) params.add('category=$category');
      if (difficulty != null && difficulty.isNotEmpty) params.add('difficulty=$difficulty');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final resp = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data
            .cast<Map<String, dynamic>>()
            .map(Story.fromJson)
            .toList();
      }
      print('StoryService.getStories HTTP ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      print('StoryService.getStories error: $e');
    }
    return [];
  }

  /// Fetches a single story with all its pages.
  static Future<StoryDetail?> getStoryDetail(int id) async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/stories/$id'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'] as Map<String, dynamic>;
        final story = Story.fromJson(data);
        final rawPages = data['pages'] as List<dynamic>? ?? [];
        final pages = rawPages
            .cast<Map<String, dynamic>>()
            .map(StoryPage.fromJson)
            .toList()
          ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
        return StoryDetail(story: story, pages: pages);
      }
      print('StoryService.getStoryDetail HTTP ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      print('StoryService.getStoryDetail error: $e');
    }
    return null;
  }
}