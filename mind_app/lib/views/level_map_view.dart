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
    _dynamicLevels = List.from(widget.subject.levels);
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _loadLevels();
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          _AmbientBlobs(isDark: isDark),
          SafeArea(
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
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 20, 10),
      child: Row(
        children: [
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
                Text(widget.subject.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                Text('Choose a level to start',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black38,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _buildStarBadge(_totalStars),
        ],
      ),
    );
  }

  Widget _buildStarBadge(int stars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: sunnyYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sunnyYellow.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: accentOrange, size: 18),
          const SizedBox(width: 5),
          Text(
            '$stars',
            style: GoogleFonts.fredoka(
              color: accentOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelMap() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      itemCount: _dynamicLevels.length,
      itemBuilder: (ctx, i) {
        final level = _dynamicLevels[i];
        final unlocked = _totalStars >= level.starsRequired;
        final completed = _completedLevels.contains(level.levelNumber);
        return _buildLevelNode(
            level: level,
            unlocked: unlocked,
            completed: completed,
            isLeft: i.isEven,
            isLast: i == _dynamicLevels.length - 1);
      },
    );
  }

  Widget _buildLevelNode(
      {required GameLevel level,
      required bool unlocked,
      required bool completed,
      required bool isLeft,
      required bool isLast}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color nodeColor = completed
        ? sunnyYellow
        : unlocked
            ? mainBlue
            : (isDark ? Colors.white24 : Colors.grey.shade300);

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
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: nodeColor.withValues(alpha: isDark ? 0.3 : 0.5),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: nodeColor.withValues(alpha: isDark ? 0.15 : 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: nodeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                        completed
                            ? '✅'
                            : unlocked
                                ? level.icon
                                : '🔒',
                        style: const TextStyle(fontSize: 34)),
                  ),
                  const SizedBox(height: 12),
                  Text('LEVEL ${level.levelNumber}',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900,
                          color: nodeColor,
                          letterSpacing: 1.5,
                          fontSize: 10)),
                  Text(level.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87)),
                  if (!unlocked) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Need ${level.starsRequired} ⭐',
                          style: GoogleFonts.nunito(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 11)),
                    ),
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
    final quiz = await _adminService.getFullQuiz(widget.subject.id);
    if (quiz == null || !mounted) return;
    final rawLevels = (quiz['levels'] as List<dynamic>?) ?? [];
    final fetchedLevels = rawLevels.map((l) {
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
                isImage: q['is_image'] as bool? ?? false,
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
      setState(() {
        // Merge the built-in levels with fetched levels
        final builtInLevelNumbers = widget.subject.levels.map((l) => l.levelNumber).toSet();
        final newLevels = fetchedLevels.where((l) => !builtInLevelNumbers.contains(l.levelNumber)).toList();
        
        final combined = [...widget.subject.levels, ...newLevels];
        combined.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
        _dynamicLevels = combined;
      });
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
class _AmbientBlobs extends StatelessWidget {
  final bool isDark;
  const _AmbientBlobs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
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
          left: -50,
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
          top: h * 0.35,
          right: -30,
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
      ],
    );
  }
}
