import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../helpers/config.dart';

class AIService {
  // ── Gemini API Key from Config ──
  static final String _apiKey = Config.geminiApiKey;

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> getAIResponse(String userMsg) async {
    if (!Config.isAiConfigured) {
      return "Mindie is ready to chat, but you need to add your Gemini API Key in your '.env' file first!";
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
