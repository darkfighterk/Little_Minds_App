import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'story_player.dart';
import '../models/user_model.dart';

// ── Same brand palette as login / home ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class LibraryView extends StatefulWidget {
  final User user;
  final VoidCallback? onBack;

  const LibraryView({super.key, required this.user, this.onBack});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with TickerProviderStateMixin {
  // ── Entry + float animations (mirrors login / home) ──
  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  int _selectedCategoryIndex = 0; // 0 = All

  // ── Story List ──
  final List<Map<String, dynamic>> staticStories = const [
    {
      "title": "The Giving Tree",
      "author": "Shel Silverstein",
      "cover": "assets/story1/page1.png",
      "category": "Nature",
      "pages": [
        {
          "text": "Once there was a tree... and she loved a little boy.",
          "image": "assets/story1/page1.png"
        },
        {
          "text":
              "And every day the boy would come to eat her apples and play.",
          "image": "assets/story1/page2.png"
        },
        {
          "text": "The tree was very happy to give everything to the boy.",
          "image": "assets/story1/page3.png"
        }
      ]
    },
    {
      "title": "Peter Rabbit",
      "author": "Beatrix Potter",
      "cover": "assets/story2/page1.png",
      "category": "Animals",
      "pages": [
        {
          "text": "Once upon a time there were four little Rabbits...",
          "image": "assets/story2/page1.png"
        },
        {
          "text": "Flopsy, Mopsy, Cottontail, and Peter.",
          "image": "assets/story2/page2.png"
        },
        {
          "text": "Peter was very naughty and ran to Mr. McGregor's garden!",
          "image": "assets/story2/page3.png"
        }
      ]
    },
    {
      "title": "Hungry Caterpillar",
      "author": "Eric Carle",
      "cover": "assets/story3/page1.png",
      "category": "Science",
      "pages": [
        {
          "text": "In the light of the moon, a little egg lay on a leaf.",
          "image": "assets/story3/page1.png"
        },
        {
          "text": "On Monday, he ate through one apple.",
          "image": "assets/story3/page2.png"
        },
        {
          "text": "Suddenly, he became a butterfly!",
          "image": "assets/story3/page3.png"
        }
      ]
    },
  ];

  // ── Per-story fallback emojis & gradient colors shown when asset is missing ──
  static const List<String> _fallbackEmojis = ['🌳', '🐰', '🦋'];
  static const List<List<Color>> _fallbackGradients = [
    [Color(0xFF81C784), Color(0xFF4CAF50)], // green  – Giving Tree
    [Color(0xFFFFB74D), Color(0xFFFF8811)], // orange – Peter Rabbit
    [Color(0xFF4FC3F7), Color(0xFF3AAFFF)], // blue   – Hungry Caterpillar
  ];

  // ── Category filter tabs ──
  final List<Map<String, dynamic>> _categories = const [
    {'label': 'All', 'emoji': '✨'},
    {'label': 'Animals', 'emoji': '🐰'},
    {'label': 'Science', 'emoji': '🧪'},
    {'label': 'Nature', 'emoji': '🌿'},
  ];

  List<Map<String, dynamic>> get _filteredStories {
    if (_selectedCategoryIndex == 0) return staticStories;
    final cat = _categories[_selectedCategoryIndex]['label'] as String;
    return staticStories.where((s) => s['category'] == cat).toList();
  }

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
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
          // ── Ambient blobs (mirrors login / home) ──
          _AmbientBlobs(isDark: isDark),

          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    _buildTopBar(context, isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            // ── Reading Streak Banner ──
                            _buildStreakBanner(context, isDark),
                            const SizedBox(height: 22),

                            // ── Category Chips ──
                            _buildCategoryChips(context, isDark),
                            const SizedBox(height: 22),

                            // ── Category Circle Icons ──
                            _buildCategoryCircles(context, isDark),
                            const SizedBox(height: 28),

                            // ── Featured Story Card ──
                            _buildFeaturedCard(context, isDark),
                            const SizedBox(height: 28),

                            // ── Section Header ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "New Adventures",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  "${_filteredStories.length} stories",
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Book Grid ──
                            _buildBookGrid(context, isDark),
                            const SizedBox(height: 100),
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

  // ── Top Bar (mirrors HomeView header style) ──
  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Magic Library 📚',
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Pick a story to explore!',
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Book count badge (mirrors star badge from HomeView)
          AnimatedBuilder(
            animation: _floatController,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, sin(_floatController.value * pi) * 3),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mainBlue.withValues(alpha: 0.25),
                    secondaryPurple.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: mainBlue.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: mainBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories_rounded,
                      color: mainBlue, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '${staticStories.length}',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: mainBlue,
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

  // ── Reading Streak Banner (replaces generic orange banner) ──
  Widget _buildStreakBanner(BuildContext context, bool isDark) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, sin((_floatController.value + 0.3) * pi) * 2),
        child: child,
      ),
      child: GestureDetector(
        onTap: () => _navigateToStory(context, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9E2D), Color(0xFFFF5F5F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF712D).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative icon
              Positioned(
                right: -10,
                top: -15,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Row(
                children: [
                  // Flame icon bubble
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('🔥', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reading Streak!",
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "3 days in a row 🎉 Keep it up!",
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Progress dots
                        Row(
                          children: List.generate(7, (i) {
                            final active = i < 3;
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: active ? 28 : 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Horizontal Category Chips ──
  Widget _buildCategoryChips(BuildContext context, bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [mainBlue, secondaryPurple])
                    : null,
                color: selected
                    ? null
                    : isDark
                        ? const Color(0xFF1E1C2A)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : mainBlue.withValues(alpha: 0.18),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: mainBlue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _categories[index]['emoji'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _categories[index]['label'] as String,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: selected
                          ? Colors.white
                          : isDark
                              ? Colors.white60
                              : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Category Circles (original logic, redesigned) ──
  Widget _buildCategoryCircles(BuildContext context, bool isDark) {
    final List<Map<String, dynamic>> cats = [
      {'n': 'Biology', 'i': '🧬', 'c': const Color(0xFFE1F5FE)},
      {'n': 'Animals', 'i': '🐰', 'c': const Color(0xFFFFF3E0)},
      {'n': 'Geography', 'i': '🌍', 'c': const Color(0xFFE8F5E9)},
      {'n': 'Science', 'i': '🧪', 'c': const Color(0xFFF3E5F5)},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cats.map((cat) {
        return Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? (cat['c'] as Color).withValues(alpha: 0.15)
                    : cat['c'] as Color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (cat['c'] as Color)
                        .withValues(alpha: isDark ? 0.1 : 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white,
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Text(cat['i'] as String,
                    style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cat['n'] as String,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Featured Story Card (NEW — mirrors Puzzles card from HomeView) ──
  Widget _buildFeaturedCard(BuildContext context, bool isDark) {
    final featured = staticStories[1]; // Peter Rabbit as featured
    return GestureDetector(
      onTap: () => _navigateToStory(context, 1),
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, sin((_floatController.value + 0.5) * pi) * 2.5),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [secondaryPurple, mainBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: secondaryPurple.withValues(alpha: isDark ? 0.25 : 0.35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Book cover with fallback
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
                child: SizedBox(
                  width: 64,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        featured['cover'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFB74D), Color(0xFFFF8811)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('🐰', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                      // Spine shadow
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⭐ FEATURED',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      featured['title'] as String,
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      featured['author'] as String,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${(featured['pages'] as List).length} pages',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Book Grid (original logic, redesigned cards) ──
  Widget _buildBookGrid(BuildContext context, bool isDark) {
    final stories = _filteredStories;
    if (stories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Text('📭', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'No stories in this category yet!',
                style: GoogleFonts.nunito(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
        childAspectRatio: 0.55,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final storyIndex = staticStories.indexOf(stories[index]);
        return GestureDetector(
          onTap: () => _navigateToStory(context, storyIndex),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.35 : 0.15),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Cover image with emoji fallback ──
                        Image.asset(
                          stories[index]['cover'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            final gi = storyIndex.clamp(
                                0, _fallbackGradients.length - 1);
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _fallbackGradients[gi],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _fallbackEmojis[gi],
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                            );
                          },
                        ),
                        // Book Spine Effect
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(Icons.menu_book_rounded,
                              color: Colors.white70, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stories[index]['title'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                stories[index]['author'],
                maxLines: 1,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Original navigation logic — untouched ──
  void _navigateToStory(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MagicStoryPlayer(
          title: staticStories[index]['title'],
          storyPages: (staticStories[index]['pages'] as List)
              .map((p) => {
                    "text": p['text'].toString(),
                    "image": p['image'].toString(),
                  })
              .toList(),
        ),
      ),
    );
  }
}

// ─────────────── Ambient Blobs (matches login / home exactly) ───────────────

class _AmbientBlobs extends StatelessWidget {
  final bool isDark;
  const _AmbientBlobs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // Top-right blob
        Positioned(
          top: -40,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? mainBlue.withValues(alpha: 0.05)
                  : mainBlue.withValues(alpha: 0.07),
            ),
          ),
        ),
        // Bottom-right blob
        Positioned(
          bottom: h * 0.1,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? secondaryPurple.withValues(alpha: 0.05)
                  : secondaryPurple.withValues(alpha: 0.07),
            ),
          ),
        ),
        // Mid-left blob
        Positioned(
          top: h * 0.45,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? accentOrange.withValues(alpha: 0.04)
                  : accentOrange.withValues(alpha: 0.06),
            ),
          ),
        ),
        // Small yellow dot
        Positioned(
          top: h * 0.25,
          right: w * 0.12,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? sunnyYellow.withValues(alpha: 0.15)
                  : sunnyYellow.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }
}
