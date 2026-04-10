import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'views/onboarding_view.dart';
import 'views/login_view.dart';
import 'views/sign_up_view.dart';
import 'views/auth_wrapper.dart';

import 'theme/app_theme.dart';

void main() async {
  // Required for local storage and OCR plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Theme Persistence
  await AppTheme.init();

  runApp(const MindApp());
}

class MindApp extends StatelessWidget {
  const MindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Little Minds',
          debugShowCheckedModeBanner: false,

          // ──  Global Premium Theme ──
          themeMode: currentMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // ──  Navigation Routes ──
      home: const AuthWrapper(),
          routes: {
            '/onboarding': (context) => const OnboardingView(),
            '/login': (context) => const LoginView(),
            '/register': (context) => const SignUpView(),
          },
        );
      },
    );
  }
}
