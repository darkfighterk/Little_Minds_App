import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Checks if the database is empty and seeds it with initial data if needed.
  static Future<void> seedIfEmpty() async {
    try {
      final query = await _db.collection('courses').limit(1).get();
      if (query.docs.isEmpty) {
        debugPrint('🌱 Firestore is empty. Starting automatic seeding...');
        await _seedData();
        debugPrint('✅ Seeding complete!');
      } else {
        debugPrint('ℹ️ Firestore already contains data. Skipping seeding.');
      }
    } catch (e) {
      debugPrint('⚠️ Seeder: Could not access database: $e');
      debugPrint('ℹ️ Continuing to app, but data might be missing until permissions are fixed.');
    }
  }

  static Future<void> _seedData() async {
    final batch = _db.batch();

    // 1. Seed Courses
    final courses = [
      {
        'id': '1',
        'title': 'Machine Learning Basics',
        'category': 'AI',
        'description': 'Learn fundamentals of Machine Learning.',
        'imageUrl': 'https://example.com/images/ml.jpg',
        'instructor': 'Dr. Silva'
      },
      {
        'id': '2',
        'title': 'Full Stack Web Development',
        'category': 'Web Development',
        'description': 'Complete MERN stack development course.',
        'imageUrl': 'https://example.com/images/mern.jpg',
        'instructor': 'Mr. Perera'
      },
      {
        'id': '3',
        'title': 'Data Structures & Algorithms',
        'category': 'Programming',
        'description': 'Master DSA concepts for coding interviews.',
        'imageUrl': 'https://example.com/images/dsa.jpg',
        'instructor': 'Ms. Fernando'
      },
    ];

    for (var course in courses) {
      batch.set(_db.collection('courses').doc(course['id']), course);
    }

    // 2. Seed Puzzles
    final puzzles = [
      {
        'id': '2',
        'title': 'Kungfu Panda',
        'image_url': 'https://firebasestorage.googleapis.com/v0/b/little-minds-352e3.appspot.com/o/placeholders%2Fpanda.jpg?alt=media',
        'piece_count': 9,
        'category': 'Animals',
        'difficulty': 'Easy',
      }
    ];

    for (var puzzle in puzzles) {
      batch.set(_db.collection('puzzles').doc(puzzle['id'] as String), puzzle);
    }

    // 3. Seed Quiz Subjects
    final subjects = [
      {'id': 'science', 'name': 'Science', 'emoji': '🔬'},
      {'id': 'biology', 'name': 'Biology', 'emoji': '🧬'},
      {'id': 'history', 'name': 'History', 'emoji': '📜'},
      {'id': 'math', 'name': 'Mathamatics', 'emoji': '➗'},
    ];

    for (var sub in subjects) {
      batch.set(_db.collection('quiz_subjects').doc(sub['id']!), sub);
      
      // Add a sample level for each subject
      final levelDoc = _db.collection('quiz_subjects').doc(sub['id']).collection('levels').doc('1');
      batch.set(levelDoc, {
        'level_number': 1,
        'title': 'Introduction to ${sub['name']}',
        'icon': '🎯',
        'stars_required': 0,
      });

      // Add a sample question
      final qDoc = levelDoc.collection('questions').doc('1');
      batch.set(qDoc, {
        'question_text': 'What is the first step of learning ${sub['name']}?',
        'option_a': 'Observing',
        'option_b': 'Writing',
        'option_c': 'Sleeping',
        'option_d': 'Eating',
        'correct_index': 0,
        'fun_fact': 'Curiosity is the key!',
        'sort_order': 0,
      });
    }

    await batch.commit();
  }
}
