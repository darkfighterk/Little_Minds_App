// ============================================================
// level_map_view.dart
// Place in: lib/views/level_map_view.dart
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/admin_service.dart';
import 'quiz_view.dart';

class LevelMapView extends StatefulWidget {
  final Subject subject;
  final User user;

  const LevelMapView({
    required this.subject,
    required this.user,
    super.key,
  });

  @override
  State<LevelMapView> createState() => _LevelMapViewState();
}

class _LevelMapViewState extends State<LevelMapView>
    with TickerProviderStateMixin {
  final GameService _gameService = GameService();
  final AdminService _adminService = AdminService();
  List<GameLevel> _dynamicLevels = [];

  int _totalStars = 0;
  List<int> _completedLevels = [];
  bool _loading = true;

  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadLevels();
    _loadProgress();
  }

  Future<void> _loadLevels() async {
    if (widget.subject.levels.isNotEmpty) return;
    final quiz = await _adminService.getFullQuiz(widget.subject.id);
    if (quiz == null || !mounted) return;
    final rawLevels = (quiz['levels'] as List<dynamic>?) ?? [];
    final levels = rawLevels.map((l) {
      final rawQs = (l['questions'] as List<dynamic>?) ?? [];
      final questions = rawQs
          .map((q) => QuizQuestion(
                question: q['question_text'] as String? ?? '',
                options: [
                  q['option_a'] as String? ?? '',
                  q['option_b'] as String? ?? '',
                  q['option_c'] as String? ?? '',
                  q['option_d'] as String? ?? '',
                ],
                correctIndex: (q['correct_index'] as num?)?.toInt() ?? 0,
                funFact: q['fun_fact'] as String?,
              ))
          .toList();
      return GameLevel(
        id: (l['id'] as num?)?.toInt(),
        levelNumber: (l['level_number'] as num?)?.toInt() ?? 0,
        title: l['title'] as String? ?? '',
        icon: l['icon'] as String? ?? '🎯',
        starsRequired: (l['stars_required'] as num?)?.toInt() ?? 0,
        questions: questions,
      );
    }).toList();
    if (mounted) setState(() => _dynamicLevels = levels);
  }

  Future<void> _loadProgress() async {
    final result = await _gameService.fetchProgress(widget.subject.id);
    if (mounted) {
      setState(() {
        _totalStars = result.stars;
        _completedLevels = result.completedLevels;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  bool _isLevelUnlocked(GameLevel level) {
    return _totalStars >= level.starsRequired;
  }

  bool _isLevelCompleted(GameLevel level) {
    return _completedLevels.contains(level.levelNumber);
  }

  Color get _primaryColor {
    switch (widget.subject.id) {
      case 'science':
        return const Color(0xFF4FC3F7);
      case 'biology':
        return const Color(0xFF81C784);
      default:
        return const Color(0xFFFFB74D);
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              if (_loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFD700),
                    ),
                  ),
                )
              else if (widget.subject.levels.isEmpty && _dynamicLevels.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No levels yet',
                            style: GoogleFonts.fredoka(
                                fontSize: 22, color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('Add levels in the Admin panel',
                            style: GoogleFonts.nunito(
                                fontSize: 14, color: Colors.white38)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(child: _buildLevelMap()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject.emoji + ' ' + widget.subject.name,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Choose a level',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Stars badge
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, sin(_floatController.value * pi) * 3),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 5),
                  Text(
                    '$_totalStars',
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
    );
  }

  // ── Level Map ──────────────────────────────────────────────

  Widget _buildLevelMap() {
    final levels = widget.subject.levels.isNotEmpty
        ? widget.subject.levels
        : _dynamicLevels;

    return RefreshIndicator(
      color: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF2D1B69),
      onRefresh: _loadProgress,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final unlocked = _isLevelUnlocked(level);
          final completed = _isLevelCompleted(level);

          // Alternate left/right for a path feel
          final isLeft = index.isEven;

          return _buildLevelNode(
            level: level,
            unlocked: unlocked,
            completed: completed,
            isLeft: isLeft,
            isLast: index == levels.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildLevelNode({
    required GameLevel level,
    required bool unlocked,
    required bool completed,
    required bool isLeft,
    required bool isLast,
  }) {
    final color = completed
        ? const Color(0xFFFFD700)
        : unlocked
            ? _primaryColor
            : Colors.grey.shade600;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: unlocked ? () => _openLevel(level) : null,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (_, child) {
                  final dy = unlocked
                      ? sin((_floatController.value + level.levelNumber * 0.3) *
                              pi) *
                          4
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: child,
                  );
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: unlocked ? 0.6 : 0.2),
                      width: 2,
                    ),
                    boxShadow: unlocked
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      // Level icon
                      Text(
                        completed
                            ? '✅'
                            : unlocked
                                ? level.icon
                                : '🔒',
                        style: TextStyle(
                          fontSize: 36,
                          color: unlocked ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Level ${level.levelNumber}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      Text(
                        level.title,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          color: unlocked ? Colors.white : Colors.white38,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (!unlocked) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${level.starsRequired} needed',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.white38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (completed) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Completed!',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Connector line (not after the last item)
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(
              left: isLeft ? 100 : 0,
              right: isLeft ? 0 : 100,
              top: 4,
              bottom: 4,
            ),
            child: Column(
              children: List.generate(3, (i) {
                return Container(
                  width: 2,
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.white.withValues(alpha: 0.15),
                );
              }),
            ),
          ),
      ],
    );
  }

  // ── Open Level ─────────────────────────────────────────────

  void _openLevel(GameLevel level) async {
    final result = await Navigator.push<
        ({int starsEarned, int quizScore, int totalQuestions})?>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => QuizView(
          subject: widget.subject,
          level: level,
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

    if (result != null && result.starsEarned > 0) {
      // Save to backend
      await _gameService.saveLevelResult(
        subjectId: widget.subject.id,
        levelId: level.id!,
        starsEarned: result.starsEarned,
        quizScore: result.quizScore,
        totalQuestions: result.totalQuestions,
      );
    }

    // Always refresh progress after returning
    await _loadProgress();
  }
}
