import 'dart:async';
import 'package:flutter/material.dart';
import 'login_view.dart'; // or use the correct import path

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Wait 3–4 seconds then go to login
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E1E9), // nice light purple / pinkish
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main logo - big in the center
              Image.asset('assets/logo.png', width: 400, height: 350),
              const SizedBox(height: 24),

              // App name

              // Optional tagline / fun text
              const Text(
                "Loading Your Learning Adventure...",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              // Loading dots animation
              const _LoadingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple animated loading dots
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => __LoadingDotsState();
}

class __LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Opacity(
                opacity: _getOpacity(index),
                child: const CircleAvatar(
                  radius: 6,
                  backgroundColor: Color(0xFFAB47BC),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _getOpacity(int index) {
    final progress = _animation.value * 3;
    if (progress < index) return 0.3;
    if (progress < index + 1) return 0.3 + (progress - index) * 0.7;
    return 1.0;
  }
}
