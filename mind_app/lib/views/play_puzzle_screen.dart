import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/puzzle.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────────────────────────────────────

const _bg = Color(0xFF0F1117);
const _surface = Color(0xFF1A1D27);
const _surfaceHigh = Color(0xFF23273A);
const _accent = Color(0xFF6C63FF);
const _accentSoft = Color(0xFF9B94FF);
const _danger = Color(0xFFFF5C5C);
const _success = Color(0xFF4ADE80);
const _warning = Color(0xFFFFBB45);
const _textPrimary = Color(0xFFF0F0F5);
const _textSecondary = Color(0xFF9395A5);
const _border = Color(0xFF2E3248);
const _cellWhite = Color(0xFFF8F8FC);
const _cellBlack = Color(0xFF0D0F16);

// ─────────────────────────────────────────────────────────────────────────────
// Play Screen
// ─────────────────────────────────────────────────────────────────────────────

class PlayPuzzleScreen extends StatefulWidget {
  final int puzzleId;
  const PlayPuzzleScreen({super.key, required this.puzzleId});

  @override
  State<PlayPuzzleScreen> createState() => _PlayPuzzleScreenState();
}

class _PlayPuzzleScreenState extends State<PlayPuzzleScreen>
    with TickerProviderStateMixin {
  // ── Data ─────────────────────────────────────────────────────────────────
  late Future<Puzzle> _puzzleFuture;
  Puzzle? _puzzle;

  // ── Controllers — keyed by "row_col" ─────────────────────────────────────
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  // ── Game state ────────────────────────────────────────────────────────────
  bool _showAnswers = false;
  bool _timeUp = false;
  bool _completed = false;
  int _remainingSeconds = 0;
  Timer? _timer;
  int? _selectedRow;
  int? _selectedCol;

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late AnimationController _celebCtrl;

  // ─────────────────────────────────────────────────────────────────────────
  // KEY FIX: call getCrossword (→ /crosswords/$id), not getPuzzle (→ /puzzles/$id)
  // Also normalise the map so Puzzle.fromJson always finds the right keys.
  // ─────────────────────────────────────────────────────────────────────────
  Future<Puzzle> _fetchPuzzle(int id) async {
    // ✅ correct endpoint
    final map = await ApiService().getCrossword(id);

    // Backend returns camelCase (gridData, acrossClues, downClues, timerMinutes).
    // Normalise just in case the server ever returns snake_case variants.
    map['gridData'] = _safeList(map['gridData'] ?? map['grid_data']);
    map['acrossClues'] = _safeList(map['acrossClues'] ?? map['across_clues']);
    map['downClues'] = _safeList(map['downClues'] ?? map['down_clues']);
    map['timerMinutes'] = map['timerMinutes'] ?? map['timer_minutes'] ?? 10;
    map['rows'] = map['rows'] ?? map['grid_rows'] ?? 10;
    map['cols'] = map['cols'] ?? map['grid_cols'] ?? 10;

    return Puzzle.fromJson(map);
  }

  static dynamic _safeList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v;
    return [];
  }

  @override
  void initState() {
    super.initState();
    _puzzleFuture = _fetchPuzzle(widget.puzzleId);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _celebCtrl.dispose();
    for (final c in _controllers.values) c.dispose();
    for (final f in _focusNodes.values) f.dispose();
    super.dispose();
  }

  // ── Setup ─────────────────────────────────────────────────────────────────

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

  // ── Input ─────────────────────────────────────────────────────────────────

  void _onCellChanged(Cell cell, int r, int c, String value) {
    if (_timeUp || _showAnswers) return;
    final letter = value.isEmpty ? '' : value[value.length - 1].toUpperCase();
    setState(() {
      cell.userInput = letter;
      _controllers['${r}_$c']!.text = letter;
      _controllers['${r}_$c']!.selection =
          TextSelection.collapsed(offset: letter.length);
    });
    if (letter.isNotEmpty) _advanceFocus(r, c);
    _checkCompletion();
  }

  void _advanceFocus(int r, int c) {
    if (_puzzle == null) return;
    for (int nc = c + 1; nc < _puzzle!.cols; nc++) {
      if (!_puzzle!.grid[r][nc].isBlack) {
        _focusNodes['${r}_$nc']?.requestFocus();
        return;
      }
    }
    for (int nr = r + 1; nr < _puzzle!.rows; nr++) {
      for (int nc = 0; nc < _puzzle!.cols; nc++) {
        if (!_puzzle!.grid[nr][nc].isBlack) {
          _focusNodes['${nr}_$nc']?.requestFocus();
          return;
        }
      }
    }
  }

  void _checkCompletion() {
    if (_puzzle == null) return;
    final total = _puzzle!.totalLetters;
    if (total == 0) return;
    if (_puzzle!.correctLetters == total) {
      setState(() => _completed = true);
      _celebCtrl.forward(from: 0);
      _timer?.cancel();
    }
  }

  void _revealAnswers() {
    if (_puzzle == null) return;
    setState(() {
      _showAnswers = true;
      _timer?.cancel();
    });
    for (int r = 0; r < _puzzle!.rows; r++) {
      for (int c = 0; c < _puzzle!.cols; c++) {
        final cell = _puzzle!.grid[r][c];
        if (!cell.isBlack) {
          _controllers['${r}_$c']?.text = cell.solution;
          cell.userInput = cell.solution;
        }
      }
    }
  }

  void _resetPuzzle() {
    if (_puzzle == null) return;
    setState(() {
      _showAnswers = false;
      _timeUp = false;
      _completed = false;
    });
    for (int r = 0; r < _puzzle!.rows; r++) {
      for (int c = 0; c < _puzzle!.cols; c++) {
        final cell = _puzzle!.grid[r][c];
        cell.userInput = '';
        _controllers['${r}_$c']?.text = '';
      }
    }
    _timer?.cancel();
    _startCountdown(_puzzle!.timerMinutes);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTime() {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_puzzle == null || _puzzle!.totalLetters == 0) return 0;
    return _puzzle!.correctLetters / _puzzle!.totalLetters;
  }

  Color get _timerColor {
    if (_timeUp) return _danger;
    if (_remainingSeconds <= 30) return _danger;
    if (_remainingSeconds <= 60) return _warning;
    return _success;
  }

  Color _cellColor(Cell cell, int r, int c) {
    if (cell.isBlack) return _cellBlack;
    if (_selectedRow == r && _selectedCol == c)
      return _accent.withOpacity(0.15);
    if (_showAnswers) return const Color(0xFFFFF8F8);
    if (cell.userInput.isNotEmpty) {
      return cell.isCorrect
          ? _success.withOpacity(0.12)
          : _danger.withOpacity(0.08);
    }
    return _cellWhite;
  }

  Color _letterColor(Cell cell) {
    if (_showAnswers) return const Color(0xFFCC2222);
    if (cell.userInput.isEmpty) return const Color(0xFF1A1A3A);
    return cell.isCorrect ? const Color(0xFF1A7A3A) : const Color(0xFFBB2222);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FutureBuilder<Puzzle>(
        future: _puzzleFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _accent));
          }
          if (snap.hasError || !snap.hasData) {
            return _ErrorView(
              message: snap.error?.toString() ?? 'No data',
              onRetry: () => setState(() {
                _puzzleFuture = _fetchPuzzle(widget.puzzleId);
              }),
            );
          }

          final puzzle = snap.data!;
          if (_puzzle == null) {
            _setupPuzzle(puzzle);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _startCountdown(puzzle.timerMinutes);
            });
          }
          return _buildMain(puzzle);
        },
      ),
    );
  }

  Widget _buildMain(Puzzle puzzle) {
    return Column(
      children: [
        _buildHeader(puzzle),
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              children: [
                _buildGrid(puzzle),
                const SizedBox(height: 24),
                _buildCluesSection(puzzle),
              ],
            ),
          ),
        ),
        _buildBottomBar(puzzle),
        if (_completed) _buildCompletionBanner(),
        if (_timeUp && !_completed) _buildTimeUpBanner(),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(Puzzle puzzle) {
    return Container(
      color: _surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: _textSecondary, size: 20),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: _surfaceHigh,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  puzzle.title,
                  style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    _MiniChip(label: puzzle.category, color: _accentSoft),
                    const SizedBox(width: 6),
                    _MiniChip(
                      label: puzzle.difficulty,
                      color: puzzle.difficulty == 'Easy'
                          ? _success
                          : puzzle.difficulty == 'Hard'
                              ? _danger
                              : _warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Timer
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final pulse = _timeUp || _remainingSeconds <= 30;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: pulse
                      ? _timerColor.withOpacity(0.1 + 0.08 * _pulseCtrl.value)
                      : _surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: pulse ? _timerColor.withOpacity(0.4) : _border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _timeUp ? Icons.timer_off_rounded : Icons.timer_rounded,
                      size: 14,
                      color: _timerColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _timeUp ? 'TIME UP' : _formatTime(),
                      style: TextStyle(
                        color: _timerColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Progress bar ──────────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    final pct = (_progress * 100).toInt();
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress',
                  style: TextStyle(color: _textSecondary, fontSize: 11)),
              Text(
                '$pct%  (${_puzzle?.correctLetters ?? 0}/${_puzzle?.totalLetters ?? 0})',
                style: const TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: _border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  _completed ? _success : _accent),
              minHeight: 5,
            ),
          ),
          Container(
              height: 1,
              color: _border,
              margin: const EdgeInsets.only(top: 10)),
        ],
      ),
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  Widget _buildGrid(Puzzle puzzle) {
    if (puzzle.grid.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Grid is empty', style: TextStyle(color: _textSecondary)),
        ),
      );
    }

    final screenW = MediaQuery.of(context).size.width - 32;
    final rawSize = screenW / puzzle.cols;
    final cellSize = rawSize.clamp(22.0, 42.0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _border, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 3.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(puzzle.rows, (r) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(puzzle.cols, (c) {
                  if (r >= puzzle.grid.length || c >= puzzle.grid[r].length) {
                    return SizedBox(width: cellSize, height: cellSize);
                  }
                  return _buildCell(puzzle.grid[r][c], r, c, cellSize);
                }),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(Cell cell, int r, int c, double size) {
    final key = '${r}_$c';
    if (cell.isBlack) {
      return Container(width: size, height: size, color: _cellBlack);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRow = r;
          _selectedCol = c;
        });
        _focusNodes[key]?.requestFocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _cellColor(cell, r, c),
          border: Border.all(
            color: (_selectedRow == r && _selectedCol == c)
                ? _accent
                : const Color(0xFFCCCCDD),
            width: (_selectedRow == r && _selectedCol == c) ? 1.5 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            if (cell.number != null)
              Positioned(
                top: 1,
                left: 2,
                child: Text(
                  '${cell.number}',
                  style: TextStyle(
                    fontSize: (size * 0.24).clamp(6.0, 10.0),
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Center(
              child: TextField(
                controller: _controllers[key],
                focusNode: _focusNodes[key],
                textAlign: TextAlign.center,
                maxLength: 2,
                textCapitalization: TextCapitalization.characters,
                enabled: !_showAnswers && !_timeUp,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                ],
                style: TextStyle(
                  fontSize: (size * 0.46).clamp(10.0, 20.0),
                  color: _letterColor(cell),
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (v) => _onCellChanged(cell, r, c, v),
                onTap: () {
                  setState(() {
                    _selectedRow = r;
                    _selectedCol = c;
                  });
                  _controllers[key]?.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controllers[key]!.text.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Clues ─────────────────────────────────────────────────────────────────

  Widget _buildCluesSection(Puzzle puzzle) {
    if (puzzle.acrossClues.isEmpty && puzzle.downClues.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (puzzle.acrossClues.isNotEmpty)
          Expanded(
              child: _ClueGroup(title: 'Across', clues: puzzle.acrossClues)),
        if (puzzle.acrossClues.isNotEmpty && puzzle.downClues.isNotEmpty)
          const SizedBox(width: 12),
        if (puzzle.downClues.isNotEmpty)
          Expanded(child: _ClueGroup(title: 'Down', clues: puzzle.downClues)),
      ],
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(Puzzle puzzle) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          _BarButton(
            icon: Icons.refresh_rounded,
            label: 'Reset',
            onPressed: _resetPuzzle,
            color: _textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BarButton(
              icon: Icons.visibility_rounded,
              label: _showAnswers ? 'Answers Shown' : 'Reveal Answers',
              onPressed: _showAnswers ? null : _revealAnswers,
              color: _danger,
              filled: true,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: _accentSoft,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text('Score',
                    style: TextStyle(color: _textSecondary, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Banners ───────────────────────────────────────────────────────────────

  Widget _buildCompletionBanner() {
    return AnimatedBuilder(
      animation: _celebCtrl,
      builder: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: _success.withOpacity(0.92),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text('Puzzle Complete! 🎉',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUpBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: _danger.withOpacity(0.88),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_off_rounded, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Text("Time's Up!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clue group
// ─────────────────────────────────────────────────────────────────────────────

class _ClueGroup extends StatelessWidget {
  final String title;
  final List<Clue> clues;
  const _ClueGroup({required this.title, required this.clues});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  title == 'Across'
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: _accentSoft,
                ),
                const SizedBox(width: 6),
                Text(title,
                    style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3)),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          ...clues.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text('${c.number}',
                          style: const TextStyle(
                              color: _accentSoft,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.text.isEmpty ? '—' : c.text,
                      style: const TextStyle(
                          color: _textPrimary, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool filled;

  const _BarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              onPressed == null ? _surfaceHigh : color.withOpacity(0.15),
          foregroundColor: onPressed == null ? _textSecondary : color,
          elevation: 0,
          side: BorderSide(
              color: onPressed == null ? _border : color.withOpacity(0.3)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: _danger.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  color: _danger, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('Failed to load puzzle',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              message.length > 100 ? '${message.substring(0, 100)}…' : message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
