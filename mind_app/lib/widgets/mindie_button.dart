import 'package:flutter/material.dart';
import '../views/chat_screen.dart';

class MindieButton extends StatelessWidget {
  const MindieButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        child: Hero(
          tag: 'mindie-bot',
          child: Image.asset(
            'assets/images/mindie.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
