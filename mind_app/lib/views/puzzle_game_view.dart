// lib/views/puzzle_game_view.dart
//
// Real jigsaw puzzle game — every piece is bezier-shaped with interlocking
// tabs (knobs) and blanks (holes), just like a physical jigsaw puzzle.
// The admin-uploaded image is sliced into N×N pieces automatically.

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle_model.dart';
import '../models/user_model.dart';

// =====================================================================
//  EDGE MODEL
// =====================================================================
//   1  = tab   (knob protrudes outward)
//  -1  = blank (hole indented inward)
//   0  = flat  (border edge — no tab)

class _Edges {
  final int top, right, bottom, left;
  const _Edges(
      {required this.top,
      required this.right,
      required this.bottom,
      required this.left});
}

/// Generates consistent edges for every piece so that adjacent pieces
/// always have complementary shapes (tab ↔ blank).
List<_Edges> _generateEdges(int cols, Random rng) {
  final rows = cols;
  // hJoints[r][c] = bottom-of-(r,c) / top-of-(r+1,c) uses negated value
  final hJoints = List.generate(
      rows - 1, (_) => List.generate(cols, (_) => rng.nextBool() ? 1 : -1));
  // vJoints[r][c] = right-of-(r,c) / left-of-(r,c+1) uses negated value
  final vJoints = List.generate(
      rows, (_) => List.generate(cols - 1, (_) => rng.nextBool() ? 1 : -1));

  return List.generate(rows * cols, (i) {
    final r = i ~/ cols;
    final c = i % cols;
    return _Edges(
      top: r == 0 ? 0 : -hJoints[r - 1][c],
      bottom: r == rows - 1 ? 0 : hJoints[r][c],
      left: c == 0 ? 0 : -vJoints[r][c - 1],
      right: c == cols - 1 ? 0 : vJoints[r][c],
    );
  });
}

// =====================================================================
//  JIGSAW PATH BUILDER
// =====================================================================
//  The piece body fills [ox .. ox+w] × [oy .. oy+h].
//  Tabs can protrude by [nub] beyond this rect, so the canvas widget
//  must be (w + 2*nub) × (h + 2*nub) with ox = oy = nub.

Path _buildPiecePath(
    double w, double h, _Edges e, double nub, double ox, double oy) {
  final path = Path()..moveTo(ox, oy);

  // Top   left→right    tab UP      = negative-y direction
  _hEdge(path, ox, ox + w, oy, e.top * (-nub));
  // Right top→bottom    tab RIGHT   = positive-x direction
  _vEdge(path, ox + w, oy, oy + h, e.right * nub);
  // Bottom right→left   tab DOWN    = positive-y direction
  _hEdge(path, ox + w, ox, oy + h, e.bottom * nub);
  // Left  bottom→top    tab LEFT    = negative-x direction
  _vEdge(path, ox, oy + h, oy, e.left * (-nub));

  return path..close();
}

/// Horizontal edge from (x0,y)→(x1,y).
/// nub>0 → tab in +y; nub<0 → tab in -y; 0 → straight line.
void _hEdge(Path p, double x0, double x1, double y, double nub) {
  if (nub == 0) { p.lineTo(x1, y); return; }
  final s = x1 > x0 ? 1.0 : -1.0;
  final w = (x1 - x0).abs();
  final mx = x0 + s * w * 0.5;

  p.lineTo(x0 + s * w * 0.28, y);
  p.cubicTo(x0 + s * w * 0.28, y + nub * 0.6,
            mx - s * w * 0.12, y + nub, mx, y + nub);
  p.cubicTo(mx + s * w * 0.12, y + nub,
            x0 + s * w * 0.72, y + nub * 0.6,
            x0 + s * w * 0.72, y);
  p.lineTo(x1, y);
}

/// Vertical edge from (x,y0)→(x,y1).
/// nub>0 → tab in +x; nub<0 → tab in -x; 0 → straight line.
void _vEdge(Path p, double x, double y0, double y1, double nub) {
  if (nub == 0) { p.lineTo(x, y1); return; }
  final s = y1 > y0 ? 1.0 : -1.0;
  final h = (y1 - y0).abs();
  final my = y0 + s * h * 0.5;

  p.lineTo(x, y0 + s * h * 0.28);
  p.cubicTo(x + nub * 0.6, y0 + s * h * 0.28,
            x + nub, my - s * h * 0.12, x + nub, my);
  p.cubicTo(x + nub, my + s * h * 0.12,
            x + nub * 0.6, y0 + s * h * 0.72,
            x, y0 + s * h * 0.72);
  p.lineTo(x, y1);
}

// =====================================================================
//  PIECE PAINTER  (CustomPainter)
// =====================================================================

class _PiecePainter extends CustomPainter {
  final ui.Image? image;
  final int pieceIndex;
  final int cols;
  final _Edges edges;
  final double cellSize;
  final double nub;
  final bool isGhost;
  final bool isHovered;
  final bool isWrong;
  final bool isCorrect;

  const _PiecePainter({
    required this.image,
    required this.pieceIndex,
    required this.cols,
    required this.edges,
    required this.cellSize,
    required this.nub,
    this.isGhost = false,
    this.isHovered = false,
    this.isWrong = false,
    this.isCorrect = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        _buildPiecePath(cellSize, cellSize, edges, nub, nub, nub);

    if (isGhost) {
      _paintGhost(canvas, path);
      return;
    }

    if (image == null) return;
    _paintPiece(canvas, path);
  }

  void _paintGhost(Canvas canvas, Path path) {
    final fillColor = isWrong
        ? Colors.red.withOpacity(0.18)
        : isHovered
            ? const Color(0xFFFF7043).withOpacity(0.16)
            : Colors.white.withOpacity(0.04);

    final strokeColor = isWrong
        ? Colors.red.withOpacity(0.7)
        : isHovered
            ? const Color(0xFFFF7043).withOpacity(0.8)
            : Colors.white.withOpacity(0.13);

    canvas.drawPath(path,
        Paint()..color = fillColor..style = PaintingStyle.fill);

    // Icon hint
    final cx = nub + cellSize / 2;
    final cy = nub + cellSize / 2;
    final ir = cellSize * 0.11;
    final iconPaint = Paint()
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (isWrong) {
      iconPaint.color = Colors.red.withOpacity(0.7);
      canvas.drawLine(
          Offset(cx - ir, cy - ir), Offset(cx + ir, cy + ir), iconPaint);
      canvas.drawLine(
          Offset(cx + ir, cy - ir), Offset(cx - ir, cy + ir), iconPaint);
    } else if (isHovered) {
      iconPaint.color = const Color(0xFFFF7043).withOpacity(0.8);
      canvas.drawLine(Offset(cx - ir, cy), Offset(cx + ir, cy), iconPaint);
      canvas.drawLine(Offset(cx, cy - ir), Offset(cx, cy + ir), iconPaint);
    }

    canvas.drawPath(
        path,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeJoin = StrokeJoin.round);
  }

  void _paintPiece(Canvas canvas, Path path) {
    final row = pieceIndex ~/ cols;
    final col = pieceIndex % cols;

    final srcW = image!.width / cols;
    final srcH = image!.height / cols;
    final src = Rect.fromLTWH(col * srcW, row * srcH, srcW, srcH);
    final dst = Rect.fromLTWH(nub, nub, cellSize, cellSize);

    canvas.save();
    canvas.clipPath(path);

    // Draw image crop
    canvas.drawImageRect(
        image!, src, dst, Paint()..filterQuality = FilterQuality.medium);

    // Subtle vignette on piece face
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(nub + cellSize / 2, nub + cellSize / 2),
          cellSize * 0.72,
          [Colors.transparent, Colors.black.withOpacity(0.07)],
        )
        ..style = PaintingStyle.fill,
    );

    canvas.restore();

    // Piece outline
    canvas.drawPath(
      path,
      Paint()
        ..color = isCorrect
            ? const Color(0xFF4CAF50).withOpacity(0.95)
            : Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCorrect ? 2.2 : 1.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PiecePainter o) =>
      o.image != image ||
      o.isGhost != isGhost ||
      o.isHovered != isHovered ||
      o.isWrong != isWrong ||
      o.isCorrect != isCorrect;
}

// =====================================================================
//  IMAGE LOADER  (network → ui.Image)
// =====================================================================

Future<ui.Image?> _loadUiImage(String url) async {
  try {
    final c = Completer<ui.Image>();
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!c.isCompleted) c.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (e, st) {
        if (!c.isCompleted) c.completeError(e, st);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return await c.future;
  } catch (e) {
    debugPrint('_loadUiImage error: $e');
    return null;
  }
}

// =====================================================================
//  PUZZLE GAME VIEW
// =====================================================================

class PuzzleGameView extends StatefulWidget {
  final PuzzleItem puzzle;
  final User user;
  const PuzzleGameView(
      {required this.puzzle, required this.user, super.key});

  @override
  State<PuzzleGameView> createState() => _PuzzleGameViewState();
}

class _PuzzleGameViewState extends State<PuzzleGameView>
    with TickerProviderStateMixin {
  // ── Config ────────────────────────────────────────────────
  late final int _cols;
  late final int _pieceCount;
  final _rng = Random();

  // ── Image ─────────────────────────────────────────────────
  ui.Image? _image;
  bool _loadingImage = true;
  String? _imageError;

  // ── Game state ────────────────────────────────────────────
  late List<_Edges> _edges;
  late List<int?> _boardSlots; // boardSlots[slot] = pieceIndex | null
  late List<int> _trayPieces; // remaining piece indices

  int? _hoveredSlot;
  int? _wrongSlot;
  int? _correctSlot;
  Timer? _wrongTimer;
  Timer? _correctTimer;

  bool _completed = false;
  late DateTime _startTime;

  // ── Animations ────────────────────────────────────────────
  late final AnimationController _completionCtrl;

  // ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cols = widget.puzzle.cols;
    _pieceCount = widget.puzzle.pieceCount;

    _completionCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));

    _initGame();
    _loadImage();
  }

  void _initGame() {
    _edges = _generateEdges(_cols, _rng);
    _boardSlots = List.filled(_pieceCount, null);
    _trayPieces = List.generate(_pieceCount, (i) => i)..shuffle(_rng);
    _completed = false;
    _hoveredSlot = _wrongSlot = _correctSlot = null;
    _startTime = DateTime.now();
    _completionCtrl.reset();
  }

  Future<void> _loadImage() async {
    setState(() { _loadingImage = true; _imageError = null; });
    final img = await _loadUiImage(widget.puzzle.imageUrl);
    if (!mounted) return;
    setState(() {
      _image = img;
      _loadingImage = false;
      if (img == null) _imageError = 'Could not load puzzle image.';
    });
  }

  @override
  void dispose() {
    _wrongTimer?.cancel();
    _correctTimer?.cancel();
    _completionCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────

  int get _placedCount => _boardSlots.where((s) => s != null).length;

  void _onPieceDropped(int pieceIndex, int slotIndex) {
    if (_boardSlots[slotIndex] != null) return;
    _wrongTimer?.cancel();
    _correctTimer?.cancel();

    if (pieceIndex == slotIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        _boardSlots[slotIndex] = pieceIndex;
        _trayPieces.remove(pieceIndex);
        _hoveredSlot = null;
        _correctSlot = slotIndex;
        _wrongSlot = null;
      });
      _correctTimer = Timer(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _correctSlot = null);
      });
      if (_trayPieces.isEmpty) {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) { setState(() => _completed = true); _completionCtrl.forward(); }
        });
      }
    } else {
      HapticFeedback.selectionClick();
      setState(() { _hoveredSlot = null; _wrongSlot = slotIndex; _correctSlot = null; });
      _wrongTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _wrongSlot = null);
      });
    }
  }

  void _shuffleTray() {
    HapticFeedback.selectionClick();
    setState(() => _trayPieces.shuffle(_rng));
  }

  void _restartGame() {
    _wrongTimer?.cancel();
    _correctTimer?.cancel();
    setState(() => _initGame());
  }

  void _showExitDialog() {
    if (_completed || _placedCount == 0) { Navigator.pop(context); return; }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Leave Puzzle?',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        content: Text('Your progress will be lost.',
            style: GoogleFonts.nunito(fontSize: 15, color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Playing',
                  style: GoogleFonts.nunito(
                      color: const Color(0xFFFF7043),
                      fontWeight: FontWeight.w700))),
          TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: Text('Leave',
                  style: GoogleFonts.nunito(color: Colors.white38))),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final boardPx = (screenW - 32.0).clamp(200.0, 480.0);
    final cellSize = boardPx / _cols;
    final nub = cellSize * 0.26;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0520),
      appBar: _buildAppBar(),
      body: _loadingImage
          ? _buildLoading()
          : _imageError != null
              ? _buildError()
              : _completed
                  ? _buildCompletionScreen()
                  : _buildGameBody(cellSize, nub, boardPx),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: const Color(0xFF1E1040),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _showExitDialog),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.puzzle.title,
              style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white),
              overflow: TextOverflow.ellipsis),
          Text('$_placedCount / $_pieceCount pieces',
              style: GoogleFonts.nunito(fontSize: 11, color: Colors.white54)),
        ]),
        actions: [
          if (_trayPieces.length > 1)
            IconButton(
                onPressed: _shuffleTray,
                icon: const Icon(Icons.shuffle_rounded, color: Colors.white54),
                tooltip: 'Shuffle tray'),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _TimerWidget(startTime: _startTime, running: !_completed),
          ),
        ],
      );

  Widget _buildLoading() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(
              color: Color(0xFFFF7043), strokeWidth: 3),
          const SizedBox(height: 20),
          Text('Loading puzzle…',
              style: GoogleFonts.fredoka(
                  fontSize: 18, color: Colors.white54)),
        ]),
      );

  Widget _buildError() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('😢', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          Text(_imageError!,
              style: GoogleFonts.nunito(
                  fontSize: 15, color: Colors.white54),
              textAlign: TextAlign.center),
          const SizedBox(height: 22),
          ElevatedButton.icon(
              onPressed: _loadImage,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Retry',
                  style: GoogleFonts.fredoka(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)))),
        ]),
      );

  // ── Game body ──────────────────────────────────────────────

  Widget _buildGameBody(
      double cellSize, double nub, double boardPx) {
    return Column(children: [
      // Progress bar
      LinearProgressIndicator(
        value: _placedCount / _pieceCount,
        backgroundColor: Colors.white12,
        valueColor:
            const AlwaysStoppedAnimation(Color(0xFFFF7043)),
        minHeight: 4,
      ),
      const SizedBox(height: 14),

      // Board
      Center(child: _buildBoard(cellSize, nub, boardPx)),

      const SizedBox(height: 8),

      // Tray label
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          const Expanded(child: Divider(color: Colors.white12)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _trayPieces.isEmpty
                  ? '🎉  All placed!'
                  : '${_trayPieces.length} left — drag onto the board',
              style: GoogleFonts.nunito(
                  fontSize: 11, color: Colors.white38),
            ),
          ),
          const Expanded(child: Divider(color: Colors.white12)),
        ]),
      ),
      const SizedBox(height: 6),

      // Tray
      Expanded(child: _buildTray(cellSize, nub)),
    ]);
  }

  // ── Board ──────────────────────────────────────────────────

  Widget _buildBoard(
      double cellSize, double nub, double boardPx) {
    return Container(
      width: boardPx,
      height: boardPx,
      decoration: BoxDecoration(
        color: const Color(0xFF160830),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 26,
              offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(_pieceCount, (slot) {
            final row = slot ~/ _cols;
            final col = slot % _cols;
            return Positioned(
              left: col * cellSize,
              top: row * cellSize,
              child: SizedBox(
                width: cellSize,
                height: cellSize,
                child: _buildSlot(slot, cellSize, nub),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSlot(int slot, double cellSize, double nub) {
    final placed = _boardSlots[slot];

    // Filled slot — just show the piece (no drag target needed)
    if (placed != null) {
      return OverflowBox(
        maxWidth: cellSize + 2 * nub,
        maxHeight: cellSize + 2 * nub,
        alignment: Alignment.center,
        child: _pieceCanvas(
            pieceIndex: placed,
            cellSize: cellSize,
            nub: nub,
            isCorrect: _correctSlot == slot),
      );
    }

    // Empty slot — drag target
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) {
        setState(() => _hoveredSlot = slot);
        return true;
      },
      onLeave: (_) => setState(() => _hoveredSlot = null),
      onAcceptWithDetails: (d) => _onPieceDropped(d.data, slot),
      builder: (_, __, ___) => OverflowBox(
        maxWidth: cellSize + 2 * nub,
        maxHeight: cellSize + 2 * nub,
        alignment: Alignment.center,
        child: _ghostCanvas(slot: slot, cellSize: cellSize, nub: nub),
      ),
    );
  }

  // ── Tray ───────────────────────────────────────────────────

  Widget _buildTray(double cellSize, double nub) {
    if (_trayPieces.isEmpty) {
      return const Center(
          child: Text('🎉', style: TextStyle(fontSize: 52)));
    }

    final trayCell =
        (cellSize * 0.80).clamp(44.0, 95.0);
    final trayNub = trayCell * 0.26;
    final pieceW = trayCell + 2 * trayNub;
    final vPad = max(4.0, (90.0 - pieceW) / 2);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(14, vPad, 14, vPad),
      itemCount: _trayPieces.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: _draggablePiece(_trayPieces[i], trayCell, trayNub),
      ),
    );
  }

  // ── Widget factories ───────────────────────────────────────

  Widget _pieceCanvas({
    required int pieceIndex,
    required double cellSize,
    required double nub,
    bool isCorrect = false,
  }) {
    final s = cellSize + 2 * nub;
    return CustomPaint(
      size: Size(s, s),
      painter: _PiecePainter(
        image: _image,
        pieceIndex: pieceIndex,
        cols: _cols,
        edges: _edges[pieceIndex],
        cellSize: cellSize,
        nub: nub,
        isCorrect: isCorrect,
      ),
    );
  }

  Widget _ghostCanvas({
    required int slot,
    required double cellSize,
    required double nub,
  }) {
    final s = cellSize + 2 * nub;
    return CustomPaint(
      size: Size(s, s),
      painter: _PiecePainter(
        image: null,
        pieceIndex: slot,
        cols: _cols,
        edges: _edges[slot],
        cellSize: cellSize,
        nub: nub,
        isGhost: true,
        isHovered: _hoveredSlot == slot,
        isWrong: _wrongSlot == slot,
      ),
    );
  }

  Widget _draggablePiece(int pieceIndex, double cellSize, double nub) {
    final s = cellSize + 2 * nub;
    final piece =
        _pieceCanvas(pieceIndex: pieceIndex, cellSize: cellSize, nub: nub);

    return Draggable<int>(
      data: pieceIndex,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.12,
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: const Color(0xFFFF7043).withOpacity(0.6),
                  blurRadius: 24,
                  spreadRadius: 4),
            ]),
            child: piece,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.18, child: piece),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.38),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ]),
          child: piece,
        ),
      ),
    );
  }

  // ── Completion screen ──────────────────────────────────────

  Widget _buildCompletionScreen() {
    final elapsed = DateTime.now().difference(_startTime);
    final min = elapsed.inMinutes.toString().padLeft(2, '0');
    final sec = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final screenW = MediaQuery.of(context).size.width;
    final previewSz = (screenW - 80).clamp(160.0, 280.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: child),
              child:
                  const Text('🎉', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 14),
            Text('Puzzle Complete!',
                style: GoogleFonts.fredoka(
                    fontSize: 34, color: Colors.white)),
            const SizedBox(height: 6),
            Text('"${widget.puzzle.title}"',
                style: GoogleFonts.nunito(
                    fontSize: 15, color: Colors.white60),
                textAlign: TextAlign.center),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.4)),
              ),
              child: Text(
                '⏱  $min:$sec   •   🧩  ${widget.puzzle.pieceCount} pcs   •   ${widget.puzzle.difficulty}',
                style: GoogleFonts.fredoka(
                    fontSize: 15,
                    color: const Color(0xFFFFD700)),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFFF7043).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 2)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  widget.puzzle.imageUrl,
                  width: previewSz,
                  height: previewSz,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: previewSz,
                    height: previewSz,
                    color: const Color(0xFF2D1B69),
                    child: const Center(
                        child: Text('🧩',
                            style: TextStyle(fontSize: 72))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ActionBtn(
                  label: 'Play Again',
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFFFF7043),
                  onTap: _restartGame),
              const SizedBox(width: 14),
              _ActionBtn(
                  label: 'More Puzzles',
                  icon: Icons.list_rounded,
                  color: const Color(0xFF1E1040),
                  borderColor: Colors.white24,
                  onTap: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 20),
          ]),
    );
  }
}

// =====================================================================
//  TIMER WIDGET
// =====================================================================

class _TimerWidget extends StatefulWidget {
  final DateTime startTime;
  final bool running;
  const _TimerWidget({required this.startTime, required this.running});

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {
  late Timer _t;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.running && mounted) {
        setState(
            () => _elapsed = DateTime.now().difference(widget.startTime));
      }
    });
  }

  @override
  void dispose() { _t.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.timer_outlined, color: Colors.white38, size: 14),
      const SizedBox(width: 3),
      Text('$m:$s',
          style: GoogleFonts.fredoka(
              fontSize: 15, color: Colors.white54)),
    ]);
  }
}

// =====================================================================
//  ACTION BUTTON
// =====================================================================

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap,
      this.borderColor});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.fredoka(fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
          elevation: 4,
        ),
      );
}