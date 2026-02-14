import 'package:flutter/material.dart';
import '../models/user_model.dart';

class HomeView extends StatelessWidget {
  final User user;

  const HomeView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Text(
          "Welcome, ${user.username}!",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
