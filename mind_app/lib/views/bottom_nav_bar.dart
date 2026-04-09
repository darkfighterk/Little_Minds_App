import 'package:flutter/material.dart';
import 'settings_view.dart';
import '../views/library_view.dart';
import '../models/user_model.dart';

class BottomNavBar extends StatelessWidget {
  final Color primaryColor;
  final bool isDark;
  final User user;

  const BottomNavBar({
    super.key,
    required this.primaryColor,
    required this.isDark,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainBlue = Color(0xFF3AAFFF);

    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _NavItem(
              icon: Icons.home_rounded,
              active: true,
              color: mainBlue,
            ),
            _NavItem(
              icon: Icons.menu_book_rounded,
              active: false,
              color: mainBlue,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LibraryView(user: user)),
                );
              },
            ),
            const _NavItem(
              icon: Icons.timer_outlined,
              active: false,
              color: mainBlue,
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              active: false,
              color: mainBlue,
              onTap: () {
                if (true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsView()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        color: active ? color : Colors.blueGrey[100],
        size: 32,
      ),
    );
  }
}
