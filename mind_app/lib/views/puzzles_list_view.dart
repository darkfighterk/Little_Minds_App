// lib/views/puzzles_list_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle_model.dart';
import '../models/user_model.dart';
import '../services/puzzle_service.dart';
import 'puzzle_game_view.dart';
import 'bottom_nav_bar.dart';

class PuzzlesListView extends StatefulWidget {
  final User user;
  const PuzzlesListView({required this.user, super.key});

  @override
  State<PuzzlesListView> createState() => _PuzzlesListViewState();
}

class _PuzzlesListViewState extends State<PuzzlesListView> {
  final PuzzleService _svc = PuzzleService();
  List<PuzzleItem> _puzzles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final list = await _svc.fetchPuzzles();
    if (!mounted) return;
    setState(() {
      _puzzles = list;
      _loading = false;
      if (list.isEmpty) _error = 'No puzzles available yet.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF1A0A3D),
              Color(0xFF0D0520),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ]),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        primaryColor: Color(0xFFFF7043),
        isDark: true,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Puzzles 🧩',
              style: GoogleFonts.fredoka(fontSize: 28, color: Colors.white),
            ),
            Text(
              'Tap a puzzle to start playing!',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.white54),
            ),
          ]),
        ),
        // Refresh button
        GestureDetector(
          onTap: _load,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.refresh_rounded,
                color: Colors.white70, size: 22),
          ),
        ),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF7043)),
      );
    }

    if (_error != null && _puzzles.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🧩', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Try Again', style: GoogleFonts.fredoka(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFFFF7043),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.76,
        ),
        itemCount: _puzzles.length,
        itemBuilder: (context, i) => _PuzzleCard(
          puzzle: _puzzles[i],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PuzzleGameView(
                  puzzle: _puzzles[i],
                  user: widget.user,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Puzzle card widget ────────────────────────────────────────────────

class _PuzzleCard extends StatelessWidget {
  final PuzzleItem puzzle;
  final VoidCallback onTap;

  const _PuzzleCard({required this.puzzle, required this.onTap});

  Color get _diffColor => puzzle.difficulty == 'Easy'
      ? const Color(0xFF4CAF50)
      : puzzle.difficulty == 'Medium'
          ? const Color(0xFFFFB74D)
          : const Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1040),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7043).withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(children: [
                  Image.network(
                    puzzle.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFF2D1B69),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFF7043), strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF2D1B69),
                      child: const Center(
                        child: Text('🧩', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),
                  // Difficulty badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _diffColor.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        puzzle.difficulty,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  // Piece count badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${puzzle.pieceCount}pcs',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // ── Info ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      puzzle.title,
                      style:
                          GoogleFonts.fredoka(fontSize: 15, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      puzzle.category,
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.white38),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7043), Color(0xFFFF9057)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '▶  Play Now',
                          style: GoogleFonts.fredoka(
                              fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}