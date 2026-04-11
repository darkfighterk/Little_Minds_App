import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../helpers/config.dart';

class AIService {
  // ── Groq API Configuration ──
  static const String _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static final String _apiKey = Config.groqApiKey;
  static const String _model = 'llama-3.3-70b-versatile';

  AIService();

  Future<String> getAIResponse(List<Map<String, String>> history) async {
    if (!Config.isAiConfigured) {
      return "Mindie is ready to chat, but you need to add your API Key in your '.env' file first!";
    }

    try {
      debugPrint(
          '🚀 AIService: Sending message to Groq ($_model) with ${history.length} messages of context...');

      // Build the prompt list starting with our "Junior Professor" system message
      final List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content':
              'You are Mindie, a cheerful and helpful AI learning buddy for kids. You are a "Junior Professor" who loves sharing knowledge! When asked about a topic, give a fun explanation and exactly 4 amazing facts using bullet points (e.g. • Fact). IMPORTANT: Keep your paragraphs very short (1-2 sentences each) so they are easy to read on a phone. Use simple words and some of emojis! 🎈🌟 Always be educational but keep it snappy and fun!',
        },
        ...history,
      ];

      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String botMessage = data['choices'][0]['message']['content'];
        return botMessage.trim();
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint(
            '❌ Groq API Error: ${response.statusCode} - ${response.body}');
        return "Mindie is a bit tired... (Error: ${errorData['error']['message'] ?? 'Status ${response.statusCode}'})";
      }
    } catch (e) {
      debugPrint('❌ AIService error: $e');
      return "Mindie is having trouble connecting to her brain. (Error: ${e.toString().split('\n').first})";
    }
  }
}
