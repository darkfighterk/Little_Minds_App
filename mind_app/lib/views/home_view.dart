import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/admin_service.dart';
import 'quiz_view.dart';
import 'level_map_view.dart';
import 'puzzles_list_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class HomeView extends StatefulWidget {
  final User user;
  const HomeView({required this.user, super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final GameService _gameService = GameService();
  final AdminService _adminService = AdminService();
  List<Subject> _adminSubjects = [];
  late AnimationController _floatController;

  final Map<String, double> _progress = {};
  final Map<String, int> _stars = {};

  @override
  void initState() {
    super.initState();
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _loadAdminSubjects();
  }

  Future<void> _loadAdminSubjects() async {
    final data = await _adminService.getSubjects();
    final builtInIds = GameData.subjects.map((s) => s.id).toSet();
    final newSubjects = data
        .where((s) => !builtInIds.contains(s['id'] as String))
        .map((s) => Subject(
              id: s['id'] as String,
              name: s['name'] as String,
              emoji: s['emoji'] as String? ?? '📚',
              gradientColors: [
                s['gradient_start'] as String? ?? '#3AAFFF',
                s['gradient_end'] as String? ?? '#A55FEF'
              ],
              levels: const [],
            ))
        .toList();

    if (!mounted) return;
    setState(() => _adminSubjects = newSubjects);
    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    final allSubjects = [...GameData.subjects, ..._adminSubjects];
    for (final subject in allSubjects) {
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
    if (subject.levels.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizView(
            subject: subject,
            level: subject.levels[0],
            user: widget.user,
          ),
        ),
      );
      if (mounted) _loadProgress();
    } else {
      // For admin subjects without predefined levels, go to level map
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LevelMapView(subject: subject, user: widget.user)));
      if (mounted) _loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStars = _stars.values.fold(0, (a, b) => a + b);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [mainBlue.withValues(alpha: 0.08), Colors.white])),
        child: SafeArea(
          child: Column(children: [
            _buildHeader(totalStars),
            Expanded(child: _buildSubjectGrid()),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(int stars) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87)),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Quiz Arena 🏆',
              style: TextStyle(
                  fontFamily: 'Recoleta',
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          Text('Pick a topic to start Quiz!',
              style: GoogleFonts.nunito(
                  color: Colors.black45, fontWeight: FontWeight.w700)),
        ])),
        _buildStarBadge(stars),
      ]),
    );
  }

  Widget _buildStarBadge(int stars) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) => Transform.translate(
          offset: Offset(0, sin(_floatController.value * pi) * 3),
          child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: sunnyYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sunnyYellow)),
        child: Row(children: [
          const Icon(Icons.stars_rounded, color: accentOrange, size: 20),
          const SizedBox(width: 5),
          Text('$stars',
              style: const TextStyle(
                  color: accentOrange, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildSubjectGrid() {
    return RefreshIndicator(
      onRefresh: _loadAdminSubjects,
      color: mainBlue,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Row(children: [
            Expanded(
                child: _SubjectCard(
                    subject: GameData.subjects[0],
                    progress: _progress[GameData.subjects[0].id] ?? 0,
                    floatController: _floatController,
                    onTap: () => _startQuiz(GameData.subjects[0]))),
            const SizedBox(width: 15),
            Expanded(
                child: _SubjectCard(
                    subject: GameData.subjects[1],
                    progress: _progress[GameData.subjects[1].id] ?? 0,
                    floatController: _floatController,
                    onTap: () => _startQuiz(GameData.subjects[1]))),
          ]),
          const SizedBox(height: 15),
          _PuzzlesCard(
              floatController: _floatController,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PuzzlesListView(user: widget.user)))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final double progress;
  final AnimationController floatController;
  final VoidCallback onTap;
  const _SubjectCard(
      {required this.subject,
      required this.progress,
      required this.floatController,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: floatController,
        builder: (_, child) => Transform.translate(
            offset: Offset(0, sin((floatController.value + 0.2) * pi) * 4),
            child: child),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: mainBlue.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8))
            ],
            border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
          ),
          child: Column(children: [
            Text(subject.emoji, style: const TextStyle(fontSize: 45)),
            const SizedBox(height: 12),
            Text(subject.name,
                style: const TextStyle(
                    fontFamily: 'Recoleta',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: mainBlue.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(mainBlue))),
          ]),
        ),
      ),
    );
  }
}

class _PuzzlesCard extends StatelessWidget {
  final AnimationController floatController;
  final VoidCallback onTap;
  const _PuzzlesCard({required this.floatController, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [secondaryPurple, mainBlue]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: mainBlue.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15)),
              child: const Text('🧩', style: TextStyle(fontSize: 30))),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Brain Puzzles',
                    style: TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text('Sharpen your mind!',
                    style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ])),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white70, size: 18),
        ]),
      ),
    );
  }
}
