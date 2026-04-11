import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crossword.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import 'crossword_play_page.dart';

class CrosswordListView extends StatefulWidget {
  final User user;
  const CrosswordListView({required this.user, super.key});

  @override
  State<CrosswordListView> createState() => _CrosswordListViewState();
}

class _CrosswordListViewState extends State<CrosswordListView> {
  final AdminService _adminService = AdminService();
  bool _loading = true;
  String? _error;
  List<Puzzle> _crosswords = [];

  @override
  void initState() {
    super.initState();
    _loadCrosswords();
  }

  Future<void> _loadCrosswords() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final rawList = await _adminService.getCrosswordPuzzles();
    if (!mounted) return;

    setState(() {
      _crosswords = rawList.map((raw) {
        final data = Map<String, dynamic>.from(raw);
        if (data['id'] == null && data['docId'] != null) {
          data['id'] = data['docId'];
        }
        return Puzzle.fromJson(data);
      }).toList();
      _loading = false;
      if (_crosswords.isEmpty) {
        _error =
            'No crosswords available yet. Please create one from the admin panel.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crossword Puzzles'),
        actions: [
          IconButton(
            onPressed: _loadCrosswords,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _crosswords.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      _error ?? 'No crosswords available.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _crosswords.length,
                  itemBuilder: (context, index) {
                    final puzzle = _crosswords[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CrosswordPlayPage(
                              puzzle: puzzle,
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1F1F1F) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              puzzle.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${puzzle.rows} x ${puzzle.cols} grid',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${puzzle.acrossClues.length} across clues • ${puzzle.downClues.length} down clues',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CrosswordPlayPage(
                                        puzzle: puzzle,
                                        user: widget.user,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8E24AA),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Play'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
