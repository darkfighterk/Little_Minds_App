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
import 'puzzle_list_screen.dart';
import 'create_puzzle_screen.dart';
import 'admin_view.dart';
import 'package:mind_app/widgets/mindie_button.dart';
import 'package:mind_app/views/crossword_list_view.dart';

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
<<<<<<< Updated upstream
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: mainBlue.withOpacity(0.1),
                  child: Icon(Icons.person_rounded, color: mainBlue, size: 28),
=======
              GestureDetector(
                onTap: _goToProfile,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFF3AAFFF).withValues(alpha: 0.1),
                    backgroundImage: _currentUser.photoUrl != null &&
                            _currentUser.photoUrl!.isNotEmpty
                        ? NetworkImage(_currentUser.photoUrl!)
                        : null,
                    child: _currentUser.photoUrl == null ||
                            _currentUser.photoUrl!.isEmpty
                        ? const Icon(Icons.person_rounded,
                            color: Color(0xFF3AAFFF), size: 28)
                        : null,
                  ),
>>>>>>> Stashed changes
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Little Minds',
                style: const TextStyle(
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
          Text(
            'Browse your\nadventure!',
            style: const TextStyle(
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
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 25),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
<<<<<<< Updated upstream
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
=======
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
>>>>>>> Stashed changes
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search adventure...',
                hintStyle: GoogleFonts.nunito(
<<<<<<< Updated upstream
                    color: Colors.grey[400], fontWeight: FontWeight.bold),
=======
                    color: isDark ? Colors.white38 : Colors.grey[400],
                    fontWeight: FontWeight.bold),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 22,
      crossAxisSpacing: 22,
=======
    final List<Map<String, dynamic>> allButtons = [
      {
        'title': 'Quiz Arena',
        'icon': Icons.quiz_rounded,
        'color': secondaryPurple,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => HomeView(user: widget.user))),
      },
      {
        'title': 'Note Scanner',
        'icon': Icons.document_scanner_rounded,
        'color': secondaryOrange,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TextFromImagePage())),
      },
      {
        'title': 'Story Time',
        'icon': Icons.menu_book_rounded,
        'color': secondaryYellow,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StoryTimePage(user: widget.user))),
      },
      {
        'title': 'Drawing',
        'icon': Icons.brush_rounded,
        'color': mainBlue,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const DrawingPadView())),
      },
      {
        'title': 'Puzzles',
        'icon': Icons.extension_rounded,
        'color': const Color(0xFF26A69A), // Teal
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PuzzlesListView(user: widget.user))),
      },
      {
        'title': 'Crossword',
        'icon': Icons.grid_on_rounded,
        'color': const Color(0xFF8E24AA),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CrosswordListView(user: widget.user),
            ),
          );
        },
      },
    ];

    final filteredButtons = allButtons
        .where((btn) =>
            btn['title'].toString().toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredButtons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No adventures found!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 22,
        crossAxisSpacing: 22,
        childAspectRatio: 0.82,
      ),
>>>>>>> Stashed changes
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
        _buildRefCard(
            'Crossword',
            Icons.grid_on_rounded,
            const Color(0xFF6C63FF),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PuzzleListScreen()))),
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
          color: accentColor.withOpacity(0.12),
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
              Text('Admin Tools 🛠️',
                  style: const TextStyle(
                      fontFamily: 'Recoleta',
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
<<<<<<< Updated upstream
              _buildAdminTile('Quiz Admin', Icons.quiz_rounded, mainBlue, () {
=======
              _buildAdminTile('Admin Control Panel',
                  Icons.admin_panel_settings_rounded, mainBlue, () {
>>>>>>> Stashed changes
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminGateView()));
              }),
              _buildAdminTile(
                  'Crossword Admin', Icons.grid_4x4_rounded, secondaryPurple,
                  () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminGateScreen()));
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color)),
      title:
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
