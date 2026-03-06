// ============================================================
// story_reader_page.dart
// Place in: lib/views/story_reader_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/story_service.dart';

class StoryReaderPage extends StatefulWidget {
  final int storyId;
  final User user;

  const StoryReaderPage({
    required this.storyId,
    required this.user,
    super.key,
  });

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage>
    with TickerProviderStateMixin {

  // ── Data ──────────────────────────────────────────────────────────
  StoryDetail? _detail;
  bool  _loading = true;
  String? _error;

  // ── Page state ────────────────────────────────────────────────────
  late PageController _pageCtrl;
  int _currentPage = 0;      // 0-indexed
  bool _finished   = false;

  // ── Animation ─────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _loadDetail();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────────

  Future<void> _loadDetail() async {
    setState(() { _loading = true; _error = null; });
    final detail = await StoryService.getStoryDetail(widget.storyId);
    if (!mounted) return;
    if (detail == null) {
      setState(() { _error = 'Could not load the story. Please try again.'; _loading = false; });
    } else {
      setState(() { _detail = detail; _loading = false; });
      _fadeCtrl.forward();
    }
  }

  // ── Navigation ────────────────────────────────────────────────────

  void _goToPage(int index) {
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    final total = _detail!.pages.length;
    if (_currentPage < total - 1) {
      HapticFeedback.lightImpact();
      _goToPage(_currentPage + 1);
    } else {
      setState(() => _finished = true);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _goToPage(_currentPage - 1);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0520),
      body: _loading
          ? _buildLoader()
          : _error != null
              ? _buildError()
              : _finished
                  ? _buildFinished()
                  : _buildReader(),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFFB74D)),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────

  Widget _buildError() {
    return SafeArea(
      child: Center(
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
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Try Again', style: GoogleFonts.fredoka(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back', style: GoogleFonts.nunito(color: Colors.white38)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Finished screen ───────────────────────────────────────────────

  Widget _buildFinished() {
    final story = _detail!.story;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0533), Color(0xFF2D0B5A), Color(0xFF1A0A3D)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(story.coverEmoji, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text('The End! 🎉',
                    style: GoogleFonts.fredoka(
                        fontSize: 36, color: const Color(0xFFFFD700), fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Text(
                  'You finished "${story.title}"!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Great job, ${widget.user.name}! 🌟',
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.white38),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _finished = false; _currentPage = 0; });
                    _pageCtrl.jumpToPage(0);
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: Text('Read Again', style: GoogleFonts.fredoka(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back to Stories',
                      style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main reader ───────────────────────────────────────────────────

  Widget _buildReader() {
    final story = _detail!.story;
    final pages = _detail!.pages;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0533), Color(0xFF2D0B5A), Color(0xFF2D1B69), Color(0xFF1A0A3D)],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildTopBar(story, pages.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) => _buildPageContent(pages[i]),
                ),
              ),
              _buildBottomNav(pages.length),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar: back + title + page counter ─────────────────────────

  Widget _buildTopBar(Story story, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              story.title,
              style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Progress pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1} / $total',
              style: GoogleFonts.fredoka(fontSize: 13, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress bar ─────────────────────────────────────────────────

  Widget _buildProgressBar(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: total > 0 ? (_currentPage + 1) / total : 0,
          minHeight: 4,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
        ),
      ),
    );
  }

  // ── Single page content ───────────────────────────────────────────

  Widget _buildPageContent(StoryPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page illustration
          if (page.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  page.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.white.withOpacity(0.05),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFFB74D), strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.05),
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white24, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Page title (optional)
          if (page.title.isNotEmpty) ...[
            Text(
              page.title,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Page body text
          Text(
            page.body,
            style: GoogleFonts.nunito(
              fontSize: 17,
              color: Colors.white.withOpacity(0.92),
              fontWeight: FontWeight.w500,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Bottom navigation bar ─────────────────────────────────────────

  Widget _buildBottomNav(int total) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressBar(total),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              // Previous
              AnimatedOpacity(
                opacity: _currentPage > 0 ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _currentPage > 0 ? _prevPage : null,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Dot indicators
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(total, (i) {
                      final active = i == _currentPage;
                      return GestureDetector(
                        onTap: () => _goToPage(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFFFB74D)
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Next / Finish
              GestureDetector(
                onTap: _nextPage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB74D).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage < total - 1 ? 'Next' : 'Finish',
                        style: GoogleFonts.fredoka(
                            fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _currentPage < total - 1
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}