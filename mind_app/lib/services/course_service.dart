import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Course>> fetchCourses() async {
    try {
      debugPrint('🔵 CourseService: Fetching from Firestore...');
      final snapshot = await _db.collection('courses').get();

      debugPrint('✅ CourseService: ${snapshot.docs.length} courses received');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Use Firestore document ID
        return Course.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint("❌ CourseService.fetchCourses error: $e");
      return [];
    }
  }
}
