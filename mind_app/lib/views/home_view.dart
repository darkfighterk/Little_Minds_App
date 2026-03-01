// lib/views/home_view.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/admin_service.dart';
import 'level_map_view.dart';
import 'bottom_nav_bar.dart';
import 'chat_screen.dart';

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
  final Map<String, int> _totalLevelCounts = {};

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    for (final s in GameData.subjects) {
      _totalLevelCounts[s.id] = s.levels.length;
    }

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
                s['gradient_start'] as String? ?? '#4FC3F7',
                s['gradient_end'] as String? ?? '#0288D1',
              ],
              levels: const [],
            ))
        .toList();

    if (!mounted) return;

    setState(() => _adminSubjects = newSubjects);

    for (final subject in newSubjects) {
      final levels = await _adminService.getLevels(subject.id);
      if (!mounted) return;
      setState(() => _totalLevelCounts[subject.id] = levels.length);
    }

    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    final allSubjects = [...GameData.subjects, ..._adminSubjects];

    for (final subject in allSubjects) {
      final result = await _gameService.fetchProgress(subject.id);

      final totalLevels =
          _totalLevelCounts[subject.id] ?? subject.levels.length;

      final progressRatio =
          totalLevels == 0 ? 0.0 : result.completedLevels.length / totalLevels;

      if (!mounted) return;

      setState(() {
        _progress[subject.id] = progressRatio.clamp(0.0, 1.0);
        _stars[subject.id] = result.stars;
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildChatButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
      bottomNavigationBar: const BottomNavBar(
        primaryColor: Color(0xFFFFD700),
        isDark: true,
      ),
    );
  }

  Widget _buildChatButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ChatScreen(),
          ),
        );
      },
      child: Container(
        height: 85,
        width: 85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 65,
              width: 65,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF00E5FF),
                    Color(0xFF1DE9B6),
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/images/mindie.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D1B69),
            Color(0xFF1A0A3D),
            Color(0xFF0D0520),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildSubjectGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalStars = _stars.values.fold(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your',
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Adventure!',
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _floatController,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, sin(_floatController.value * pi) * 4),
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('⭐'),
                      const SizedBox(width: 6),
                      Text(
                        '$totalStars Stars',
                        style: GoogleFonts.fredoka(
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid() {
    return RefreshIndicator(
      onRefresh: _loadAdminSubjects,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SubjectCard(
                    subject: GameData.subjects[0],
                    progress: _progress[GameData.subjects[0].id] ?? 0,
                    floatController: _floatController,
                    onTap: () => _openSubject(GameData.subjects[0]),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SubjectCard(
                    subject: GameData.subjects[1],
                    progress: _progress[GameData.subjects[1].id] ?? 0,
                    floatController: _floatController,
                    onTap: () => _openSubject(GameData.subjects[1]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSubject(Subject subject) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelMapView(
          subject: subject,
          user: widget.user,
        ),
      ),
    );

    if (mounted) {
      await _loadProgress();
    }
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final double progress;
  final AnimationController floatController;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.progress,
    required this.floatController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: floatController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, sin((floatController.value + 0.2) * pi) * 3),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                subject.emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 12),
              Text(
                subject.name,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  color: Color(0xFF3A1C72),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
