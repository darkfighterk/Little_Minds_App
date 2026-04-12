import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course_model.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color canvasBg = Color(0xFFF8FAFC);

class CategoryFilterScreen extends StatelessWidget {
  final String categoryName;
  final List<Course> courses;

  const CategoryFilterScreen({
    super.key,
    required this.categoryName,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "$categoryName Adventures",
          style: TextStyle(
            fontFamily: 'Recoleta',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [isDark ? const Color(0xFF1E1E1E) : mainBlue.withValues(alpha: 0.05), Theme.of(context).scaffoldBackgroundColor],
          ),
        ),
        child: courses.isEmpty
            ? _buildEmptyState(context)
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.72,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return _buildModernAdventureCard(courses[index], context);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🔭", style: TextStyle(fontSize: 60)),
          const SizedBox(height: 15),
          Text(
            "No adventures found in $categoryName",
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAdventureCard(Course course, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Determine card accent based on category
    final cardColor = categoryName == "Science" ? mainBlue : accentOrange;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : cardColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 40,
                  color: cardColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Recoleta',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.instructor,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                // Play Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "START",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: cardColor,
                      letterSpacing: 0.5,
                    ),
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
