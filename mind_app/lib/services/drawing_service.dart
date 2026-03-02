// lib/services/drawing_service.dart
//
// Handles all network calls for user drawings:
//   POST /drawings/upload  — upload a PNG and save to DB
//   GET  /drawings         — list saved drawings for this user
//   DELETE /drawings?id=X  — delete a drawing by id

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DrawingRecord {
  final int id;
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
        id: j['id'] as int,
        imageUrl: j['image_url'] as String,
        title: j['title'] as String? ?? 'My Drawing',
        createdAt: j['created_at'] as String? ?? '',
      );
}

class DrawingService {
  // ── Change this to your server IP if testing on a physical device ──
  static const String _base = 'http://10.0.2.2:8080';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Upload [pngBytes] to the server.
  /// Returns the saved [DrawingRecord] on success, throws on failure.
  Future<DrawingRecord> uploadDrawing(Uint8List pngBytes, {String title = 'My Drawing'}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not logged in');

    final uri = Uri.parse('$_base/drawings/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        pngBytes,
        filename: 'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      ));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final body = await streamed.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;

    if (streamed.statusCode != 200) {
      throw Exception(json['error'] ?? 'Upload failed');
    }

    final data = json['data'] as Map<String, dynamic>;
    return DrawingRecord(
      id: data['id'] as int,
      imageUrl: data['image_url'] as String,
      title: data['title'] as String? ?? title,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  /// Fetch all drawings belonging to the current user.
  Future<List<DrawingRecord>> getDrawings() async {
    final token = await _getToken();
    if (token == null) return [];

    final res = await http
        .get(
          Uri.parse('$_base/drawings'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) return [];

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => DrawingRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Delete a drawing by [id].
  Future<void> deleteDrawing(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not logged in');

    final res = await http
        .delete(
          Uri.parse('$_base/drawings?id=$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(json['error'] ?? 'Delete failed');
    }
  }
}