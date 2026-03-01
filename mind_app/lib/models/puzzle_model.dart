// lib/models/puzzle_model.dart

import 'dart:math';

class PuzzleItem {
  final int id;
  final String title;
  final String imageUrl;
  final int pieceCount;
  final String category;
  final String difficulty;

  const PuzzleItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.pieceCount,
    required this.category,
    required this.difficulty,
  });

  factory PuzzleItem.fromJson(Map<String, dynamic> json) {
    return PuzzleItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      imageUrl: json['image_url'] as String? ?? '',
      pieceCount: (json['piece_count'] as num?)?.toInt() ?? 16,
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Easy',
    );
  }

  /// Number of columns (and rows) in the grid. E.g. 16 pieces → 4 cols.
  int get cols => sqrt(pieceCount).toInt();
}