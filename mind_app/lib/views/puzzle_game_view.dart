// lib/views/puzzle_game_view.dart
//
// Jigsaw puzzle game
//
//  ┌──────────────────────────────────┐
//  │  AppBar  title · pieces · timer  │
//  │  ▓▓▓▓▓▓░░░░░░  progress bar      │
//  │                                  │
//  │   BOARD  – N×N drop targets      │
//  │   (jigsaw-shaped ghost slots)    │
//  │                                  │
//  │  ── 12 pieces left ──            │
//  │                                  │
//  │   TRAY  – horizontal scroll      │
//  │   (shuffled draggable pieces)    │
//  └──────────────────────────────────┘
//
// Piece rendering:  ClipPath(jigsaw) → SizedBox → Stack(Clip.none)
//                   → Positioned(left, top, width, height)
//                   → Image.network   (full image, shifted so this
//                                      piece's region shows through clip)
//
// No ui.Image / dart:ui needed – Image.network is used directly.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle_model.dart';
import '../models/user_model.dart';

// ── Brand palette (consistent with entire app) ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

// ── Game-canvas palette (intentionally dark/immersive) ──
const Color _canvasBg = Color(0xFF0D0520);
const Color _boardBg = Color(0xFF160830);
const Color _trayBg = Color(0xFF080215);
const Color _pieceGlow = Color(0xFFFF7043);

// ─────────────────────────────────────────────────────────────────
// EDGE MODEL
//   1 = tab   (knob protrudes OUT)
//  -1 = blank (hole cut IN)
//   0 = flat  (border edge)
// ─────────────────────────────────────────────────────────────────

class _E {
  final int top, right, bottom, left;
  const _E(
      {required this.top,
      required this.right,
      required this.bottom,
      required this.left});
}

/// Deterministic edge map for a given seed – same seed → same puzzle.
List<_E> _makeEdges(int cols, Random rng) {
  final rows = cols;
  final hj = List.generate(
      rows - 1, (_) => List.generate(cols, (_) => rng.nextBool() ? 1 : -1));
  final vj = List.generate(
      rows, (_) => List.generate(cols - 1, (_) => rng.nextBool() ? 1 : -1));

  return List.generate(rows * cols, (i) {
    final r = i ~/ cols, c = i % cols;
    return _E(
      top: r == 0 ? 0 : -hj[r - 1][c],
      bottom: r == rows - 1 ? 0 : hj[r][c],
      left: c == 0 ? 0 : -vj[r][c - 1],
      right: c == cols - 1 ? 0 : vj[r][c],
    );
  });
}

// ─────────────────────────────────────────────────────────────────
// JIGSAW PATH  (bezier tabs & blanks)
// ─────────────────────────────────────────────────────────────────

Path _jigsawPath(_E e, double cell, double nub) {
  final o = nub;
  final p = Path()..moveTo(o, o);
  _hSeg(p, o, o + cell, o, e.top * (-nub)); // top    L→R
  _vSeg(p, o + cell, o, o + cell, e.right * nub); // right  T→B
  _hSeg(p, o + cell, o, o + cell, e.bottom * nub); // bottom R→L
  _vSeg(p, o, o + cell, o, e.left * (-nub)); // left   B→T
  return p..close();
}

void _hSeg(Path p, double x0, double x1, double y, double n) {
  if (n == 0) {
    p.lineTo(x1, y);
    return;
  }
  final s = x1 > x0 ? 1.0 : -1.0;
  final w = (x1 - x0).abs();
  final mx = x0 + s * w * .5;
  p.lineTo(x0 + s * w * .28, y);
  p.cubicTo(x0 + s * w * .28, y + n * .6, mx - s * w * .12, y + n, mx, y + n);
  p.cubicTo(mx + s * w * .12, y + n, x0 + s * w * .72, y + n * .6,
      x0 + s * w * .72, y);
  p.lineTo(x1, y);
}

void _vSeg(Path p, double x, double y0, double y1, double n) {
  if (n == 0) {
    p.lineTo(x, y1);
    return;
  }
  final s = y1 > y0 ? 1.0 : -1.0;
  final h = (y1 - y0).abs();
  final my = y0 + s * h * .5;
  p.lineTo(x, y0 + s * h * .28);
  p.cubicTo(x + n * .6, y0 + s * h * .28, x + n, my - s * h * .12, x + n, my);
  p.cubicTo(x + n, my + s * h * .12, x + n * .6, y0 + s * h * .72, x,
      y0 + s * h * .72);
  p.lineTo(x, y1);
}

// ─────────────────────────────────────────────────────────────────
// JIGSAW CLIPPER
// ─────────────────────────────────────────────────────────────────

class _JigsawClipper extends CustomClipper<Path> {
  final _E edge;
  final double cell, nub;
  const _JigsawClipper(this.edge, this.cell, this.nub);

  @override
  Path getClip(Size _) => _jigsawPath(edge, cell, nub);

  @override
  bool shouldReclip(_JigsawClipper o) => o.cell != cell || o.nub != nub;
}

// ─────────────────────────────────────────────────────────────────
// PIECE WIDGET
// ─────────────────────────────────────────────────────────────────

class _PieceTile extends StatelessWidget {
  final String imageUrl;
  final int pieceIndex;
  final int cols;
  final _E edge;
  final double cell, nub;
  final bool correct;

  const _PieceTile({
    required this.imageUrl,
    required this.pieceIndex,
    required this.cols,
    required this.edge,
    required this.cell,
    required this.nub,
    this.correct = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = pieceIndex ~/ cols;
    final col = pieceIndex % cols;
    final sz = cell + 2 * nub;
    final imgPx = cell * cols;
    final left = nub - col * cell;
    final top = nub - row * cell;

    return SizedBox(
      width: sz,
      height: sz,
      child: Stack(children: [
        ClipPath(
          clipper: _JigsawClipper(edge, cell, nub),
          child: SizedBox(
            width: sz,
            height: sz,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: left,
                  top: top,
                  width: imgPx,
                  height: imgPx,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    loadingBuilder: (_, child, prog) {
                      if (prog == null) return child;
                      return Container(
                        color: const Color(0xFF1E1040),
                        child: Center(
                          child: SizedBox(
                            width: cell * .28,
                            height: cell * .28,
                            child: const CircularProgressIndicator(
                                color: secondaryPurple, strokeWidth: 1.5),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1E1040),
                      child: Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white24, size: cell * .3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomPaint(
          size: Size(sz, sz),
          painter: _PieceOutline(edge, cell, nub, correct: correct),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GHOST SLOT WIDGET
// ─────────────────────────────────────────────────────────────────

class _GhostSlot extends StatelessWidget {
  final _E edge;
  final double cell, nub;
  final bool hovered, wrong;

  const _GhostSlot({
    required this.edge,
    required this.cell,
    required this.nub,
    this.hovered = false,
    this.wrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final sz = cell + 2 * nub;
    return CustomPaint(
      size: Size(sz, sz),
      painter: _GhostPainter(edge, cell, nub, hovered: hovered, wrong: wrong),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PAINTERS  (outline + ghost)
// ─────────────────────────────────────────────────────────────────

class _PieceOutline extends CustomPainter {
  final _E edge;
  final double cell, nub;
  final bool correct;
  const _PieceOutline(this.edge, this.cell, this.nub, {this.correct = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _jigsawPath(edge, cell, nub),
      Paint()
        ..color = correct
            ? const Color(0xFF4CAF50).withValues(alpha: .95)
            : Colors.white.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = correct ? 2.4 : 1.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PieceOutline o) => o.correct != correct;
}

class _GhostPainter extends CustomPainter {
  final _E edge;
  final double cell, nub;
  final bool hovered, wrong;
  const _GhostPainter(this.edge, this.cell, this.nub,
      {this.hovered = false, this.wrong = false});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _jigsawPath(edge, cell, nub);

    final fill = wrong
        ? Colors.red.withValues(alpha: .18)
        : hovered
            ? _pieceGlow.withValues(alpha: .18)
            : Colors.white.withValues(alpha: .05);
    canvas.drawPath(
        path,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill);

    final cx = nub + cell / 2, cy = nub + cell / 2;
    final ir = cell * .10;
    final ip = Paint()
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (wrong) {
      ip.color = Colors.red.withValues(alpha: .75);
      canvas.drawLine(Offset(cx - ir, cy - ir), Offset(cx + ir, cy + ir), ip);
      canvas.drawLine(Offset(cx + ir, cy - ir), Offset(cx - ir, cy + ir), ip);
    } else if (hovered) {
      ip.color = _pieceGlow.withValues(alpha: .9);
      canvas.drawLine(Offset(cx - ir, cy), Offset(cx + ir, cy), ip);
      canvas.drawLine(Offset(cx, cy - ir), Offset(cx, cy + ir), ip);
    }

    canvas.drawPath(
        path,
        Paint()
          ..color = wrong
              ? Colors.red.withValues(alpha: .65)
              : hovered
                  ? _pieceGlow.withValues(alpha: .85)
                  : Colors.white.withValues(alpha: .20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = hovered || wrong ? 1.8 : 1.2
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_GhostPainter o) =>
      o.hovered != hovered || o.wrong != wrong;
}

// ═════════════════════════════════════════════════════════════════
// PUZZLE GAME VIEW
// ═════════════════════════════════════════════════════════════════

class PuzzleGameView extends StatefulWidget {
  final PuzzleItem puzzle;
  final User user;
  const PuzzleGameView({required this.puzzle, required this.user, super.key});

  @override
  State<PuzzleGameView> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGameView>
    with TickerProviderStateMixin {
  // ── config ────────────────────────────────────────────────
  late final int _cols;
  late final int _total;
  final _rng = Random();

  // ── game state ────────────────────────────────────────────
  late List<_E> _edges;
  late List<int?> _board;
  late List<int> _tray;

  int? _hovSlot;
  int? _wrongSlot;
  int? _okSlot;
  Timer? _wrongT, _okT;

  bool _done = false;
  late DateTime _t0;

  late final AnimationController _winCtrl;

  // ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cols = widget.puzzle.cols;
    _total = widget.puzzle.pieceCount;
    _winCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _reset();
  }

  void _reset() {
    _edges = _makeEdges(_cols, Random(_cols * 99991));
    _board = List.filled(_total, null);
    _tray = List.generate(_total, (i) => i)..shuffle(_rng);
    _done = false;
    _hovSlot = _wrongSlot = _okSlot = null;
    _t0 = DateTime.now();
    _winCtrl.reset();
  }

  @override
  void dispose() {
    _wrongT?.cancel();
    _okT?.cancel();
    _winCtrl.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────

  int get _placed => _board.where((s) => s != null).length;

  void _drop(int piece, int slot) {
    if (_board[slot] != null) return;
    _wrongT?.cancel();
    _okT?.cancel();

    if (piece == slot) {
      HapticFeedback.lightImpact();
      setState(() {
        _board[slot] = piece;
        _tray.remove(piece);
        _hovSlot = null;
        _wrongSlot = null;
        _okSlot = slot;
      });
      _okT = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _okSlot = null);
      });

      if (_tray.isEmpty) {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() => _done = true);
            _winCtrl.forward();
          }
        });
      }
    } else {
      HapticFeedback.selectionClick();
      setState(() {
        _hovSlot = null;
        _wrongSlot = slot;
        _okSlot = null;
      });
      _wrongT = Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _wrongSlot = null);
      });
    }
  }

  void _exitOrPop() {
    if (_done || _placed == 0) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Leave Puzzle?',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        content: Text('Your progress will be lost.',
            style: GoogleFonts.nunito(fontSize: 15, color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Playing',
                  style: GoogleFonts.nunito(
                      color: secondaryPurple, fontWeight: FontWeight.w800))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Leave',
                  style: GoogleFonts.nunito(color: Colors.white38))),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final boardPx = (sw - 40).clamp(280.0, 500.0);
    final cell = boardPx / _cols;
    final nub = cell * 0.22;

    return Scaffold(
      backgroundColor: _canvasBg,
      body: Column(
        children: [
          // ── Gradient AppBar (matches home/story header style) ──
          _buildGradientAppBar(),
          Expanded(
            child: _done ? _winScreen() : _gameBody(cell, nub, boardPx),
          ),
        ],
      ),
    );
  }

  // ── Gradient AppBar ───────────────────────────────────────

  Widget _buildGradientAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [secondaryPurple, Color(0xFF6A35CF), Color(0xFF3D1A8E)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x55A55FEF),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 16),
          child: Row(
            children: [
              // Back button — glass pill
              GestureDetector(
                onTap: _exitOrPop,
                child: Container(
                  margin: const EdgeInsets.only(left: 8, right: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.puzzle.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$_placed / $_total pieces placed',
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              // Shuffle button
              if (_tray.length > 1)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _tray.shuffle(_rng));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shuffle_rounded,
                        color: Colors.white70, size: 20),
                  ),
                ),
              const SizedBox(width: 8),
              // Timer chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _Timer(start: _t0, running: !_done),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // GAME BODY
  // ─────────────────────────────────────────────────────────

  Widget _gameBody(double cell, double nub, double boardPx) {
    return Column(children: [
      const SizedBox(height: 10),

      // Progress bar — brand gradient
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _placed / _total,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(secondaryPurple, mainBlue, _placed / _total)!,
                ),
                minHeight: 7,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      // ── Board ─────────────────────────────────────────────
      Center(child: _buildBoard(cell, nub, boardPx)),

      const SizedBox(height: 10),

      // ── Divider label ─────────────────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(children: [
          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _tray.isEmpty
                  ? '🎉  All placed!'
                  : '${_tray.length} piece${_tray.length == 1 ? '' : 's'} left  —  drag to the board',
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
        ]),
      ),

      const SizedBox(height: 6),

      // ── Tray ──────────────────────────────────────────────
      Expanded(child: _buildTray(cell, nub)),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // BOARD  — N×N grid of drop targets
  // ─────────────────────────────────────────────────────────

  Widget _buildBoard(double cell, double nub, double boardPx) {
    return Container(
      width: boardPx,
      height: boardPx,
      decoration: BoxDecoration(
        color: _boardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: secondaryPurple.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: secondaryPurple.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(_total, (slot) {
            final r = slot ~/ _cols, c = slot % _cols;
            return Positioned(
                left: c * cell,
                top: r * cell,
                child: SizedBox(
                    width: cell,
                    height: cell,
                    child: _boardSlot(slot, cell, nub)));
          }),
        ),
      ),
    );
  }

  Widget _boardSlot(int slot, double cell, double nub) {
    final placed = _board[slot];

    if (placed != null) {
      return OverflowBox(
        maxWidth: cell + 2 * nub,
        maxHeight: cell + 2 * nub,
        alignment: Alignment.center,
        child: _PieceTile(
          imageUrl: widget.puzzle.imageUrl,
          pieceIndex: placed,
          cols: _cols,
          edge: _edges[placed],
          cell: cell,
          nub: nub,
          correct: _okSlot == slot,
        ),
      );
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (d) {
        setState(() => _hovSlot = slot);
        return true;
      },
      onLeave: (_) => setState(() => _hovSlot = null),
      onAcceptWithDetails: (d) => _drop(d.data, slot),
      builder: (_, __, ___) => OverflowBox(
        maxWidth: cell + 2 * nub,
        maxHeight: cell + 2 * nub,
        alignment: Alignment.center,
        child: _GhostSlot(
          edge: _edges[slot],
          cell: cell,
          nub: nub,
          hovered: _hovSlot == slot,
          wrong: _wrongSlot == slot,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TRAY  — horizontal scroll of draggable pieces
  // ─────────────────────────────────────────────────────────

  Widget _buildTray(double cell, double nub) {
    if (_tray.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              'All pieces placed!',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      );
    }

    final tc = (cell * .76).clamp(42.0, 95.0);
    final tn = tc * .22;
    final pxH = tc + 2 * tn;
    final vPad = max(6.0, (100.0 - pxH) / 2);

    return Container(
      decoration: BoxDecoration(
        color: _trayBg,
        border: Border(
          top: BorderSide(
            color: secondaryPurple.withValues(alpha: 0.12),
            width: 1.5,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(14, vPad, 14, vPad),
        itemCount: _tray.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _draggable(_tray[i], tc, tn),
        ),
      ),
    );
  }

  Widget _draggable(int pieceIndex, double cell, double nub) {
    final sz = cell + 2 * nub;
    final face = _PieceTile(
      imageUrl: widget.puzzle.imageUrl,
      pieceIndex: pieceIndex,
      cols: _cols,
      edge: _edges[pieceIndex],
      cell: cell,
      nub: nub,
    );

    return Draggable<int>(
      data: pieceIndex,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.12,
          child: Container(
            width: sz,
            height: sz,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: secondaryPurple.withValues(alpha: .65),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ]),
            child: face,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: .15, child: face),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          width: sz,
          height: sz,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .45),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]),
          child: face,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // WIN SCREEN — full brand redesign
  // ─────────────────────────────────────────────────────────

  Widget _winScreen() {
    final elapsed = DateTime.now().difference(_t0);
    final m = elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final sw = MediaQuery.of(context).size.width;
    final ps = (sw - 80).clamp(180.0, 300.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Celebration badge (arch-top, matches _ActivityCard) ──
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 750),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [sunnyYellow, accentOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(80),
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentOrange.withValues(alpha: 0.5),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 52)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Puzzle Complete!',
            style: GoogleFonts.fredoka(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"${widget.puzzle.title}"',
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: Colors.white60,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),

          // Stats badge — brand gold
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sunnyYellow.withValues(alpha: 0.15),
                  accentOrange.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: sunnyYellow.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Text(
              '⏱  $m:$s   •   🧩  $_total pcs   •   ${widget.puzzle.difficulty}',
              style: GoogleFonts.fredoka(
                fontSize: 15,
                color: sunnyYellow,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Completed image — brand glow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: secondaryPurple.withValues(alpha: 0.5),
                  blurRadius: 36,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                widget.puzzle.imageUrl,
                width: ps,
                height: ps,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: ps,
                  height: ps,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D1B69), Color(0xFF1A0D40)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text('🧩', style: TextStyle(fontSize: 72)),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons — gradient style (matches login _GradientButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GradientBtn(
                label: 'Play Again',
                icon: Icons.refresh_rounded,
                colors: const [accentOrange, Color(0xFFFF5F5F)],
                onTap: () => setState(_reset),
              ),
              const SizedBox(width: 14),
              _OutlineBtn(
                label: 'More Puzzles',
                icon: Icons.grid_view_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TIMER
// ─────────────────────────────────────────────────────────────────

class _Timer extends StatefulWidget {
  final DateTime start;
  final bool running;
  const _Timer({required this.start, required this.running});
  @override
  State<_Timer> createState() => _TimerState();
}

class _TimerState extends State<_Timer> {
  late Timer _t;
  Duration _e = Duration.zero;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.running && mounted) {
        setState(() => _e = DateTime.now().difference(widget.start));
      }
    });
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _e.inMinutes.toString().padLeft(2, '0');
    final s = (_e.inSeconds % 60).toString().padLeft(2, '0');
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.timer_outlined, color: Colors.white60, size: 14),
      const SizedBox(width: 4),
      Text('$m:$s',
          style: GoogleFonts.fredoka(fontSize: 15, color: Colors.white70)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────
// GRADIENT BUTTON (matches login _GradientButton)
// ─────────────────────────────────────────────────────────────────

class _GradientBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GradientBtn({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// OUTLINE BUTTON
// ─────────────────────────────────────────────────────────────────

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.fredoka(
                color: Colors.white70,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
