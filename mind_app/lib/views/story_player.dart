import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Shared brand palette ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class MagicStoryPlayer extends StatefulWidget {
  final String title;
  final List<Map<String, String>> storyPages;

  const MagicStoryPlayer(
      {super.key, required this.title, required this.storyPages});

  @override
  State<MagicStoryPlayer> createState() => _MagicStoryPlayerState();
}

class _MagicStoryPlayerState extends State<MagicStoryPlayer>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  double _progress = 0;

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
    _entrySlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _progress =
              (_pageController.page ?? 0) / (widget.storyPages.length - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
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
          // ── Ambient background blobs (matches home/login) ──
          _AmbientBlobs(isDark: isDark, floatController: _floatController),

          // ── Story Content ──
          FadeTransition(
            opacity: _entryFade,
            child: SlideTransition(
              position: _entrySlide,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.storyPages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildStorySlide(
                    widget.storyPages[index]['text'] ?? 'Loading story...',
                    widget.storyPages[index]['image'] ?? '',
                    index,
                    isDark,
                  );
                },
              ),
            ),
          ),

          // ── Top Control Bar ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(isDark),
                _buildProgressBar(isDark),
              ],
            ),
          ),

          // ── Navigation Buttons ──
          _buildNavButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainBlue,
            mainBlue.withValues(alpha: 0.85),
            secondaryPurple.withValues(alpha: isDark ? 0.4 : 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: mainBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close — glass pill (matches story_time_page back button)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 22),
            ),
          ),

          // Title — Fredoka (consistent with all pages)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Volume — glass pill
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.volume_up_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress.isFinite ? _progress : 0.0,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : mainBlue.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(mainBlue),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 8),
          // Page indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.storyPages.length,
              (i) {
                final double rawPage = _pageController.hasClients
                    ? (_pageController.page ?? 0)
                    : 0;
                final bool active = rawPage.round() == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? mainBlue
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : mainBlue.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(bool isDark) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_progress > 0)
              _NavCircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                isPrimary: false,
                isDark: isDark,
                onTap: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              )
            else
              const SizedBox(width: 56),

            // Center label showing current page
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: mainBlue.withValues(alpha: isDark ? 0.2 : 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _progress >= 0.99
                    ? '🎉 Finished!'
                    : 'Page ${(_progress * (widget.storyPages.length - 1)).round() + 1} / ${widget.storyPages.length}',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
                ),
              ),
            ),

            _NavCircleButton(
              icon: _progress >= 0.99
                  ? Icons.check_rounded
                  : Icons.arrow_forward_ios_rounded,
              isPrimary: true,
              isDark: isDark,
              onTap: () {
                if (_progress < 0.99) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySlide(
      String text, String imagePath, int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 140),
      child: Column(
        children: [
          // ── Image area — arch-top shape (matches _ActivityCard from home) ──
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: imagePath.isEmpty
                      ? LinearGradient(
                          colors: [
                            mainBlue.withValues(alpha: 0.15),
                            secondaryPurple.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isDark && imagePath.isNotEmpty
                      ? const Color(0xFF1E1C2A)
                      : null,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(80),
                    bottom: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mainBlue.withValues(alpha: isDark ? 0.12 : 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? mainBlue.withValues(alpha: 0.12)
                        : mainBlue.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(80),
                    bottom: Radius.circular(28),
                  ),
                  child: imagePath.isNotEmpty
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: AnimatedBuilder(
                              animation: _floatController,
                              builder: (_, child) => Transform.translate(
                                offset: Offset(
                                    0, sin(_floatController.value * pi) * 5),
                                child: child,
                              ),
                              child: const Icon(Icons.broken_image_rounded,
                                  size: 72, color: mainBlue),
                            ),
                          ),
                        )
                      : Center(
                          child: AnimatedBuilder(
                            animation: _floatController,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(
                                  0, sin(_floatController.value * pi) * 8),
                              child: child,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: mainBlue.withValues(alpha: 0.1),
                                  ),
                                ),
                                const Icon(Icons.auto_stories_rounded,
                                    size: 54, color: mainBlue),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),

          // ── Text area — card style matching home ──
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? secondaryPurple.withValues(alpha: 0.12)
                        : secondaryPurple.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : secondaryPurple.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.92)
                            : Colors.black87,
                        height: 1.45,
                      ),
                    ),
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

// ─────────────── Nav Circle Button ───────────────

class _NavCircleButton extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  final bool isDark;
  final VoidCallback onTap;

  const _NavCircleButton({
    required this.icon,
    required this.isPrimary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [mainBlue, secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary
              ? null
              : (isDark ? const Color(0xFF1E1C2A) : Colors.white),
          shape: BoxShape.circle,
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark
                      ? mainBlue.withValues(alpha: 0.2)
                      : mainBlue.withValues(alpha: 0.15),
                  width: 1.5,
                ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? mainBlue.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: isPrimary ? 16 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isPrimary
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black54),
          size: 24,
        ),
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
                    : accentOrange.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
