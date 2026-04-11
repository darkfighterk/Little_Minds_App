import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/crossword.dart';

class CrosswordCreatePage extends StatefulWidget {
  final String? docId;
  const CrosswordCreatePage({this.docId, super.key});

  @override
  State<CrosswordCreatePage> createState() => _CrosswordCreatePageState();
}

class _CrosswordCreatePageState extends State<CrosswordCreatePage> {
  final AdminService _adminService = AdminService();
  final _titleController = TextEditingController();

  int rows = 5;
  int cols = 5;

  List<List<CrosswordCell>> grid = [];
  List<Clue> acrossClues = [];
  List<Clue> downClues = [];

  bool isEditing = false;
  String? currentDocId;

  @override
  void initState() {
    super.initState();
    _initGrid();

    if (widget.docId != null) {
      isEditing = true;
      currentDocId = widget.docId;
      _loadExistingPuzzle();
    }
  }

  // ======================
  // GRID INIT
  // ======================
  void _initGrid() {
    grid = List.generate(
      rows,
      (_) => List.generate(cols, (_) => CrosswordCell()),
    );
  }

  void _updateGridSize() {
    setState(() => _initGrid());
  }

  // ======================
  // CELL EDIT
  // ======================
  void _handleCellTap(int r, int c) {
    final cell = grid[r][c];

    final letterCtrl = TextEditingController(text: cell.letter);
    final numberCtrl =
        TextEditingController(text: cell.number?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cell ($r, $c)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BLACK CELL
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                setState(() {
                  cell.isBlack = true;
                  cell.isInvisible = false;
                  cell.letter = '';
                  cell.number = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Black Cell'),
            ),

            const SizedBox(height: 10),

            // WHITE / INVISIBLE EDIT (SAME EDITOR)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Edit Cell (White / Invisible)'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: letterCtrl,
                          maxLength: 1,
                          textCapitalization: TextCapitalization.characters,
                          decoration:
                              const InputDecoration(labelText: 'Letter'),
                        ),
                        TextField(
                          controller: numberCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Number'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            cell.isBlack = false;
                            cell.isInvisible = false; // default white
                            cell.letter = letterCtrl.text.toUpperCase();
                            cell.number = int.tryParse(numberCtrl.text);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Edit White / Invisible',
                  style: TextStyle(color: Colors.black)),
            ),

            const SizedBox(height: 10),

            // MAKE INVISIBLE
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () {
                setState(() {
                  cell.isInvisible = true;
                  cell.isBlack = false;
                });
                Navigator.pop(context);
              },
              child: const Text('Make Invisible'),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // SAVE
  // ======================
  Future<void> _savePuzzle() async {
    final puzzle = Puzzle(
      title: _titleController.text.trim(),
      rows: rows,
      cols: cols,
      grid: grid,
      acrossClues: acrossClues,
      downClues: downClues,
    );

    if (isEditing && currentDocId != null) {
      await _adminService.updateCrosswordPuzzle(currentDocId!, puzzle);
    } else {
      await _adminService.createCrosswordPuzzle(puzzle);
    }

    Navigator.pop(context);
  }

  // ======================
  // LOAD
  // ======================
  Future<void> _loadExistingPuzzle() async {
    final puzzle = await _adminService.getCrosswordPuzzleById(currentDocId!);

    if (puzzle != null) {
      _titleController.text = puzzle.title;
      rows = puzzle.rows;
      cols = puzzle.cols;
      grid = puzzle.grid;
      acrossClues = puzzle.acrossClues;
      downClues = puzzle.downClues;
      setState(() {});
    }
  }

  // ======================
  // ADD CLUE
  // ======================
  void _addClue(bool isAcross) {
    final numCtrl = TextEditingController();
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAcross ? 'Across Clue' : 'Down Clue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number'),
            ),
            TextField(
              controller: textCtrl,
              decoration: const InputDecoration(labelText: 'Clue'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final num = int.tryParse(numCtrl.text);
              if (num != null && textCtrl.text.isNotEmpty) {
                setState(() {
                  if (isAcross) {
                    acrossClues.add(Clue(number: num, text: textCtrl.text));
                  } else {
                    downClues.add(Clue(number: num, text: textCtrl.text));
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crossword Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Rows'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => rows = int.tryParse(v) ?? 5,
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Cols'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => cols = int.tryParse(v) ?? 5,
                  ),
                ),
                IconButton(
                    onPressed: _updateGridSize, icon: const Icon(Icons.refresh))
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows * cols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols),
              itemBuilder: (_, index) {
                final r = index ~/ cols;
                final c = index % cols;
                final cell = grid[r][c];

                return GestureDetector(
                  onTap: () => _handleCellTap(r, c),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cell.isBlack
                          ? Colors.black
                          : cell.isInvisible
                              ? Colors.grey.shade300
                              : Colors.white,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: cell.isBlack
                        ? null
                        : Stack(
                            children: [
                              if (cell.number != null)
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  child: Text('${cell.number}',
                                      style: const TextStyle(fontSize: 10)),
                                ),
                              Center(
                                child: Text(cell.letter,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildClueList('Across Clues', acrossClues, true),
            _buildClueList('Down Clues', downClues, false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePuzzle,
              child: const Text('Save Puzzle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClueList(String title, List<Clue> clues, bool isAcross) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: () => _addClue(isAcross),
                icon: const Icon(Icons.add))
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: clues.length,
          itemBuilder: (_, i) => ListTile(
            title: Text('${clues[i].number}. ${clues[i].text}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(() => clues.removeAt(i)),
            ),
          ),
        ),
      ],
    );
  }
}
