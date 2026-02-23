// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// You can keep these imports commented until you actually create the screens
// import 'progress_view.dart';
// import 'friends_view.dart';
// import 'settings_view.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
              // Home (active when on home screen)
              _NavItem(
                icon: Icons.home_rounded,
                label: "HOME",
                active: true,
                color: primaryColor,
              ),

              // Progress – beautiful modern icon
              _NavItem(
                icon: Icons.auto_graph_rounded,
                label: "PROGRESS",
                active: false,
                color: primaryColor,
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => const ProgressView()),
                //   );
                // },
              ),

              // Friends
              _NavItem(
                icon: Icons.group_rounded,
                label: "FRIENDS",
                active: false,
                color: primaryColor,
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => const FriendsView()),
                //   );
                // },
              ),

              // Settings
              _NavItem(
                icon: Icons.settings_rounded,
                label: "SETTINGS",
                active: false,
                color: primaryColor,
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => const SettingsView()),
                //   );
                // },
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
  final Color color;
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
    final itemColor = active ? color : Colors.grey[400]!;

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