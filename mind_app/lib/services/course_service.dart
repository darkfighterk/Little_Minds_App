import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class CourseService {
  final String baseUrl = "http://10.0.2.2:8080/courses";

  Future<List<Course>> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'];

        return data.map((item) => Course.fromJson(item)).toList();
      } else {
        throw Exception("Server returned an error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Could not connect to backend: $e");
    }
  }
}
