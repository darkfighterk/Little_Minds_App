import 'package:flutter/material.dart';
import 'views/login_view.dart';




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
      home: const LoginView(),
    );
  }
}
