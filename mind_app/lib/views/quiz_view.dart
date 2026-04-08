import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);
const Color canvasBg = Color(0xFFF8FAFC);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(child: _buildQuizBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.subject.name.toUpperCase(),
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: mainBlue,
                      letterSpacing: 1.2)),
              Text(widget.level.title,
                  style: const TextStyle(
                      fontFamily: 'Recoleta',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const Spacer(),
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
        builder: (context, child) => LinearProgressIndicator(
          value: _progressController.value,
          backgroundColor: mainBlue.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(mainBlue),
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildQuizBody() {
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
            Text(_currentQuestion.question,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.4)),
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
                    shadowColor: mainBlue.withOpacity(0.4),
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

    Color borderCol = Colors.grey.shade200;
    Color bgCol = Colors.white;
    if (_answered) {
      if (isCorrect) {
        borderCol = Colors.green;
        bgCol = Colors.green.withOpacity(0.1);
      } else if (isSelected) {
        borderCol = Colors.red;
        bgCol = Colors.red.withOpacity(0.1);
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isSelected ? mainBlue : Colors.grey.shade100,
              child: Text(String.fromCharCode(65 + index),
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontSize: 12)),
            ),
            const SizedBox(width: 15),
            Expanded(
                child: Text(text,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87))),
            if (_answered && isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildFunFactBox() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: sunnyYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: sunnyYellow)),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(_currentQuestion.funFact!,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.black87,
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
    return Dialog(
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
                    color: Colors.black54,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Icon(Icons.star_rounded,
                        color: i < (stars / 10)
                            ? sunnyYellow
                            : Colors.grey.shade200,
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
