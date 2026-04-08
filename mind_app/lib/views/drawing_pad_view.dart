import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color canvasBg = Color(0xFFF8FAFC);

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  const _Stroke(
      {required this.points, required this.color, required this.width});
}

class _DrawingPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? currentStroke;
  final ui.Image? backgroundImage;

  const _DrawingPainter(
      {required this.strokes, this.currentStroke, this.backgroundImage});

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      final src = Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(),
          backgroundImage!.height.toDouble());
      final dst = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(backgroundImage!, src, dst,
          Paint()..filterQuality = ui.FilterQuality.high);
    }

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in [
      ...strokes,
      if (currentStroke != null) currentStroke!
    ]) {
      if (stroke.points.isEmpty) continue;
      paint.color = stroke.color;
      paint.strokeWidth = stroke.width;

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

class SavedDrawing {
  final String path;
  final DateTime createdAt;
  SavedDrawing({required this.path, required this.createdAt});
}

class DrawingPadView extends StatefulWidget {
  const DrawingPadView({super.key});
  @override
  State<DrawingPadView> createState() => _DrawingPadViewState();
}

class _DrawingPadViewState extends State<DrawingPadView>
    with TickerProviderStateMixin {
  final List<_Stroke> _strokes = [];
  final List<_Stroke> _redoStack = [];
  _Stroke? _currentStroke;
  Color _selectedColor = mainBlue;
  double _strokeWidth = 6.0;
  bool _isEraser = false;
  String? _guideLetter;
  ui.Image? _backgroundImage;
  String? _backgroundImagePath;
  bool _showGallery = false;
  List<SavedDrawing> _savedDrawings = [];
  final GlobalKey _canvasKey = GlobalKey();

  static const List<Color> _palette = [
    Color(0xFF2D3142),
    Color(0xFF3AAFFF),
    Color(0xFFA55FEF),
    Color(0xFFFF8811),
    Color(0xFFFDDF50),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedDrawings();
  }

  Future<Directory> _getDrawingsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/little_mind_drawings');
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> _loadSavedDrawings() async {
    try {
      final dir = await _getDrawingsDir();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList()
        ..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      if (mounted)
        setState(() => _savedDrawings = files
            .map((f) =>
                SavedDrawing(path: f.path, createdAt: f.statSync().modified))
            .toList());
    } catch (_) {}
  }

  Future<void> _saveDrawing() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await _getDrawingsDir();
      final file = File(_backgroundImagePath ??
          '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Saved to Gallery! 🎨'),
            backgroundColor: Colors.green));
        _loadSavedDrawings();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(_showGallery ? 'My Art Gallery' : 'Drawing Pad',
            style: const TextStyle(
                fontFamily: 'Recoleta',
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: Icon(
                  _showGallery
                      ? Icons.brush_rounded
                      : Icons.collections_rounded,
                  color: mainBlue),
              onPressed: () => setState(() => _showGallery = !_showGallery)),
        ],
      ),
      body: _showGallery
          ? _buildGallery()
          : Column(children: [
              _buildLetterPicker(),
              Expanded(child: _buildCanvas()),
              _buildToolbar()
            ]),
    );
  }

  Widget _buildLetterPicker() {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 26,
        itemBuilder: (context, i) {
          final l = String.fromCharCode(65 + i);
          final sel = _guideLetter == l;
          return GestureDetector(
            onTap: () => setState(() => _guideLetter = sel ? null : l),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 45,
              decoration: BoxDecoration(
                  color: sel ? mainBlue : Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15)),
              child: Center(
                  child: Text(l,
                      style: TextStyle(
                          fontFamily: 'Recoleta',
                          color: sel ? Colors.white : mainBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: canvasBg,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: mainBlue.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5)
          ]),
      child: RepaintBoundary(
        key: _canvasKey,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(children: [
            if (_guideLetter != null && _backgroundImage == null)
              Center(
                  child: Opacity(
                      opacity: 0.05,
                      child: Text(_guideLetter!,
                          style: const TextStyle(
                              fontSize: 250, fontWeight: FontWeight.w900)))),
            GestureDetector(
              onPanStart: (d) => setState(() {
                _redoStack.clear();
                _currentStroke = _Stroke(
                    points: [d.localPosition],
                    color: _isEraser ? canvasBg : _selectedColor,
                    width: _isEraser ? 35 : _strokeWidth);
              }),
              onPanUpdate: (d) => setState(() {
                if (_currentStroke != null)
                  _currentStroke = _Stroke(
                      points: [..._currentStroke!.points, d.localPosition],
                      color: _currentStroke!.color,
                      width: _currentStroke!.width);
              }),
              onPanEnd: (_) => setState(() {
                if (_currentStroke != null) {
                  _strokes.add(_currentStroke!);
                  _currentStroke = null;
                }
              }),
              child: CustomPaint(
                  painter: _DrawingPainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      backgroundImage: _backgroundImage),
                  child: const SizedBox.expand()),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)
          ]),
      child: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: _palette
                  .map((c) => GestureDetector(
                        onTap: () => setState(() {
                          _selectedColor = c;
                          _isEraser = false;
                        }),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: _selectedColor == c && !_isEraser
                                      ? mainBlue
                                      : Colors.grey.shade200,
                                  width: 3)),
                        ),
                      ))
                  .toList()),
        ),
        const SizedBox(height: 25),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _actionIcon(
              Icons.undo_rounded,
              () => setState(() => _strokes.isNotEmpty
                  ? _redoStack.add(_strokes.removeLast())
                  : null)),
          _actionIcon(
              _isEraser ? Icons.edit_rounded : Icons.auto_fix_high_rounded,
              () => setState(() => _isEraser = !_isEraser),
              active: _isEraser),
          _actionIcon(Icons.delete_sweep_rounded,
              () => setState(() => _strokes.clear())),
          ElevatedButton.icon(
            onPressed: _saveDrawing,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text("Save Hub"),
            style: ElevatedButton.styleFrom(
                backgroundColor: mainBlue,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
          ),
        ]),
      ]),
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap, {bool active = false}) {
    return IconButton(
        onPressed: onTap,
        icon: Icon(icon,
            color: active ? secondaryPurple : Colors.blueGrey.shade300,
            size: 30));
  }

  Widget _buildGallery() {
    if (_savedDrawings.isEmpty)
      return Center(
          child: Text("Your gallery is empty! 🎨",
              style: GoogleFonts.nunito(color: Colors.grey, fontSize: 18)));
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
      itemCount: _savedDrawings.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () async {
          final bytes = await File(_savedDrawings[i].path).readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          setState(() {
            _backgroundImage = frame.image;
            _backgroundImagePath = _savedDrawings[i].path;
            _showGallery = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: mainBlue.withOpacity(0.1))),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child:
                  Image.file(File(_savedDrawings[i].path), fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
