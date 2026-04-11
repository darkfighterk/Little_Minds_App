import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../models/user_model.dart';

class BottomNavBar extends StatelessWidget {
  final Color primaryColor;
  final bool isDark;
  final User user;
  final int currentIndex;
  final Function(int)? onTabSelected;

  const BottomNavBar({
    super.key,
    required this.primaryColor,
    required this.isDark,
    required this.user,
    this.currentIndex = 0,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainBlue = Color(0xFF3AAFFF);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glassmorphism effect background
          ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1E1E1E).withValues(alpha: 0.85) 
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.1) 
                          : Colors.white.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  active: currentIndex == 0,
                  color: mainBlue,
                  label: "Home",
                  onTap: () => onTabSelected?.call(0),
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  active: currentIndex == 1,
                  color: mainBlue,
                  label: "Library",
                  onTap: () => onTabSelected?.call(1),
                ),
                _NavItem(
                  icon: Icons.auto_awesome_rounded,
                  active: currentIndex == 2,
                  color: mainBlue,
                  label: "Magic",
                  onTap: () => onTabSelected?.call(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  active: currentIndex == 3,
                  color: mainBlue,
                  label: "Profile",
                  onTap: () => onTabSelected?.call(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.color,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? color.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: active 
                      ? color 
                      : (isDark ? Colors.white24 : Colors.black38),
                  size: 28,
                ),
                if (active) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
