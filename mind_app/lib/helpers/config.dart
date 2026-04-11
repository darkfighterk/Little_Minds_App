import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  // Gemini AI
  static String get geminiApiKey => dotenv.get('GEMINI_API_KEY', fallback: '');

  // Groq AI
  static String get groqApiKey => dotenv.get('GROQ_API_KEY', fallback: '');

  // Cloudinary
  static String get cloudinaryCloudName => dotenv.get('CLOUDINARY_CLOUD_NAME', fallback: '');
  static String get cloudinaryUploadPreset => dotenv.get('CLOUDINARY_UPLOAD_PRESET', fallback: 'ml_default');

  // Admin
  static String get adminGateKey => dotenv.get('ADMIN_GATE_KEY', fallback: 'littleminds_admin_2024');

  // Firebase
  static String get firebaseAndroidApiKey => dotenv.get('FIREBASE_ANDROID_API_KEY', fallback: '');
  static String get firebaseAndroidAppId => dotenv.get('FIREBASE_ANDROID_APP_ID', fallback: '');
  static String get firebaseIosApiKey => dotenv.get('FIREBASE_IOS_API_KEY', fallback: '');
  static String get firebaseIosAppId => dotenv.get('FIREBASE_IOS_APP_ID', fallback: '');

  // Helper to check if AI is configured (check both)
  static bool get isAiConfigured => 
    (geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') || 
    (groqApiKey.isNotEmpty && !groqApiKey.startsWith('YOUR'));
  
  static bool get isGroqEnabled => groqApiKey.isNotEmpty && !groqApiKey.startsWith('YOUR');
}
