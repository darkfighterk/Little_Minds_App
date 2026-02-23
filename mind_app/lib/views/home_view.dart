// ============================================================
// home_view.dart  (FIXED — progress bar + admin level counts)
// Place in: lib/views/home_view.dart
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/admin_service.dart';
import 'level_map_view.dart';
import 'admin_view.dart';
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
  late AnimationController _starController;

  final Map<String, double> _progress = {};
  final Map<String, int> _stars = {};
  final Map<String, int> _totalLevelCounts = {};

  int _navIndex = 0;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

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
      if (mounted) {
        setState(() => _totalLevelCounts[subject.id] = levels.length);
      }
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

      if (mounted) {
        setState(() {
          _progress[subject.id] = progressRatio.clamp(0.0, 1.0);
          _stars[subject.id] = result.stars;
        });
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── UPDATED: Playful Mindie Robot Floating Action Button ──
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
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
              // Background Glow
              Container(
                height: 65,
                width: 65,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF1DE9B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Mindie Image
              Image.asset(
                'assets/images/mindie.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1B69), Color(0xFF1A0A3D), Color(0xFF0D0520)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildSubjectGrid(),
              ),
              _buildBottomNav(),
            ],
          ),
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
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Adventure!',
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      color: const Color(0xFFFFD700),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, sin(_floatController.value * pi) * 4),
                    child: child,
                  );
                },
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
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        '$totalStars Stars',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Continue your learning journey!',
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDecoStars(),
        ],
      ),
    );
  }

  Widget _buildDecoStars() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final offset = sin((_floatController.value + i * 0.2) * pi) * 3;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Icon(
                  Icons.star_rounded,
                  size: 14 + (i % 3) * 4.0,
                  color: const Color(0xFFFFD700).withOpacity(0.5 + i * 0.1),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSubjectGrid() {
    return RefreshIndicator(
      color: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF2D1B69),
      onRefresh: () async {
        await _loadAdminSubjects();
      },
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
                    stars: _stars[GameData.subjects[0].id] ?? 0,
                    floatController: _floatController,
                    onTap: () => _openSubject(GameData.subjects[0]),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SubjectCard(
                    subject: GameData.subjects[1],
                    progress: _progress[GameData.subjects[1].id] ?? 0,
                    stars: _stars[GameData.subjects[1].id] ?? 0,
                    floatController: _floatController,
                    onTap: () => _openSubject(GameData.subjects[1]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SubjectCardWide(
              subject: GameData.subjects[2],
              progress: _progress[GameData.subjects[2].id] ?? 0,
              stars: _stars[GameData.subjects[2].id] ?? 0,
              floatController: _floatController,
              onTap: () => _openSubject(GameData.subjects[2]),
            ),
            if (_adminSubjects.isNotEmpty) ...[
              const SizedBox(height: 14),
              ..._buildAdminSubjectRows(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAdminSubjectRows() {
    final rows = <Widget>[];
    for (int i = 0; i < _adminSubjects.length; i += 2) {
      final hasSecond = i + 1 < _adminSubjects.length;
      rows.add(Row(children: [
        Expanded(
          child: _SubjectCard(
            subject: _adminSubjects[i],
            progress: _progress[_adminSubjects[i].id] ?? 0,
            stars: _stars[_adminSubjects[i].id] ?? 0,
            floatController: _floatController,
            onTap: () => _openSubject(_adminSubjects[i]),
          ),
        ),
        if (hasSecond) ...[
          const SizedBox(width: 14),
          Expanded(
            child: _SubjectCard(
              subject: _adminSubjects[i + 1],
              progress: _progress[_adminSubjects[i + 1].id] ?? 0,
              stars: _stars[_adminSubjects[i + 1].id] ?? 0,
              floatController: _floatController,
              onTap: () => _openSubject(_adminSubjects[i + 1]),
            ),
          ),
        ] else
          const Expanded(child: SizedBox()),
      ]));
      if (i + 2 < _adminSubjects.length) rows.add(const SizedBox(height: 14));
    }
    return rows;
  }

  void _openSubject(Subject subject) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => LevelMapView(
          subject: subject,
          user: widget.user,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
    if (mounted) await _loadProgress();
  }

  void _openAdmin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminGateView()),
    );
    if (mounted) {
      await _loadAdminSubjects();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: _navIndex == 0,
                onTap: () => setState(() => _navIndex = 0),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
                selected: _navIndex == 1,
                onTap: () => setState(() => _navIndex = 1),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: _navIndex == 2,
                onTap: () => setState(() => _navIndex = 2),
              ),
              _NavItem(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admin',
                selected: _navIndex == 3,
                onTap: _openAdmin,
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
  final int stars;
  final AnimationController floatController;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.progress,
    required this.stars,
    required this.floatController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = (subject.id == 'science')
        ? const Color(0xFF4FC3F7)
        : (subject.id == 'biology'
            ? const Color(0xFF81C784)
            : const Color(0xFFFFB74D));
    Color progressColor = (subject.id == 'science')
        ? const Color(0xFF29B6F6)
        : (subject.id == 'biology'
            ? const Color(0xFF66BB6A)
            : const Color(0xFFFFA726));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: floatController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, sin((floatController.value + 0.2) * pi) * 3),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor.withOpacity(0.15),
                ),
                child: Center(
                  child: Text(
                    subject.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subject.name,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  color: const Color(0xFF3A1C72),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).round()}% Complete',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectCardWide extends StatelessWidget {
  final Subject subject;
  final double progress;
  final int stars;
  final AnimationController floatController;
  final VoidCallback onTap;

  const _SubjectCardWide({
    required this.subject,
    required this.progress,
    required this.stars,
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF29B6F6),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF29B6F6).withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF29B6F6).withOpacity(0.15),
                ),
                child: Center(
                  child: Text(
                    subject.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        color: const Color(0xFF3A1C72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF29B6F6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(progress * 100).round()}% Complete',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF29B6F6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C3AED);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: selected ? purple : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: selected ? purple : Colors.grey[400],
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
