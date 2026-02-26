// ============================================================
// quiz_view.dart
// Place in: lib/views/quiz_view.dart
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  late AnimationController _bounceController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressController.forward();
  }

  int get _totalQuestions => widget.level.questions.length;
  QuizQuestion get _currentQuestion => widget.level.questions[_currentIndex];

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // ── Answer Selection ───────────────────────────────────────

  void _selectAnswer(int index) {
    if (_answered) return;

    final correct = index == _currentQuestion.correctIndex;

    setState(() {
      _selectedOption = index;
      _answered = true;
      _showFunFact = _currentQuestion.funFact != null;
      if (correct) _correctAnswers++;
    });

    if (correct) {
      _bounceController.forward().then((_) => _bounceController.reverse());
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
        _showFunFact = false;
      });

      // Animate progress bar
      _progressController.animateTo(
        (_currentIndex + 1) / _totalQuestions,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    } else {
      _showResults();
    }
  }

  // ── Results ────────────────────────────────────────────────

  void _showResults() {
    final starsEarned = _calculateStars();
    Future<void> _sendPointsToBackend(int starsEarned) async {
      await http.post(
        Uri.parse("http://localhost:8080/quiz/complete"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.user.id,
          "points": starsEarned,
        }),
      );
    }
    // Capture the quiz-screen context BEFORE opening the dialog,
    // so we still hold a valid reference after the dialog is popped.
    final quizContext = context;

    showDialog(
      context: quizContext,
      barrierDismissible: false,
      builder: (dialogContext) => _ResultDialog(
        correctAnswers: _correctAnswers,
        totalQuestions: _totalQuestions,
        starsEarned: starsEarned,
        levelTitle: widget.level.title,
        onContinue: () async {
          await _sendPointsToBackend(starsEarned);
          // 1. Close the dialog using the dialog's own context.
          Navigator.of(dialogContext).pop();
          // 2. Pop the quiz screen using the quiz-screen context,
          //    returning the result record to LevelMapView.
          //    Use a post-frame callback so the dialog is fully
          //    removed from the tree before we pop the quiz screen.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (quizContext.mounted) {
              Navigator.of(quizContext).pop((
                starsEarned: starsEarned,
                quizScore: _correctAnswers,
                totalQuestions: _totalQuestions,
              ));
            }
          });
        },
        onRetry: () {
          // Close only the dialog; stay on the quiz screen.
          Navigator.of(dialogContext).pop();
          if (!mounted) return;
          setState(() {
            _currentIndex = 0;
            _correctAnswers = 0;
            _selectedOption = null;
            _answered = false;
            _showFunFact = false;
          });
          _progressController.animateTo(
            1 / _totalQuestions,
            duration: const Duration(milliseconds: 600),
          );
        },
      ),
    );
  }

  int _calculateStars() {
    final ratio = _correctAnswers / _totalQuestions;
    if (ratio == 1.0) return 30;
    if (ratio >= 0.66) return 20;
    if (ratio >= 0.33) return 10;
    return 0;
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B69), Color(0xFF1A0A3D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildProgressBar(),
              Expanded(child: _buildQuizBody()),
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
            onTap: () => Navigator.of(context).pop(null),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject.name,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.level.title,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Question counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentIndex + 1} / $_totalQuestions',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress Bar ───────────────────────────────────────────

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _progressController.value,
            minHeight: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFFFD700),
            ),
          ),
        ),
      ),
    );
  }

  // ── Quiz Body ──────────────────────────────────────────────

  Widget _buildQuizBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (_, child) {
          final shake = sin(_shakeController.value * pi * 6) * 8;
          return Transform.translate(
            offset: Offset(shake * (1 - _shakeController.value), 0),
            child: child,
          );
        },
        child: Column(
          children: [
            // Question card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.level.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuestion.question,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Options
            ..._currentQuestion.options.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionButton(entry.key, entry.value),
              );
            }),

            // Fun fact
            if (_showFunFact && _currentQuestion.funFact != null) ...[
              const SizedBox(height: 8),
              _buildFunFact(_currentQuestion.funFact!),
            ],

            // Next button
            if (_answered) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentIndex < _totalQuestions - 1
                        ? 'Next Question →'
                        : 'See Results! 🎉',
                    style: GoogleFonts.fredoka(fontSize: 18),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, String text) {
    Color bgColor = Colors.white.withValues(alpha: 0.1);
    Color borderColor = Colors.white.withValues(alpha: 0.2);
    Color textColor = Colors.white;
    IconData? trailingIcon;

    if (_answered) {
      if (index == _currentQuestion.correctIndex) {
        bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.3);
        borderColor = const Color(0xFF4CAF50);
        trailingIcon = Icons.check_circle_rounded;
      } else if (index == _selectedOption) {
        bgColor = const Color(0xFFE53935).withValues(alpha: 0.3);
        borderColor = const Color(0xFFE53935);
        trailingIcon = Icons.cancel_rounded;
      } else {
        bgColor = Colors.white.withValues(alpha: 0.05);
        textColor = Colors.white54;
        borderColor = Colors.white12;
      }
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Letter badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: index == _currentQuestion.correctIndex
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE53935),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunFact(String fact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fun Fact!',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fact,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result Dialog ──────────────────────────────────────────────

class _ResultDialog extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int starsEarned;
  final String levelTitle;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const _ResultDialog({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.starsEarned,
    required this.levelTitle,
    required this.onContinue,
    required this.onRetry,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _emoji {
    final ratio = widget.correctAnswers / widget.totalQuestions;
    if (ratio == 1.0) return '🏆';
    if (ratio >= 0.66) return '🎉';
    if (ratio >= 0.33) return '👍';
    return '💪';
  }

  String get _title {
    final ratio = widget.correctAnswers / widget.totalQuestions;
    if (ratio == 1.0) return 'Perfect Score!';
    if (ratio >= 0.66) return 'Great Job!';
    if (ratio >= 0.33) return 'Keep Going!';
    return 'Try Again!';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A1C72), Color(0xFF1A0A3D)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                _title,
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.correctAnswers} / ${widget.totalQuestions} correct',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // Stars earned
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.starsEarned} Stars',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onRetry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '🔄 Retry',
                        style: GoogleFonts.fredoka(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Continue →',
                        style: GoogleFonts.fredoka(fontSize: 16),
                      ),
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
