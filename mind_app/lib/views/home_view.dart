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
import 'puzzles_list_view.dart';

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

    final List<Subject> newSubjects = [];
    
    for (var s in data) {
      final id = s['id'] as String;
      if (builtInIds.contains(id)) continue;

      // Fetch levels to populate the Subject object properly
      final levelData = await _adminService.getLevels(id);
      
      newSubjects.add(Subject(
        id: id,
        name: s['name'] as String,
        emoji: s['emoji'] as String? ?? '📚',
        gradientColors: [
          s['gradient_start'] as String? ?? '#4FC3F7',
          s['gradient_end'] as String? ?? '#0288D1',
        ],
        // Note: Full level/question data is loaded by LevelMapView/QuizView 
        // using AdminService. Here we just need the count for progress calculation.
        levels: List.generate(levelData.length, (index) => GameLevel(
          levelNumber: index + 1,
          title: '',
          icon: '',
          starsRequired: 0,
          questions: [],
        )),
      ));
      
      if (mounted) {
        setState(() => _totalLevelCounts[id] = levelData.length);
      }
    }

    if (!mounted) return;

    setState(() => _adminSubjects = newSubjects);
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
    final allSubjects = [...GameData.subjects, ..._adminSubjects];

    return RefreshIndicator(
      onRefresh: _loadAdminSubjects,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: allSubjects.length,
              itemBuilder: (context, index) {
                final subject = allSubjects[index];
                return _SubjectCard(
                  subject: subject,
                  progress: _progress[subject.id] ?? 0,
                  floatController: _floatController,
                  onTap: () => _openSubject(subject),
                );
              },
            ),
            const SizedBox(height: 14),
            _PuzzlesCard(
              floatController: _floatController,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PuzzlesListView(user: widget.user),
                  ),
                );
              },
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

class _PuzzlesCard extends StatelessWidget {
  final AnimationController floatController;
  final VoidCallback onTap;

  const _PuzzlesCard({
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
          offset: Offset(0, sin((floatController.value + 0.5) * pi) * 3),
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🧩', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puzzles',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Challenge your brain!',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject.emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 12),
              Text(
                subject.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: const Color(0xFF3A1C72),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    subject.gradientColors.length > 1 
                      ? Color(int.parse(subject.gradientColors[1].replaceAll('#', '0xFF')))
                      : Colors.blue,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
