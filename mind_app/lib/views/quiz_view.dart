import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class QuizView extends StatefulWidget {
  final Subject subject;
  final GameLevel level;
  final User user;

  const QuizView({
    required this.subject,
    required this.level,
    required this.user,
    super.key,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _showFunFact = false;

  late AnimationController _shakeController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _progressController.forward();
  }

  int get _totalQuestions => widget.level.questions.length;
  QuizQuestion get _currentQuestion => widget.level.questions[_currentIndex];

  void _selectAnswer(int index) {
    if (_answered) return;
    final correct = index == _currentQuestion.correctIndex;

    setState(() {
      _selectedOption = index;
      _answered = true;
      _showFunFact = _currentQuestion.funFact != null &&
          _currentQuestion.funFact!.isNotEmpty;
      if (correct) _correctAnswers++;
    });

    if (!correct) _shakeController.forward(from: 0);
  }

  void _nextQuestion() {
    if (_currentIndex < _totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
        _showFunFact = false;
      });
      _progressController.animateTo((_currentIndex + 1) / _totalQuestions);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final stars = _calculateStars();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ResultDialog(
        correct: _correctAnswers,
        total: _totalQuestions,
        stars: stars,
        onContinue: () {
          Navigator.pop(ctx); // Close dialog
          Navigator.pop(context, (
            starsEarned: stars,
            quizScore: _correctAnswers,
            totalQuestions: _totalQuestions
          ));
        },
      ),
    );
  }

  int _calculateStars() {
    final ratio = _correctAnswers / _totalQuestions;
    if (ratio == 1.0) return 30;
    if (ratio >= 0.6) return 20;
    if (ratio >= 0.3) return 10;
    return 0;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          _AmbientBlobs(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressBar(),
                Expanded(child: _buildQuizBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.subject.name.toUpperCase(),
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: mainBlue,
                        letterSpacing: 1.2)),
                Text(widget.level.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: mainBlue, borderRadius: BorderRadius.circular(15)),
            child: Text('${_currentIndex + 1}/$_totalQuestions',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _progressController.value,
            backgroundColor: mainBlue.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(mainBlue),
            minHeight: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizBody() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (ctx, child) {
          final s = sin(_shakeController.value * pi * 10) * 5;
          return Transform.translate(offset: Offset(s, 0), child: child);
        },
        child: Column(
          children: [
            _currentQuestion.isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _currentQuestion.question,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 180,
                        color: Colors.grey.withValues(alpha: 0.1),
                        child: const Icon(Icons.broken_image_rounded,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                  )
                : Text(_currentQuestion.question,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.3)),
            const SizedBox(height: 30),
            ..._currentQuestion.options
                .asMap()
                .entries
                .map((e) => _buildOption(e.key, e.value)),
            if (_showFunFact) _buildFunFactBox(),
            if (_answered) ...[
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: mainBlue.withValues(alpha: 0.4),
                  ),
                  child: Text(
                      _currentIndex < _totalQuestions - 1
                          ? 'Next Question'
                          : 'See Results',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    bool isCorrect = index == _currentQuestion.correctIndex;
    bool isSelected = index == _selectedOption;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200;
    Color bgCol = isDark ? const Color(0xFF1E1C2A) : Colors.white;
    if (_answered) {
      if (isCorrect) {
        borderCol = Colors.green.withValues(alpha: 0.5);
        bgCol = Colors.green.withValues(alpha: 0.1);
      } else if (isSelected) {
        borderCol = Colors.red.withValues(alpha: 0.5);
        bgCol = Colors.red.withValues(alpha: 0.1);
      }
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderCol, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: isSelected ? mainBlue : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100),
              child: Text(String.fromCharCode(65 + index),
                  style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                      fontSize: 12)),
            ),
            const SizedBox(width: 15),
            Expanded(
                child: Text(text,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87))),
            if (_answered && isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildFunFactBox() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: sunnyYellow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: sunnyYellow.withValues(alpha: 0.5))),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(_currentQuestion.funFact!,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int correct, total, stars;
  final VoidCallback onContinue;
  const _ResultDialog(
      {required this.correct,
      required this.total,
      required this.stars,
      required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(stars == 30 ? '🏆 Amazing!' : '🎉 Well Done!',
                style: const TextStyle(
                    fontFamily: 'Recoleta',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mainBlue)),
            const SizedBox(height: 10),
            Text('You got $correct out of $total correct!',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Icon(Icons.star_rounded,
                        color: i < (stars / 10)
                            ? sunnyYellow
                            : (isDark ? Colors.white12 : Colors.grey.shade200),
                        size: 50))),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                  backgroundColor: mainBlue,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text('Continue',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
      ],
    );
  }
}
