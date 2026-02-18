import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'course_library_screen.dart'; // ← import only what's needed

class BottomNavBar extends StatelessWidget {
  final Color primaryColor;
  final bool isDark;

  const BottomNavBar({
    super.key,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? const Color(0xFF1A0F1C) : Colors.white;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: BoxDecoration(
            color: isDark
                ? backgroundColor.withOpacity(0.82)
                : Colors.white.withOpacity(0.80),
            border: Border(
              top: BorderSide(color: primaryColor.withOpacity(0.18)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home (active)
              _NavItem(
                icon: Icons.home_rounded,
                label: "HOME",
                active: true,
                color: primaryColor,
              ),

              // Library
              _NavItem(
                icon: Icons.auto_stories_rounded,
                label: "LIBRARY",
                active: false,
                color: primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CourseLibraryScreen(),
                    ),
                  );
                },
              ),

              // Spacer for FAB
              const SizedBox(width: 56),

              // Ranking
              _NavItem(
                icon: Icons.leaderboard_rounded,
                label: "RANKING",
                active: false,
                color: primaryColor,
              ),

              // Profile
              _NavItem(
                icon: Icons.person_rounded,
                label: "PROFILE",
                active: false,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color; // primary color passed from parent
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = active ? color : Colors.grey[500]!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: itemColor,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: itemColor,
            ),
          ),
        ],
      ),
    );
  }
}
