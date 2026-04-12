import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/admin_service.dart';
import 'level_map_view.dart';
import 'puzzles_list_view.dart';

// ── Same brand palette as login/signup ──
const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class QuizArenaView extends StatefulWidget {
  final User user;
  const QuizArenaView({required this.user, super.key});

  @override
  State<QuizArenaView> createState() => _QuizArenaViewState();
}

class _QuizArenaViewState extends State<QuizArenaView> with TickerProviderStateMixin {
  final GameService _gameService = GameService();
  final AdminService _adminService = AdminService();
  List<Subject> _subjects = [];
  bool _isLoading = true;

  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  final Map<String, double> _progress = {};
  final Map<String, int> _stars = {};

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final data = await _adminService.getSubjects();
    
    final fetchedSubjects = data.map((s) {
      final levelCount = (s['level_count'] as num?)?.toInt() ?? 0;
      return Subject(
        id: s['id'] as String,
        name: s['name'] as String,
        emoji: s['emoji'] as String? ?? '📚',
        gradientColors: [
          s['gradient_start'] as String? ?? '#3AAFFF',
          s['gradient_end'] as String? ?? '#A55FEF',
        ],
        levels: List.generate(levelCount, (i) => const GameLevel(levelNumber: 0, title: '', icon: '', starsRequired: 0, questions: [])), 
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      _subjects = fetchedSubjects;
      _isLoading = false;
    });
    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    for (final subject in _subjects) {
      final result = await _gameService.fetchProgress(subject.id);
      if (!mounted) return;
      setState(() {
        final totalLevels = subject.levels.length;
        _progress[subject.id] = totalLevels == 0
            ? 0.0
            : (result.completedLevels.length / totalLevels).clamp(0.0, 1.0);
        _stars[subject.id] = result.stars;
      });
    }
  }

  void _startQuiz(Subject subject) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelMapView(subject: subject, user: widget.user),
      ),
    );
    if (mounted) _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    final totalStars = _stars.values.fold(0, (a, b) => a + b);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // ── Ambient blobs (match login) ──
          _AmbientBlobs(isDark: isDark),

          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    _buildHeader(totalStars, isDark),
                    Expanded(child: _buildSubjectGrid(isDark)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(int stars, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back button matching login style
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Arena 🏆',
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Pick a topic to start!',
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _buildStarBadge(stars),
        ],
      ),
    );
  }

  Widget _buildStarBadge(int stars) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, sin(_floatController.value * pi) * 3),
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              sunnyYellow.withValues(alpha: 0.25),
              accentOrange.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: sunnyYellow.withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: sunnyYellow.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.stars_rounded, color: accentOrange, size: 20),
            const SizedBox(width: 5),
            Text(
              '$stars',
              style: GoogleFonts.fredoka(
                color: accentOrange,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subject Grid ──
  Widget _buildSubjectGrid(bool isDark) {

    return RefreshIndicator(
      onRefresh: _loadSubjects,
      color: mainBlue,
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: mainBlue))
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              // ── Section label ──
              _SectionLabel(label: 'Subjects', isDark: isDark),
              const SizedBox(height: 14),

              // ── Dynamic Grid of all subjects ──
              _subjects.isEmpty 
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No quizzes found. Check Admin Panel!', 
                      style: GoogleFonts.nunito(color: isDark ? Colors.white38 : Colors.black38)),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _subjects.length,
                    itemBuilder: (ctx, i) {
                      final subject = _subjects[i];
                      return _SubjectCard(
                        subject: subject,
                        progress: _progress[subject.id] ?? 0,
                        stars: _stars[subject.id] ?? 0,
                        floatController: _floatController,
                        phaseOffset: i * 0.15,
                        isDark: isDark,
                        onTap: () => _startQuiz(subject),
                      );
                    },
                  ),

              const SizedBox(height: 30),
              _SectionLabel(label: 'Challenges', isDark: isDark),
              const SizedBox(height: 14),

              // ── Puzzles Card ──
              _PuzzlesCard(
                floatController: _floatController,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PuzzlesListView(user: widget.user),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }
}

// ─────────────── Section Label ───────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
        color: isDark ? Colors.white38 : Colors.black.withValues(alpha: 0.35),
      ),
    );
  }
}

// ─────────────── Subject Card (2-col) ───────────────

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final double progress;
  final int stars;
  final AnimationController floatController;
  final double phaseOffset;
  final bool isDark;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.progress,
    required this.stars,
    required this.floatController,
    required this.phaseOffset,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: floatController,
        builder: (_, child) => Transform.translate(
          offset:
              Offset(0, sin((floatController.value + phaseOffset) * pi) * 4),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : mainBlue.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : mainBlue.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Emoji in a gradient bubble
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      mainBlue.withValues(alpha: isDark ? 0.25 : 0.12),
                      secondaryPurple.withValues(alpha: isDark ? 0.2 : 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child:
                      Text(subject.emoji, style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subject.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              // Stars row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars_rounded, color: sunnyYellow, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '$stars',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: mainBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor:
                          mainBlue.withValues(alpha: isDark ? 0.15 : 0.10),
                      valueColor: const AlwaysStoppedAnimation(mainBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────── Puzzles Card ───────────────

class _PuzzlesCard extends StatelessWidget {
  final AnimationController floatController;
  final bool isDark;
  final VoidCallback onTap;

  const _PuzzlesCard({
    required this.floatController,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: floatController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, sin((floatController.value + 0.5) * pi) * 3),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [secondaryPurple, mainBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: secondaryPurple.withValues(alpha: isDark ? 0.25 : 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon bubble
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🧩', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brain Puzzles',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sharpen your mind!',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────── Ambient Blobs (match login) ───────────────

class _AmbientBlobs extends StatelessWidget {
  final bool isDark;
  const _AmbientBlobs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? mainBlue.withValues(alpha: 0.05)
                  : mainBlue.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          bottom: h * 0.1,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? secondaryPurple.withValues(alpha: 0.05)
                  : secondaryPurple.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          top: h * 0.45,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? accentOrange.withValues(alpha: 0.04)
                  : accentOrange.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: h * 0.25,
          right: w * 0.12,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? sunnyYellow.withValues(alpha: 0.15)
                  : sunnyYellow.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }
}
