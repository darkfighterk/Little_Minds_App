import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/course_model.dart';
import '../services/course_service.dart';
import 'bottom_nav_bar.dart';

class CourseLibraryScreen extends StatefulWidget {
  const CourseLibraryScreen({super.key});

  @override
  State<CourseLibraryScreen> createState() => _CourseLibraryScreenState();
}

class _CourseLibraryScreenState extends State<CourseLibraryScreen> {
  final CourseService _courseService = CourseService();
  late Future<List<Course>> _futureCourses;

  @override
  void initState() {
    super.initState();
    // Fetch courses when screen initializes
    _futureCourses = _courseService.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const primary = Color(0xFFAB47BC);
    const bgLight = Color(0xFFFAF5FB);
    const bgDark = Color(0xFF1A0F1C);

    final backgroundColor = isDark ? bgDark : bgLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<List<Course>>(
              future: _futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: primary));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Connection Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No adventures found. Check Backend!"));
                }

                final allCourses = snapshot.data!;

                return Column(
                  children: [
                    // Wrap CustomScrollView with Expanded to fix "RenderFlex overflow" error
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 32, 24, 24),
                              child: _buildHeader(isDark, primary),
                            ),
                          ),

                          // Science Wonders Section
                          _buildCategorySection(
                            context: context,
                            title: "Science Wonders",
                            accentColor: const Color(0xFF4ADE80),
                            primary: primary,
                            courses: allCourses
                                .where((c) => c.category == "Science")
                                .toList(),
                          ),

                          // History Time-Travel Section
                          _buildCategorySection(
                            context: context,
                            title: "History Time-Travel",
                            accentColor: const Color(0xFFFB923C),
                            primary: primary,
                            courses: allCourses
                                .where((c) => c.category == "History")
                                .toList(),
                          ),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 120)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Fixed Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(primaryColor: primary, isDark: isDark),
            ),

            // AR Button (Floating)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: primary,
                  shape: const CircleBorder(),
                  onPressed: () {},
                  child: const Icon(Icons.view_in_ar_rounded,
                      color: Colors.white, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, Little Explorer! 🚀",
                    style: GoogleFonts.lexend(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                Text("What shall we discover today?",
                    style:
                        GoogleFonts.lexend(fontSize: 14, color: Colors.grey)),
              ],
            ),
            // Points Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text("1,250 💎",
                  style:
                      TextStyle(color: primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: "Search adventures...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required Color accentColor,
    required Color primary,
    required List<Course> courses,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(title,
                style: GoogleFonts.lexend(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 240, // Reduced height to fit better and avoid overflow
            child: courses.isEmpty
                ? const Center(child: Text("No courses in this category"))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _buildCourseCard(course, accentColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course, Color accentColor) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
              child: Center(
                  child: Icon(Icons.play_circle_fill,
                      size: 40, color: accentColor)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1),
                Text(course.instructor,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
