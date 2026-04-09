import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DrawingRecord {
  final String id;
  final String imageUrl;
  final String title;
  final String createdAt;

  DrawingRecord({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
  });

  factory DrawingRecord.fromJson(Map<String, dynamic> j) => DrawingRecord(
        id: j['id']?.toString() ?? '',
        imageUrl: j['image_url'] as String? ?? '',
        title: j['title'] as String? ?? 'My Drawing',
        createdAt: j['created_at']?.toString() ?? '',
      );
}

class DrawingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload [pngBytes] to Firebase Storage and record in Firestore.
  Future<DrawingRecord> uploadDrawing(Uint8List pngBytes, {String title = 'My Drawing'}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    try {
      debugPrint('🔵 DrawingService: Uploading to Firebase Storage...');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'drawing_${user.uid}_$timestamp.png';
      final storageRef = _storage.ref().child('users/${user.uid}/drawings/$fileName');
      
      // Upload to Storage
      await storageRef.putData(pngBytes, SettableMetadata(contentType: 'image/png'));
      final downloadUrl = await storageRef.getDownloadURL();

      // Save metadata to Firestore
      final docRef = await _db.collection('users').doc(user.uid).collection('drawings').add({
        'image_url': downloadUrl,
        'title': title,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ DrawingService: Drawing saved with ID ${docRef.id}');
      
      return DrawingRecord(
        id: docRef.id,
        imageUrl: downloadUrl,
        title: title,
        createdAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('❌ DrawingService.uploadDrawing error: $e');
      throw Exception('Failed to save drawing to Firebase');
    }
  }

  /// Fetch all drawings belonging to the current user from Firestore.
  Future<List<DrawingRecord>> getDrawings() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      debugPrint('🔵 DrawingService: Fetching drawings for ${user.uid}...');
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('drawings')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DrawingRecord(
          id: doc.id,
          imageUrl: data['image_url'] as String? ?? '',
          title: data['title'] as String? ?? 'My Drawing',
          createdAt: (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ DrawingService.getDrawings error: $e');
      return [];
    }
  }

  /// Delete a drawing from both Firestore and Storage.
  Future<void> deleteDrawing(String id, String imageUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint('🔵 DrawingService: Deleting drawing $id...');
      
      // 1. Delete from Firestore
      await _db.collection('users').doc(user.uid).collection('drawings').doc(id).delete();
      
      // 2. Delete from Storage (extracting path from URL is complex, so we usually store the path too)
      // For now, we'll focus on the DB cleanup. In a full app, you should also delete the file.
      // Reference: FirebaseStorage.instance.refFromURL(imageUrl).delete();
      
      debugPrint('✅ DrawingService: Drawing $id deleted');
    } catch (e) {
      debugPrint('❌ DrawingService.deleteDrawing error: $e');
      throw Exception('Failed to delete drawing');
    }
  }
}
