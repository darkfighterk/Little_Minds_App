import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';

// ── Shared brand palette (matches puzzle/home/login) ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);
const Color teal = Color(0xFF26A69A);

// Card colors cycle (matches puzzle/story_time_page pattern)
const List<Color> _cardCycle = [
  mainBlue,
  secondaryPurple,
  accentOrange,
  sunnyYellow,
  teal,
  Color(0xFFEF5350),
];

class LibraryView extends StatefulWidget {
  final User user;
  final VoidCallback? onBack;

  const LibraryView({super.key, required this.user, this.onBack});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _entryController;
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
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // ── Core Logic (unchanged) ──
  void openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    final List<Map<String, String>> books = [
      {
        "title": "Ginger The Giraffe",
        "image": "assets/books/ginger_giraffe.png",
        "url":
            "https://monkeypen.com/blogs/news/ginger-the-giraffe-free-children-book"
      },
      {
        "title": "Sunny Meadows Woodland School",
        "image": "assets/books/sunny_meadows.png",
        "url": "https://monkeypen.com/blogs/news/sunny-meadows-woodland-school"
      },
      {
        "title": "Bully Bill",
        "image": "assets/books/bully_bill.png",
        "url": "https://monkeypen.com/blogs/news/bully-bill-free-children-book"
      },
      {
        "title": "Dylan The Dragon",
        "image": "assets/books/dylan_dragon.png",
        "url":
            "https://monkeypen.com/blogs/news/dylan-the-dragon-free-children-book"
      },
      {
        "title": "Jessie The Rabbit",
        "image": "assets/books/jessie_rabbit.png",
        "url":
            "https://monkeypen.com/blogs/news/jessie-the-rabbit-free-children-book"
      },
      {
        "title": "I Found a Frog",
        "image": "assets/books/found_frog.png",
        "url":
            "https://monkeypen.com/blogs/news/i-found-a-frog-free-children-book"
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // ── Ambient background blobs (matches puzzle page) ──
          _AmbientBlobs(isDark: isDark, floatController: _floatController),

          // ── Gradient header block (matches puzzle page) ──
          _buildGradientHeader(context),

          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    _buildTopBar(context, isDark, books.length),
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 28,
                          mainAxisSpacing: 32,
                          // Taller aspect ratio to show the book nicely
                          childAspectRatio: 0.60,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          return _BookCard(
                            book: books[index],
                            cardColor: _cardCycle[index % _cardCycle.length],
                            isDark: isDark,
                            floatController: _floatController,
                            phaseOffset: index * 0.2,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              openUrl(books[index]['url']!);
                            },
                          );
                        },
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

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainBlue,
            Color(0xFF2E9FEF),
            Color(0xFF7B5FEF),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: mainBlue.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark, int bookCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          // Back button — glass pill (matches puzzle pattern)
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Magic Library 📚',
                  style: GoogleFonts.fredoka(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Pick a story to explore!',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          // Book count badge — glass style (matches puzzle refresh button area)
          AnimatedBuilder(
            animation: _floatController,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, sin(_floatController.value * pi) * 3),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '$bookCount',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────
// BOOK CARD  — real 3D physical book appearance
// ─────────────────────────────────────────────────────────────────

class _BookCard extends StatefulWidget {
  final Map<String, String> book;
  final Color cardColor;
  final bool isDark;
  final AnimationController floatController;
  final double phaseOffset;
  final VoidCallback onTap;

  const _BookCard({
    required this.book,
    required this.cardColor,
    required this.isDark,
    required this.floatController,
    required this.phaseOffset,
    required this.onTap,
  });

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _pressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  /// Darken a colour for the spine
  Color get _spineColor {
    final hsl = HSLColor.fromColor(widget.cardColor);
    return hsl.withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0)).toColor();
  }

  /// Lighten slightly for a gloss highlight on the cover
  Color get _glossColor {
    final hsl = HSLColor.fromColor(widget.cardColor);
    return hsl.withLightness((hsl.lightness + 0.10).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.floatController, _pressAnim]),
        builder: (_, child) {
          final floatY =
              sin((widget.floatController.value + widget.phaseOffset) * pi) *
                  3.0;
          // On press: book shifts slightly down-right (like pushing it down)
          final pressShift = _pressAnim.value * 3.0;
          final pressScale = 1.0 - _pressAnim.value * 0.025;

          return Transform.translate(
            offset: Offset(pressShift, floatY + pressShift),
            child: Transform.scale(
              scale: pressScale,
              child: child,
            ),
          );
        },
        child: _buildBook(),
      ),
    );
  }

  Widget _buildBook() {
    return AnimatedBuilder(
      animation: _pressAnim,
      builder: (context, child) {
        final shadowBlur = 18.0 - _pressAnim.value * 10.0;
        final shadowX = 7.0 - _pressAnim.value * 5.0;
        final shadowY = 12.0 - _pressAnim.value * 8.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3),
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
            boxShadow: [
              // Coloured glow shadow (like the book casts its colour)
              BoxShadow(
                color: widget.cardColor
                    .withValues(alpha: 0.45 - _pressAnim.value * 0.18),
                blurRadius: shadowBlur,
                offset: Offset(shadowX, shadowY),
              ),
              // Crisp dark shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: shadowBlur * 0.6,
                offset: Offset(shadowX * 0.4, shadowY * 0.5),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          bottomLeft: Radius.circular(3),
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── SPINE (left edge) ──
            _buildSpine(),
            // ── COVER (main face) ──
            Expanded(child: _buildCover()),
            // ── PAGE EDGES (right side) ──
            _buildPageEdges(),
          ],
        ),
      ),
    );
  }

  // ── Spine: darker, narrower, with binding details + rotated title ──
  Widget _buildSpine() {
    return Container(
      width: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _spineColor.withValues(alpha: 0.85),
            _spineColor,
            widget.cardColor.withValues(alpha: 0.88),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top binding block
          _SpineBinding(color: Colors.white.withValues(alpha: 0.20)),
          // Rotated title along the spine
          Expanded(
            child: Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.book['title']!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 6.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.80),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom binding block
          _SpineBinding(color: Colors.white.withValues(alpha: 0.20)),
        ],
      ),
    );
  }

  // ── Cover: full-bleed image + gloss + gradient overlay with title/button ──
  Widget _buildCover() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient (visible if image fails)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_glossColor, widget.cardColor, _spineColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Full-bleed book cover image
        Image.asset(
          widget.book['image']!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                const Text('📖', style: TextStyle(fontSize: 40)),
              ],
            ),
          ),
        ),

        // Top gloss highlight (like light hitting a hardcover)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Subtle left-edge crease line (where cover meets spine)
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.20),
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.20),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Bottom gradient overlay for title + button readability
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.82),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(10, 28, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Book title
                Text(
                  widget.book['title']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                // FREE badge + READ button row
                Row(
                  children: [
                    // FREE badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: widget.cardColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'FREE',
                        style: GoogleFonts.nunito(
                          color: widget.cardColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // READ button
                    Expanded(
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'READ NOW',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Page edges: cream coloured with fine lines, like a real book's side ──
  Widget _buildPageEdges() {
    return SizedBox(
      width: 9,
      child: CustomPaint(
        painter: _PageEdgePainter(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SPINE BINDING BLOCK — small decorative bar at top/bottom of spine
// ─────────────────────────────────────────────────────────────────

class _SpineBinding extends StatelessWidget {
  final Color color;
  const _SpineBinding({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PAGE EDGE PAINTER — cream background + subtle horizontal lines
// ─────────────────────────────────────────────────────────────────

class _PageEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Cream/ivory base gradient (lighter at centre, slightly darker at edges)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFEDE8D6),
          Color(0xFFF8F4E8),
          Color(0xFFE8E2CE),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Fine horizontal lines simulating page stacking
    final linePaint = Paint()
      ..color = const Color(0xFFC8BFA8).withValues(alpha: 0.55)
      ..strokeWidth = 0.5;

    const spacing = 2.8;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Slight shadow on left edge (where pages meet cover)
    final leftShadowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), leftShadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────
// AMBIENT BLOBS (matches puzzle page — floatController + animated dot)
// ─────────────────────────────────────────────────────────────────

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
        // Animated floating dot (matches puzzle page)
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
                    ? sunnyYellow.withValues(alpha: 0.15)
                    : sunnyYellow.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
