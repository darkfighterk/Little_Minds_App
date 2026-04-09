import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // ── IMPORTANT: Get your API Key from https://aistudio.google.com/ ──
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> getAIResponse(String userMsg) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return "Mindie is ready to chat, but you need to add your Gemini API Key in 'lib/services/ai_service.dart' first!";
    }

    try {
      debugPrint('🔵 AIService: Sending message to Gemini...');
      final content = [Content.text(userMsg)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        return response.text!;
      } else {
        return "Mindie is speechless... (No response from AI)";
      }
    } catch (e) {
      debugPrint('❌ AIService error: $e');
      return "Mindie is having trouble connecting to her brain. Please check your internet or API key!";
    }
  }
}
