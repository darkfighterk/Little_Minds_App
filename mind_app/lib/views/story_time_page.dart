import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/story_service.dart';
import 'bottom_nav_bar.dart';
import 'story_reader_page.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

const List<Color> _brandCycle = [
  mainBlue,
  secondaryPurple,
  accentOrange,
  sunnyYellow
];

class StoryTimePage extends StatefulWidget {
  final User user;
  const StoryTimePage({required this.user, super.key});

  @override
  State<StoryTimePage> createState() => _StoryTimePageState();
}

class _StoryTimePageState extends State<StoryTimePage> {
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

  // ──  Core Logic (Identical to your version) ──
  Future<void> _loadStories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stories = await StoryService.getStories(
        difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
      );
      if (mounted)
        setState(() {
          _stories = stories;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Could not load stories. Please try again.';
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withOpacity(0.08), Colors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(),
              _buildDifficultyFilters(),
              Expanded(child: _buildStoryGrid()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(primaryColor: mainBlue, isDark: false),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Story Time 📖',
                    style: TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text('Pick a magic book to read!',
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.black45,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
              onPressed: _loadStories,
              icon:
                  const Icon(Icons.refresh_rounded, color: mainBlue, size: 28)),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilters() {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _difficulties.length,
        itemBuilder: (context, i) {
          final d = _difficulties[i];
          final bool active = _selectedDifficulty == d;
          return GestureDetector(
            onTap: () {
              if (!active) {
                setState(() => _selectedDifficulty = d);
                _loadStories();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: active ? mainBlue : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: active ? mainBlue : mainBlue.withOpacity(0.1),
                    width: 2),
                boxShadow: active
                    ? [
                        BoxShadow(
                            color: mainBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Center(
                child: Text(d,
                    style: GoogleFonts.nunito(
                        color: active ? Colors.white : mainBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 13)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryGrid() {
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: mainBlue));
    if (_error != null) return _buildErrorState();
    if (_stories.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.72,
      ),
      itemCount: _stories.length,
      itemBuilder: (context, i) => _StoryCard(
        story: _stories[i],
        cardColor: _brandCycle[i % _brandCycle.length],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StoryReaderPage(
                    storyId: _stories[i].id, user: widget.user))),
      ),
    );
  }

  Widget _buildErrorState() => Center(
      child: Text(_error!,
          style:
              const TextStyle(fontFamily: 'Recoleta', color: Colors.black38)));
  Widget _buildEmptyState() => const Center(
      child: Text("No stories found here yet! 📚",
          style: TextStyle(fontFamily: 'Recoleta', color: Colors.black38)));
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final Color cardColor;
  final VoidCallback onTap;
  const _StoryCard(
      {required this.story, required this.cardColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: cardColor.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
          border: Border.all(color: cardColor.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.08),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Center(
                  child: story.coverUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(25)),
                          child: Image.network(story.coverUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity))
                      : Text(story.coverEmoji,
                          style: const TextStyle(fontSize: 50)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Recoleta',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _Badge(label: "${story.pageCount}p", color: cardColor),
                      const SizedBox(width: 5),
                      _Badge(label: story.difficulty, color: Colors.black26),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: color == Colors.black26 ? Colors.black45 : color,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }
}
