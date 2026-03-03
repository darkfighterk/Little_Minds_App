import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_gate_screen.dart';
import 'play_puzzle_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme — matches create_puzzle_screen.dart
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

class PuzzleListScreen extends StatefulWidget {
  const PuzzleListScreen({super.key});

  @override
  State<PuzzleListScreen> createState() => _PuzzleListScreenState();
}

class _PuzzleListScreenState extends State<PuzzleListScreen> {
  late Future<List<Map<String, dynamic>>> _puzzlesFuture;
  String _search = '';
  String _filterCategory = 'All';
  String _filterDifficulty = 'All';

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
  }

  void _load() {
    setState(() {
      _puzzlesFuture = ApiService().adminGetCrosswords('LittleMind@Admin2024');
    });
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    return all.where((p) {
      final title = (p['title'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString();
      final diff = (p['difficulty'] ?? '').toString();
      final matchSearch =
          _search.isEmpty || title.contains(_search.toLowerCase());
      final matchCat = _filterCategory == 'All' || cat == _filterCategory;
      final matchDiff = _filterDifficulty == 'All' || diff == _filterDifficulty;
      return matchSearch && matchCat && matchDiff;
    }).toList();
  }

  Color _diffColor(String? d) {
    switch (d) {
      case 'Easy':
        return _success;
      case 'Hard':
        return _danger;
      default:
        return _accentSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: _surface,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 120,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              title: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_accent, Color(0xFFBB5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.grid_4x4_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Crosswords',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1D27), Color(0xFF12141E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48, right: 20),
                    child: IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded,
                          color: _textSecondary, size: 20),
                      tooltip: 'Refresh',
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: _border),
            ),
          ),
        ],
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _puzzlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _accent),
              );
            }
            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                onRetry: _load,
              );
            }

            final all = snapshot.data ?? [];
            final filtered = _filtered(all);

            return CustomScrollView(
              slivers: [
                // Search + filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => _search = v),
                            style: const TextStyle(
                                color: _textPrimary, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Search puzzles…',
                              hintStyle: TextStyle(
                                  color: _textSecondary, fontSize: 14),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: _textSecondary, size: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Filter chips row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ..._categories.map((cat) => _FilterChip(
                                    label: cat,
                                    selected: _filterCategory == cat,
                                    onTap: () =>
                                        setState(() => _filterCategory = cat),
                                  )),
                              const SizedBox(width: 8),
                              Container(width: 1, height: 20, color: _border),
                              const SizedBox(width: 8),
                              ..._difficulties.map((d) => _FilterChip(
                                    label: d,
                                    selected: _filterDifficulty == d,
                                    color: d == 'Easy'
                                        ? _success
                                        : d == 'Hard'
                                            ? _danger
                                            : null,
                                    onTap: () =>
                                        setState(() => _filterDifficulty = d),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Stats bar
                        Row(
                          children: [
                            Text(
                              '${filtered.length} puzzle${filtered.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  color: _textSecondary, fontSize: 12),
                            ),
                            const Spacer(),
                            if (all.isNotEmpty)
                              Text(
                                '${all.length} total',
                                style: const TextStyle(
                                    color: _textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // List or empty state
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyState(
                      hasFilters: _search.isNotEmpty ||
                          _filterCategory != 'All' ||
                          _filterDifficulty != 'All',
                      onClear: () => setState(() {
                        _search = '';
                        _filterCategory = 'All';
                        _filterDifficulty = 'All';
                      }),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _PuzzleCard(
                          puzzle: filtered[index],
                          diffColor: _diffColor(filtered[index]['difficulty']),
                          onPlay: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayPuzzleScreen(
                                  puzzleId: filtered[index]['id']),
                            ),
                          ),
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminGateScreen(
                                editId: filtered[index]['id'],
                              ),
                            ),
                          ).then((_) => _load()),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminGateScreen(),
          ),
        ).then((_) => _load()),
        backgroundColor: _accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Puzzle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
  final Color diffColor;
  final VoidCallback onPlay;
  final VoidCallback onEdit;

  const _PuzzleCard({
    required this.puzzle,
    required this.diffColor,
    required this.onPlay,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final title = puzzle['title'] ?? 'Untitled';
    final category = puzzle['category'] ?? 'General';
    final difficulty = puzzle['difficulty'] ?? 'Medium';
    final rows = puzzle['rows'] ?? 0;
    final cols = puzzle['cols'] ?? 0;
    final timer = puzzle['timerMinutes'] ?? 0;
    final id = puzzle['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(16),
          splashColor: _accent.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid preview icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _accent.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.grid_on_rounded,
                          color: _accentSoft, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _MiniChip(label: category, color: _accentSoft),
                              const SizedBox(width: 6),
                              _MiniChip(label: difficulty, color: diffColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      color: _textSecondary,
                      onPressed: onEdit,
                      style: IconButton.styleFrom(
                        backgroundColor: _surfaceHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatItem(
                        icon: Icons.grid_4x4_rounded, label: '${rows}×$cols'),
                    const SizedBox(width: 16),
                    _StatItem(icon: Icons.timer_rounded, label: '$timer min'),
                    const SizedBox(width: 16),
                    _StatItem(icon: Icons.tag_rounded, label: '#$id'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Play',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: _textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
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
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.18) : _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? c.withOpacity(0.5) : _border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : _textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.wifi_off_rounded, color: _danger, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('Connection Error',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              message.length > 80 ? '${message.substring(0, 80)}…' : message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptyState({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters
                    ? Icons.filter_list_off_rounded
                    : Icons.grid_off_rounded,
                color: _textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matches' : 'No puzzles yet',
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try adjusting your filters'
                  : 'Tap "New Puzzle" to create your first crossword',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 14),
                label: const Text('Clear filters'),
                style: TextButton.styleFrom(foregroundColor: _accentSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
