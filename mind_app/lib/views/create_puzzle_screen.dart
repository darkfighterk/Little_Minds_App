import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/puzzle.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme constants
// ─────────────────────────────────────────────────────────────────────────────

const _bg = Color(0xFF0F1117);
const _surface = Color(0xFF1A1D27);
const _surfaceHigh = Color(0xFF23273A);
const _accent = Color(0xFF6C63FF);
const _accentSoft = Color(0xFF9B94FF);
const _danger = Color(0xFFFF5C5C);
const _success = Color(0xFF4ADE80);
const _textPrimary = Color(0xFFF0F0F5);
const _textSecondary = Color(0xFF9395A5);
const _border = Color(0xFF2E3248);

// ─────────────────────────────────────────────────────────────────────────────
// Admin Gate Screen — key input before showing editor
// ─────────────────────────────────────────────────────────────────────────────

class AdminGateScreen extends StatefulWidget {
  const AdminGateScreen({super.key});

  @override
  State<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends State<AdminGateScreen>
    with SingleTickerProviderStateMixin {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;
  bool _checking = false;
  String? _error;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Admin key is required');
      _shakeCtrl.forward(from: 0);
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      await ApiService().adminGetCrosswords(key);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePuzzleScreen(adminKey: key),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            e.toString().contains('403') || e.toString().contains('Invalid')
                ? 'Incorrect admin key. Access denied.'
                : 'Could not reach server. Check connection.';
        _checking = false;
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_accent, Color(0xFFBB5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 38),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Admin Access',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your admin key to create\nor manage crossword puzzles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _textSecondary, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (context, child) {
                    final offset = _error != null
                        ? (4.0 *
                            (1 - _shakeAnim.value) *
                            ((_shakeCtrl.value * 6).toInt().isEven ? 1 : -1))
                        : 0.0;
                    return Transform.translate(
                        offset: Offset(offset, 0), child: child);
                  },
                  child: _AdminTextField(
                    controller: _keyCtrl,
                    label: 'Admin Key',
                    hint: 'Enter your secret admin key',
                    obscure: _obscure,
                    prefixIcon: Icons.key_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: _textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    onSubmitted: (_) => _verify(),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _GradientButton(
                    onPressed: _checking ? null : _verify,
                    child: _checking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_open_rounded,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Unlock Admin Panel',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Create / Edit Puzzle Screen
// ─────────────────────────────────────────────────────────────────────────────

class CreatePuzzleScreen extends StatefulWidget {
  final String adminKey;
  final int? editId;

  const CreatePuzzleScreen({
    super.key,
    required this.adminKey,
    this.editId,
  });

  @override
  State<CreatePuzzleScreen> createState() => _CreatePuzzleScreenState();
}

class _CreatePuzzleScreenState extends State<CreatePuzzleScreen>
    with TickerProviderStateMixin {
  final _titleCtrl = TextEditingController(text: 'My New Crossword');
  final _formKey = GlobalKey<FormState>();

  int rows = 10;
  int cols = 10;
  int selectedTimerMinutes = 10;
  String selectedCategory = 'General';
  String selectedDifficulty = 'Medium';
  late List<List<Cell>> grid;
  List<Clue> across = [];
  List<Clue> down = [];

  bool _isSaving = false;
  bool _isLoading = false;
  int _activeTab = 0;
  late TabController _tabCtrl;

  static const _categories = [
    'General',
    'Science',
    'History',
    'Nature',
    'Sports',
    'Music',
    'Kids'
  ];
  static const _difficulties = ['Easy', 'Medium', 'Hard'];
  static const _timerOptions = [5, 10, 15, 20, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeTab = _tabCtrl.index);
      }
    });
    _initGrid();
    if (widget.editId != null) _loadExisting();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _initGrid() {
    grid = List.generate(rows, (_) => List.generate(cols, (_) => Cell()));
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    try {
      final data =
          await ApiService().adminGetCrossword(widget.editId!, widget.adminKey);
      if (!mounted) return;
      setState(() {
        _titleCtrl.text = data['title'] ?? '';
        rows = data['rows'] ?? 10;
        cols = data['cols'] ?? 10;
        selectedTimerMinutes = data['timerMinutes'] ?? 10;
        selectedCategory = data['category'] ?? 'General';
        selectedDifficulty = data['difficulty'] ?? 'Medium';

        final rawGrid = data['gridData'];
        if (rawGrid is List && rawGrid.isNotEmpty) {
          grid = (rawGrid as List)
              .map((row) => (row as List)
                  .map((c) => Cell.fromJson(c as Map<String, dynamic>))
                  .toList())
              .toList();
        } else {
          _initGrid();
        }

        final rawAcross = data['acrossClues'];
        if (rawAcross is List) {
          across = rawAcross
              .map((c) => Clue.fromJson(c as Map<String, dynamic>))
              .toList();
        }
        final rawDown = data['downClues'];
        if (rawDown is List) {
          down = rawDown
              .map((c) => Clue.fromJson(c as Map<String, dynamic>))
              .toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to load puzzle: $e');
    }
  }

  void _updateGridSize() {
    final r = rows.clamp(5, 25);
    final c = cols.clamp(5, 25);
    final newGrid = List.generate(
      r,
      (ri) => List.generate(c, (ci) {
        if (ri < grid.length && ci < grid[ri].length) return grid[ri][ci];
        return Cell();
      }),
    );
    setState(() => grid = newGrid);
  }

  Future<void> _savePuzzle() async {
    if (!_formKey.currentState!.validate()) {
      _tabCtrl.animateTo(0);
      return;
    }
    setState(() => _isSaving = true);
    try {
      if (grid.isEmpty || grid.any((row) => row.isEmpty)) _initGrid();

      final puzzle = Puzzle(
        id: widget.editId ?? 0,
        title: _titleCtrl.text.trim().isEmpty
            ? 'Untitled'
            : _titleCtrl.text.trim(),
        category: selectedCategory,
        difficulty: selectedDifficulty,
        rows: rows,
        cols: cols,
        grid: grid,
        acrossClues: across,
        downClues: down,
        timerMinutes: selectedTimerMinutes,
      );

      if (widget.editId != null) {
        await ApiService()
            .adminUpdateCrossword(widget.editId!, puzzle, widget.adminKey);
      } else {
        await ApiService().adminCreateCrossword(puzzle, widget.adminKey);
      }

      if (!mounted) return;
      _showSuccess(
          widget.editId != null ? 'Crossword updated!' : 'Crossword created!');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: _success, size: 18),
        const SizedBox(width: 10),
        Text(msg, style: const TextStyle(color: _textPrimary)),
      ]),
      backgroundColor: _surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_rounded, color: _danger, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: _textPrimary))),
      ]),
      backgroundColor: _surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _buildDetailsTab(),
                        _buildGridTab(),
                        _buildCluesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: _textSecondary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.editId != null ? 'Edit Crossword' : 'New Crossword',
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text('Admin Panel',
              style: TextStyle(color: _accent, fontSize: 11)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded,
                  size: 12, color: _accentSoft),
              const SizedBox(width: 5),
              Text(
                '${widget.adminKey.substring(0, widget.adminKey.length.clamp(0, 6))}••••',
                style: const TextStyle(
                  color: _accentSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      (Icons.tune_rounded, 'Details'),
      (Icons.grid_on_rounded, 'Grid'),
      (Icons.format_list_bulleted_rounded, 'Clues'),
    ];
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final active = _activeTab == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => _tabCtrl.animateTo(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(e.value.$1,
                        size: 14,
                        color: active ? Colors.white : _textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      e.value.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? Colors.white : _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Tab 1: Details ─────────────────────────────────────────────────────────

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'Basic Info',
          icon: Icons.info_outline_rounded,
          children: [
            _AdminTextField(
              controller: _titleCtrl,
              label: 'Puzzle Title',
              hint: 'e.g. Animals of the World',
              prefixIcon: Icons.title_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DropdownField<String>(
                    label: 'Category',
                    value: selectedCategory,
                    items: _categories,
                    icon: Icons.category_rounded,
                    onChanged: (v) => setState(() => selectedCategory = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField<String>(
                    label: 'Difficulty',
                    value: selectedDifficulty,
                    items: _difficulties,
                    icon: Icons.bar_chart_rounded,
                    onChanged: (v) => setState(() => selectedDifficulty = v!),
                    itemColor: (v) => v == 'Easy'
                        ? _success
                        : v == 'Hard'
                            ? _danger
                            : _accentSoft,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Grid Size',
          icon: Icons.grid_view_rounded,
          children: [
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Rows',
                    value: rows,
                    min: 5,
                    max: 25,
                    onChanged: (v) {
                      rows = v;
                      _updateGridSize();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: 'Columns',
                    value: cols,
                    min: 5,
                    max: 25,
                    onChanged: (v) {
                      cols = v;
                      _updateGridSize();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: _textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Grid: ${rows}×$cols = ${rows * cols} cells',
                    style: const TextStyle(color: _textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Timer',
          icon: Icons.timer_rounded,
          children: [
            const Text(
              'Duration limit for players',
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timerOptions.map((min) {
                final selected = selectedTimerMinutes == min;
                return GestureDetector(
                  onTap: () => setState(() => selectedTimerMinutes = min),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _accent : _bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? _accent : _border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '$min min',
                      style: TextStyle(
                        color: selected ? Colors.white : _textSecondary,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tab 2: Grid ────────────────────────────────────────────────────────────

  Widget _buildGridTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: _surface,
          child: Row(
            children: [
              _LegendDot(color: Colors.white, label: 'Letter cell'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.black, label: 'Black cell'),
              const Spacer(),
              const Icon(Icons.touch_app_rounded,
                  size: 12, color: _textSecondary),
              const SizedBox(width: 4),
              const Text('Tap=edit  Long=toggle black',
                  style: TextStyle(color: _textSecondary, fontSize: 11)),
            ],
          ),
        ),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildGrid(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final available = MediaQuery.of(context).size.width - 32;
    final raw = available / cols;
    final size = raw.clamp(24.0, 44.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(cols, (c) {
            if (r >= grid.length || c >= grid[r].length) {
              return const SizedBox();
            }
            final cell = grid[r][c];
            return GestureDetector(
              onTap: () => _editCell(r, c),
              onLongPress: () => setState(() => cell.isBlack = !cell.isBlack),
              child: Container(
                width: size,
                height: size,
                margin: const EdgeInsets.all(0.5),
                decoration: BoxDecoration(
                  color: cell.isBlack ? const Color(0xFF111318) : Colors.white,
                  border: Border.all(
                    color: cell.isBlack
                        ? const Color(0xFF222530)
                        : const Color(0xFFCCCCDD),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    if (cell.number != null)
                      Positioned(
                        top: 1,
                        left: 2,
                        child: Text(
                          '${cell.number}',
                          style: TextStyle(
                            fontSize: (size * 0.25).clamp(6.0, 10.0),
                            color: cell.isBlack ? Colors.white38 : _accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (!cell.isBlack && cell.solution.isNotEmpty)
                      Center(
                        child: Text(
                          cell.solution,
                          style: TextStyle(
                            fontSize: (size * 0.45).clamp(10.0, 20.0),
                            color: const Color(0xFF222244),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  void _editCell(int r, int c) {
    final cell = grid[r][c];
    final numCtrl = TextEditingController(text: cell.number?.toString() ?? '');
    final letterCtrl = TextEditingController(text: cell.solution);
    bool isBlack = cell.isBlack;

    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isBlack ? Colors.black : Colors.white,
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: cell.solution.isNotEmpty
                        ? Center(
                            child: Text(
                            cell.solution,
                            style: TextStyle(
                              color: isBlack ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cell ($r, $c)',
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setModal(() => isBlack = !isBlack),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isBlack ? Colors.black.withOpacity(0.4) : _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isBlack ? Colors.black54 : _border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBlack
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isBlack ? _accentSoft : _textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text('Black cell',
                          style: TextStyle(color: _textPrimary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isBlack) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _AdminTextField(
                        controller: letterCtrl,
                        label: 'Letter',
                        hint: 'A–Z',
                        maxLength: 1,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: _AdminTextField(
                        controller: numCtrl,
                        label: 'Clue Number',
                        hint: 'e.g. 1',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textSecondary,
                        side: const BorderSide(color: _border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _GradientButton(
                      onPressed: () {
                        setState(() {
                          cell.isBlack = isBlack;
                          cell.solution = isBlack
                              ? ''
                              : letterCtrl.text.trim().toUpperCase();
                          cell.number = int.tryParse(numCtrl.text.trim());
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Save Cell',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

  // ── Tab 3: Clues ───────────────────────────────────────────────────────────

  Widget _buildCluesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'Across Clues',
          icon: Icons.arrow_forward_rounded,
          trailing: TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add'),
            style: TextButton.styleFrom(foregroundColor: _accent),
            onPressed: () => setState(
                () => across.add(Clue(number: across.length + 1, text: ''))),
          ),
          children: across.isEmpty
              ? [
                  _EmptyClueHint(
                    onAdd: () =>
                        setState(() => across.add(Clue(number: 1, text: ''))),
                    direction: 'Across',
                  )
                ]
              : across.asMap().entries.map((e) {
                  return _ClueRow(
                    clue: e.value,
                    index: e.key,
                    onChanged: (v) => across[e.key].text = v,
                    onDelete: () => setState(() => across.removeAt(e.key)),
                  );
                }).toList(),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Down Clues',
          icon: Icons.arrow_downward_rounded,
          trailing: TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add'),
            style: TextButton.styleFrom(foregroundColor: _accent),
            onPressed: () => setState(
                () => down.add(Clue(number: down.length + 1, text: ''))),
          ),
          children: down.isEmpty
              ? [
                  _EmptyClueHint(
                    onAdd: () =>
                        setState(() => down.add(Clue(number: 1, text: ''))),
                    direction: 'Down',
                  )
                ]
              : down.asMap().entries.map((e) {
                  return _ClueRow(
                    clue: e.value,
                    index: e.key,
                    onChanged: (v) => down[e.key].text = v,
                    onDelete: () => setState(() => down.removeAt(e.key)),
                  );
                }).toList(),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _isSaving ? null : _savePuzzle,
      backgroundColor: _accent,
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
      label: Text(
        _isSaving
            ? 'Saving…'
            : widget.editId != null
                ? 'Update Puzzle'
                : 'Publish Puzzle',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 16, color: _accentSoft),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final bool obscure;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _AdminTextField({
    this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        counterText: '',
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF4A4D60), fontSize: 13),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _textSecondary, size: 18)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _danger, width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final IconData icon;
  final void Function(T?) onChanged;
  final Color Function(T)? itemColor;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
    this.itemColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: _textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: _surfaceHigh,
              icon: const Icon(Icons.expand_more_rounded,
                  color: _textSecondary, size: 18),
              items: items.map((item) {
                final color = itemColor?.call(item) ?? _textPrimary;
                return DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 8),
                      Text(item.toString(),
                          style: TextStyle(color: color, fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: _textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded, size: 16),
                color: value <= min ? _border : _textSecondary,
                onPressed: value <= min ? null : () => onChanged(value - 1),
              ),
              Expanded(
                child: Center(
                  child: Text('$value',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 16),
                color: value >= max ? _border : _textSecondary,
                onPressed: value >= max ? null : () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClueRow extends StatelessWidget {
  final Clue clue;
  final int index;
  final void Function(String) onChanged;
  final VoidCallback onDelete;

  const _ClueRow({
    required this.clue,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('${clue.number}',
                  style: const TextStyle(
                    color: _accentSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: clue.text,
              onChanged: onChanged,
              style: const TextStyle(color: _textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter clue text…',
                hintStyle:
                    const TextStyle(color: Color(0xFF4A4D60), fontSize: 13),
                filled: true,
                fillColor: _bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _accent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            color: _textSecondary,
            onPressed: onDelete,
            style: IconButton.styleFrom(
              backgroundColor: _bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyClueHint extends StatelessWidget {
  final VoidCallback onAdd;
  final String direction;

  const _EmptyClueHint({required this.onAdd, required this.direction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: _textSecondary.withOpacity(0.5), size: 28),
            const SizedBox(height: 6),
            Text('Tap to add $direction clues',
                style: const TextStyle(color: _textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _GradientButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed == null
                ? const LinearGradient(
                    colors: [Color(0xFF4A4D60), Color(0xFF3A3D50)])
                : const LinearGradient(
                    colors: [_accent, Color(0xFF9B59FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: _textSecondary, fontSize: 11)),
      ],
    );
  }
}
