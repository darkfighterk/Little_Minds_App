import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Models ────────────────────────────────────────────────────────────

class Story {
  final String id;
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
        id:          j['id']?.toString() ?? '',
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
  final String id;
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
        id:         j['id']?.toString() ?? '',
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
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches all stories (no pages). Optionally filter by [category] or [difficulty].
  static Future<List<Story>> getStories({
    String? category,
    String? difficulty,
  }) async {
    try {
      debugPrint('🔵 StoryService: Fetching stories from Firestore...');
      Query query = _db.collection('stories');
      
      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        query = query.where('category', isEqualTo: category);
      }
      if (difficulty != null && difficulty.isNotEmpty && difficulty.toLowerCase() != 'all') {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Story.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('StoryService.getStories error: $e');
    }
    return [];
  }

  /// Fetches a single story with all its pages from its subcollection.
  static Future<StoryDetail?> getStoryDetail(String id) async {
    try {
      debugPrint('🔵 StoryService: Fetching story detail for $id...');
      final doc = await _db.collection('stories').doc(id).get();
      if (!doc.exists) return null;

      final story = Story.fromJson({...doc.data()!, 'id': doc.id});
      
      final pagesSnapshot = await doc.reference
          .collection('pages')
          .orderBy('page_number')
          .get();

      final pages = pagesSnapshot.docs
          .map((d) => StoryPage.fromJson({...d.data(), 'id': d.id}))
          .toList();

      return StoryDetail(story: story, pages: pages);
    } catch (e) {
      debugPrint('StoryService.getStoryDetail error: $e');
    }
    return null;
  }
}
