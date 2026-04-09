import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'main_home_view.dart';
import 'library_view.dart';
import 'settings_view.dart';
import 'bottom_nav_bar.dart';

class MainTabView extends StatefulWidget {
  final User user;
  const MainTabView({super.key, required this.user});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Magic View placeholder
    const Widget magicPlaceholder = Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 80, color: Color(0xFF3AAFFF)),
            SizedBox(height: 20),
            Text(
              "Magic Coming Soon ✨",
              style: TextStyle(
                fontFamily: 'Recoleta',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    _pages = [
      HomePage(user: widget.user),
      LibraryView(user: widget.user),
      magicPlaceholder,
      SettingsView(user: widget.user),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // IMPORTANT: Lets content flow beautifully behind the navbar
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        primaryColor: const Color(0xFF3AAFFF),
        isDark: false,
        user: widget.user,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
