// ============================================================
// admin_view.dart  (UPDATED — deduplication & add to existing levels)
// Place in: lib/views/admin_view.dart
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

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  @override
  State<AdminView> createState() => _AdminModeState();
}

enum _AdminMode { quiz, puzzle, story }

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
          _mode == _AdminMode.quiz
              ? 'Quiz Creator'
              : _mode == _AdminMode.puzzle
                  ? 'Puzzle Creator'
                  : 'Story Creator',
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
              const SizedBox(width: 10),
              _TabChip(
                label: '📖  Stories',
                active: _mode == _AdminMode.story,
                onTap: () => setState(() => _mode = _AdminMode.story),
              ),
            ]),
          ),
        ),
      ),
      body: _mode == _AdminMode.quiz
          ? const _QuizWizard()
          : _mode == _AdminMode.puzzle
              ? const _PuzzleWizard()
              : const _StoryWizard(),
    );
  }
}

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
  int? _selectedLevelId; // If null, we create a new level. If set, we add questions to it.

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

  Future<void> _loadExistingLevels(String subjectId) async {
    setState(() => _loadingExistingLevels = true);
    final levels = await _svc.getLevels(subjectId);
    if (!mounted) return;

    int maxLevelNumber = 0;
    for (final l in levels) {
      final n = (l['level_number'] as num?)?.toInt() ?? 0;
      if (n > maxLevelNumber) maxLevelNumber = n;
    }

    setState(() {
      _existingLevels = levels;
      _loadingExistingLevels = false;
      _levelNumber = maxLevelNumber + 1;
      _starsRequired = maxLevelNumber * 30;
      _selectedLevelId = null;
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
    if (_selectedLevelId != null) return null; // Using existing level
    if (_levelTitleCtrl.text.trim().isEmpty) return 'Level title is required';
    if (_levelIcon.trim().isEmpty) return 'Level icon is required';

    final existingNumbers = _existingLevels
        .map((l) => (l['level_number'] as num?)?.toInt() ?? 0)
        .toSet();
    if (existingNumbers.contains(_levelNumber)) {
      return 'Level $_levelNumber already exists. Select it above to add questions, or choose a different number.';
    }
    return null;
  }

  String? _validateStep2() {
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (!q.isImageQuestion && q.questionCtrl.text.trim().isEmpty) {
        return 'Question ${i + 1}: text is required';
      }
      if (q.isImageQuestion && q.uploadedImageUrl == null) {
        return 'Question ${i + 1}: image required';
      }
      for (int j = 0; j < 4; j++) {
        if (q.optionCtrls[j].text.trim().isEmpty) {
          return 'Question ${i + 1}: all 4 options are required';
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
      final subjectId = _createNewSubject
          ? _subjectIdCtrl.text.trim().toLowerCase().replaceAll(' ', '_')
          : _selectedSubjectId!;
      await _loadExistingLevels(subjectId);
      _goTo(1);
    } else if (_step < 3) {
      _goTo(_step + 1);
    } else {
      _publish();
    }
  }

  Future<void> _publish() async {
    setState(() {
      _publishing = true;
      _publishStatus = 'Preparing...';
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
        _publishFailed('Failed to create subject.');
        return;
      }
      subjectId = _subjectIdCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
    } else {
      subjectId = _selectedSubjectId!;
    }

    int? levelId = _selectedLevelId;
    if (levelId == null) {
      setState(() => _publishStatus = 'Creating level...');
      levelId = await _svc.createLevel(
        subjectId: subjectId,
        levelNumber: _levelNumber,
        title: _levelTitleCtrl.text.trim(),
        icon: _levelIcon,
        starsRequired: _starsRequired,
      );
    }

    if (levelId == null) {
      _publishFailed('Failed to create/identify level.');
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
      content: Text(msg),
      backgroundColor: isError ? _red : _green,
    ));
  }

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
        } else {
          _showSnack('Image upload failed', isError: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _published ? _buildSuccessScreen() : _buildWizard();
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text('Published!',
              style: GoogleFonts.fredoka(fontSize: 32, color: Colors.white)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

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

  Widget _buildStepIndicator() {
    final steps = ['Subject', 'Level', 'Questions', 'Review'];
    return Container(
      color: _card,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (i) {
          final active = i == _step;
          return Text(steps[i],
              style: TextStyle(
                  color: active ? _accent : Colors.white38,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal));
        }),
      ),
    );
  }

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
            foregroundColor: isLast ? Colors.black : Colors.white,
          ),
          child: _publishing
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(isLast ? '🚀 Publish' : 'Continue →'),
        ),
      ),
    );
  }

  Widget _buildStep0Subject() {
    final builtInIds = _builtInSubjects.map((s) => s['id'] as String).toSet();
    final uniqueDbSubjects =
        _dbSubjects.where((s) => !builtInIds.contains(s['id'])).toList();
    final allSubjects = [..._builtInSubjects, ...uniqueDbSubjects];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Choose a Subject',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        const SizedBox(height: 20),
        Row(children: [
          _TabChip(
            label: 'Existing',
            active: !_createNewSubject,
            onTap: () => setState(() => _createNewSubject = false),
          ),
          const SizedBox(width: 10),
          _TabChip(
            label: '+ New',
            active: _createNewSubject,
            onTap: () => setState(() => _createNewSubject = true),
          ),
        ]),
        const SizedBox(height: 20),
        if (!_createNewSubject)
          ...allSubjects.map((s) {
            final selected = _selectedSubjectId == s['id'];
            return ListTile(
              onTap: () => setState(() {
                _selectedSubjectId = s['id'] as String;
                _selectedSubjectName = s['name'] as String;
                _selectedSubjectEmoji = s['emoji'] as String? ?? '';
              }),
              leading: Text(s['emoji'] as String, style: const TextStyle(fontSize: 24)),
              title: Text(s['name'] as String,
                  style: TextStyle(color: selected ? _accent : Colors.white)),
              trailing: selected ? const Icon(Icons.check, color: _accent) : null,
            );
          })
        else ...[
          _buildField('ID', _subjectIdCtrl, hint: 'e.g. math'),
          _buildField('Name', _subjectNameCtrl, hint: 'e.g. Mathematics'),
        ],
      ]),
    );
  }

  Widget _buildStep1Level() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Level Details',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        const SizedBox(height: 20),
        if (_loadingExistingLevels)
          const Center(child: CircularProgressIndicator())
        else if (_existingLevels.isNotEmpty) ...[
          Text('Select an Existing Level to add questions:',
              style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 10),
          ..._existingLevels.map((l) {
            final id = (l['id'] as num).toInt();
            final selected = _selectedLevelId == id;
            return Card(
              color: selected ? _accent.withOpacity(0.2) : _card,
              child: ListTile(
                onTap: () => setState(() {
                  _selectedLevelId = id;
                  _levelNumber = (l['level_number'] as num).toInt();
                  _levelTitleCtrl.text = l['title'] as String;
                  _levelIcon = l['icon'] as String;
                  _starsRequired = (l['stars_required'] as num).toInt();
                }),
                leading: Text(l['icon'] as String),
                title: Text('Level ${l['level_number']}: ${l['title']}',
                    style: const TextStyle(color: Colors.white)),
                trailing: selected ? const Icon(Icons.check, color: _accent) : null,
              ),
            );
          }),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
        ],
        Text(_selectedLevelId == null ? 'Or Create a New Level:' : 'Edit selected level details:',
            style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 10),
        _buildField('Title', _levelTitleCtrl),
        _buildField('Emoji Icon', TextEditingController(text: _levelIcon),
            onChanged: (v) => _levelIcon = v),
        const SizedBox(height: 10),
        Text('Level Number', style: TextStyle(color: Colors.white54)),
        _NumberStepper(
            value: _levelNumber,
            min: 1,
            max: 99,
            onChanged: (v) => setState(() => _levelNumber = v)),
        const SizedBox(height: 20),
        Text('Stars Required', style: TextStyle(color: Colors.white54)),
        _NumberStepper(
            value: _starsRequired,
            min: 0,
            max: 999,
            step: 10,
            onChanged: (v) => setState(() => _starsRequired = v)),
        if (_selectedLevelId != null)
          TextButton(
            onPressed: () => setState(() {
              _selectedLevelId = null;
              _levelTitleCtrl.clear();
            }),
            child: const Text('Cancel selection (Create New)', style: TextStyle(color: _red)),
          ),
      ]),
    );
  }

  Widget _buildStep2Questions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        ..._questions.asMap().entries.map((e) => _buildQuestionCard(e.key)),
        ElevatedButton(
          onPressed: () => setState(() => _questions.add(_QuestionDraft())),
          child: const Text('Add Another Question'),
        ),
      ]),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];
    return Card(
      color: _card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Text('Question ${index + 1}', style: const TextStyle(color: _gold)),
            const Spacer(),
            Switch(
                value: q.isImageQuestion,
                onChanged: (v) => setState(() => q.isImageQuestion = v)),
            const Text('Image?', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
          if (q.isImageQuestion) ...[
            GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                height: 100,
                width: double.infinity,
                color: Colors.white10,
                child: q.uploadedImageUrl != null
                    ? Image.network(q.uploadedImageUrl!)
                    : const Icon(Icons.add_a_photo, color: Colors.white38),
              ),
            ),
          ],
          TextField(
            controller: q.questionCtrl,
            decoration: const InputDecoration(hintText: 'Question Text'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          ...List.generate(4, (i) => TextField(
            controller: q.optionCtrls[i],
            decoration: InputDecoration(hintText: 'Option ${['A','B','C','D'][i]}'),
            style: const TextStyle(color: Colors.white),
          )),
          const SizedBox(height: 10),
          DropdownButton<int>(
            value: q.correctIndex,
            dropdownColor: _card,
            items: List.generate(4, (i) => DropdownMenuItem(value: i, child: Text('Correct: ${['A','B','C','D'][i]}', style: const TextStyle(color: Colors.white)))),
            onChanged: (v) => setState(() => q.correctIndex = v!),
          ),
        ]),
      ),
    );
  }

  Widget _buildStep3Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Review', style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        const SizedBox(height: 20),
        Text('Subject: $_selectedSubjectName', style: const TextStyle(color: Colors.white70)),
        Text('Level $_levelNumber: ${_levelTitleCtrl.text}', style: const TextStyle(color: Colors.white70)),
        Text('Questions: ${_questions.length}', style: const TextStyle(color: Colors.white70)),
      ]),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String hint = '', Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label, hintText: hint, labelStyle: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: active ? _accent : _card, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: const TextStyle(color: Colors.white)),
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
  const _NumberStepper({required this.value, required this.min, required this.max, this.step = 1, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(icon: const Icon(Icons.remove, color: _accent), onPressed: value > min ? () => onChanged(value - step) : null),
      Text('$value', style: const TextStyle(color: Colors.white, fontSize: 18)),
      IconButton(icon: const Icon(Icons.add, color: _accent), onPressed: value < max ? () => onChanged(value + step) : null),
    ]);
  }
}

class _PuzzleWizard extends StatefulWidget {
  const _PuzzleWizard();
  @override
  State<_PuzzleWizard> createState() => _PuzzleWizardState();
}

class _PuzzleWizardState extends State<_PuzzleWizard> {
  final AdminService _svc = AdminService();
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'General');
  int _pieceCount = 16;
  String _difficulty = 'Easy';
  XFile? _imageFile;
  String? _uploadedImageUrl;
  bool _uploadingImage = false;
  List<Map<String, dynamic>> _existingPuzzles = [];
  bool _loadingPuzzles = true;
  int _step = 0;
  bool _publishing = false;
  bool _published = false;
  String _publishStatus = '';

  static const List<int> _pieceCounts = [9, 16, 25, 36];
  static const List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  static const List<String> _categories = ['General', 'Nature', 'Animals', 'Cities', 'Science', 'History', 'Art'];

  @override
  void initState() {
    super.initState();
    _fetchExistingPuzzles();
  }

  Future<void> _fetchExistingPuzzles() async {
    final list = await _svc.getPuzzles();
    if (mounted) setState(() { _existingPuzzles = list; _loadingPuzzles = false; });
  }

  @override
  void dispose() { _titleCtrl.dispose(); _categoryCtrl.dispose(); super.dispose(); }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() { _uploadingImage = true; _imageFile = picked; });
    final url = await _svc.uploadImage(picked);
    if (mounted) setState(() { _uploadingImage = false; _uploadedImageUrl = url; });
  }

  void _nextStep() async {
    if (_step == 0) {
      if (_titleCtrl.text.isEmpty || _uploadedImageUrl == null) return;
      setState(() => _step = 1);
    } else { _publish(); }
  }

  Future<void> _publish() async {
    setState(() { _publishing = true; _publishStatus = 'Creating...'; });
    final result = await _svc.createPuzzle(title: _titleCtrl.text, imageUrl: _uploadedImageUrl!, pieceCount: _pieceCount, category: _categoryCtrl.text, difficulty: _difficulty);
    if (mounted) {
      if (result != null) { setState(() { _publishing = false; _published = true; }); _fetchExistingPuzzles(); }
      else { setState(() { _publishing = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_published) return const Center(child: Text('Puzzle Published!', style: TextStyle(color: Colors.white, fontSize: 24)));
    return Column(children: [
      Expanded(child: _step == 0 ? SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title'), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 20),
        GestureDetector(onTap: _pickAndUploadImage, child: Container(height: 150, width: double.infinity, color: Colors.white10, child: _uploadedImageUrl != null ? Image.network(_uploadedImageUrl!) : const Icon(Icons.add_a_photo, color: Colors.white38))),
      ])) : const Center(child: Text('Review', style: TextStyle(color: Colors.white)))),
      ElevatedButton(onPressed: _nextStep, child: Text(_step == 0 ? 'Continue' : 'Publish')),
    ]);
  }
}

class _StoryWizard extends StatefulWidget {
  const _StoryWizard();
  @override
  State<_StoryWizard> createState() => _StoryWizardState();
}

class _StoryWizardState extends State<_StoryWizard> {
  @override
  Widget build(BuildContext context) => const Center(child: Text('Story Wizard Coming Soon', style: TextStyle(color: Colors.white)));
}
