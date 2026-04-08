import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/course_model.dart';
import '../services/course_service.dart';
import 'bottom_nav_bar.dart';
import 'category_filter_screen.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

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
    _futureCourses = _courseService.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<List<Course>>(
              future: _futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: mainBlue));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Connection Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No adventures found! Check Backend."));
                }

                final allCourses = snapshot.data!;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: _buildModernHeader(isDark),
                      ),
                    ),
                    _buildCategorySection(
                      context: context,
                      title: "Science Wonders",
                      accentColor: const Color(0xFF4ADE80),
                      courses: allCourses
                          .where((c) => c.category == "Science")
                          .toList(),
                    ),
                    _buildCategorySection(
                      context: context,
                      title: "History Time-Travel",
                      accentColor: accentOrange,
                      courses: allCourses
                          .where((c) => c.category == "History")
                          .toList(),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  ],
                );
              },
            ),
            _buildFixedOverlays(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hi, Little Explorer! 🚀",
                    style: TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text("What shall we discover today?",
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: sunnyYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sunnyYellow)),
              child: const Text("1,250 💎",
                  style: TextStyle(
                      color: accentOrange, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 25),
        TextField(
          decoration: InputDecoration(
            hintText: "Search adventures...",
            hintStyle: GoogleFonts.nunito(color: Colors.black26),
            prefixIcon: const Icon(Icons.search_rounded, color: mainBlue),
            filled: true,
            fillColor: mainBlue.withOpacity(0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
      {required BuildContext context,
      required String title,
      required Color accentColor,
      required List<Course> courses}) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CategoryFilterScreen(
                              categoryName: title, courses: courses))),
                  child: const Text("View All",
                      style: TextStyle(
                          color: mainBlue, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: courses.length,
              itemBuilder: (context, index) =>
                  _buildCourseCard(courses[index], accentColor),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course, Color accentColor) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8))
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
                      const BorderRadius.vertical(top: Radius.circular(25))),
              child: Center(
                  child: Icon(Icons.auto_awesome_rounded,
                      size: 45, color: accentColor)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Recoleta',
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text(course.instructor,
                    style: GoogleFonts.nunito(
                        color: Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedOverlays(bool isDark) {
    return Stack(
      children: [
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(primaryColor: mainBlue, isDark: isDark)),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      const LinearGradient(colors: [mainBlue, secondaryPurple]),
                  boxShadow: [
                    BoxShadow(
                        color: mainBlue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5))
                  ]),
              child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.view_in_ar_rounded,
                      color: Colors.white, size: 32)),
            ),
          ),
        ),
      ],
    );
  }
}
