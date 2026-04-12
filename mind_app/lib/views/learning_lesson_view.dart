import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color softBlueBg = Color(0xFFF1F5F9);

enum LessonFilter { all, beginners, intermediate, advance }

class Lesson {
  final String id, title, subtitle, imageAsset;
  final int completed, total;
  const Lesson(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.imageAsset,
      required this.completed,
      required this.total});
}

// ──  Mock Data ───────────────────────────────────────────
class MockLessonRepository {
  Future<List<Lesson>> fetchLessons(
      {required String query, required LessonFilter filter}) async {
    final all = [
      const Lesson(
          id: 'animals',
          title: 'Life of Animals',
          subtitle: 'Discover amazing creatures in nature!',
          imageAsset:
              'https://images.unsplash.com/photo-1550147760-44c9966d6bc7?w=400',
          completed: 2,
          total: 10),
      const Lesson(
          id: 'space',
          title: 'Journey to Space',
          subtitle: 'Explore planets and distant stars.',
          imageAsset:
              'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400',
          completed: 0,
          total: 8),
      const Lesson(
          id: 'body',
          title: 'The Human Body',
          subtitle: 'How your amazing body works!',
          imageAsset:
              'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=400',
          completed: 5,
          total: 12),
    ];
    return all
        .where((l) => l.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

class LearningLessonScreen extends StatefulWidget {
  const LearningLessonScreen({super.key});
  @override
  State<LearningLessonScreen> createState() => _LearningLessonScreenState();
}

class _LearningLessonScreenState extends State<LearningLessonScreen> {
  final _repo = MockLessonRepository();
  final _search = TextEditingController();
  LessonFilter _filter = LessonFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildFilters()),
          _buildLessonList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: mainBlue,
      elevation: 0,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [mainBlue, secondaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pick a New",
                  style: TextStyle(
                      fontFamily: 'Recoleta',
                      color: Colors.white,
                      fontSize: 24)),
              Text("Learning Lesson",
                  style: TextStyle(
                      fontFamily: 'Recoleta',
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: LessonFilter.values
            .map((f) => _FilterChip(
                label: f.name,
                selected: _filter == f,
                onTap: () => setState(() => _filter = f)))
            .toList(),
      ),
    );
  }

  Widget _buildLessonList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: FutureBuilder<List<Lesson>>(
        future: _repo.fetchLessons(query: _search.text, filter: _filter),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()));
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _LessonCard(lesson: snap.data![i]),
              childCount: snap.data!.length,
            ),
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 140,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          // ──  Image Section ──
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), bottomLeft: Radius.circular(25)),
            child: Image.network(lesson.imageAsset,
                width: 120, height: 140, fit: BoxFit.cover),
          ),
          // ──  Content Section ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: softBlueBg, shape: BoxShape.circle),
                            child: Text("${lesson.completed}/${lesson.total}",
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: mainBlue))),
                        const Icon(Icons.bookmark_border_rounded,
                            size: 20, color: Colors.grey),
                      ]),
                  const SizedBox(height: 5),
                  Text(lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Recoleta',
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold)),
                  Text(lesson.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: isDark ? Colors.white54 : Colors.black54)),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text("Start",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
            color: selected ? mainBlue : (isDark ? const Color(0xFF2A2A2A) : softBlueBg),
            borderRadius: BorderRadius.circular(15)),
        child: Center(
            child: Text(label.toUpperCase(),
                style: TextStyle(
                    color: selected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                    fontWeight: FontWeight.bold,
                    fontSize: 11))),
      ),
    );
  }
}
