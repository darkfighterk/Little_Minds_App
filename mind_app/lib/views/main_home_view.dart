// lib/views/main_home_view.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_app/views/text_to_image.dart';
import '../models/user_model.dart';
import 'home_view.dart';
import 'bottom_nav_bar.dart';
import 'puzzles_list_view.dart';
import 'story_time_page.dart';
import 'drawing_pad_view.dart';
import 'puzzle_list_screen.dart'; // ← Crossword public list
import 'create_puzzle_screen.dart'; // ← AdminGateScreen (crossword admin)
import 'admin_view.dart'; // ← AdminGateView (quiz admin)

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _floatController;

  static const Color primaryAccent = Color(0xFFDA22FF);

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5, milliseconds: 200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0533),
              Color(0xFF2D0B5A),
              Color(0xFF2D1B69),
              Color(0xFF1A0A3D),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Glow orbs
            Positioned(
              top: -120,
              right: -140,
              child: _GlowOrb(
                  size: 240, color: const Color(0xFF8B2FC9), opacity: 0.18),
            ),
            Positioned(
              bottom: size.height * 0.12,
              left: -120,
              child: _GlowOrb(
                  size: 200, color: const Color(0xFFDA22FF), opacity: 0.12),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildMainButtonsGrid()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        primaryColor: primaryAccent,
        isDark: true,
      ),
    );
  }

  // ── Header (unchanged except Settings icon added top-right) ───────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile coming soon!')),
                  );
                },
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF9EF5), Colors.white],
                      ).createShader(bounds),
                      child: Text(
                        'Welcome Back!',
                        style: GoogleFonts.fredoka(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'Hi, ${widget.user.name}! 🌟',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Settings icon → admin panel ──────────────────────────
              IconButton(
                onPressed: _showSettingsSheet,
                icon: const Icon(Icons.settings_rounded,
                    color: Colors.white54, size: 26),
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pick your favorite adventure today!',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white.withOpacity(0.70),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildFloatingStars(),
        ],
      ),
    );
  }

  Widget _buildFloatingStars() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final delay = i * 0.12;
            final offset = sin((_floatController.value + delay) * pi * 2) * 6;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Icon(
                  Icons.star_rounded,
                  size: 14 + (i % 4) * 5,
                  color: const Color(0xFFFF9EF5).withOpacity(0.6 + i * 0.06),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ── Grid (all original buttons kept + Crossword added) ────────────────────

  Widget _buildMainButtonsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ── original buttons (unchanged) ─────────────────────────────
          _buildBigButton(
            title: 'Quiz Arena',
            icon: Icons.quiz_rounded,
            accentColor: const Color(0xFF66BB6A),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomeView(user: widget.user)),
            ),
          ),
          _buildBigButton(
            title: 'Text to Image',
            icon: Icons.image_rounded,
            accentColor: const Color(0xFF66BB6A),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TextFromImagePage()),
            ),
          ),
          _buildBigButton(
            title: 'Notebook',
            icon: Icons.edit_note_rounded,
            accentColor: const Color(0xFF42A5F5),
            onTap: () => _showComingSoon('Notebook 📝'),
          ),
          _buildBigButton(
            title: 'Story Time',
            icon: Icons.menu_book_rounded,
            accentColor: const Color(0xFFFFB74D),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoryTimePage(user: widget.user),
              ),
            ),
          ),
          _buildBigButton(
            title: 'Drawing Pad',
            icon: Icons.brush_rounded,
            accentColor: const Color(0xFFAB47BC),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DrawingPadView()),
            ),
          ),
          _buildBigButton(
            title: 'Puzzles',
            icon: Icons.extension_rounded,
            accentColor: const Color(0xFFFF7043),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PuzzlesListView(user: widget.user),
              ),
            ),
          ),
          // ── NEW: Crossword ────────────────────────────────────────────
          _buildBigButton(
            title: 'Crossword',
            icon: Icons.grid_on_rounded,
            accentColor: const Color(0xFF6C63FF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PuzzleListScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigButton({
    required String title,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, sin((_floatController.value + 0.25) * pi) * 5),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.55),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 68, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Settings bottom sheet → admin gates ───────────────────────────────────

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Settings',
                  style:
                      GoogleFonts.fredoka(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Admin tools',
                  style:
                      GoogleFonts.nunito(fontSize: 13, color: Colors.white38)),
              const SizedBox(height: 20),

              // Crossword Admin
              _SettingsTile(
                icon: Icons.grid_4x4_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Crossword Admin',
                subtitle: 'Create & manage crossword puzzles',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminGateScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Quiz Admin
              _SettingsTile(
                icon: Icons.quiz_rounded,
                iconColor: const Color(0xFF66BB6A),
                title: 'Quiz Admin',
                subtitle: 'Create & manage quiz subjects and levels',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminGateView()),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unchanged helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.fredoka(
                            fontSize: 16, color: Colors.white)),
                    Text(subtitle,
                        style: GoogleFonts.nunito(
                            fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
