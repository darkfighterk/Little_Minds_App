import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_app/views/text_to_image.dart';
import '../models/user_model.dart';
import '../widgets/mindie_button.dart';
import 'home_view.dart';
import 'bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Animation controller for floating effects throughout the page
  late AnimationController _floatController;

  // Primary accent color for consistency across the page
  static const Color primaryAccent = Color(0xFFDA22FF);

  @override
  void initState() {
    super.initState();
    // Initialize continuous floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5, milliseconds: 200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Clean up controller to prevent memory leaks
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      // Global Mindie AI Button placed in the standard floating action button slot
      floatingActionButton: const MindieButton(),
      // Standard position for bottom-right floating button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Deep space theme background gradient
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
            // Decorative background glow effects (Orbs)
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
              child: Column(
                children: [
                  _buildHeader(), // User greeting and stars
                  Expanded(child: _buildMainButtonsGrid()), // App features grid
                ],
              ),
            ),
          ],
        ),
      ),
      // Persistent bottom navigation bar
      bottomNavigationBar: BottomNavBar(
        primaryColor: primaryAccent,
        isDark: true,
      ),
    );
  }

  // Header Widget: Displays user profile, name, and floating stars
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
                    // Gradient text for welcoming the user
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
                      'Hi, ${widget.user.name ?? "Explorer"}! 🌟',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
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
          _buildFloatingStars(), // Animating stars under the greeting
        ],
      ),
    );
  }

  // Widget to generate animating star icons with staggered offsets
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

  // Grid layout for main feature buttons
  Widget _buildMainButtonsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
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
              MaterialPageRoute(
                builder: (_) => const TextFromImagePage(),
              ),
            ),
          ),
          _buildBigButton(
            title: 'Notebook',
            icon: Icons.edit_note_rounded,
            accentColor: const Color(0xFF42A5F5),
            onTap: () => _showComingSoon('Notebook 📝'),
          ),
          _buildBigButton(
            title: 'Stories',
            icon: Icons.menu_book_rounded,
            accentColor: const Color(0xFFFFB74D),
            onTap: () => _showComingSoon('Stories 📖✨'),
          ),
          _buildBigButton(
            title: 'Fun Games',
            icon: Icons.sports_esports_rounded,
            accentColor: const Color(0xFFEC407A),
            onTap: () => _showComingSoon('Fun Games 🎮'),
          ),
        ],
      ),
    );
  }

  // Reusable card widget for the main feature grid
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
          // Subtle individual floating animation for buttons
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

  // Simple feedback utility for features not yet implemented
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}

// Background decoration: Soft glowing radial gradients
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
