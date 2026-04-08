import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle_model.dart';
import '../models/user_model.dart';
import '../services/puzzle_service.dart';
import 'puzzle_game_view.dart';
import 'bottom_nav_bar.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

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

  // ──  Core Logic (No changes made here) ──
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
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withOpacity(0.08), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        primaryColor: mainBlue,
        isDark: false,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 18),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Puzzle Arena 🧩',
              style: TextStyle(
                fontFamily: 'Recoleta',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Solve and earn stars!',
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.black45,
                  fontWeight: FontWeight.w700),
            ),
          ]),
        ),
        IconButton(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded, color: mainBlue, size: 28),
        ),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: mainBlue));

    if (_error != null && _puzzles.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🧩', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text(_error!,
              style: const TextStyle(
                  fontFamily: 'Recoleta', fontSize: 18, color: Colors.black38)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainBlue,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Try Again',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: mainBlue,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 0.72,
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

class _PuzzleCard extends StatelessWidget {
  final PuzzleItem puzzle;
  final VoidCallback onTap;

  const _PuzzleCard({required this.puzzle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color diffColor = puzzle.difficulty == 'Easy'
        ? Colors.green
        : puzzle.difficulty == 'Medium'
            ? accentOrange
            : Colors.redAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: mainBlue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                child: Stack(children: [
                  Image.network(
                    puzzle.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: mainBlue.withOpacity(0.1),
                      child: const Center(
                          child: Text('🧩', style: TextStyle(fontSize: 40))),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: diffColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        puzzle.difficulty,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    puzzle.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    puzzle.category,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.black38,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [accentOrange, Color(0xFFFFB74D)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: accentOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'PLAY NOW',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
