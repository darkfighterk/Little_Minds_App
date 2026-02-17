import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseLibraryScreen extends StatelessWidget {
  const CourseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const primary = Color(0xFFAB47BC);
    const primaryDark = Color(0xFF8E24AA);
    const bgLight = Color(0xFFFAF5FB);
    const bgDark = Color(0xFF1A0F1C);

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
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header + Points
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hi, Little Explorer! 🚀",
                                  style: GoogleFonts.lexend(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "What shall we discover today?",
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: primary.withOpacity(0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.diamond,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "1,250",
                                    style: GoogleFonts.lexend(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Search bar – matched with HomeView
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? primary.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primary.withOpacity(isDark ? 0.25 : 0.18),
                            ),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search adventures...",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // ── Category Sections ───────────────────────────────────────
                _buildCategorySection(
                  context: context,
                  title: "Science Wonders",
                  accentColor: const Color(0xFF4ADE80),
                  primary: primary,
                ),

                _buildCategorySection(
                  context: context,
                  title: "History Time-Travel",
                  accentColor: const Color(0xFFFB923C),
                  primary: primary,
                ),

                _buildCategorySection(
                  context: context,
                  title: "Wild Animals",
                  accentColor: primary,
                  primary: primary,
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 180)),
              ],
            ),

            // ── Bottom Navigation ───────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    decoration: BoxDecoration(
                      color: isDark
                          ? backgroundColor.withOpacity(0.82)
                          : Colors.white.withOpacity(0.80),
                      border: Border(
                        top: BorderSide(color: primary.withOpacity(0.18)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: Icons.grid_view_rounded,
                          label: "LIBRARY",
                          active: true,
                          primary: primary,
                        ),
                        _NavItem(
                          icon: Icons.collections_bookmark_rounded,
                          label: "LESSONS",
                          active: false,
                          primary: primary,
                        ),
                        const SizedBox(width: 56), // space for FAB
                        _NavItem(
                          icon: Icons.emoji_events_rounded,
                          label: "AWARDS",
                          active: false,
                          primary: primary,
                        ),
                        _NavItem(
                          icon: Icons.person_rounded,
                          label: "PROFILE",
                          active: false,
                          primary: primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Floating AR Button ──────────────────────────────────────
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
                    // TODO: Navigate to ARCameraView
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

  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required Color accentColor,
    required Color primary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "View All",
                    style: GoogleFonts.lexend(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 380,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // You can keep your _CourseCard widgets here
                // Just pass the new primary color
                // Example:
                // _CourseCard(..., primary: primary),
                // _CourseCard(..., primary: primary),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color primary;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? primary : Colors.grey[500]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}