import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';

// ── Brand palette (matches home) ──
const Color _mainBlue = Color(0xFF3AAFFF);
const Color _secondaryPurple = Color(0xFFA55FEF);
const Color _accentOrange = Color(0xFFFF8811);
const Color _sunnyYellow = Color(0xFFFDDF50);
const Color _teal = Color(0xFF26A69A);

// ── Prompt categories for kids ──
class _Category {
  final String emoji;
  final String label;
  final String prompt;
  final Color color;
  const _Category({
    required this.emoji,
    required this.label,
    required this.prompt,
    required this.color,
  });
}

const List<_Category> _categories = [
  _Category(
    emoji: '🦁',
    label: 'Animals',
    prompt:
        'cute cartoon animal in a magical forest, children illustration, bright colors, friendly',
    color: _accentOrange,
  ),
  _Category(
    emoji: '🚀',
    label: 'Space',
    prompt:
        'cute cartoon rocket ship in colorful space with stars and planets, children illustration, bright colors',
    color: _secondaryPurple,
  ),
  _Category(
    emoji: '🦕',
    label: 'Dinos',
    prompt:
        'cute friendly cartoon dinosaur in a jungle, children book illustration, bright cheerful colors',
    color: _teal,
  ),
  _Category(
    emoji: '🧚',
    label: 'Fairy Tale',
    prompt:
        'magical fairy tale castle with rainbow and unicorn, children illustration, pastel colors, dreamy',
    color: _mainBlue,
  ),
  _Category(
    emoji: '🌊',
    label: 'Ocean',
    prompt:
        'cute cartoon underwater scene with colorful fish and coral reef, children illustration, bright colors',
    color: Color(0xFF0288D1),
  ),
  _Category(
    emoji: '🦸',
    label: 'Heroes',
    prompt:
        'cute cartoon superhero child flying through the sky, children illustration, bright bold colors',
    color: Color(0xFFEF5350),
  ),
  _Category(
    emoji: '🍭',
    label: 'Candy Land',
    prompt:
        'magical candy land with lollipops gingerbread houses rainbow, children illustration, sweet pastel colors',
    color: Color(0xFFEC407A),
  ),
  _Category(
    emoji: '🌈',
    label: 'Rainbow',
    prompt:
        'colorful rainbow landscape with happy clouds and sunshine, children illustration, vivid bright colors',
    color: _sunnyYellow,
  ),
];

class MagicCanvasView extends StatefulWidget {
  final VoidCallback? onBack;
  const MagicCanvasView({super.key, this.onBack});

  @override
  State<MagicCanvasView> createState() => _MagicCanvasViewState();
}

class _MagicCanvasViewState extends State<MagicCanvasView>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  _Category? _selectedCategory;
  String? _currentImageUrl;
  bool _isGenerating = false;
  int _seed = 0;

  final TextEditingController _promptController = TextEditingController();
  final List<String> _history = [];

  // ── Magic Tips (UX feedback) ──
  int _currentTipIndex = 0;
  Timer? _tipTimer;
  final List<String> _magicTips = [
    'Summoning some magic dust... ✨',
    'Mindie is finding her favorite brush... 🖌️',
    'Mixing colors from the rainbow... 🌈',
    'Asking the stars for inspiration... ⭐',
    'Waking up the creative dragons... 🐉',
    'Almost ready, just a tiny bit more magic... 🪄',
    'Sprinkling glitter on your canvas... ✨',
  ];

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
    _floatController.dispose();
    _entryController.dispose();
    _promptController.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  void _startTipRotation() {
    _tipTimer?.cancel();
    _currentTipIndex = Random().nextInt(_magicTips.length);
    _tipTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isGenerating) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _magicTips.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // ── Pollinations AI — free, no API key needed ──
  String _buildImageUrl(String prompt, int seed) {
    // Tweak parameters for better reliability
    final cleanPrompt = Uri.encodeComponent(
      '$prompt, high quality children illustration, cheerful',
    );
    // Using a more standard URL format as verified by testing
    return 'https://image.pollinations.ai/prompt/$cleanPrompt?seed=$seed&width=1024&height=1024&nologo=true';
  }

  Future<void> _generate() async {
    final prompt = _selectedCategory?.prompt ??
        (_promptController.text.trim().isNotEmpty
            ? _promptController.text.trim()
            : null);

    if (prompt == null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isGenerating = true;
      _seed = Random().nextInt(999999);
    });
    _startTipRotation();

    // Pollinations returns immediately as a URL — we just load it
    final url = _buildImageUrl(prompt, _seed);

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _currentImageUrl = url;
        // _isGenerating will be set to false by frameBuilder once the image renders
        if (!_history.contains(url)) _history.insert(0, url);
        if (_history.length > 12) _history.removeLast();
      });
    }
  }

  void _regenerate() {
    if (_selectedCategory == null && _promptController.text.trim().isEmpty) {
      return;
    }
    _generate();
  }

  Future<void> _saveImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await Gal.putImageBytes(response.bodyBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Yay! Saved to your photos! 📸',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w500),
              ),
              backgroundColor: _teal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          );
        }
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Oops! Couldn\'t save the magic just yet.',
              style: GoogleFonts.fredoka(),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
          _AmbientBlobs(isDark: isDark, floatController: _floatController),
          _buildGradientHeader(isDark),
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Canvas / preview ──
                            _buildCanvas(isDark),
                            const SizedBox(height: 24),

                            // ── Category chips ──
                            _buildSectionLabel('Choose a Theme', isDark),
                            const SizedBox(height: 12),
                            _buildCategoryGrid(isDark),
                            const SizedBox(height: 24),

                            // ── Custom prompt ──
                            _buildSectionLabel('Or Describe Your Own', isDark),
                            const SizedBox(height: 12),
                            _buildCustomPromptBar(isDark),
                            const SizedBox(height: 24),

                            // ── History ──
                            if (_history.length > 1) ...[
                              _buildSectionLabel('Your Creations', isDark),
                              const SizedBox(height: 12),
                              _buildHistory(isDark),
                            ],
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

  Widget _buildGradientHeader(bool isDark) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _secondaryPurple,
            _secondaryPurple.withValues(alpha: 0.85),
            _mainBlue.withValues(alpha: isDark ? 0.45 : 0.7),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: _secondaryPurple.withValues(alpha: isDark ? 0.3 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Magic Canvas ✨',
                  style: GoogleFonts.fredoka(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Draw anything with AI!',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          // Regenerate button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _regenerate,
              icon: AnimatedBuilder(
                animation: _floatController,
                builder: (_, child) => Transform.rotate(
                  angle: _floatController.value * 2 * pi * 0.15,
                  child: child,
                ),
                child: const Icon(Icons.auto_fix_high_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(bool isDark) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _secondaryPurple.withValues(alpha: isDark ? 0.18 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _secondaryPurple.withValues(alpha: isDark ? 0.12 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: _currentImageUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _currentImageUrl!,
                    fit: BoxFit.cover,
                    headers: const {
                      'User-Agent':
                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                    },
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        // Image has rendered at least one frame
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && _isGenerating) {
                            setState(() => _isGenerating = false);
                          }
                        });
                        return child;
                      }
                      return _buildLoadingState(isDark);
                    },
                    errorBuilder: (_, __, ___) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _isGenerating) {
                          setState(() => _isGenerating = false);
                        }
                      });
                      return _buildErrorState(isDark);
                    },
                  ),
                  // Regenerate overlay button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _regenerate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'New Version',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Save Button Overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => _saveImage(_currentImageUrl!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.download_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Save',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _isGenerating
                ? _buildLoadingState(isDark)
                : _buildEmptyCanvas(isDark),
      ),
    );
  }

  Widget _buildEmptyCanvas(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _floatController,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, sin(_floatController.value * pi) * 6),
            child: child,
          ),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_secondaryPurple, _mainBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _secondaryPurple.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎨', style: TextStyle(fontSize: 42)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pick a theme or type something!',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white54 : Colors.black38,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your AI art will appear here ✨',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: _secondaryPurple,
          strokeWidth: 3,
        ),
        const SizedBox(height: 16),
        Text(
          'Creating your magic… 🪄',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _magicTips[_currentTipIndex],
            key: ValueKey<int>(_currentTipIndex),
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('😔', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'Oops! Try again',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            color: isDark ? Colors.white54 : Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
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

  Widget _buildCategoryGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) {
        final cat = _categories[i];
        final bool selected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedCategory = selected ? null : cat;
              if (!selected) _promptController.clear();
            });
            if (!selected) _generate();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [cat.color, cat.color.withValues(alpha: 0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selected
                  ? null
                  : (isDark ? const Color(0xFF1E1C2A) : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? cat.color
                    : cat.color.withValues(alpha: isDark ? 0.2 : 0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cat.color.withValues(
                      alpha: selected ? 0.3 : (isDark ? 0.08 : 0.08)),
                  blurRadius: selected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 5),
                Text(
                  cat.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white60 : cat.color),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomPromptBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : _secondaryPurple.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _promptController,
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              onSubmitted: (_) {
                setState(() => _selectedCategory = null);
                _generate();
              },
              decoration: InputDecoration(
                hintText: 'e.g. a dragon eating pizza 🍕',
                hintStyle: GoogleFonts.nunito(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_promptController.text.trim().isEmpty) return;
              setState(() => _selectedCategory = null);
              _generate();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_secondaryPurple, _mainBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _secondaryPurple.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '✨ Create',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _history.length,
        itemBuilder: (context, i) {
          final url = _history[i];
          final bool isActive = url == _currentImageUrl;
          return GestureDetector(
            onTap: () => setState(() => _currentImageUrl = url),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? _secondaryPurple : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _secondaryPurple.withValues(
                            alpha: isActive ? 0.4 : 0.0),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? const Color(0xFF1E1C2A) : Colors.black12,
                        child: const Center(
                            child: Text('🎨', style: TextStyle(fontSize: 28))),
                      ),
                    ),
                  ),
                ),
                // Direct Download Button for history item
                Positioned(
                  top: 6,
                  right: 18,
                  child: GestureDetector(
                    onTap: () => _saveImage(url),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────── Ambient Blobs (matches home exactly) ───────────────

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
                  ? _secondaryPurple.withValues(alpha: 0.05)
                  : _secondaryPurple.withValues(alpha: 0.07),
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
                  ? _mainBlue.withValues(alpha: 0.04)
                  : _mainBlue.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: h * 0.72,
          right: w * 0.15,
          child: AnimatedBuilder(
            animation: floatController,
            builder: (_, child) => Transform.translate(
              offset: Offset(sin(floatController.value * pi) * 4, 0),
              child: child,
            ),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? _sunnyYellow.withValues(alpha: 0.15)
                    : _sunnyYellow.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
