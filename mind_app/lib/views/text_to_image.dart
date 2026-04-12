import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Shared brand palette ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class TextFromImagePage extends StatefulWidget {
  const TextFromImagePage({super.key});
  @override
  State<TextFromImagePage> createState() => _TextFromImagePageState();
}

class _TextFromImagePageState extends State<TextFromImagePage>
    with TickerProviderStateMixin {
  Uint8List? imageBytes;
  String extractedText = '';
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();

  late AnimationController _entryController;
  late AnimationController _floatController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entrySlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // ── Logic untouched ──
  Future<void> pickImage(ImageSource source) async {
    final XFile? xFile = await picker.pickImage(source: source);
    if (xFile == null) return;

    setState(() {
      isLoading = true;
      extractedText = '';
      imageBytes = null;
    });

    final bytes = await xFile.readAsBytes();
    setState(() => imageBytes = bytes);

    String text = '';
    if (!kIsWeb) {
      try {
        final inputImage = InputImage.fromFilePath(xFile.path);
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        final recognizedText = await textRecognizer.processImage(inputImage);
        text = recognizedText.text;
        await textRecognizer.close();
      } catch (e) {
        text = "Detection Error: $e";
      }
    } else {
      text = "OCR is best on Mobile! 🚀";
    }

    if (mounted) {
      setState(() {
        extractedText = text;
        isLoading = false;
      });
    }
  }

  Future<void> saveAndSharePDF() async {
    if (extractedText.isEmpty) return;
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Text(extractedText))));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/discovery.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: "Magic Discovery! ✨");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // ── Ambient background blobs ──
          _AmbientBlobs(isDark: isDark, floatController: _floatController),

          // ── Gradient header ──
          _GradientHeader(isDark: isDark, floatController: _floatController),

          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top bar ──
                    _buildTopBar(isDark),

                    // ── Hero subtitle ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                      child: Text(
                        'Point, snap, and let the magic read it for you ✨',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Scrollable body card ──
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: scaffoldBg,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.3 : 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(22, 28, 22, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionLabel(
                                        label: 'Preview', isDark: isDark),
                                    const SizedBox(height: 12),
                                    _buildPreview(isDark),
                                    const SizedBox(height: 24),
                                    if (isLoading)
                                      _buildLoadingState(isDark)
                                    else ...[
                                      _SectionLabel(
                                          label: 'Extracted Text',
                                          isDark: isDark),
                                      const SizedBox(height: 12),
                                      _buildTextDisplay(isDark),
                                    ],
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),

                            // ── Action panel ──
                            _buildActionPanel(isDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar with back button + title ──
  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Note Scanner',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Image preview card ──
  Widget _buildPreview(bool isDark) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? accentOrange.withValues(alpha: 0.18)
              : accentOrange.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentOrange.withValues(alpha: isDark ? 0.10 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: imageBytes != null
            ? Image.memory(imageBytes!, fit: BoxFit.contain)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [accentOrange, Color(0xFFFF5F5F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentOrange.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.document_scanner_rounded,
                        size: 38, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No image yet',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use the buttons below to scan or pick',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Loading state ──
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: accentOrange, strokeWidth: 3),
          const SizedBox(height: 14),
          Text(
            'Reading your notes… 🔍',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  // ── Extracted text display ──
  Widget _buildTextDisplay(bool isDark) {
    if (extractedText.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : mainBlue.withValues(alpha: 0.10),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Text('✨', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(
              'Scan your study notes to see magic!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? mainBlue.withValues(alpha: 0.18)
              : mainBlue.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: mainBlue.withValues(alpha: isDark ? 0.08 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── word count badge ──
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [mainBlue, secondaryPurple]),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${extractedText.trim().split(RegExp(r'\s+')).length} words',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SelectableText(
            extractedText,
            style: GoogleFonts.nunito(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action panel ──
  Widget _buildActionPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
      decoration: BoxDecoration(
        color: scaffoldBgColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Primary scan buttons row
          Row(
            children: [
              Expanded(
                child: _gradientBtn(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  gradient: const [accentOrange, Color(0xFFFF5F5F)],
                  onTap: () => pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _gradientBtn(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  gradient: const [secondaryPurple, mainBlue],
                  onTap: () => pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),

          // Secondary actions (only when image is present)
          if (imageBytes != null && extractedText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _outlineBtn(
                    icon: Icons.copy_rounded,
                    label: 'Copy Text',
                    color: mainBlue,
                    isDark: isDark,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: extractedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Magic words copied! 🪄")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _outlineBtn(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Share PDF',
                    color: accentOrange,
                    isDark: isDark,
                    onTap: saveAndSharePDF,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color scaffoldBgColor(bool isDark) =>
      isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

  // ── Gradient primary button ──
  Widget _gradientBtn({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.40),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Outline secondary button ──
  Widget _outlineBtn({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? color.withValues(alpha: 0.30)
                : color.withValues(alpha: 0.45),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.08 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Gradient Header ───────────────

class _GradientHeader extends StatelessWidget {
  final bool isDark;
  final AnimationController floatController;
  const _GradientHeader({required this.isDark, required this.floatController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1030), const Color(0xFF0D1B40)]
              : [accentOrange, const Color(0xFFFF5F5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative top-right circle
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.12),
              ),
            ),
          ),
          // Small orange dot
          Positioned(
            bottom: 60,
            right: 60,
            child: AnimatedBuilder(
              animation: floatController,
              builder: (_, __) => Transform.translate(
                offset: Offset(sin(floatController.value * pi) * 4, 0),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Ambient Blobs ───────────────

class _AmbientBlobs extends StatelessWidget {
  final bool isDark;
  final AnimationController floatController;
  const _AmbientBlobs({required this.isDark, required this.floatController});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned(
          bottom: h * 0.08,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? secondaryPurple.withValues(alpha: 0.05)
                  : secondaryPurple.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          top: h * 0.55,
          left: -50,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? mainBlue.withValues(alpha: 0.04)
                  : mainBlue.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: h * 0.72,
          right: w * 0.15,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? sunnyYellow.withValues(alpha: 0.15)
                  : sunnyYellow.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────── Section Label ───────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
        color: isDark ? Colors.white38 : Colors.black.withValues(alpha: 0.35),
      ),
    );
  }
}
