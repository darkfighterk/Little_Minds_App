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
// MAIN ADMIN VIEW — 4-step wizard
// Steps: 0=Subject  1=Level  2=Questions  3=Review & Publish
// =====================================================================

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
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
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Quiz Creator',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
        leading: _step > 0 && !_published
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => _goTo(_step - 1),
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: _published ? _buildSuccessScreen() : _buildWizard(),
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
