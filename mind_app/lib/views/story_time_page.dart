import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/story_service.dart';

import 'story_reader_page.dart';

// ── Shared brand palette (matches home/login) ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

const List<Color> _brandCycle = [
  mainBlue,
  secondaryPurple,
  accentOrange,
  sunnyYellow,
];

class StoryTimePage extends StatefulWidget {
  final User user;
  const StoryTimePage({required this.user, super.key});

  @override
  State<StoryTimePage> createState() => _StoryTimePageState();
}

class _StoryTimePageState extends State<StoryTimePage>
    with TickerProviderStateMixin {
  List<Story> _stories = [];
  bool _loading = true;
  String? _error;

  String _selectedDifficulty = 'All';
  static const List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

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

    _loadStories();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // ── Core Logic (unchanged) ──
  Future<void> _loadStories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stories = await StoryService.getStories(
        difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
      );
      if (mounted) {
        setState(() {
          _stories = stories;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load stories. Please try again.';
          _loading = false;
        });
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
          // ── Ambient background blobs (matches home/login) ──
          _AmbientBlobs(isDark: isDark, floatController: _floatController),

          // ── Gradient header block ──
          _buildGradientHeader(isDark),

          // ── Main content ──
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 10),
                    _buildDifficultyFilters(isDark),
                    Expanded(child: _buildStoryGrid(isDark)),
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
            mainBlue,
            mainBlue.withValues(alpha: 0.85),
            secondaryPurple.withValues(alpha: isDark ? 0.4 : 0.65),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: mainBlue.withValues(alpha: isDark ? 0.3 : 0.25),
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
          // Back button — rounded glass pill (matches home card style)
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
                  'Story Time 📖',
                  style: GoogleFonts.fredoka(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Pick a magic book to read!',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          // Refresh button — consistent with home icon buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _loadStories,
              icon: AnimatedBuilder(
                animation: _floatController,
                builder: (_, child) => Transform.rotate(
                  angle: _floatController.value * 2 * pi * 0.1,
                  child: child,
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilters(bool isDark) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _difficulties.length,
        itemBuilder: (context, i) {
          final d = _difficulties[i];
          final bool active = _selectedDifficulty == d;
          // Cycle through brand colors for active states
          final Color chipColor = _brandCycle[i % _brandCycle.length];
          return GestureDetector(
            onTap: () {
              if (!active) {
                HapticFeedback.selectionClick();
                setState(() => _selectedDifficulty = d);
                _loadStories();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                gradient: active
                    ? LinearGradient(
                        colors: [chipColor, chipColor.withValues(alpha: 0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: active
                    ? null
                    : (isDark ? const Color(0xFF1E1C2A) : Colors.white),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: active
                      ? chipColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : chipColor.withValues(alpha: 0.2)),
                  width: 1.8,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: chipColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.nunito(
                    color: active
                        ? Colors.white
                        : (isDark ? Colors.white60 : chipColor),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryGrid(bool isDark) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: mainBlue),
            const SizedBox(height: 16),
            Text(
              'Loading stories…',
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
    if (_error != null) return _buildErrorState(isDark);
    if (_stories.isEmpty) return _buildEmptyState(isDark);

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.72,
      ),
      itemCount: _stories.length,
      itemBuilder: (context, i) => _StoryCard(
        story: _stories[i],
        cardColor: _brandCycle[i % _brandCycle.length],
        isDark: isDark,
        floatController: _floatController,
        phaseOffset: i * 0.2,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => StoryReaderPage(
                storyId: _stories[i].id,
                user: widget.user,
              ),
              transitionsBuilder: (_, animation, __, child) => FadeTransition(
                opacity:
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(bool isDark) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('😔', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadStories,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [mainBlue, secondaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: mainBlue.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState(bool isDark) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mainBlue.withValues(alpha: 0.15),
                    secondaryPurple.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('📚', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No stories found here yet!',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back soon for new adventures',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ],
        ),
      );
}

// ─────────────── Story Card (arch-top, matches _ActivityCard) ───────────────

class _StoryCard extends StatelessWidget {
  final Story story;
  final Color cardColor;
  final bool isDark;
  final AnimationController floatController;
  final double phaseOffset;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.cardColor,
    required this.isDark,
    required this.floatController,
    required this.phaseOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: floatController,
        builder: (_, child) => Transform.translate(
          offset:
              Offset(0, sin((floatController.value + phaseOffset) * pi) * 3.0),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? cardColor.withValues(alpha: 0.18)
                  : cardColor.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: isDark ? 0.12 : 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Arch icon / cover area (mirrors _ActivityCard) ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: story.coverUrl.isEmpty
                          ? LinearGradient(
                              colors: [
                                cardColor,
                                cardColor.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: story.coverUrl.isNotEmpty
                          ? cardColor.withValues(alpha: 0.08)
                          : null,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: story.coverUrl.isEmpty
                          ? [
                              BoxShadow(
                                color: cardColor.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: story.coverUrl.isNotEmpty
                          ? Image.network(
                              story.coverUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  story.coverEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            )
                          : Stack(
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
                                Text(
                                  story.coverEmoji,
                                  style: const TextStyle(fontSize: 42),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              // ── Label area ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Badge(
                            label: '${story.pageCount}p',
                            color: cardColor,
                            isDark: isDark),
                        const SizedBox(width: 6),
                        _Badge(
                            label: story.difficulty,
                            color: isDark
                                ? Colors.white24
                                : Colors.black.withValues(alpha: 0.25),
                            isDark: isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _Badge(
      {required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bool isNeutral = color == Colors.black26 ||
        color == Colors.white24 ||
        (color.a * 255).round() < 80;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: isNeutral ? (isDark ? Colors.white38 : Colors.black45) : color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ─────────────── Ambient Blobs (matches home/login exactly) ───────────────

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
