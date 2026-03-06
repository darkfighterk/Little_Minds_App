import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'create_puzzle_screen.dart'; // AdminGateScreen
import 'play_puzzle_screen.dart'; // PlayPuzzleScreen

// ─────────────────────────────────────────────────────────────────────────────
// Theme
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
// Puzzle List Screen
// ─────────────────────────────────────────────────────────────────────────────

class PuzzleListScreen extends StatefulWidget {
  const PuzzleListScreen({super.key});

  @override
  State<PuzzleListScreen> createState() => _PuzzleListScreenState();
}

class _PuzzleListScreenState extends State<PuzzleListScreen> {
  List<dynamic> _puzzles = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  static const _categories = [
    'All',
    'General',
    'Science',
    'History',
    'Nature',
    'Sports',
    'Music',
    'Kids'
  ];
  static const _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // ✅ PUBLIC endpoint — no admin key needed
      final data = await ApiService().getCrosswords();
      if (!mounted) return;
      setState(() {
        _puzzles = data;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load puzzles. Check your connection and try again.';
      });
    }
  }

  void _applyFilters() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _puzzles.where((p) {
        final title = (p['title'] ?? '').toString().toLowerCase();
        final cat = (p['category'] ?? '').toString();
        final diff = (p['difficulty'] ?? '').toString();
        return (query.isEmpty || title.contains(query)) &&
            (_selectedCategory == 'All' || cat == _selectedCategory) &&
            (_selectedDifficulty == 'All' || diff == _selectedDifficulty);
      }).toList();
    });
  }

  void _goToAdmin({int? editId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminGateScreen()),
    ).then((_) => _load());
  }

  Color _difficultyColor(String diff) {
    switch (diff) {
      case 'Easy':
        return _success;
      case 'Hard':
        return _danger;
      default:
        return _accentSoft;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crossword Puzzles',
          style: TextStyle(
              color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded,
                color: _accentSoft),
            tooltip: 'Admin',
            onPressed: () => _goToAdmin(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToAdmin(),
        backgroundColor: _accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Puzzle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: _textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search puzzles…',
              hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: _textSecondary, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: _textSecondary, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              filled: true,
              fillColor: _bg,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _accent, width: 1.5)),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._categories.map((c) => _FilterChip(
                      label: c,
                      active: _selectedCategory == c,
                      onTap: () {
                        setState(() => _selectedCategory = c);
                        _applyFilters();
                      },
                    )),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: _border),
                const SizedBox(width: 8),
                ..._difficulties.map((d) => _FilterChip(
                      label: d,
                      active: _selectedDifficulty == d,
                      color: d == 'Easy'
                          ? _success
                          : d == 'Hard'
                              ? _danger
                              : null,
                      onTap: () {
                        setState(() => _selectedDifficulty = d);
                        _applyFilters();
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: _textSecondary, size: 56),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🧩', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                _puzzles.isEmpty
                    ? 'No puzzles yet.\nTap "+ New Puzzle" to create one!'
                    : 'No puzzles match your filters.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, fontSize: 14),
              ),
              if (_puzzles.isEmpty) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _goToAdmin(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create First Puzzle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: _accent,
      backgroundColor: _surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _PuzzleCard(
          puzzle: _filtered[i],
          onPlay: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayPuzzleScreen(
                puzzleId: _filtered[i]['id'] as int,
              ),
            ),
          ),
          onEdit: () => _goToAdmin(editId: _filtered[i]['id'] as int?),
          difficultyColor:
              _difficultyColor((_filtered[i]['difficulty'] ?? '').toString()),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Puzzle Card
// ─────────────────────────────────────────────────────────────────────────────

class _PuzzleCard extends StatelessWidget {
  final Map<String, dynamic> puzzle;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final Color difficultyColor;

  const _PuzzleCard({
    required this.puzzle,
    required this.onPlay,
    required this.onEdit,
    required this.difficultyColor,
  });

  @override
  Widget build(BuildContext context) {
    final title = puzzle['title'] ?? 'Untitled';
    final category = puzzle['category'] ?? 'General';
    final difficulty = puzzle['difficulty'] ?? 'Medium';
    // Backend may return 'rows'/'cols' or 'grid_rows'/'grid_cols'
    final rows = puzzle['rows'] ?? puzzle['grid_rows'] ?? '?';
    final cols = puzzle['cols'] ?? puzzle['grid_cols'] ?? '?';
    final timer = puzzle['timerMinutes'] ?? puzzle['timer_minutes'] ?? 10;
    final id = puzzle['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: _textSecondary, size: 18),
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: _surfaceHigh,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(label: category, color: _accentSoft),
                _Tag(label: difficulty, color: difficultyColor, filled: true),
                _Tag(label: '${rows}×$cols grid', color: _textSecondary),
                _Tag(label: '⏱ $timer min', color: _textSecondary),
                if (id != null) _Tag(label: '#$id', color: _border),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded,
                    size: 18, color: Colors.white),
                label: const Text('Play',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  const _Tag({required this.label, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.15) : _surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: filled ? color.withOpacity(0.4) : _border),
      ),
      child: Text(label,
          style: TextStyle(
              color: filled ? color : _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? color;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? _accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? c.withOpacity(0.15) : _surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: active ? c : _border, width: active ? 1.5 : 1),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? c : _textSecondary,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}
