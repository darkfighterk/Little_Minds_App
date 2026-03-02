// ============================================================
// admin_view.dart  (FIXED — add levels to existing subjects)
// Place in: lib/views/admin_view.dart
//
// Add to pubspec.yaml:
//   image_picker: ^1.0.7
//
// Access from your app with:
//   Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGateView()));
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/admin_service.dart';

// ── Colours ────────────────────────────────────────────────
const _bg = Color(0xFF0D0520);
const _card = Color(0xFF1E1040);
const _accent = Color(0xFF7C3AED);
const _gold = Color(0xFFFFD700);
const _green = Color(0xFF4CAF50);
const _red = Color(0xFFE53935);

// ── Local model for building a question before submission ──
class _QuestionDraft {
  final TextEditingController questionCtrl = TextEditingController();
  final List<TextEditingController> optionCtrls =
      List.generate(4, (_) => TextEditingController());
  final TextEditingController funFactCtrl = TextEditingController();
  bool isImageQuestion = false;
  XFile? imageFile;
  String? uploadedImageUrl;
  int correctIndex = 0;

  void dispose() {
    questionCtrl.dispose();
    for (final c in optionCtrls) {
      c.dispose();
    }
    funFactCtrl.dispose();
  }
}

// =====================================================================
// ENTRY POINT — Admin Key Gate
// =====================================================================

class AdminGateView extends StatefulWidget {
  const AdminGateView({super.key});
  @override
  State<AdminGateView> createState() => _AdminGateViewState();
}

class _AdminGateViewState extends State<AdminGateView> {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  void _submit() {
    if (AdminService.verifyKey(_keyCtrl.text.trim())) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminView()),
      );
    } else {
      setState(() => _error = 'Incorrect admin key');
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Admin Access',
                    style:
                        GoogleFonts.fredoka(fontSize: 32, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Enter your admin key to continue',
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.white54)),
                const SizedBox(height: 40),
                TextField(
                  controller: _keyCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Admin key',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: _card,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _accent, width: 2)),
                    prefixIcon:
                        const Icon(Icons.key_rounded, color: Colors.white38),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.white38),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    errorText: _error,
                    errorStyle: const TextStyle(color: _red),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Enter Admin Panel',
                        style: GoogleFonts.fredoka(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// MAIN ADMIN VIEW — mode selector: Quiz | Puzzles
// =====================================================================

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  @override
  State<AdminView> createState() => _AdminModeState();
}

enum _AdminMode { quiz, puzzle }

class _AdminModeState extends State<AdminView> {
  _AdminMode _mode = _AdminMode.quiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _mode == _AdminMode.quiz ? 'Quiz Creator' : 'Puzzle Creator',
          style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: _card,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(children: [
              _TabChip(
                label: '📝  Quiz',
                active: _mode == _AdminMode.quiz,
                onTap: () => setState(() => _mode = _AdminMode.quiz),
              ),
              const SizedBox(width: 10),
              _TabChip(
                label: '🧩  Puzzles',
                active: _mode == _AdminMode.puzzle,
                onTap: () => setState(() => _mode = _AdminMode.puzzle),
              ),
            ]),
          ),
        ),
      ),
      body: _mode == _AdminMode.quiz
          ? const _QuizWizard()
          : const _PuzzleWizard(),
    );
  }
}

// =====================================================================
// QUIZ WIZARD (original quiz creation wizard)
// Steps: 0=Subject  1=Level  2=Questions  3=Review & Publish
// =====================================================================

class _QuizWizard extends StatefulWidget {
  const _QuizWizard();
  @override
  State<_QuizWizard> createState() => _QuizWizardState();
}

class _QuizWizardState extends State<_QuizWizard> {
  final AdminService _svc = AdminService();
  final PageController _pageCtrl = PageController();
  int _step = 0;

  // ── Step 0 — Subject ───────────────────────────────────────
  bool _createNewSubject = false;
  String? _selectedSubjectId;
  String _selectedSubjectName = '';
  String _selectedSubjectEmoji = '';
  final _subjectIdCtrl = TextEditingController();
  final _subjectNameCtrl = TextEditingController();
  String _subjectEmoji = '📚';
  String _gradientStart = '#4FC3F7';
  String _gradientEnd = '#0288D1';
  List<Map<String, dynamic>> _dbSubjects = [];
  bool _loadingSubjects = true;

  // Built-in subjects (always shown)
  final List<Map<String, dynamic>> _builtInSubjects = [
    {'id': 'science', 'name': 'Science', 'emoji': '🔬'},
    {'id': 'biology', 'name': 'Biology', 'emoji': '🌿'},
    {'id': 'history', 'name': 'History', 'emoji': '🏰'},
  ];

  // ── Step 1 — Level ─────────────────────────────────────────
  final _levelTitleCtrl = TextEditingController();
  String _levelIcon = '🎯';
  int _levelNumber = 1;
  int _starsRequired = 0;

  // FIX: existing levels for selected subject (populated when moving to Step 1)
  List<Map<String, dynamic>> _existingLevels = [];
  bool _loadingExistingLevels = false;

  // ── Step 2 — Questions ─────────────────────────────────────
  final List<_QuestionDraft> _questions = [_QuestionDraft()];
  bool _uploadingImage = false;

  // ── Step 3 — Publishing ────────────────────────────────────
  bool _publishing = false;
  bool _published = false;
  String _publishStatus = '';

  @override
  void initState() {
    super.initState();
    _fetchDbSubjects();
  }

  Future<void> _fetchDbSubjects() async {
    final list = await _svc.getSubjects();
    if (mounted) {
      setState(() {
        _dbSubjects = list;
        _loadingSubjects = false;
      });
    }
  }

  // FIX: load existing levels for a subject and auto-set next level number
  Future<void> _loadExistingLevels(String subjectId) async {
    setState(() => _loadingExistingLevels = true);
    final levels = await _svc.getLevels(subjectId);
    if (!mounted) return;

    // Find the highest level number already used
    int maxLevelNumber = 0;
    for (final l in levels) {
      final n = (l['level_number'] as num?)?.toInt() ?? 0;
      if (n > maxLevelNumber) maxLevelNumber = n;
    }

    setState(() {
      _existingLevels = levels;
      _loadingExistingLevels = false;
      // Auto-set to next available level number
      _levelNumber = maxLevelNumber + 1;
      // Auto-suggest stars required (30 per level is the convention)
      _starsRequired = maxLevelNumber * 30;
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _subjectIdCtrl.dispose();
    _subjectNameCtrl.dispose();
    _levelTitleCtrl.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────

  void _goTo(int step) {
    setState(() => _step = step);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  String? _validateStep0() {
    if (_createNewSubject) {
      if (_subjectIdCtrl.text.trim().isEmpty) return 'Subject ID is required';
      if (_subjectNameCtrl.text.trim().isEmpty)
        return 'Subject name is required';
    } else {
      if (_selectedSubjectId == null) return 'Please select a subject';
    }
    return null;
  }

  String? _validateStep1() {
    if (_levelTitleCtrl.text.trim().isEmpty) return 'Level title is required';
    if (_levelIcon.trim().isEmpty) return 'Level icon is required';

    // FIX: warn if the chosen level number already exists for this subject
    final existingNumbers = _existingLevels
        .map((l) => (l['level_number'] as num?)?.toInt() ?? 0)
        .toSet();
    if (existingNumbers.contains(_levelNumber)) {
      return 'Level $_levelNumber already exists for this subject. Choose a different number.';
    }
    return null;
  }

  String? _validateStep2() {
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (!q.isImageQuestion && q.questionCtrl.text.trim().isEmpty) {
        return 'Question ${i + 1}: text is required (or switch to image mode)';
      }
      if (q.isImageQuestion && q.uploadedImageUrl == null) {
        return 'Question ${i + 1}: please upload an image first';
      }
      for (int j = 0; j < 4; j++) {
        if (q.optionCtrls[j].text.trim().isEmpty) {
          return 'Question ${i + 1}: option ${[
            'A',
            'B',
            'C',
            'D'
          ][j]} is required';
        }
      }
    }
    return null;
  }

  void _nextStep() async {
    String? err;
    if (_step == 0) err = _validateStep0();
    if (_step == 1) err = _validateStep1();
    if (_step == 2) err = _validateStep2();
    if (err != null) {
      _showSnack(err, isError: true);
      return;
    }

    if (_step == 0) {
      // FIX: when moving from subject step to level step,
      // load existing levels so we can show them and avoid duplicates.
      final subjectId = _createNewSubject
          ? _subjectIdCtrl.text.trim().toLowerCase().replaceAll(' ', '_')
          : _selectedSubjectId!;
      await _loadExistingLevels(subjectId);
      _goTo(1);
    } else if (_step < 3) {
      _goTo(_step + 1);
    } else {
      _publish(); // only when already ON step 3 (Review)
    }
  }

  // ── Publish ────────────────────────────────────────────────

  Future<void> _publish() async {
    setState(() {
      _publishing = true;
      _publishStatus = 'Creating subject...';
    });

    String subjectId;
    if (_createNewSubject) {
      final ok = await _svc.createSubject(
        id: _subjectIdCtrl.text.trim(),
        name: _subjectNameCtrl.text.trim(),
        emoji: _subjectEmoji,
        gradientStart: _gradientStart,
        gradientEnd: _gradientEnd,
      );
      if (!ok) {
        _publishFailed('Failed to create subject. ID may already exist.');
        return;
      }
      subjectId = _subjectIdCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
    } else {
      subjectId = _selectedSubjectId!;
    }

    setState(() => _publishStatus = 'Creating level...');
    final levelId = await _svc.createLevel(
      subjectId: subjectId,
      levelNumber: _levelNumber,
      title: _levelTitleCtrl.text.trim(),
      icon: _levelIcon,
      starsRequired: _starsRequired,
    );
    if (levelId == null) {
      _publishFailed('Failed to create level. Level number may already exist.');
      return;
    }

    setState(() => _publishStatus = 'Saving ${_questions.length} questions...');
    final questionsPayload = _questions
        .map((q) => {
              'level_id': levelId,
              'question_text': q.questionCtrl.text.trim(),
              'image_url': q.uploadedImageUrl ?? '',
              'option_a': q.optionCtrls[0].text.trim(),
              'option_b': q.optionCtrls[1].text.trim(),
              'option_c': q.optionCtrls[2].text.trim(),
              'option_d': q.optionCtrls[3].text.trim(),
              'correct_index': q.correctIndex,
              'fun_fact': q.funFactCtrl.text.trim(),
            })
        .toList();

    final saved = await _svc.saveQuestions(levelId, questionsPayload);
    if (!saved) {
      _publishFailed('Failed to save questions.');
      return;
    }

    if (mounted) {
      setState(() {
        _publishing = false;
        _published = true;
        _publishStatus = '';
      });
    }
  }

  void _publishFailed(String msg) {
    if (mounted)
      setState(() {
        _publishing = false;
        _publishStatus = '';
      });
    _showSnack(msg, isError: true);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? _red : _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Pick & upload image ────────────────────────────────────

  Future<void> _pickImage(int questionIndex) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _uploadingImage = true;
      _questions[questionIndex].imageFile = picked;
    });

    final url = await _svc.uploadImage(picked);
    if (mounted) {
      setState(() {
        _uploadingImage = false;
        if (url != null) {
          _questions[questionIndex].uploadedImageUrl = url;
          _showSnack('Image uploaded ✓');
        } else {
          _showSnack('Image upload failed', isError: true);
        }
      });
    }
  }

  // =====================================================================
  // BUILD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    return _published ? _buildSuccessScreen() : _buildWizard();
  }

  // ── Back navigation (called by parent AppBar if needed) ───────────
  // ── Success Screen ─────────────────────────────────────────

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('Quiz Published!',
                style: GoogleFonts.fredoka(fontSize: 36, color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              '${_questions.length} question${_questions.length == 1 ? '' : 's'} saved to Level $_levelNumber\n"${_levelTitleCtrl.text}"',
              style: GoogleFonts.nunito(
                  fontSize: 16, color: Colors.white70, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text('Done', style: GoogleFonts.fredoka(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Wizard layout ──────────────────────────────────────────

  Widget _buildWizard() {
    return Column(
      children: [
        _buildStepIndicator(),
        Expanded(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep0Subject(),
              _buildStep1Level(),
              _buildStep2Questions(),
              _buildStep3Review(),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  // ── Step Indicator ─────────────────────────────────────────

  Widget _buildStepIndicator() {
    final steps = ['Subject', 'Level', 'Questions', 'Review'];
    return Container(
      color: _card,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final label = e.value;
          final active = i == _step;
          final done = i < _step;
          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: done
                            ? _green
                            : active
                                ? _accent
                                : Colors.white12,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: active ? _accent : Colors.transparent,
                            width: 2),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : Text('${i + 1}',
                                style: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    color: active
                                        ? Colors.white
                                        : Colors.white38)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            color: active ? _accent : Colors.white38,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: done ? _green : Colors.white12,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Bottom Action Bar ──────────────────────────────────────

  Widget _buildBottomBar() {
    final isLast = _step == 3;
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _publishing ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLast ? _gold : _accent,
            foregroundColor: isLast ? Colors.black87 : Colors.white,
            disabledBackgroundColor: _accent.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _publishing
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 12),
                  Text(_publishStatus,
                      style: GoogleFonts.fredoka(
                          fontSize: 16, color: Colors.white)),
                ])
              : Text(
                  isLast ? '🚀  Publish Quiz' : 'Continue →',
                  style: GoogleFonts.fredoka(fontSize: 18),
                ),
        ),
      ),
    );
  }

  // =====================================================================
  // STEP 0 — Subject
  // =====================================================================

  Widget _buildStep0Subject() {
    final allSubjects = [..._builtInSubjects, ..._dbSubjects];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('📚', 'Choose a Subject'),
        const SizedBox(height: 8),
        Text('Select an existing subject or create a new one.',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 20),

        // Toggle
        Row(children: [
          _TabChip(
            label: 'Existing Subject',
            active: !_createNewSubject,
            onTap: () => setState(() => _createNewSubject = false),
          ),
          const SizedBox(width: 10),
          _TabChip(
            label: '+ Create New',
            active: _createNewSubject,
            onTap: () => setState(() => _createNewSubject = true),
          ),
        ]),
        const SizedBox(height: 20),

        if (!_createNewSubject) ...[
          if (_loadingSubjects)
            const Center(child: CircularProgressIndicator(color: _accent))
          else
            ...allSubjects.map((s) {
              final selected = _selectedSubjectId == s['id'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedSubjectId = s['id'] as String;
                  _selectedSubjectName = s['name'] as String;
                  _selectedSubjectEmoji = s['emoji'] as String? ?? '';
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? _accent.withValues(alpha: 0.2) : _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? _accent : Colors.white12,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Text(s['emoji'] as String,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Text(s['name'] as String,
                        style: GoogleFonts.fredoka(
                            fontSize: 18,
                            color: selected ? Colors.white : Colors.white70)),
                    const Spacer(),
                    if (selected)
                      const Icon(Icons.check_circle_rounded, color: _accent),
                  ]),
                ),
              );
            }),
        ] else ...[
          // New subject form
          _buildField('Subject ID', _subjectIdCtrl,
              hint: 'e.g. math  (lowercase, no spaces)',
              keyboardType: TextInputType.name),
          _buildField('Subject Name', _subjectNameCtrl,
              hint: 'e.g. Mathematics'),
          _emojiField(
            label: 'Subject Emoji',
            value: _subjectEmoji,
            onChanged: (v) => setState(() => _subjectEmoji = v),
          ),
          const SizedBox(height: 16),
          Text('Gradient Colours (hex)',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _buildField(
                'Start',
                TextEditingController(text: _gradientStart),
                hint: '#4FC3F7',
                onChanged: (v) => _gradientStart = v,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildField(
                'End',
                TextEditingController(text: _gradientEnd),
                hint: '#0288D1',
                onChanged: (v) => _gradientEnd = v,
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  // =====================================================================
  // STEP 1 — Level
  // =====================================================================

  Widget _buildStep1Level() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('📋', 'Level Details'),
        const SizedBox(height: 8),
        Text('Define the level that will contain your questions.',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 20),

        // FIX: show existing levels for the selected subject
        if (_loadingExistingLevels) ...[
          const Center(child: CircularProgressIndicator(color: _accent)),
          const SizedBox(height: 20),
        ] else if (_existingLevels.isNotEmpty) ...[
          _buildExistingLevelsList(),
          const SizedBox(height: 24),
        ],

        _buildField('Level Title', _levelTitleCtrl,
            hint: 'e.g. "Basic Algebra"'),
        _emojiField(
          label: 'Level Icon (emoji)',
          value: _levelIcon,
          onChanged: (v) => setState(() => _levelIcon = v),
        ),
        const SizedBox(height: 20),
        Text('Level Number',
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.white54,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _NumberStepper(
          value: _levelNumber,
          min: 1,
          max: 99,
          onChanged: (v) => setState(() => _levelNumber = v),
        ),

        // FIX: warn inline if the chosen number already exists
        if (_existingLevels
            .any((l) => (l['level_number'] as num?)?.toInt() == _levelNumber))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(Icons.warning_rounded, color: _red, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Level $_levelNumber already exists! Choose a different number.',
                  style: GoogleFonts.nunito(fontSize: 12, color: _red),
                ),
              ),
            ]),
          ),

        const SizedBox(height: 20),
        Text('Stars Required to Unlock',
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.white54,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _NumberStepper(
          value: _starsRequired,
          min: 0,
          max: 999,
          step: 10,
          onChanged: (v) => setState(() => _starsRequired = v),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: Colors.white38),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Level 1 should be 0 stars. Each subsequent level is typically +30 stars.',
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.white38),
            ),
          ),
        ]),
      ]),
    );
  }

  // FIX: widget that displays the existing levels for the selected subject
  Widget _buildExistingLevelsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.layers_rounded, color: _accent, size: 18),
          const SizedBox(width: 8),
          Text(
            'Existing Levels (${_existingLevels.length})',
            style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white),
          ),
        ]),
        const SizedBox(height: 12),
        ..._existingLevels.map((l) {
          final levelNum = (l['level_number'] as num?)?.toInt() ?? 0;
          final title = l['title'] as String? ?? '';
          final icon = l['icon'] as String? ?? '🎯';
          final stars = (l['stars_required'] as num?)?.toInt() ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _green.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    '$levelNum',
                    style: GoogleFonts.fredoka(fontSize: 14, color: _green),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style:
                      GoogleFonts.nunito(fontSize: 13, color: Colors.white70),
                ),
              ),
              Row(children: [
                const Icon(Icons.star_rounded,
                    size: 12, color: Color(0xFFFFD700)),
                const SizedBox(width: 3),
                Text('$stars',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.white38)),
              ]),
            ]),
          );
        }),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _accent.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.add_circle_rounded, color: _accent, size: 16),
            const SizedBox(width: 8),
            Text(
              'Adding Level $_levelNumber next',
              style: GoogleFonts.nunito(
                  fontSize: 12, color: _accent, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ]),
    );
  }

  // =====================================================================
  // STEP 2 — Questions
  // =====================================================================

  Widget _buildStep2Questions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('❓', 'Add Questions'),
        const SizedBox(height: 4),
        Text('Minimum 1 question. Each question has 4 options.',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 20),
        ..._questions.asMap().entries.map((entry) {
          final i = entry.key;
          return _buildQuestionCard(i);
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => _questions.add(_QuestionDraft())),
          icon: const Icon(Icons.add_circle_rounded, color: _accent),
          label: Text('Add Another Question',
              style: GoogleFonts.fredoka(fontSize: 16, color: _accent)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _accent),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ]),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Card header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF2A1050),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Text('Question ${index + 1}',
                style: GoogleFonts.fredoka(fontSize: 16, color: _gold)),
            const Spacer(),
            // Toggle text / image
            GestureDetector(
              onTap: () => setState(() {
                q.isImageQuestion = !q.isImageQuestion;
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: q.isImageQuestion
                      ? Colors.blue.withValues(alpha: 0.2)
                      : _accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: q.isImageQuestion ? Colors.blue : _accent,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    q.isImageQuestion
                        ? Icons.image_rounded
                        : Icons.text_fields_rounded,
                    size: 14,
                    color: q.isImageQuestion ? Colors.blue : _accent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    q.isImageQuestion ? 'Image Q' : 'Text Q',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: q.isImageQuestion ? Colors.blue : _accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ),
            ),
            if (_questions.length > 1) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _questions[index].dispose();
                  _questions.removeAt(index);
                }),
                child: const Icon(Icons.delete_rounded, color: _red, size: 20),
              ),
            ],
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Question input — text or image
            if (q.isImageQuestion) ...[
              _buildImagePicker(index, q),
            ] else ...[
              _inputLabel('Question Text'),
              TextField(
                controller: q.questionCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Type your question here...'),
              ),
            ],

            const SizedBox(height: 16),
            _inputLabel('Answer Options'),
            const SizedBox(height: 8),

            ...List.generate(4, (oi) => _buildOptionField(q, oi, index)),

            const SizedBox(height: 16),
            _inputLabel('Correct Answer'),
            const SizedBox(height: 8),
            Row(
                children: List.generate(4, (oi) {
              final selected = q.correctIndex == oi;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => q.correctIndex = oi),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: oi < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? _green.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? _green : Colors.white12,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(children: [
                      Text(['A', 'B', 'C', 'D'][oi],
                          style: GoogleFonts.fredoka(
                              fontSize: 16,
                              color: selected ? _green : Colors.white54)),
                      if (selected)
                        const Icon(Icons.check_rounded,
                            color: _green, size: 14),
                    ]),
                  ),
                ),
              );
            })),

            const SizedBox(height: 16),
            _inputLabel('Fun Fact (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: q.funFactCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration:
                  _inputDecoration('A cool fact shown after answering...'),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildOptionField(_QuestionDraft q, int optionIndex, int qIndex) {
    final letters = ['A', 'B', 'C', 'D'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: q.correctIndex == optionIndex
                ? _green.withValues(alpha: 0.2)
                : _accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: q.correctIndex == optionIndex ? _green : _accent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(letters[optionIndex],
                style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: q.correctIndex == optionIndex ? _green : _accent)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: q.optionCtrls[optionIndex],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration:
                _inputDecoration('Option ${letters[optionIndex]}...').copyWith(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildImagePicker(int index, _QuestionDraft q) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputLabel('Question Image'),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _uploadingImage ? null : () => _pickImage(index),
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: q.uploadedImageUrl != null ? _green : Colors.white24,
              width: 1.5,
            ),
          ),
          child: _uploadingImage
              ? const Center(child: CircularProgressIndicator(color: _accent))
              : q.uploadedImageUrl != null
                  ? Stack(fit: StackFit.expand, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(q.uploadedImageUrl!,
                            fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ])
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_rounded,
                            color: Colors.white38, size: 40),
                        const SizedBox(height: 8),
                        Text('Tap to upload image',
                            style: GoogleFonts.nunito(
                                fontSize: 14, color: Colors.white38)),
                        const SizedBox(height: 4),
                        Text('JPG, PNG, GIF — max 10 MB',
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: Colors.white24)),
                      ],
                    ),
        ),
      ),
      if (q.uploadedImageUrl != null) ...[
        const SizedBox(height: 8),
        _inputLabel('Optional caption (question text below image)'),
        const SizedBox(height: 6),
        TextField(
          controller: q.questionCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: _inputDecoration('e.g. "What is shown in this image?"'),
        ),
      ],
    ]);
  }

  // =====================================================================
  // STEP 3 — Review
  // =====================================================================

  Widget _buildStep3Review() {
    final subjName = _createNewSubject
        ? _subjectNameCtrl.text.trim().isEmpty
            ? '(unnamed subject)'
            : _subjectNameCtrl.text.trim()
        : _selectedSubjectName;
    final emoji = _createNewSubject ? _subjectEmoji : _selectedSubjectEmoji;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('🔍', 'Review & Publish'),
        const SizedBox(height: 8),
        Text('Check your quiz before publishing.',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 20),

        // Subject card
        _ReviewCard(
          icon: '📚',
          title: 'Subject',
          content: '$emoji $subjName'.trim(),
        ),
        const SizedBox(height: 12),

        // Level card
        _ReviewCard(
          icon: _levelIcon,
          title: 'Level $_levelNumber — ${_levelTitleCtrl.text.trim()}',
          content: '⭐ $_starsRequired stars required to unlock',
        ),
        const SizedBox(height: 12),

        // Questions summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('❓', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                  '${_questions.length} Question${_questions.length == 1 ? '' : 's'}',
                  style:
                      GoogleFonts.fredoka(fontSize: 18, color: Colors.white)),
            ]),
            const SizedBox(height: 12),
            ..._questions.asMap().entries.map((e) {
              final i = e.key;
              final q = e.value;
              final preview = q.isImageQuestion
                  ? (q.uploadedImageUrl != null
                      ? '🖼️ Image question'
                      : '🖼️ [no image]')
                  : q.questionCtrl.text.trim().isEmpty
                      ? '(empty)'
                      : q.questionCtrl.text.trim();
              final correct = ['A', 'B', 'C', 'D'][q.correctIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: GoogleFonts.fredoka(
                                  fontSize: 12, color: _accent)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(preview,
                                  style: GoogleFonts.nunito(
                                      fontSize: 13, color: Colors.white70),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              Text('Correct: Option $correct',
                                  style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      color: _green,
                                      fontWeight: FontWeight.w700)),
                            ]),
                      ),
                    ]),
              );
            }),
          ]),
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: _gold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Once published, this quiz is immediately stored in your database.',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.white70, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // =====================================================================
  // Helpers — shared UI builders
  // =====================================================================

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _inputLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          decoration: _inputDecoration(hint),
        ),
      ]),
    );
  }

  Widget _emojiField({
    required String label,
    required String value,
    required void Function(String) onChanged,
  }) {
    final ctrl = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _inputLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 22),
          maxLength: 2,
          onChanged: onChanged,
          decoration: _inputDecoration('e.g. 🧪').copyWith(counterText: ''),
        ),
      ]),
    );
  }

  Widget _inputLabel(String text) => Text(
        text,
        style: GoogleFonts.nunito(
            fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w700),
      );

  Widget _sectionTitle(String emoji, String title) => Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
      ]);

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

// =====================================================================
// Small reusable widgets
// =====================================================================

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _accent : _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _accent : Colors.white12),
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: active ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final void Function(int) onChanged;
  const _NumberStepper({
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StepBtn(
        icon: Icons.remove_rounded,
        onTap: value > min ? () => onChanged(value - step) : null,
      ),
      const SizedBox(width: 12),
      Text('$value',
          style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
      const SizedBox(width: 12),
      _StepBtn(
        icon: Icons.add_rounded,
        onTap: value < max ? () => onChanged(value + step) : null,
      ),
    ]);
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? _accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onTap != null ? _accent : Colors.white12),
        ),
        child: Icon(icon,
            size: 20, color: onTap != null ? _accent : Colors.white24),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String icon;
  final String title;
  final String content;
  const _ReviewCard(
      {required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 4),
            Text(content,
                style: GoogleFonts.nunito(fontSize: 13, color: Colors.white54)),
          ]),
        ),
      ]),
    );
  }
}

// =====================================================================
// PUZZLE WIZARD
// Steps: 0=Details & Image  1=Review & Publish
// =====================================================================

class _PuzzleWizard extends StatefulWidget {
  const _PuzzleWizard();
  @override
  State<_PuzzleWizard> createState() => _PuzzleWizardState();
}

class _PuzzleWizardState extends State<_PuzzleWizard> {
  final AdminService _svc = AdminService();

  // ── Step 0 fields ──────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'General');
  int _pieceCount = 16;
  String _difficulty = 'Easy';
  XFile? _imageFile;
  String? _uploadedImageUrl;
  bool _uploadingImage = false;

  // ── Existing puzzles list ───────────────────────────────────
  List<Map<String, dynamic>> _existingPuzzles = [];
  bool _loadingPuzzles = true;

  // ── Step ───────────────────────────────────────────────────
  int _step = 0;

  // ── Publishing ─────────────────────────────────────────────
  bool _publishing = false;
  bool _published = false;
  String _publishStatus = '';

  // Piece count options
  static const List<int> _pieceCounts = [9, 16, 25, 36];
  static const List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  static const List<String> _categories = [
    'General', 'Nature', 'Animals', 'Cities', 'Science', 'History', 'Art'
  ];

  @override
  void initState() {
    super.initState();
    _fetchExistingPuzzles();
  }

  Future<void> _fetchExistingPuzzles() async {
    final list = await _svc.getPuzzles();
    if (mounted) {
      setState(() {
        _existingPuzzles = list;
        _loadingPuzzles = false;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  // ── Image Pick & Upload ────────────────────────────────────

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _uploadingImage = true;
      _imageFile = picked;
    });

    final url = await _svc.uploadImage(picked);
    if (mounted) {
      setState(() {
        _uploadingImage = false;
        if (url != null) {
          _uploadedImageUrl = url;
          _showSnack('Image uploaded ✓');
        } else {
          _showSnack('Image upload failed', isError: true);
        }
      });
    }
  }

  // ── Validation ─────────────────────────────────────────────

  String? _validateStep0() {
    if (_titleCtrl.text.trim().isEmpty) return 'Puzzle title is required';
    if (_uploadedImageUrl == null) return 'Please upload a puzzle image first';
    return null;
  }

  void _nextStep() async {
    if (_step == 0) {
      final err = _validateStep0();
      if (err != null) {
        _showSnack(err, isError: true);
        return;
      }
      setState(() => _step = 1);
    } else {
      _publish();
    }
  }

  // ── Publish ────────────────────────────────────────────────

  Future<void> _publish() async {
    setState(() {
      _publishing = true;
      _publishStatus = 'Creating puzzle...';
    });

    final result = await _svc.createPuzzle(
      title: _titleCtrl.text.trim(),
      imageUrl: _uploadedImageUrl!,
      pieceCount: _pieceCount,
      category: _categoryCtrl.text.trim().isEmpty
          ? 'General'
          : _categoryCtrl.text.trim(),
      difficulty: _difficulty,
    );

    if (mounted) {
      if (result != null) {
        setState(() {
          _publishing = false;
          _published = true;
          _publishStatus = '';
        });
        _fetchExistingPuzzles();
      } else {
        setState(() {
          _publishing = false;
          _publishStatus = '';
        });
        _showSnack('Failed to create puzzle', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? _red : _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _deletePuzzle(int id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: Text('Delete Puzzle',
            style: GoogleFonts.fredoka(color: Colors.white)),
        content: Text('Delete "$title"? This cannot be undone.',
            style: GoogleFonts.nunito(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.nunito(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: GoogleFonts.nunito(color: _red))),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await _svc.deletePuzzle(id);
      if (ok) {
        _showSnack('Puzzle deleted');
        _fetchExistingPuzzles();
      } else {
        _showSnack('Delete failed', isError: true);
      }
    }
  }

  // =====================================================================
  // BUILD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    if (_published) return _buildSuccessScreen();

    return Column(children: [
      _buildStepIndicator(),
      Expanded(
        child: _step == 0 ? _buildStep0() : _buildStep1Review(),
      ),
      _buildBottomBar(),
    ]);
  }

  // ── Step Indicator ─────────────────────────────────────────

  Widget _buildStepIndicator() {
    final steps = ['Details', 'Review'];
    return Container(
      color: _card,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final label = e.value;
          final active = i == _step;
          final done = i < _step;
          return Expanded(
            child: Row(children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: done ? _green : active ? _accent : Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : Text('${i + 1}',
                            style: GoogleFonts.fredoka(
                                fontSize: 14,
                                color: active ? Colors.white : Colors.white38)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(label,
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: active ? _accent : Colors.white38,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500)),
              ]),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: done ? _green : Colors.white12,
                  ),
                ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isLast = _step == 1;
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _publishing ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLast ? _gold : _accent,
            foregroundColor: isLast ? Colors.black87 : Colors.white,
            disabledBackgroundColor: _accent.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _publishing
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 12),
                  Text(_publishStatus,
                      style: GoogleFonts.fredoka(
                          fontSize: 16, color: Colors.white)),
                ])
              : Text(
                  isLast ? '🚀  Publish Puzzle' : 'Continue →',
                  style: GoogleFonts.fredoka(fontSize: 18),
                ),
        ),
      ),
    );
  }

  // ── Success Screen ─────────────────────────────────────────

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧩', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('Puzzle Published!',
                style: GoogleFonts.fredoka(fontSize: 36, color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              '"${_titleCtrl.text}" with $_pieceCount pieces is now live!',
              style: GoogleFonts.nunito(
                  fontSize: 16, color: Colors.white70, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _published = false;
                  _step = 0;
                  _titleCtrl.clear();
                  _categoryCtrl.text = 'General';
                  _imageFile = null;
                  _uploadedImageUrl = null;
                  _pieceCount = 16;
                  _difficulty = 'Easy';
                });
              },
              icon: const Icon(Icons.add_rounded),
              label:
                  Text('Add Another', style: GoogleFonts.fredoka(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // STEP 0 — Puzzle Details & Image
  // =====================================================================

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Section: puzzle details ──────────────────────────
        Row(children: [
          const Text('🧩', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text('Puzzle Details',
              style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        ]),
        const SizedBox(height: 6),
        Text('Fill in the puzzle info and upload the image.',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 20),

        // Title
        _buildField('PUZZLE TITLE', _titleCtrl, hint: 'e.g. Eiffel Tower'),
        const SizedBox(height: 4),

        // Category dropdown
        _buildLabel('CATEGORY'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categories.contains(_categoryCtrl.text)
                  ? _categoryCtrl.text
                  : 'General',
              dropdownColor: _card,
              isExpanded: true,
              style: const TextStyle(color: Colors.white),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: GoogleFonts.nunito(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _categoryCtrl.text = v!),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Difficulty
        _buildLabel('DIFFICULTY'),
        const SizedBox(height: 10),
        Row(
          children: _difficulties.map((d) {
            final active = d == _difficulty;
            final color = d == 'Easy'
                ? _green
                : d == 'Medium'
                    ? const Color(0xFFFFB74D)
                    : _red;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _difficulty = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? color.withOpacity(0.2) : _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: active ? color : Colors.white12, width: 2),
                  ),
                  child: Text(d,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: active ? color : Colors.white54,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Piece count
        _buildLabel('NUMBER OF PIECES'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: _pieceCounts.map((n) {
            final active = n == _pieceCount;
            final label = n == 9
                ? '9  (3×3)'
                : n == 16
                    ? '16  (4×4)'
                    : n == 25
                        ? '25  (5×5)'
                        : '36  (6×6)';
            return GestureDetector(
              onTap: () => setState(() => _pieceCount = n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _accent.withOpacity(0.2) : _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: active ? _accent : Colors.white12, width: 2),
                ),
                child: Text(label,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: active ? _accent : Colors.white54,
                        fontWeight: FontWeight.w700)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Image upload
        _buildLabel('PUZZLE IMAGE'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _uploadingImage ? null : _pickAndUploadImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _uploadedImageUrl != null ? _green : _accent.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: _uploadingImage
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        CircularProgressIndicator(color: _accent),
                        SizedBox(height: 12),
                        Text('Uploading image…', style: TextStyle(color: Colors.white54)),
                      ]),
                    ))
                : _uploadedImageUrl != null
                        ? Column(children: [
                            // ── Jigsaw piece grid preview ──────────────
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(children: [
                                Row(children: [
                                  const Icon(Icons.check_circle_rounded, color: _green, size: 16),
                                  const SizedBox(width: 6),
                                  Text('Image broken into $_pieceCount pieces',
                                      style: GoogleFonts.nunito(fontSize: 13, color: _green, fontWeight: FontWeight.w700)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: _pickAndUploadImage,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(children: [
                                        const Icon(Icons.edit_rounded, color: Colors.white54, size: 14),
                                        const SizedBox(width: 4),
                                        Text('Change', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white54)),
                                      ]),
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                // Actual piece grid
                                _AdminPieceGrid(
                                  imageUrl: _uploadedImageUrl!,
                                  cols: _pieceCount == 9 ? 3 : _pieceCount == 16 ? 4 : _pieceCount == 25 ? 5 : 6,
                                  pieceCount: _pieceCount,
                                ),
                              ]),
                            ),
                          ])
                        : SizedBox(
                            height: 180,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.add_photo_alternate_rounded, size: 48, color: _accent),
                              const SizedBox(height: 12),
                              Text('Tap to upload puzzle image',
                                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
                              const SizedBox(height: 4),
                              Text('JPG, PNG, WEBP — max 10 MB',
                                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.white30)),
                            ]),
                          ),
          ),
        ),
        const SizedBox(height: 32),

        // ── Existing Puzzles ──────────────────────────────────
        Row(children: [
          const Text('📋', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text('Existing Puzzles',
              style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white)),
          const SizedBox(width: 10),
          if (_loadingPuzzles)
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _accent)),
        ]),
        const SizedBox(height: 12),
        if (!_loadingPuzzles && _existingPuzzles.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Text('No puzzles yet. Create your first one!',
                  style:
                      GoogleFonts.nunito(fontSize: 14, color: Colors.white38)),
            ),
          ),
        ..._existingPuzzles.map((p) => _buildPuzzleListItem(p)),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildPuzzleListItem(Map<String, dynamic> p) {
    final imageUrl = p['image_url'] as String? ?? '';
    final title = p['title'] as String? ?? 'Untitled';
    final pieces = p['piece_count'] as int? ?? 0;
    final difficulty = p['difficulty'] as String? ?? '';
    final category = p['category'] as String? ?? '';
    final id = p['id'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(children: [
        // Thumbnail
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
          child: SizedBox(
            width: 80,
            height: 80,
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Text('🧩', style: TextStyle(fontSize: 28))))
                : const Center(
                    child: Text('🧩', style: TextStyle(fontSize: 28))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.fredoka(
                      fontSize: 16, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('$pieces pieces  •  $difficulty  •  $category',
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.white54)),
            ]),
          ),
        ),
        IconButton(
          onPressed: () => _deletePuzzle(id, title),
          icon: const Icon(Icons.delete_outline_rounded, color: _red, size: 22),
        ),
      ]),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {String hint = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _accent, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ]),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: GoogleFonts.nunito(
          fontSize: 13,
          color: Colors.white54,
          fontWeight: FontWeight.w700));

  // =====================================================================
  // STEP 1 — Review
  // =====================================================================

  Widget _buildStep1Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🔍', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text('Review & Publish',
              style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        ]),
        const SizedBox(height: 6),
        Text('Double-check everything before publishing.',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 24),

        // Puzzle piece grid preview
        if (_uploadedImageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: const Color(0xFF160830),
              padding: const EdgeInsets.all(8),
              child: _AdminPieceGrid(
                imageUrl: _uploadedImageUrl!,
                cols: _pieceCount == 9 ? 3 : _pieceCount == 16 ? 4 : _pieceCount == 25 ? 5 : 6,
                pieceCount: _pieceCount,
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Review cards
        _buildReviewRow('📌', 'Title', _titleCtrl.text),
        const SizedBox(height: 10),
        _buildReviewRow('🏷️', 'Category', _categoryCtrl.text),
        const SizedBox(height: 10),
        _buildReviewRow('⚡', 'Difficulty', _difficulty),
        const SizedBox(height: 10),
        _buildReviewRow('🔢', 'Pieces', '$_pieceCount pieces ($_pieceCount pcs)'),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: _gold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Once published, this puzzle will be immediately available in the app.',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.white70, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildReviewRow(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white54)),
          Text(value,
              style: GoogleFonts.fredoka(fontSize: 17, color: Colors.white)),
        ]),
      ]),
    );
  }
}

// =====================================================================
// Jigsaw Path  (bezier tabs & blanks)
// =====================================================================

Path _pzPath(int top, int right, int bottom, int left,
    double cell, double nub) {
  final o = nub;
  final p = Path()..moveTo(o, o);
  _pzH(p, o, o + cell, o,        top    * (-nub));
  _pzV(p, o + cell, o, o + cell, right  *   nub);
  _pzH(p, o + cell, o, o + cell, bottom *   nub);
  _pzV(p, o, o + cell, o,        left   * (-nub));
  return p..close();
}

void _pzH(Path p, double x0, double x1, double y, double n) {
  if (n == 0) { p.lineTo(x1, y); return; }
  final s = x1 > x0 ? 1.0 : -1.0;
  final w = (x1 - x0).abs();
  final mx = x0 + s * w * .5;
  p.lineTo(x0 + s * w * .28, y);
  p.cubicTo(x0 + s * w * .28, y + n * .6, mx - s * w * .12, y + n, mx, y + n);
  p.cubicTo(mx + s * w * .12, y + n, x0 + s * w * .72, y + n * .6, x0 + s * w * .72, y);
  p.lineTo(x1, y);
}

void _pzV(Path p, double x, double y0, double y1, double n) {
  if (n == 0) { p.lineTo(x, y1); return; }
  final s = y1 > y0 ? 1.0 : -1.0;
  final h = (y1 - y0).abs();
  final my = y0 + s * h * .5;
  p.lineTo(x, y0 + s * h * .28);
  p.cubicTo(x + n * .6, y0 + s * h * .28, x + n, my - s * h * .12, x + n, my);
  p.cubicTo(x + n, my + s * h * .12, x + n * .6, y0 + s * h * .72, x, y0 + s * h * .72);
  p.lineTo(x, y1);
}

// =====================================================================
// Jigsaw Clipper
// =====================================================================

class _PzClipper extends CustomClipper<Path> {
  final int eT, eR, eB, eL;
  final double cell, nub;
  const _PzClipper(this.eT, this.eR, this.eB, this.eL, this.cell, this.nub);

  @override
  Path getClip(Size _) => _pzPath(eT, eR, eB, eL, cell, nub);

  @override
  bool shouldReclip(_PzClipper o) =>
      o.eT != eT || o.eR != eR || o.eB != eB || o.eL != eL ||
      o.cell != cell || o.nub != nub;
}

// =====================================================================
// Outline Painter  (draws only the jigsaw stroke, on top of image)
// =====================================================================

class _PzOutline extends CustomPainter {
  final int eT, eR, eB, eL;
  final double cell, nub;
  const _PzOutline(this.eT, this.eR, this.eB, this.eL, this.cell, this.nub);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _pzPath(eT, eR, eB, eL, cell, nub),
      Paint()
        ..color       = Colors.white.withOpacity(.70)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin  = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PzOutline o) => o.cell != cell || o.nub != nub;
}

// =====================================================================
// Single Piece Tile
//
// Correct technique:
//   ClipPath (jigsaw shape)
//     └── SizedBox (canvas: cell + 2·nub square)
//           └── Stack (clipBehavior: Clip.none  ← lets image overflow layout)
//                 └── Positioned(left: nub - col·cell, top: nub - row·cell)
//                       └── Image.network (rendered at cols·cell square)
//
// The Positioned shifts the FULL image so that piece (row,col) aligns
// with the canvas's (nub,nub) origin.  Stack's Clip.none lets it paint
// beyond the stack's own bounds.  ClipPath then clips all that painting
// to the jigsaw bezier shape.
// =====================================================================

class _PzTile extends StatelessWidget {
  final String imageUrl;
  final int row, col, cols;
  final int eT, eR, eB, eL;
  final double cell, nub;

  const _PzTile({
    required this.imageUrl,
    required this.row, required this.col, required this.cols,
    required this.eT, required this.eR, required this.eB, required this.eL,
    required this.cell, required this.nub,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sz     = cell + 2 * nub;   // canvas size
    final imgPx  = cell * cols;      // full-image render size
    // Shift so that pixel (col·cell, row·cell) of the image
    // lands at (nub, nub) inside the canvas.
    final left   = nub - col * cell;
    final top    = nub - row * cell;

    return SizedBox(
      width: sz,
      height: sz,
      child: Stack(children: [

        // ── Jigsaw-clipped image ─────────────────────────────
        ClipPath(
          clipper: _PzClipper(eT, eR, eB, eL, cell, nub),
          child: SizedBox(
            width: sz,
            height: sz,
            child: Stack(
              clipBehavior: Clip.none,        // ← key: image may overflow
              children: [
                Positioned(
                  left:   left,
                  top:    top,
                  width:  imgPx,   // ← must be explicit; without this Flutter
                  height: imgPx,   //   constrains to remaining Stack space → wrong size
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    loadingBuilder: (_, child, prog) {
                      if (prog == null) return child;
                      return Container(
                        color: const Color(0xFF1A0A3D),
                        child: Center(
                          child: SizedBox(
                            width: cell * .3, height: cell * .3,
                            child: const CircularProgressIndicator(
                              color: Color(0xFFFF7043), strokeWidth: 1.5),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1A0A3D),
                      child: Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white24, size: cell * .3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── White jigsaw outline drawn on top ───────────────
        CustomPaint(
          size: Size(sz, sz),
          painter: _PzOutline(eT, eR, eB, eL, cell, nub),
        ),
      ]),
    );
  }
}

// =====================================================================
// Admin Piece Grid
// Displays every piece of the puzzle with the real image visible.
// No ui.Image required — uses Image.network directly.
// =====================================================================

class _AdminPieceGrid extends StatelessWidget {
  final String imageUrl;
  final int cols;
  final int pieceCount;

  const _AdminPieceGrid({
    required this.imageUrl,
    required this.cols,
    required this.pieceCount,
    super.key,
  });

  /// Deterministic edge map — stable per (cols) so preview never jumps.
  List<List<int>> _buildEdges() {
    final rng  = Random(cols * 99991);
    final rows = cols;
    final hj   = List.generate(rows - 1,
        (_) => List.generate(cols, (_) => rng.nextBool() ? 1 : -1));
    final vj   = List.generate(rows,
        (_) => List.generate(cols - 1, (_) => rng.nextBool() ? 1 : -1));
    return List.generate(pieceCount, (i) {
      final r = i ~/ cols, c = i % cols;
      return [
        r == 0        ? 0 : -hj[r - 1][c], // top
        c == cols - 1 ? 0 :  vj[r][c],      // right
        r == rows - 1 ? 0 :  hj[r][c],      // bottom
        c == 0        ? 0 : -vj[r][c - 1],  // left
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw    = MediaQuery.of(context).size.width;
    final gridW = (sw - 80).clamp(120.0, 360.0);
    final cell  = gridW / cols;
    // Nub smaller than game view so preview fits on screen
    final nub   = cell * .20;
    final sz    = cell + 2 * nub;   // single tile canvas size (includes tab overhang)

    // The N×N grid of bodies occupies exactly gridW×gridW.
    // Each tile canvas is sz×sz but the body sits at (nub,nub) inside it.
    // So tile at (r,c) is Positioned at (c*cell - nub, r*cell - nub)
    // so that its body starts at (c*cell, r*cell).
    // Total container = gridW + 2*nub (to accommodate edge tab overhangs).
    final total = gridW + 2 * nub;

    final edges = _buildEdges();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: total,
            height: total,
            color: const Color(0xFF080215),
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(pieceCount, (i) {
                final r = i ~/ cols;
                final c = i % cols;
                final e = edges[i];
                return Positioned(
                  // Place tile so its body (starting at nub offset inside tile)
                  // aligns with cell position in the grid.
                  left: c * cell,          // tile left = c*cell (body starts at c*cell+nub inside tile, but tile's Positioned offsets by nub already)
                  top:  r * cell,
                  child: _PzTile(
                    imageUrl: imageUrl,
                    row: r, col: c, cols: cols,
                    eT: e[0], eR: e[1], eB: e[2], eL: e[3],
                    cell: cell, nub: nub,
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          '$pieceCount pieces  •  swipe right to scroll',
          style: GoogleFonts.nunito(fontSize: 11, color: Colors.white38),
        ),
      ],
    );
  }
}