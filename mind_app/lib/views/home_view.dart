import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import 'ar_camera_view.dart'; // ← AR scan screen
// ...existing code...
import 'bottom_nav_bar.dart'; // ← NEW: our extracted bottom nav

class HomeView extends StatelessWidget {
  final User user;

  const HomeView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const primary = Color(0xFFAB47BC);
    const primaryDark = Color(0xFF8E24AA);
    const bgLight = Color(0xFFFAF5FB);
    const bgDark = Color(0xFF1A0F1C);

    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? bgDark : bgLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back,",
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: isDark
                                        ? primary.withOpacity(0.7)
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Hello, ${user.name}! 👋",
                                  style: GoogleFonts.lexend(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primary.withOpacity(0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_rounded,
                                    color: primary,
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: backgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? primary.withOpacity(0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primary.withOpacity(isDark ? 0.25 : 0.18),
                            ),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search 3D models or subjects...",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.grey[500]),
                              suffixIcon:
                                  Icon(Icons.tune_rounded, color: primary),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Continue Learning
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Continue Learning",
                              style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "View Plan",
                                style: GoogleFonts.lexend(
                                  color: primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primary, primaryDark],
                            ),
                          ),
                          padding: const EdgeInsets.all(1.5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.5),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(isDark ? 0.14 : 0.78),
                                  borderRadius: BorderRadius.circular(14.5),
                                ),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/human_heart_anatomy.png',
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 96,
                                                height: 96,
                                                color:
                                                    primary.withOpacity(0.25),
                                                child: const Icon(Icons.image,
                                                    size: 48),
                                              );
                                            },
                                          ),
                                        ),
                                        const Positioned.fill(
                                          child: Center(
                                            child: Icon(
                                              Icons.view_in_ar_rounded,
                                              color: Colors.white70,
                                              size: 42,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.28),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              "BIOLOGY",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Human Heart Anatomy",
                                            style: GoogleFonts.lexend(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Lesson 4: Ventricle Function",
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.75),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: 0.65,
                                                    minHeight: 6,
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.30),
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                            Colors.white),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                "65%",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    FloatingActionButton.small(
                                      backgroundColor: Colors.white,
                                      foregroundColor: primary,
                                      elevation: 5,
                                      shape: const CircleBorder(),
                                      onPressed: () {},
                                      child:
                                          const Icon(Icons.play_arrow_rounded),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          "Categories",
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 148,
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: const [
                              _CategoryBox(
                                icon: Icons.science_rounded,
                                title: "Biology",
                                gradientColors: [
                                  Color(0xFFAB47BC),
                                  Color(0xFF7B1FA2)
                                ],
                              ),
                              _CategoryBox(
                                icon: Icons.history_edu_rounded,
                                title: "History",
                                gradientColors: [
                                  Color(0xFFCE93D8),
                                  Color(0xFFAB47BC)
                                ],
                              ),
                              _CategoryBox(
                                icon: Icons.precision_manufacturing_rounded,
                                title: "Engineering",
                                gradientColors: [
                                  Color(0xFF8E24AA),
                                  Color(0xFF4A148C)
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Featured Experiences",
                              style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "See All",
                                style: GoogleFonts.lexend(
                                  color: primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 240,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            children: const [
                              _FeaturedCard(
                                title: "Jurassic Giants: T-Rex",
                                subtitle: "12 Interactive Scenes",
                                rating: 4.9,
                                imagePath: 'assets/images/trex_skeleton.png',
                              ),
                              SizedBox(width: 16),
                              _FeaturedCard(
                                title: "ISS: Orbital Station",
                                subtitle: "8 Interaction Points",
                                rating: 4.7,
                                imagePath: 'assets/images/iss_orbit.png',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Bottom Navigation Bar (now extracted) ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                primaryColor: primary,
                isDark: isDark,
              ),
            ),

            // Floating AR / Scan Button
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: primary,
                  elevation: 8,
                  focusElevation: 12,
                  highlightElevation: 16,
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ARCameraView(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.view_in_ar_rounded,
                    color: Colors.white,
                    size: 36,
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

// ──────────────────────────────────────────────────────────────────────────────
// Helper classes (unchanged)
// ──────────────────────────────────────────────────────────────────────────────

class _CategoryBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradientColors;

  const _CategoryBox({
    required this.icon,
    required this.title,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.14),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          splashColor: Colors.white.withOpacity(0.12),
          highlightColor: Colors.white.withOpacity(0.08),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 42,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black45,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final String imagePath;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFAB47BC);

    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF4A1C48),
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white70, size: 48),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.60),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_in_ar_rounded,
                            color: primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "3D MODEL",
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[
                      Theme.of(context).brightness == Brightness.dark
                          ? 400
                          : 600],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
