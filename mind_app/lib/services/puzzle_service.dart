import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puzzle_model.dart';

class PuzzleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Fetch all jigsaw puzzles from Firestore ────────────────────────────────
  Future<List<PuzzleItem>> fetchPuzzles({String? category}) async {
    try {
      debugPrint('🔵 PuzzleService: Fetching from Firestore...');
      
      Query query = _db.collection('puzzles');
      
      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      debugPrint('✅ PuzzleService: ${snapshot.docs.length} puzzles received');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Use Firestore document ID
        return PuzzleItem.fromJson(data);
      }).toList();
    } catch (e, st) {
      debugPrint('❌ PuzzleService.fetchPuzzles error: $e\n$st');
    }

    return [];
  }

  // ── Utility: filter locally (Still useful for some UI logic) ───────────────
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
