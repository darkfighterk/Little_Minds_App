// lib/models/puzzle.dart
import 'package:flutter/foundation.dart';

class CrosswordCell {
  bool isBlack;
  bool isInvisible;
  String letter; // normal letter (solution)
  int? number; // superscript clue number (optional)

  CrosswordCell({
    this.isBlack = false,
    this.isInvisible = false,
    this.letter = '',
    this.number,
  });

  Map<String, dynamic> toJson() => {
        'isBlack': isBlack,
        'isInvisible': isInvisible,
        'letter': letter,
        'number': number,
      };

  factory CrosswordCell.fromJson(Map<String, dynamic> json) => CrosswordCell(
        isBlack: json['isBlack'] ?? false,
        isInvisible: json['isInvisible'] ?? false,
        letter: json['letter'] ?? '',
        number: json['number'],
      );
}

class Clue {
  int number;
  String text;

  Clue({required this.number, required this.text});

  Map<String, dynamic> toJson() => {'number': number, 'text': text};

  factory Clue.fromJson(Map<String, dynamic> json) =>
      Clue(number: json['number'], text: json['text']);
}

class Puzzle {
  String? id;
  String title;
  int rows;
  int cols;
  List<List<CrosswordCell>> grid;
  List<Clue> acrossClues;
  List<Clue> downClues;

  Puzzle({
    this.id,
    required this.title,
    required this.rows,
    required this.cols,
    required this.grid,
    required this.acrossClues,
    required this.downClues,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'rows': rows,
        'cols': cols,
        'grid': grid
            .map((row) => {
                  'cells': row.map((cell) => cell.toJson()).toList(),
                })
            .toList(),
        'acrossClues': acrossClues.map((c) => c.toJson()).toList(),
        'downClues': downClues.map((c) => c.toJson()).toList(),
        'createdAt': DateTime.now().millisecondsSinceEpoch, // optional
      };

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'],
      title: json['title'] ?? '',
      rows: json['rows'] ?? 5,
      cols: json['cols'] ?? 5,
      grid: (json['grid'] as List<dynamic>? ?? [])
          .map<List<CrosswordCell>>((row) {
        if (row is Map<String, dynamic> && row['cells'] is List<dynamic>) {
          return (row['cells'] as List<dynamic>)
              .map((cell) =>
                  CrosswordCell.fromJson(cell as Map<String, dynamic>))
              .toList();
        }
        if (row is List<dynamic>) {
          return row
              .map((cell) =>
                  CrosswordCell.fromJson(cell as Map<String, dynamic>))
              .toList();
        }
        return <CrosswordCell>[];
      }).toList(),
      acrossClues: (json['acrossClues'] as List<dynamic>? ?? [])
          .map((c) => Clue.fromJson(c as Map<String, dynamic>))
          .toList(),
      downClues: (json['downClues'] as List<dynamic>? ?? [])
          .map((c) => Clue.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
