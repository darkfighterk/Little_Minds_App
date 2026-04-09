import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_app/views/text_to_image.dart';
import '../models/user_model.dart';
import 'home_view.dart';
import 'bottom_nav_bar.dart';
import 'puzzles_list_view.dart';
import 'story_time_page.dart';
import 'drawing_pad_view.dart';
import 'admin_view.dart';
import 'package:mind_app/widgets/mindie_button.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _floatController;

  final Color mainBlue = const Color(0xFF3AAFFF);
  final Color secondaryPurple = const Color(0xFFA55FEF);
  final Color secondaryOrange = const Color(0xFFFF8811);
  final Color secondaryYellow = const Color(0xFFFDDF50);

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Header Blue Section (Reference style) ──
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            decoration: BoxDecoration(
              color: mainBlue,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(45)),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildSearchAndFilters(),
                const SizedBox(height: 25),
                // ── White Background Body (Reference style) ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(45)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 35, 20, 100),
                      child: _buildMainButtonsGrid(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        user: widget.user,
        primaryColor: mainBlue,
        isDark: false,
      ),
      floatingActionButton: const MindieButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Section or App Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF3AAFFF).withValues(alpha: 0.1),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF3AAFFF), size: 28),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Little Minds',
                style: TextStyle(
                  fontFamily: 'Recoleta',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Settings button
          IconButton(
            onPressed: _showSettingsSheet,
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse your\nadventure!',
            style: TextStyle(
              fontFamily: 'Recoleta',
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hi ${widget.user.name}, pick a fun activity! ✨',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 25),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search adventure...',
                hintStyle: GoogleFonts.nunito(
                    color: Colors.grey[400], fontWeight: FontWeight.bold),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: mainBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButtonsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 22,
      crossAxisSpacing: 22,
      shrinkWrap: true,
      childAspectRatio: 0.82,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildRefCard(
            'Quiz Arena',
            Icons.quiz_rounded,
            secondaryPurple,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HomeView(user: widget.user)))),
        _buildRefCard(
            'Magic Art',
            Icons.image_rounded,
            secondaryOrange,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TextFromImagePage()))),
        _buildRefCard(
            'Story Time',
            Icons.menu_book_rounded,
            secondaryYellow,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StoryTimePage(user: widget.user)))),
        _buildRefCard(
            'Drawing',
            Icons.brush_rounded,
            mainBlue,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DrawingPadView()))),
        _buildRefCard(
            'Puzzles',
            Icons.extension_rounded,
            Colors.teal[400]!,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PuzzlesListView(user: widget.user)))),
      ],
    );
  }

  Widget _buildRefCard(
      String title, IconData icon, Color accentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            // Arch-style Image container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(100),
                    bottom: Radius.circular(25),
                  ),
                ),
                child: Icon(icon, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Recoleta',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
              ),
            ),
            Text(
              'Explore',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('Admin Tools 🛠️',
                  style: TextStyle(
                      fontFamily: 'Recoleta',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildAdminTile('Admin Control Panel', Icons.admin_panel_settings_rounded, mainBlue, () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminGateView()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminTile(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color)),
      title:
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
