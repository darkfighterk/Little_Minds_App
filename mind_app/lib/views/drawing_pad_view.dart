// lib/views/drawing_pad_view.dart
//
// Dependencies already in pubspec.yaml:
//   path_provider: ^2.1.5
//
// Make sure main.dart has: WidgetsFlutterBinding.ensureInitialized(); before runApp()
//
// Usage: Navigator.push(context, MaterialPageRoute(builder: (_) => const DrawingPadView()));

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Stroke model
// ─────────────────────────────────────────────────────────────────────────────
class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  const _Stroke({required this.points, required this.color, required this.width});
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painter  (strokes + optional background image)
// ─────────────────────────────────────────────────────────────────────────────
class _DrawingPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? currentStroke;
  final ui.Image? backgroundImage;

  const _DrawingPainter({
    required this.strokes,
    this.currentStroke,
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background image (loaded drawing) first
    if (backgroundImage != null) {
      final src = Rect.fromLTWH(
        0, 0,
        backgroundImage!.width.toDouble(),
        backgroundImage!.height.toDouble(),
      );
      final dst = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(backgroundImage!, src, dst, Paint());
    }

    // Draw all strokes on top
    for (final stroke in [...strokes, if (currentStroke != null) currentStroke!]) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i - 1];
        final c = stroke.points[i];
        path.quadraticBezierTo(
            p.dx, p.dy, (p.dx + c.dx) / 2, (p.dy + c.dy) / 2);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved drawing model
// ─────────────────────────────────────────────────────────────────────────────
class SavedDrawing {
  final String path;
  final DateTime createdAt;
  SavedDrawing({required this.path, required this.createdAt});
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawing Pad View
// ─────────────────────────────────────────────────────────────────────────────
class DrawingPadView extends StatefulWidget {
  const DrawingPadView({super.key});

  @override
  State<DrawingPadView> createState() => _DrawingPadViewState();
}

class _DrawingPadViewState extends State<DrawingPadView>
    with TickerProviderStateMixin {
  // ── Drawing state ──────────────────────────────────────────────────────────
  final List<_Stroke> _strokes = [];
  final List<_Stroke> _redoStack = [];
  _Stroke? _currentStroke;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 6.0;
  bool _isEraser = false;
  String? _guideLetter;

  /// When the user taps "Draw on top" in gallery, the selected image is loaded
  /// here and rendered as a background layer on the canvas.
  ui.Image? _backgroundImage;
  String? _backgroundImagePath; // used to overwrite the same file on save

  // ── UI state ───────────────────────────────────────────────────────────────
  bool _showGallery = false;
  List<SavedDrawing> _savedDrawings = [];
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _bounceController;

  // ── Constants ──────────────────────────────────────────────────────────────
  static const List<Color> _palette = [
    Colors.black,
    Color(0xFFE53935),
    Color(0xFFFF7043),
    Color(0xFFFFB300),
    Color(0xFF43A047),
    Color(0xFF039BE5),
    Color(0xFF8E24AA),
    Color(0xFFEC407A),
    Colors.white,
    Color(0xFF795548),
  ];

  static const List<String> _letters = [
    'A','B','C','D','E','F','G','H','I','J',
    'K','L','M','N','O','P','Q','R','S','T',
    'U','V','W','X','Y','Z',
    '1','2','3','4','5','6','7','8','9','0',
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadSavedDrawings();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  // ── File helpers ───────────────────────────────────────────────────────────
  /// Returns the drawings directory, trying multiple path_provider methods
  /// in order so the app works on Android, iOS, and desktop.
  /// Falls back gracefully if a MissingPluginException is thrown.
  Future<Directory> _getDrawingsDir() async {
    // Build a prioritised list of candidate base directories.
    // getExternalStorageDirectory() is Android-specific and works without
    // extra permissions for app-private folders.
    final List<Future<Directory?> Function()> getters = [
      () async {
        try { return await getApplicationDocumentsDirectory(); }
        catch (_) { return null; }
      },
      () async {
        try { return await getExternalStorageDirectory(); }
        catch (_) { return null; }
      },
      () async {
        try { return await getApplicationSupportDirectory(); }
        catch (_) { return null; }
      },
      () async {
        try { return await getApplicationCacheDirectory(); }
        catch (_) { return null; }
      },
      () async {
        try { return await getTemporaryDirectory(); }
        catch (_) { return null; }
      },
    ];

    for (final getter in getters) {
      final candidate = await getter();
      if (candidate == null) continue;
      try {
        final dir = Directory('\${candidate.path}/little_mind_drawings');
        await dir.create(recursive: true);
        // Verify we can actually write to it
        final testFile = File('\${dir.path}/.write_test');
        await testFile.writeAsString('ok');
        await testFile.delete();
        return dir;
      } catch (_) {
        continue;
      }
    }

    throw Exception('No writable storage found on this device.');
  }

  Future<void> _loadSavedDrawings() async {
    try {
      final dir = await _getDrawingsDir();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList()
        ..sort((a, b) =>
            b.statSync().modified.compareTo(a.statSync().modified));
      if (!mounted) return;
      setState(() {
        _savedDrawings = files
            .map((f) =>
                SavedDrawing(path: f.path, createdAt: f.statSync().modified))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _saveDrawing() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await _getDrawingsDir();

      // If we're editing an existing drawing, overwrite it; otherwise create new
      final filePath = _backgroundImagePath ??
          '${dir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Clear background edit mode after saving
      setState(() {
        _backgroundImagePath = null;
        _backgroundImage = null;
      });

      await _loadSavedDrawings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Text('🎉 ', style: TextStyle(fontSize: 20)),
            Text('Drawing saved!',
                style:
                    GoogleFonts.fredoka(fontSize: 16, color: Colors.white)),
          ]),
          backgroundColor: const Color(0xFF43A047),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

  Future<void> _deleteDrawing(SavedDrawing drawing) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A0A3D),
        title: Text('Delete Drawing? 🗑️',
            style:
                GoogleFonts.fredoka(color: Colors.white, fontSize: 22)),
        content: Text(
            'Are you sure you want to delete this drawing? This cannot be undone.',
            style: GoogleFonts.nunito(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.fredoka(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.fredoka(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await File(drawing.path).delete();
      await _loadSavedDrawings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Text('🗑️ ', style: TextStyle(fontSize: 18)),
            Text('Drawing deleted.',
                style:
                    GoogleFonts.fredoka(fontSize: 15, color: Colors.white)),
          ]),
          backgroundColor: const Color(0xFFE53935),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  /// Open a full-screen viewer for a saved drawing with options:
  /// "Draw on top" and "Delete".
  void _openDrawingViewer(SavedDrawing drawing) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => _DrawingViewerDialog(
        drawing: drawing,
        onDrawOnTop: () async {
          Navigator.pop(ctx);
          await _loadDrawingAsBackground(drawing);
        },
        onDelete: () async {
          Navigator.pop(ctx);
          await _deleteDrawing(drawing);
        },
      ),
    );
  }

  /// Load a saved PNG as the canvas background so kids can draw on top of it.
  Future<void> _loadDrawingAsBackground(SavedDrawing drawing) async {
    try {
      final bytes = await File(drawing.path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      setState(() {
        _backgroundImage = frame.image;
        _backgroundImagePath = drawing.path;
        _strokes.clear();
        _redoStack.clear();
        _showGallery = false; // switch back to canvas view
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Text('✏️ ', style: TextStyle(fontSize: 18)),
            Text('Drawing loaded — add more to it!',
                style:
                    GoogleFonts.fredoka(fontSize: 15, color: Colors.white)),
          ]),
          backgroundColor: const Color(0xFF8E24AA),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not load drawing: $e')));
      }
    }
  }

  // ── Drawing input ──────────────────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) => setState(() {
        _redoStack.clear();
        _currentStroke = _Stroke(
          points: [d.localPosition],
          color: _isEraser ? Colors.white : _selectedColor,
          width: _isEraser ? 28.0 : _strokeWidth,
        );
      });

  void _onPanUpdate(DragUpdateDetails d) {
    if (_currentStroke == null) return;
    setState(() {
      _currentStroke = _Stroke(
        points: [..._currentStroke!.points, d.localPosition],
        color: _currentStroke!.color,
        width: _currentStroke!.width,
      );
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _redoStack.add(_strokes.removeLast()));
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() => _strokes.add(_redoStack.removeLast()));
  }

  void _clear() => setState(() {
        _strokes.clear();
        _redoStack.clear();
        _backgroundImage = null;
        _backgroundImagePath = null;
      });

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0533),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (!_showGallery) ...[
              _buildLetterPicker(),
              Expanded(child: _buildCanvas()),
              _buildToolbar(),
            ] else
              Expanded(child: _buildGallery()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF2D1B69), Color(0xFF1A0533)]),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Show banner when editing an existing drawing
          if (_backgroundImagePath != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8E24AA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Text('✏️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('Editing saved drawing',
                    style: GoogleFonts.fredoka(
                        fontSize: 13, color: Colors.white)),
              ]),
            ),
          ] else ...[
            Text(
              '🎨 Drawing Pad',
              style: GoogleFonts.fredoka(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
          const Spacer(),
          // Gallery toggle
          GestureDetector(
            onTap: () => setState(() => _showGallery = !_showGallery),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _showGallery
                    ? const Color(0xFFDA22FF)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFDA22FF).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Text('🖼️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('Gallery',
                      style: GoogleFonts.fredoka(
                          color: Colors.white, fontSize: 15)),
                  if (_savedDrawings.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('${_savedDrawings.length}',
                          style: GoogleFonts.fredoka(
                              fontSize: 12, color: Colors.black)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterPicker() {
    return Container(
      height: 56,
      color: const Color(0xFF1A0A3D),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _letters.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            final sel = _guideLetter == null;
            return GestureDetector(
              onTap: () => setState(() => _guideLetter = null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 6),
                width: 40,
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('✕',
                      style: GoogleFonts.fredoka(
                          fontSize: 16,
                          color: sel ? Colors.black : Colors.white54)),
                ),
              ),
            );
          }
          final letter = _letters[i - 1];
          final sel = _guideLetter == letter;
          return GestureDetector(
            onTap: () => setState(() => _guideLetter = letter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              width: 40,
              decoration: BoxDecoration(
                color: sel
                    ? const Color(0xFFDA22FF)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(letter,
                    style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: sel ? Colors.white : Colors.white70)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCanvas() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: RepaintBoundary(
        key: _canvasKey,
        child: Stack(
          children: [
            // White canvas surface
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDA22FF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            // Ghost letter guide (only when no background image)
            if (_guideLetter != null && _backgroundImage == null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Text(
                      _guideLetter!,
                      style: TextStyle(
                        fontSize: 220,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.withOpacity(0.13),
                      ),
                    ),
                  ),
                ),
              ),
            // Drawing surface (with optional background image via painter)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: _DrawingPainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      backgroundImage: _backgroundImage,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: const Color(0xFF1A0A3D),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color palette
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _palette.map((c) {
                final isSel = !_isEraser && _selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedColor = c;
                    _isEraser = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSel ? 36 : 30,
                    height: isSel ? 36 : 30,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSel
                            ? const Color(0xFFFFD700)
                            : Colors.white.withOpacity(0.3),
                        width: isSel ? 3 : 1.5,
                      ),
                      boxShadow: isSel
                          ? [BoxShadow(color: c.withOpacity(0.7), blurRadius: 8)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Brush + actions row
          Row(
            children: [
              const Text('✏️', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 2.0,
                  max: 24.0,
                  activeColor: const Color(0xFFDA22FF),
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _strokeWidth = v),
                ),
              ),
              _ToolButton(
                emoji: _isEraser ? '✏️' : '🧹',
                label: _isEraser ? 'Pen' : 'Erase',
                color: _isEraser
                    ? const Color(0xFFFFB300)
                    : Colors.white.withOpacity(0.12),
                onTap: () => setState(() => _isEraser = !_isEraser),
              ),
              const SizedBox(width: 6),
              _ToolButton(
                  emoji: '↩️',
                  label: 'Undo',
                  color: Colors.white.withOpacity(0.12),
                  onTap: _undo),
              const SizedBox(width: 6),
              _ToolButton(
                  emoji: '↪️',
                  label: 'Redo',
                  color: Colors.white.withOpacity(0.12),
                  onTap: _redo),
              const SizedBox(width: 6),
              _ToolButton(
                  emoji: '🗑️',
                  label: 'Clear',
                  color: const Color(0xFFE53935).withOpacity(0.7),
                  onTap: _clear),
              const SizedBox(width: 6),
              _ToolButton(
                  emoji: '💾',
                  label: 'Save',
                  color: const Color(0xFF43A047),
                  onTap: _saveDrawing),
            ],
          ),
        ],
      ),
    );
  }

  // ── Gallery ────────────────────────────────────────────────────────────────

  Widget _buildGallery() {
    if (_savedDrawings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceController,
              builder: (_, child) => Transform.translate(
                offset:
                    Offset(0, sin(_bounceController.value * pi) * 8),
                child: child,
              ),
              child: const Text('🖼️', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 16),
            Text('No drawings yet!',
                style: GoogleFonts.fredoka(
                    fontSize: 24, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Draw something and tap 💾 to save it here.',
                style: GoogleFonts.nunito(
                    fontSize: 14, color: Colors.white54)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Hint bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Text('👆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('Tap a drawing to view, continue, or delete it',
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: Colors.white54)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _savedDrawings.length,
              itemBuilder: (_, i) => _GalleryCard(
                drawing: _savedDrawings[i],
                onTap: () => _openDrawingViewer(_savedDrawings[i]),
                onDelete: () => _deleteDrawing(_savedDrawings[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen drawing viewer dialog
// ─────────────────────────────────────────────────────────────────────────────
class _DrawingViewerDialog extends StatelessWidget {
  final SavedDrawing drawing;
  final VoidCallback onDrawOnTop;
  final VoidCallback onDelete;

  const _DrawingViewerDialog({
    required this.drawing,
    required this.onDrawOnTop,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Image preview ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
            child: Image.file(
              File(drawing.path),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: const Color(0xFF2D1B69),
                child: const Center(
                    child: Text('🖼️', style: TextStyle(fontSize: 60))),
              ),
            ),
          ),

          // ── Action bar ──────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A0A3D),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Row(
              children: [
                // Close
                _DialogButton(
                  icon: Icons.close_rounded,
                  label: 'Close',
                  color: Colors.white.withOpacity(0.12),
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                // Draw on top
                _DialogButton(
                  icon: Icons.brush_rounded,
                  label: 'Draw on top',
                  color: const Color(0xFF8E24AA),
                  onTap: onDrawOnTop,
                ),
                const SizedBox(width: 10),
                // Delete
                _DialogButton(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  color: const Color(0xFFE53935),
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.fredoka(
                    fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tool button
// ─────────────────────────────────────────────────────────────────────────────
class _ToolButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(label,
                style:
                    GoogleFonts.fredoka(fontSize: 9, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gallery card  (tap = open viewer, delete button = quick delete)
// ─────────────────────────────────────────────────────────────────────────────
class _GalleryCard extends StatelessWidget {
  final SavedDrawing drawing;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GalleryCard({
    required this.drawing,
    required this.onTap,
    required this.onDelete,
  });

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D1B69),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: const Color(0xFFDA22FF).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFDA22FF).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: Image.file(
                      File(drawing.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                          child:
                              Text('🖼️', style: TextStyle(fontSize: 40))),
                    ),
                  ),
                  // Tap-to-view overlay hint
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom bar: timestamp + delete
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Text(_ago(drawing.createdAt),
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.white54)),
                  const Spacer(),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('🗑️',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}