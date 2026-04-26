import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_app/views/text_to_image.dart';
import '../models/user_model.dart';
import 'quiz_arena_view.dart';
import 'puzzles_list_view.dart';
import 'story_time_page.dart';
import 'drawing_pad_view.dart';
import 'admin_view.dart';
import 'profile_view.dart';
import 'magic_3d_home_view.dart';

// ── Shared brand palette ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);
const Color teal = Color(0xFF26A69A);

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;
  late User _currentUser;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;

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
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // ── All activity buttons ──
  List<Map<String, dynamic>> get _allButtons => [
        {
          'title': 'Quiz Arena',
          'subtitle': 'Test your brain',
          'icon': Icons.quiz_rounded,
          'color': secondaryPurple,
          'onTap': () =>
              Navigator.push(context, _fadeRoute(QuizArenaView(user: widget.user))),
        },
        {
          'title': 'Note Scanner',
          'subtitle': 'Scan & learn',
          'icon': Icons.document_scanner_rounded,
          'color': accentOrange,
          'onTap': () =>
              Navigator.push(context, _fadeRoute(const TextFromImagePage())),
        },
        {
          'title': 'Story Time',
          'subtitle': 'Read & imagine',
          'icon': Icons.menu_book_rounded,
          'color': sunnyYellow,
          'onTap': () => Navigator.push(
              context, _fadeRoute(StoryTimePage(user: widget.user))),
        },
        {
          'title': 'Drawing',
          'subtitle': 'Create art',
          'icon': Icons.brush_rounded,
          'color': mainBlue,
          'onTap': () =>
              Navigator.push(context, _fadeRoute(const DrawingPadView())),
        },
        {
          'title': '3D Explorer',
          'subtitle': 'Magic objects',
          'icon': Icons.view_in_ar_rounded,
          'color': const Color(0xFFFF5F5F), // Reddish UI color
          'onTap': () =>
              Navigator.push(context, _fadeRoute(const Magic3DHomeView())),
        },
        {
          'title': 'Puzzles',
          'subtitle': 'Sharpen mind',
          'icon': Icons.extension_rounded,
          'color': teal,
          'onTap': () => Navigator.push(
              context, _fadeRoute(PuzzlesListView(user: widget.user))),
        },
      ];

  Route _fadeRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    final filteredButtons = _allButtons
        .where(
            (b) => b['title'].toString().toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // ── Ambient background blobs (match login) ──
          _AmbientBlobs(isDark: isDark, floatController: _floatController),

          // ── Gradient header block ──
          _GradientHeaderBlock(
            isDark: isDark,
            floatController: _floatController,
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top bar: avatar + title + settings ──
                    _buildTopBar(isDark),

                    // ── Hero text + search ──
                    _buildHeroSection(isDark),

                    const SizedBox(height: 20),

                    // ── Scrollable body on warm card ──
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
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(22, 30, 22, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(
                                label: 'Activities',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              filteredButtons.isEmpty
                                  ? _buildEmptyState(isDark)
                                  : _buildGrid(filteredButtons, isDark),
                            ],
                          ),
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

  // ── Top bar ──
  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 18, 0),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: _goToProfile,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: mainBlue.withValues(alpha: 0.15),
                backgroundImage: (_currentUser.photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(_currentUser.photoUrl!)
                    : null,
                child: (_currentUser.photoUrl?.isNotEmpty ?? false)
                    ? null
                    : const Icon(Icons.person_rounded,
                        color: mainBlue, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Little Minds',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Settings
          GestureDetector(
            onTap: _showSettingsSheet,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero section: headline + search ──
  Widget _buildHeroSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse your\nadventure!',
            style: GoogleFonts.fredoka(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Hi ${_currentUser.name}, pick a fun activity! ✨',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),

          // ── Search bar — matches login field style ──
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: mainBlue.withValues(alpha: 0.45),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: mainBlue.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search adventure...',
                hintStyle: GoogleFonts.nunito(
                  color: isDark ? Colors.white30 : Colors.black26,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: mainBlue, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid ──
  Widget _buildGrid(List<Map<String, dynamic>> buttons, bool isDark) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.80,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      itemBuilder: (_, i) {
        final btn = buttons[i];
        return _ActivityCard(
          title: btn['title'] as String,
          subtitle: btn['subtitle'] as String,
          icon: btn['icon'] as IconData,
          color: btn['color'] as Color,
          isDark: isDark,
          floatController: _floatController,
          phaseOffset: i * 0.18,
          onTap: () {
            HapticFeedback.lightImpact();
            (btn['onTap'] as VoidCallback)();
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 60, color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text(
              'No adventures found!',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToProfile() async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => ProfileView(user: _currentUser)),
    );
    if (updatedUser != null && mounted) {
      setState(() => _currentUser = updatedUser);
    }
  }

  void _showSettingsSheet() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBg = isDark ? const Color(0xFF1E1C2A) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white24
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Admin Tools 🛠️',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Admin tile
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, _fadeRoute(const AdminGateView()));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: mainBlue.withValues(alpha: isDark ? 0.12 : 0.07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: mainBlue.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: mainBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: mainBlue, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Admin Control Panel',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: isDark ? Colors.white38 : Colors.black38),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────── Gradient Header Block ───────────────

class _GradientHeaderBlock extends StatelessWidget {
  final bool isDark;
  final AnimationController floatController;

  const _GradientHeaderBlock(
      {required this.isDark, required this.floatController});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.44,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2B9FFF),
              Color(0xFF3AAFFF),
              Color(0xFFA55FEF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Large circle top-right
            Positioned(
              top: -55,
              right: -55,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Medium circle bottom-left
            Positioned(
              bottom: -30,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Floating yellow dot
            Positioned(
              top: 65,
              right: 90,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, sin(floatController.value * pi) * 5),
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: sunnyYellow,
                    ),
                  ),
                ),
              ),
            ),
            // White dot
            Positioned(
              top: 120,
              left: 55,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -sin(floatController.value * pi) * 4),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
            // Orange dot
            Positioned(
              bottom: 70,
              right: 55,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(sin(floatController.value * pi) * 4, 0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentOrange.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Activity Card ───────────────

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final AnimationController floatController;
  final double phaseOffset;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
              Offset(0, sin((floatController.value + phaseOffset) * pi) * 3.5),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? color.withValues(alpha: 0.18)
                  : color.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.12 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Arch icon area ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(80),
                        bottom: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle inner glow circle
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Icon(icon, size: 46, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Label area ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: isDark ? 0.8 : 0.75),
                      ),
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
