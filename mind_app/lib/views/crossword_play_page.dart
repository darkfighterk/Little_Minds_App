// lib/views/crossword_play_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/crossword.dart';

class CrosswordPlayPage extends StatefulWidget {
  final Puzzle puzzle;
  final dynamic user; // optional - you can pass null

  const CrosswordPlayPage({
    required this.puzzle,
    this.user,
    super.key,
  });

  @override
  State<CrosswordPlayPage> createState() => _CrosswordPlayPageState();
}

class _CrosswordPlayPageState extends State<CrosswordPlayPage> {
  late List<List<CrosswordCell>> userGrid;
  int secondsRemaining = 900; // 15 minutes
  Timer? _timer;
  int score = 0;

  final TextEditingController _inputController = TextEditingController();
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    userGrid = List.generate(
      widget.puzzle.rows,
      (r) => List.generate(
        widget.puzzle.cols,
        (c) => CrosswordCell(
          isBlack: widget.puzzle.grid[r][c].isBlack,
          letter: '',
          number: widget.puzzle.grid[r][c].number,
        ),
      ),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        _timer?.cancel();
        _showGameOver();
      }
    });
  }

  void _selectCell(int r, int c) {
    if (userGrid[r][c].isBlack) return;

    setState(() {
      selectedRow = r;
      selectedCol = c;
      _inputController.text = userGrid[r][c].letter;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cell ($r, $c)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(labelText: 'Letter (A-Z)'),
              maxLength: 1,
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                final entered = _inputController.text.toUpperCase().trim();
                userGrid[r][c].letter = entered;
                if (entered == widget.puzzle.grid[r][c].letter &&
                    entered.isNotEmpty) {
                  score += 10;
                }
              });
              Navigator.pop(context);
              _checkIfCompleted();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _checkIfCompleted() {
    bool completed = true;
    for (int r = 0; r < widget.puzzle.rows; r++) {
      for (int c = 0; c < widget.puzzle.cols; c++) {
        if (!userGrid[r][c].isBlack &&
            userGrid[r][c].letter != widget.puzzle.grid[r][c].letter) {
          completed = false;
          break;
        }
      }
      if (!completed) break;
    }

    if (completed) {
      _timer?.cancel();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Text('You solved the puzzle!\nScore: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('⏰ Time\'s Up'),
        content: Text('Final Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    final min = secondsRemaining ~/ 60;
    final sec = secondsRemaining % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.puzzle.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_formatTime(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade900,
            child: Center(
              child: Text('Score: $score',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.puzzle.cols,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                ),
                itemCount: widget.puzzle.rows * widget.puzzle.cols,
                itemBuilder: (context, index) {
                  final r = index ~/ widget.puzzle.cols;
                  final c = index % widget.puzzle.cols;
                  final cell = userGrid[r][c];

                  if (cell.isBlack) {
                    return Container(color: Colors.black87);
                  }

                  return GestureDetector(
                    onTap: () => _selectCell(r, c),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (cell.number != null)
                            Positioned(
                              top: 2,
                              left: 4,
                              child: Text('${cell.number}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          Text(
                            cell.letter,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Clues
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E1040),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACROSS',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.puzzle.acrossClues.length,
                          itemBuilder: (_, i) => Text(
                              '${widget.puzzle.acrossClues[i].number}. ${widget.puzzle.acrossClues[i].text}',
                              style: const TextStyle(color: Colors.white70)),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DOWN',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.puzzle.downClues.length,
                          itemBuilder: (_, i) => Text(
                              '${widget.puzzle.downClues[i].number}. ${widget.puzzle.downClues[i].text}',
                              style: const TextStyle(color: Colors.white70)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
