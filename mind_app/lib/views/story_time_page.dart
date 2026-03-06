// ============================================================
// story_time_page.dart
// Place in: lib/views/story_time_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/story_service.dart';
import 'bottom_nav_bar.dart';
import 'story_reader_page.dart';

// One accent color per card — cycles for variety
const List<Color> _cardColors = [
  Color(0xFFEC407A),
  Color(0xFF42A5F5),
  Color(0xFF66BB6A),
  Color(0xFF26C6DA),
  Color(0xFF8B2FC9),
  Color(0xFFFF7043),
  Color(0xFFFFB74D),
  Color(0xFF26A69A),
];

Color _colorForIndex(int i) => _cardColors[i % _cardColors.length];

// =====================================================================
// Story Time Page
// =====================================================================

class StoryTimePage extends StatefulWidget {
  final User user;
  const StoryTimePage({required this.user, super.key});

  @override
  State<StoryTimePage> createState() => _StoryTimePageState();
}

class _StoryTimePageState extends State<StoryTimePage> {
  static const Color _accent = Color(0xFFFFB74D);

  List<Story> _stories = [];
  bool _loading = true;
  String? _error;

  String _selectedDifficulty = 'All';
  static const List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() { _loading = true; _error = null; });
    try {
      final stories = await StoryService.getStories(
        difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
      );
      if (mounted) setState(() { _stories = stories; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load stories. Please try again.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildFilterRow(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(primaryColor: _accent, isDark: true),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFB74D)],
                  ).createShader(bounds),
                  child: Text(
                    'Story Time 📖',
                    style: GoogleFonts.fredoka(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Pick a story and start reading!',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadStories,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _difficulties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = _difficulties[i];
          final active = _selectedDifficulty == d;
          return GestureDetector(
            onTap: () {
              if (_selectedDifficulty != d) {
                setState(() => _selectedDifficulty = d);
                _loadStories();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? _accent : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _accent : Colors.white24, width: 1.5),
              ),
              child: Text(
                d,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: active ? Colors.white : Colors.white60,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFFFB74D)),
            const SizedBox(height: 16),
            Text('Loading stories…',
                style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(color: Colors.white54, fontSize: 15)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadStories,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Try Again', style: GoogleFonts.fredoka(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              _selectedDifficulty == 'All'
                  ? 'No stories yet.\nAsk your admin to add some!'
                  : 'No $_selectedDifficulty stories yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(color: Colors.white54, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.78,
      ),
      itemCount: _stories.length,
      itemBuilder: (context, i) => _StoryCard(
        story: _stories[i],
        color: _colorForIndex(i),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryReaderPage(storyId: _stories[i].id, user: widget.user),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Story Card widget
// =====================================================================

class _StoryCard extends StatelessWidget {
  final Story story;
  final Color color;
  final VoidCallback onTap;

  const _StoryCard({required this.story, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 18, offset: const Offset(0, 10)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image or emoji
              if (story.coverUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: Image.network(
                      story.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Center(child: Text(story.coverEmoji, style: const TextStyle(fontSize: 44))),
                    ),
                  ),
                )
              else
                Text(story.coverEmoji, style: const TextStyle(fontSize: 44)),

              const SizedBox(height: 8),
              Text(
                story.title,
                style: GoogleFonts.fredoka(
                    fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  story.description,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Chip(label: story.pageCount > 0 ? '${story.pageCount}p' : '—', icon: Icons.book_outlined),
                  const SizedBox(width: 6),
                  _Chip(label: story.difficulty, icon: Icons.bar_chart_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}