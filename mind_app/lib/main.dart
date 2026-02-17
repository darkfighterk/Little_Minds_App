import 'package:flutter/material.dart';
import 'package:mind_app/views/Onboarding_view.dart';
import 'views/login_view.dart';
import 'views/sign_up_view.dart';

void main() {
  runApp(const MindApp());
}

class MindApp extends StatelessWidget {
  const MindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const SignUpView(),
      },
    );
  }
}
