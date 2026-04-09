import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/admin_service.dart';
import 'quiz_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class LevelMapView extends StatefulWidget {
  final Subject subject;
  final User user;

  const LevelMapView({required this.subject, required this.user, super.key});

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
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _loadLevels();
    _loadProgress();
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
            colors: [mainBlue.withValues(alpha: 0.08), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              if (_loading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(color: mainBlue)))
              else
                Expanded(child: _buildLevelMap()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.subject.emoji} ${widget.subject.name}",
                    style: const TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text('Choose a level to start',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.black38,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // Stars Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sunnyYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sunnyYellow.withValues(alpha: 0.5)),
            ),
            child: Row(children: [
              const Text('⭐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('$_totalStars',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: accentOrange)),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildLevelMap() {
    final levels = widget.subject.levels.isNotEmpty
        ? widget.subject.levels
        : _dynamicLevels;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      itemCount: levels.length,
      itemBuilder: (ctx, i) {
        final level = levels[i];
        final unlocked = _totalStars >= level.starsRequired;
        final completed = _completedLevels.contains(level.levelNumber);
        return _buildLevelNode(
            level: level,
            unlocked: unlocked,
            completed: completed,
            isLeft: i.isEven,
            isLast: i == levels.length - 1);
      },
    );
  }

  Widget _buildLevelNode(
      {required GameLevel level,
      required bool unlocked,
      required bool completed,
      required bool isLeft,
      required bool isLast}) {
    final Color nodeColor = completed
        ? sunnyYellow
        : unlocked
            ? mainBlue
            : Colors.grey.shade300;

    return Column(children: [
      Row(
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: unlocked ? () => _openLevel(level) : null,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(
                    0, unlocked ? sin(_floatController.value * pi) * 5 : 0),
                child: child,
              ),
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: nodeColor, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                        color: nodeColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(children: [
                  Text(
                      completed
                          ? '✅'
                          : unlocked
                              ? level.icon
                              : '🔒',
                      style: const TextStyle(fontSize: 38)),
                  const SizedBox(height: 10),
                  Text('LEVEL ${level.levelNumber}',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900,
                          color: nodeColor,
                          letterSpacing: 1.5,
                          fontSize: 11)),
                  Text(level.title,
                      style: const TextStyle(
                          fontFamily: 'Recoleta',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  if (!unlocked) ...[
                    const SizedBox(height: 8),
                    Text('Need ${level.starsRequired} ⭐',
                        style: GoogleFonts.nunito(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ]
                ]),
              ),
            ),
          ),
        ],
      ),
      if (!isLast) _buildConnector(isLeft),
    ]);
  }

  Widget _buildConnector(bool isLeft) {
    return Padding(
      padding: EdgeInsets.only(
          left: isLeft ? 100 : 0, right: isLeft ? 0 : 100, top: 5, bottom: 5),
      child: Column(
          children: List.generate(
              3,
              (i) => Container(
                  width: 4,
                  height: 10,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                      color: mainBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2))))),
    );
  }

  // _loadLevels, _loadProgress, and _openLevel logic remains identical to your file

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
                  q['option_a'] ?? '',
                  q['option_b'] ?? '',
                  q['option_c'] ?? '',
                  q['option_d'] ?? ''
                ],
                correctIndex: (q['correct_index'] as num?)?.toInt() ?? 0,
                funFact: q['fun_fact'] as String?,
              ))
          .toList();
      return GameLevel(
          levelNumber: (l['level_number'] as num?)?.toInt() ?? 0,
          title: l['title'] as String? ?? '',
          icon: l['icon'] as String? ?? '🎯',
          starsRequired: (l['stars_required'] as num?)?.toInt() ?? 0,
          questions: questions);
    }).toList();
    if (mounted) {
      setState(() => _dynamicLevels = levels);
    }
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

  void _openLevel(GameLevel level) async {
    final result = await Navigator.push<
        ({int starsEarned, int quizScore, int totalQuestions})?>(
      context,
      MaterialPageRoute(
          builder: (ctx) => QuizView(
              subject: widget.subject, level: level, user: widget.user)),
    );
    if (result != null && result.starsEarned > 0) {
      await _gameService.saveLevelResult(
          subjectId: widget.subject.id,
          levelNumber: level.levelNumber,
          starsEarned: result.starsEarned,
          quizScore: result.quizScore,
          totalQuestions: result.totalQuestions);
    }
    await _loadProgress();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }
}
