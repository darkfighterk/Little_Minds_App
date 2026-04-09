// lib/models/puzzle_model.dart
import 'dart:math';

/// Jigsaw puzzle — matches backend JSON:
/// { id, title, image_url, piece_count, category, difficulty }
/// NOTE: backend sends id as a String (e.g. "1"), so we parse it safely.
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
      // Backend returns id as String ("1"), so handle both String and num
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      imageUrl: json['image_url'] as String? ?? '',
      // piece_count may also be a String from backend
      pieceCount: int.tryParse(json['piece_count']?.toString() ?? '16') ?? 16,
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Easy',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'piece_count': pieceCount,
        'category': category,
        'difficulty': difficulty,
      };

  /// Grid columns derived from piece count. E.g. 16 pieces → 4 cols.
  int get cols => sqrt(pieceCount).toInt();
}
