import 'package:flutter/material.dart';

enum LessonFilter { all, beginners, intermediate, advance }

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String imageAsset; // later replace with imageUrl
  final int completed;
  final int total;

  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.completed,
    required this.total,
  });
}

/// Backend-ready: replace this with http/sqflite later.
abstract class LessonRepository {
  Future<List<Lesson>> fetchLessons({
    required String query,
    required LessonFilter filter,
  });
}

class MockLessonRepository implements LessonRepository {
  @override
  Future<List<Lesson>> fetchLessons({
    required String query,
    required LessonFilter filter,
  }) async {
    final all = <Lesson>[
      const Lesson(
        id: 'animals',
        title: 'Lesson in Animals',
        subtitle: 'Animals are living beings that help nature and humans',
        imageAsset: 'assets/lesson_animals.png',
        completed: 0,
        total: 15,
      ),
      const Lesson(
        id: 'planets',
        title: 'Lesson in Planets',
        subtitle: 'Planets orbit the sun and form our solar system',
        imageAsset: 'assets/lesson_planets.png',
        completed: 0,
        total: 9,
      ),
      const Lesson(
        id: 'human_body',
        title: 'Lesson in Human Body',
        subtitle: 'My body helps me run, play, and learn every day.',
        imageAsset: 'assets/lesson_body.png',
        completed: 0,
        total: 7,
      ),
    ];

    final q = query.trim().toLowerCase();
    final filtered = all.where((l) {
      if (q.isEmpty) return true;
      return l.title.toLowerCase().contains(q) ||
          l.subtitle.toLowerCase().contains(q);
    }).toList();

    // Keep the filter pipeline for backend; mock is no-op.
    return filtered;
  }
}

class LearningLessonScreen extends StatefulWidget {
  const LearningLessonScreen({
    super.key,
    this.repository,
    this.onStartLesson,
    this.onBack,
  });

  final LessonRepository? repository;
  final void Function(Lesson lesson)? onStartLesson;
  final VoidCallback? onBack;

  @override
  State<LearningLessonScreen> createState() => _LearningLessonScreenState();
}

class _LearningLessonScreenState extends State<LearningLessonScreen> {
  late final LessonRepository _repo;
  final _search = TextEditingController();
  LessonFilter _filter = LessonFilter.all;
  Future<List<Lesson>>? _future;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? MockLessonRepository();
    _future = _load();
    _search.addListener(() => setState(() => _future = _load()));
  }

  Future<List<Lesson>> _load() {
    return _repo.fetchLessons(query: _search.text, filter: _filter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              search: _search,
              onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 10),

            // Filter chips row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChipPill(
                      label: 'All',
                      selected: _filter == LessonFilter.all,
                      filledPurpleWhenSelected: true,
                      onTap: () => _setFilter(LessonFilter.all),
                    ),
                    _FilterChipPill(
                      label: 'Beginners',
                      selected: _filter == LessonFilter.beginners,
                      onTap: () => _setFilter(LessonFilter.beginners),
                    ),
                    _FilterChipPill(
                      label: 'Intermediate',
                      selected: _filter == LessonFilter.intermediate,
                      onTap: () => _setFilter(LessonFilter.intermediate),
                    ),
                    _FilterChipPill(
                      label: 'Advance',
                      selected: _filter == LessonFilter.advance,
                      onTap: () => _setFilter(LessonFilter.advance),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Lesson list
            Expanded(
              child: FutureBuilder<List<Lesson>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lessons = snap.data ?? const <Lesson>[];
                  if (lessons.isEmpty) {
                    return const Center(child: Text('No lessons found'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                    itemCount: lessons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final lesson = lessons[i];
                      return LessonCard(
                        lesson: lesson,
                        onStart: () {
                          if (widget.onStartLesson != null) {
                            widget.onStartLesson!(lesson);
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Start: ${lesson.title}')),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setFilter(LessonFilter f) {
    setState(() {
      _filter = f;
      _future = _load();
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.search, required this.onBack});
  final TextEditingController search;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background (use your exported PNG for exact match)
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: Image.asset(
            'assets/learning_header_bg.png',
            height: 178,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 178,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8A9D4), Color(0xFFD8A7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(height: 10),

              // Title: bold + italic second line
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.05,
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(text: 'Pick a New\n'),
                    TextSpan(
                      text: 'Learning Lesson',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _SearchBar(controller: search)),
                  const SizedBox(width: 12),
                  _CircleButton(
                    icon: Icons.tune_rounded,
                    onTap: () {},
                    background: Colors.white,
                    iconColor: Colors.black87,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Search.....',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.background,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? background;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? Colors.white.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: iconColor ?? Colors.black87),
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.filledPurpleWhenSelected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool filledPurpleWhenSelected;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7A0E86);

    final Color bg;
    final Color fg;

    if (filledPurpleWhenSelected) {
      bg = selected ? purple : Colors.white;
      fg = selected ? Colors.white : Colors.black87;
    } else {
      bg = Colors.white;
      fg = Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        elevation: selected ? (filledPurpleWhenSelected ? 0 : 6) : 6,
        shadowColor: Colors.black.withOpacity(0.18),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.lesson, required this.onStart});

  final Lesson lesson;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7A0E86);
    const startPink = Color(0xFFF2B0E6);

    return Container(
      height: 132, // FIX: taller to avoid overflow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.10),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                lesson.imageAsset,
                width: 240,
                height: 132,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 240,
                  height: 132,
                  color: const Color(0xFFEFEAF8),
                ),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.98),
                  Colors.white.withOpacity(0.86),
                  Colors.white.withOpacity(0.10),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ProgressBubble(
                      text: '${lesson.completed}/${lesson.total}',
                      color: purple,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // FIX: flexible subtitle area prevents RenderFlex overflow
                Expanded(
                  child: Text(
                    lesson.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: _StartPill(
                    label: 'Start',
                    background: startPink,
                    border: purple.withOpacity(0.45),
                    onTap: onStart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBubble extends StatelessWidget {
  const _ProgressBubble({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StartPill extends StatelessWidget {
  const _StartPill({
    required this.label,
    required this.background,
    required this.border,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

