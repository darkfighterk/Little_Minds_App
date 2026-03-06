import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _bgController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _taglineController, curve: Curves.easeOutCubic));

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Staggered entrance
    _logoController.forward().then((_) {
      _taglineController.forward();
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginView(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _bgController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0533),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(const Color(0xFF1A0533), const Color(0xFF12022A),
                        _bgController.value)!,
                    Color.lerp(const Color(0xFF2D0B5A), const Color(0xFF3A0E6E),
                        _bgController.value)!,
                    Color.lerp(const Color(0xFF4A1278), const Color(0xFF6B1FA8),
                        _bgController.value)!,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              // Glow orbs
              Positioned(
                top: -100,
                left: -80,
                child: _GlowOrb(
                    size: 340, color: const Color(0xFF8B2FC9), opacity: 0.28),
              ),
              Positioned(
                top: -80,
                right: -100,
                child: _GlowOrb(
                    size: 300, color: const Color(0xFFDA22FF), opacity: 0.22),
              ),
              Positioned(
                bottom: -120,
                left: size.width * 0.2,
                child: _GlowOrb(
                    size: 320, color: const Color(0xFF6B1FA8), opacity: 0.2),
              ),

              // Particles
              AnimatedBuilder(
                animation: _particleController,
                builder: (_, __) => CustomPaint(
                  painter: _ParticlePainter(_particleController.value),
                  size: Size(size.width, size.height),
                ),
              ),

              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo with pulse + glow rings
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: child,
                      ),
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: 320,
                                height: 320,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDA22FF)
                                          .withOpacity(0.3),
                                      blurRadius: 70,
                                      spreadRadius: 25,
                                    ),
                                  ],
                                ),
                              ),
                              // Outer glass ring
                              Container(
                                width: 290,
                                height: 290,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.07),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Inner accent ring
                              Container(
                                width: 262,
                                height: 262,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: const Color(0xFFDA22FF)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              // Logo image
                              Image.asset(
                                'assets/logo.png',
                                width: 240,
                                height: 240,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tagline
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineOpacity,
                        child: Text(
                          'Loading Your Learning Adventure...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.48),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Loading dots
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: const _PulsingDots(),
                    ),

                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final List<_Particle> _particles =
      List.generate(35, (i) => _Particle(seed: i));

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in _particles) {
      final x =
          ((p.x * size.width) + progress * p.speedX * size.width) % size.width;
      final y = ((p.y * size.height) -
              progress * p.speedY * size.height +
              size.height) %
          size.height;
      final o = p.opacity * (0.4 + 0.6 * sin(progress * pi * 2 + p.phase));
      paint.color = Colors.white.withOpacity(o.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _Particle {
  late final double x, y, speedX, speedY, radius, opacity, phase;

  _Particle({required int seed}) {
    final rng = Random(seed * 6571);
    x = rng.nextDouble();
    y = rng.nextDouble();
    speedX = (rng.nextDouble() - 0.5) * 0.06;
    speedY = rng.nextDouble() * 0.1 + 0.03;
    radius = rng.nextDouble() * 2.2 + 0.5;
    opacity = rng.nextDouble() * 0.35 + 0.05;
    phase = rng.nextDouble() * pi * 2;
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => __PulsingDotsState();
}

class __PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final t = ((_controller.value - delay) % 1.0 + 1.0) % 1.0;
            final scale = 0.5 + 0.5 * sin(t * pi);
            final opacity = 0.25 + 0.75 * sin(t * pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFFDA22FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFDA22FF).withOpacity(opacity * 0.7),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
