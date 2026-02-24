import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String url = "http://10.0.2.2:8080/chat";

  Future<String> getAIResponse(String userMsg) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMsg}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['reply'];
      } else {
        return "Oops! Mindie ran into an error. (Status: ${response.statusCode})";
      }
    } catch (e) {
      return "Mindie is having trouble connecting. Please check if your internet or server is active!";
    }
  }
}
