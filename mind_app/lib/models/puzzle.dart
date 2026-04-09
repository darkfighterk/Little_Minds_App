// lib/models/puzzle.dart
// Crossword puzzle model — Cell, Clue, and Puzzle.

class Cell {
  bool isBlack;
  int? number;
  String solution;
  String userInput; // client-only, never sent to server

  Cell({
    this.isBlack = false,
    this.number,
    this.solution = '',
    this.userInput = '',
  });

  factory Cell.fromJson(Map<String, dynamic> json) => Cell(
        isBlack: json['isBlack'] as bool? ?? false,
        number: json['number'] as int?,
        solution: json['solution'] as String? ?? '',
        userInput: '',
      );

  Map<String, dynamic> toJson() => {
        'isBlack': isBlack,
        if (number != null) 'number': number,
        'solution': solution,
        // userInput intentionally omitted — client-only
      };

  bool get isEmpty => !isBlack && solution.isEmpty;

  bool get isCorrect =>
      solution.isNotEmpty && userInput.toUpperCase() == solution.toUpperCase();
}

// NOTE: number and text are intentionally non-final (mutable).
// The admin editor (create_puzzle_screen.dart) updates these
// in-place via onChanged callbacks like: clue.text = v
class Clue {
  int number;
  String text;

  Clue({required this.number, required this.text});

  factory Clue.fromJson(Map<String, dynamic> json) => Clue(
        number: json['number'] as int? ?? 0,
        text: json['text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'number': number, 'text': text};
}

class Puzzle {
  final int id;
  final String title;
  final String category;
  final String difficulty;
  final int rows;
  final int cols;
  final List<List<Cell>> grid;
  final List<Clue> acrossClues;
  final List<Clue> downClues;
  final int timerMinutes;

  const Puzzle({
    this.id = 0,
    required this.title,
    this.category = 'General',
    this.difficulty = 'Medium',
    required this.rows,
    required this.cols,
    required this.grid,
    required this.acrossClues,
    required this.downClues,
    this.timerMinutes = 10,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    // ── Grid ──────────────────────────────────────────────────
    List<List<Cell>> parsedGrid = [];
    final rawGrid = json['gridData'];
    if (rawGrid is List) {
      parsedGrid = rawGrid
          .map((row) {
            if (row is List) {
              return row
                  .map((c) =>
                      c is Map<String, dynamic> ? Cell.fromJson(c) : Cell())
                  .toList();
            }
            return <Cell>[];
          })
          .where((row) => row.isNotEmpty)
          .toList();
    }

    // ── Across clues ──────────────────────────────────────────
    List<Clue> parsedAcross = [];
    final rawAcross = json['acrossClues'];
    if (rawAcross is List) {
      parsedAcross = rawAcross
          .whereType<Map<String, dynamic>>()
          .map(Clue.fromJson)
          .toList();
    }

    // ── Down clues ────────────────────────────────────────────
    List<Clue> parsedDown = [];
    final rawDown = json['downClues'];
    if (rawDown is List) {
      parsedDown =
          rawDown.whereType<Map<String, dynamic>>().map(Clue.fromJson).toList();
    }

    return Puzzle(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      rows: json['rows'] as int? ?? 0,
      cols: json['cols'] as int? ?? 0,
      grid: parsedGrid,
      acrossClues: parsedAcross,
      downClues: parsedDown,
      timerMinutes: json['timerMinutes'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'difficulty': difficulty,
        'rows': rows,
        'cols': cols,
        'gridData':
            grid.map((row) => row.map((c) => c.toJson()).toList()).toList(),
        'acrossClues': acrossClues.map((c) => c.toJson()).toList(),
        'downClues': downClues.map((c) => c.toJson()).toList(),
        'timerMinutes': timerMinutes,
      };

  int get totalLetters => grid
      .expand((r) => r)
      .where((c) => !c.isBlack && c.solution.isNotEmpty)
      .length;

  int get correctLetters =>
      grid.expand((r) => r).where((c) => c.isCorrect).length;

  double get completionPercent =>
      totalLetters == 0 ? 0 : correctLetters / totalLetters;
}
