import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'login_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color darkBg = Color(0xFF0D0520);

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _bgController;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _particleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _logoController.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginView(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ));
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // ── Dynamic Gradient Background ──
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(darkBg, const Color(0xFF1A1040),
                          _bgController.value)!,
                      Color.lerp(const Color(0xFF1E1040),
                          mainBlue.withOpacity(0.2), _bgController.value)!,
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Particles ──
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleController.value, mainBlue),
              size: Size(size.width, size.height),
            ),
          ),

          // ──  Logo & Branding ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Outer Glow
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: mainBlue.withOpacity(0.2),
                                  blurRadius: 60,
                                  spreadRadius: 10)
                            ],
                          ),
                        ),
                        Image.asset('assets/logo.png',
                            width: 220,
                            height: 220,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.auto_stories_rounded,
                                size: 100,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _logoOpacity,
                  child: Column(
                    children: [
                      const Text(
                        "Little Minds",
                        style: TextStyle(
                            fontFamily: 'Recoleta',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your Learning Adventure Awaits...",
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ──  Bottom Loading Indicator ──
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(child: _PulsingDots(color: mainBlue)),
          ),
        ],
      ),
    );
  }
}

// ───  Helper: Particle Painter ───
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  _ParticlePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final rng = Random(42);
    for (int i = 0; i < 30; i++) {
      double x = (rng.nextDouble() * size.width + progress * 50) % size.width;
      double y =
          (rng.nextDouble() * size.height - progress * 100 + size.height) %
              size.height;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ───  Helper: Pulsing Dots ───
class _PulsingDots extends StatelessWidget {
  final Color color;
  const _PulsingDots({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          3,
          (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.6), shape: BoxShape.circle),
              )),
    );
  }
}
