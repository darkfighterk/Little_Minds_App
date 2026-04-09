import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_seeder.dart';
import 'views/onboarding_view.dart';
import 'views/login_view.dart';
import 'views/sign_up_view.dart';

void main() async {
  // Required for local storage and OCR plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Automatically seed the database if it's empty
  await FirebaseSeeder.seedIfEmpty();

  runApp(const MindApp());
}

class MindApp extends StatelessWidget {
  const MindApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ──  Premium Brand Colors ──
    const Color mainBlue = Color(0xFF3AAFFF);

    return MaterialApp(
      title: 'Little Minds',
      debugShowCheckedModeBanner: false,

      // ──  Global Premium Theme ──
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: mainBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mainBlue,
          primary: mainBlue,
        ),
        // Setting Nunito as default body font
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        // Premium Button Style across the app
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),

      // ──  Navigation Routes ──
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginView(),
        '/onboarding': (context) => const OnboardingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const SignUpView(),
      },
    );
  }
}
