import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/story_service.dart';

// ── Shared brand palette ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color sunnyYellow = Color(0xFFFDDF50);
const Color accentOrange = Color(0xFFFF8811);

class StoryReaderPage extends StatefulWidget {
  final String storyId;
  final User user;

  const StoryReaderPage({
    required this.storyId,
    required this.user,
    super.key,
  });

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage>
    with TickerProviderStateMixin {
  StoryDetail? _detail;
  bool _loading = true;
  String? _error;

  late PageController _pageCtrl;
  int _currentPage = 0;
  bool _finished = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _loadDetail();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final detail = await StoryService.getStoryDetail(widget.storyId);
    if (!mounted) return;
    if (detail == null) {
      setState(() {
        _error = 'Oops! We couldn\'t find your story book.';
        _loading = false;
      });
    } else {
      setState(() {
        _detail = detail;
        _loading = false;
      });
      _fadeCtrl.forward();
    }
  }

  void _goToPage(int index) {
    _pageCtrl.animateToPage(index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart);
  }

  void _nextPage() {
    final total = _detail!.pages.length;
    if (_currentPage < total - 1) {
      HapticFeedback.mediumImpact();
      _goToPage(_currentPage + 1);
    } else {
      setState(() => _finished = true);
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
          // ── Ambient blobs (consistent with home/login) ──
          _AmbientBlobs(isDark: isDark, floatController: _floatController),

          _loading
              ? _buildLoader()
              : _error != null
                  ? _buildError()
                  : _finished
                      ? _buildFinished(isDark)
                      : _buildReader(isDark),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [mainBlue, secondaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: mainBlue.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Text('📖', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: mainBlue),
          const SizedBox(height: 14),
          Text(
            'Opening your story…',
            style: GoogleFonts.nunito(
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: accentOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('📚', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _loadDetail,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [mainBlue, secondaryPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: mainBlue.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinished(bool isDark) {
    final story = _detail!.story;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            secondaryPurple.withValues(alpha: isDark ? 0.18 : 0.12),
            isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Celebration badge (arch-top style from _ActivityCard)
            Container(
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
                    color: accentOrange.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  story.coverEmoji,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'The End! 🎉',
              style: GoogleFonts.fredoka(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You finished "${story.title}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            // Stars row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    '⭐',
                    style: TextStyle(
                      fontSize: 22 - i.toDouble(),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 44),
            // Read Again — gradient button (matches login's _GradientButton)
            GestureDetector(
              onTap: () {
                setState(() {
                  _finished = false;
                  _currentPage = 0;
                });
                _pageCtrl.jumpToPage(0);
              },
              child: Container(
                width: 240,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [secondaryPurple, mainBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryPurple.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.replay_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Read Again',
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Back to Library',
                style: GoogleFonts.nunito(
                  color: mainBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReader(bool isDark) {
    final story = _detail!.story;
    final pages = _detail!.pages;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          // ── Gradient header strip (consistent with home) ──
          _buildGradientHeader(story, pages.length, isDark),
          _buildProgressBar(pages.length, isDark),
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => _buildPageContent(pages[i], isDark),
            ),
          ),
          _buildBottomControls(pages.length, isDark),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(Story story, int total, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainBlue,
            mainBlue.withValues(alpha: 0.85),
            secondaryPurple.withValues(alpha: isDark ? 0.35 : 0.6),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: mainBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              // Close button — glass pill (matches back button in home/story_time)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_currentPage + 1} of $total pages',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Page badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_currentPage + 1} / $total',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int total, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total > 0 ? (_currentPage + 1) / total : 0,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : mainBlue.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(mainBlue),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(StoryPage page, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (page.imageUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: mainBlue.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(
                  page.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          mainBlue.withValues(alpha: 0.08),
                          secondaryPurple.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: Icon(Icons.menu_book_rounded,
                          size: 54, color: mainBlue),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          if (page.title.isNotEmpty) ...[
            Text(
              page.title,
              style: GoogleFonts.fredoka(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: secondaryPurple,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Body text card (matches home card style)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? mainBlue.withValues(alpha: 0.12)
                    : mainBlue.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : mainBlue.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              page.body,
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black87,
                height: 1.65,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(int total, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _CircleNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            enabled: _currentPage > 0,
            onTap: () => _goToPage(_currentPage - 1),
            isDark: isDark,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _nextPage,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _currentPage < total - 1
                        ? [accentOrange, const Color(0xFFFF5F5F)]
                        : [secondaryPurple, mainBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_currentPage < total - 1
                              ? accentOrange
                              : secondaryPurple)
                          .withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _currentPage < total - 1
                        ? 'Next Page →'
                        : 'Finish Story 🎉',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

class _CircleNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;
  const _CircleNavButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? const Color(0xFF1E1C2A) : Colors.white)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade100),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? mainBlue.withValues(alpha: isDark ? 0.3 : 0.2)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: mainBlue.withValues(alpha: isDark ? 0.12 : 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: enabled
              ? mainBlue
              : (isDark ? Colors.white12 : Colors.grey.shade400),
          size: 20,
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
          top: h * 0.5,
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
              offset: Offset(sin(floatController.value * pi) * 3, 0),
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
