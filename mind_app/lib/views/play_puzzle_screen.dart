import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle.dart';
import '../services/api_service.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);
const Color canvasBg = Color(0xFFF8FAFC);

class PlayPuzzleScreen extends StatefulWidget {
  final int puzzleId;
  const PlayPuzzleScreen({super.key, required this.puzzleId});

  @override
  State<PlayPuzzleScreen> createState() => _PlayPuzzleScreenState();
}

class _PlayPuzzleScreenState extends State<PlayPuzzleScreen>
    with TickerProviderStateMixin {
  late Future<Puzzle> _puzzleFuture;
  Puzzle? _puzzle;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  bool _showAnswers = false;
  bool _timeUp = false;
  bool _completed = false;
  int _remainingSeconds = 0;
  Timer? _timer;
  int? _selectedRow;
  int? _selectedCol;

  @override
  void initState() {
    super.initState();
    _puzzleFuture = _fetchPuzzle(widget.puzzleId);
  }

  Future<Puzzle> _fetchPuzzle(int id) async {
    final map = await ApiService().getCrossword(id);
    map['gridData'] = map['gridData'] ?? map['grid_data'] ?? [];
    map['acrossClues'] = map['acrossClues'] ?? map['across_clues'] ?? [];
    map['downClues'] = map['downClues'] ?? map['down_clues'] ?? [];
    map['timerMinutes'] = map['timerMinutes'] ?? map['timer_minutes'] ?? 10;
    map['rows'] = map['rows'] ?? map['grid_rows'] ?? 10;
    map['cols'] = map['cols'] ?? map['grid_cols'] ?? 10;
    return Puzzle.fromJson(map);
  }

  void _setupPuzzle(Puzzle puzzle) {
    _puzzle = puzzle;
    for (int r = 0; r < puzzle.rows; r++) {
      for (int c = 0; c < puzzle.cols; c++) {
        final key = '${r}_$c';
        if (!_controllers.containsKey(key)) {
          _controllers[key] = TextEditingController();
          _focusNodes[key] = FocusNode();
        }
      }
    }
    _startCountdown(puzzle.timerMinutes);
  }

  void _startCountdown(int minutes) {
    _remainingSeconds = minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timeUp = true;
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: FutureBuilder<Puzzle>(
        future: _puzzleFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(
                child: CircularProgressIndicator(color: mainBlue));
          if (snap.hasError) return _buildError(snap.error.toString());

          if (_puzzle == null) _setupPuzzle(snap.data!);
          return _buildMainBody();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context)),
      title: const Text('Puzzle Adventure',
          style: TextStyle(
              fontFamily: 'Recoleta',
              color: Colors.black87,
              fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        _buildTimerBadge(),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget _buildTimerBadge() {
    final bool warning = _remainingSeconds < 60;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:
            warning ? Colors.red.withOpacity(0.1) : mainBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: warning
                ? Colors.red.withOpacity(0.3)
                : mainBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded,
              size: 16, color: warning ? Colors.red : mainBlue),
          const SizedBox(width: 6),
          Text(_formatTime(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: warning ? Colors.red : mainBlue)),
        ],
      ),
    );
  }

  Widget _buildMainBody() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildGrid(),
                const SizedBox(height: 25),
                _buildCluesSection(),
              ],
            ),
          ),
        ),
        _buildBottomControl(),
      ],
    );
  }

  Widget _buildProgressBar() {
    double progress = (_puzzle == null || _puzzle!.totalLetters == 0)
        ? 0
        : (_puzzle!.correctLetters / _puzzle!.totalLetters);
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: mainBlue.withOpacity(0.05),
      valueColor: const AlwaysStoppedAnimation<Color>(mainBlue),
      minHeight: 6,
    );
  }

  Widget _buildGrid() {
    final screenW = MediaQuery.of(context).size.width - 32;
    final cellSize = (screenW / _puzzle!.cols).clamp(25.0, 45.0);

    return Container(
      decoration: BoxDecoration(
        color: canvasBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: mainBlue.withOpacity(0.05), blurRadius: 20)
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: InteractiveViewer(
        child: Column(
          children: List.generate(
              _puzzle!.rows,
              (r) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        _puzzle!.cols, (c) => _buildCell(r, c, cellSize)),
                  )),
        ),
      ),
    );
  }

  Widget _buildCell(int r, int c, double size) {
    final cell = _puzzle!.grid[r][c];
    final key = '${r}_$c';
    if (cell.isBlack)
      return Container(width: size, height: size, color: Colors.grey.shade300);

    bool isSelected = _selectedRow == r && _selectedCol == c;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedRow = r;
        _selectedCol = c;
        _focusNodes[key]?.requestFocus();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? mainBlue.withOpacity(0.1) : Colors.white,
          border: Border.all(
              color: isSelected ? mainBlue : Colors.grey.shade200,
              width: isSelected ? 2 : 0.5),
        ),
        child: Stack(
          children: [
            if (cell.number != null)
              Positioned(
                  top: 2,
                  left: 2,
                  child: Text('${cell.number}',
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: mainBlue))),
            Center(
              child: TextField(
                controller: _controllers[key],
                focusNode: _focusNodes[key],
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.45,
                    color: _showAnswers ? accentOrange : Colors.black87),
                decoration: const InputDecoration(
                    border: InputBorder.none, counterText: ''),
                onChanged: (v) => _onInput(cell, r, c, v),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onInput(Cell cell, int r, int c, String v) {
    setState(() {
      cell.userInput = v.toUpperCase();
      if (v.isNotEmpty) _moveNext(r, c);
    });
    _checkWin();
  }

  void _moveNext(int r, int c) {
    if (c + 1 < _puzzle!.cols && !_puzzle!.grid[r][c + 1].isBlack) {
      _focusNodes['${r}_${c + 1}']?.requestFocus();
    }
  }

  void _checkWin() {
    if (_puzzle!.correctLetters == _puzzle!.totalLetters) {
      setState(() => _completed = true);
      _timer?.cancel();
      _showSuccessDialog();
    }
  }

  Widget _buildCluesSection() {
    return Column(
      children: [
        _ClueBox(
            title: "Across ➔", clues: _puzzle!.acrossClues, color: mainBlue),
        const SizedBox(height: 15),
        _ClueBox(
            title: "Down ⬇", clues: _puzzle!.downClues, color: secondaryPurple),
      ],
    );
  }

  Widget _buildBottomControl() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: Row(
        children: [
          _ActionButton(
              icon: Icons.refresh_rounded,
              label: "Reset",
              color: Colors.grey,
              onTap: _reset),
          const SizedBox(width: 15),
          Expanded(
              child: _ActionButton(
                  icon: Icons.visibility_rounded,
                  label: "Reveal",
                  color: accentOrange,
                  filled: true,
                  onTap: _reveal)),
        ],
      ),
    );
  }

  String _formatTime() {
    int m = _remainingSeconds ~/ 60;
    int s = _remainingSeconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  void _reset() => setState(() {
        _puzzleFuture = _fetchPuzzle(widget.puzzleId);
        _puzzle = null;
      });
  void _reveal() => setState(() {
        _showAnswers = true;
        _timer?.cancel();
      });

  void _showSuccessDialog() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              title: const Text("🏆 Well Done!",
                  style: TextStyle(
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.bold,
                      color: mainBlue)),
              content: const Text("You solved the puzzle, little explorer!"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Awesome!"))
              ],
            ));
  }

  Widget _buildError(String err) =>
      Center(child: Text("Error loading puzzle: $err"));

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers.values) c.dispose();
    for (var f in _focusNodes.values) f.dispose();
    super.dispose();
  }
}

// ──  Helper Widgets ──────────────────────────────────────────

class _ClueBox extends StatelessWidget {
  final String title;
  final List<Clue> clues;
  final Color color;
  const _ClueBox(
      {required this.title, required this.clues, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          const Divider(),
          ...clues.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text("${c.number}. ${c.text}",
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              )),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap,
      this.filled = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: filled ? Colors.white : color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: filled ? Colors.white : color)),
        ]),
      ),
    );
  }
}
