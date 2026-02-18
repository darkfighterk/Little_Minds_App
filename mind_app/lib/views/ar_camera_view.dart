import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ARCameraView extends StatefulWidget {
  const ARCameraView({super.key});

  @override
  State<ARCameraView> createState() => _ARCameraViewState();
}

class _ARCameraViewState extends State<ARCameraView> {
  bool surfaceDetected = true;
  double zoomLevel = 0.75;

  @override
  Widget build(BuildContext context) {
    // ── Theme colors matching HomeView / Login ──
    const primary = Color(0xFFAB47BC);
    // ...existing code...
    const glassBase = Color(0xFF1A0F1C); // same as home dark bg

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassOpacity = isDark ? 0.68 : 0.78;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (camera placeholder + overlay)
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.22),
            ),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassButton(
                      icon: Symbols.arrow_back,
                      onTap: () => Navigator.pop(context),
                      primary: primary,
                    ),
                    Text(
                      "Human Anatomy",
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              blurRadius: 12,
                              color: Colors.black54,
                              offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                    _GlassButton(
                      icon: Symbols.settings,
                      onTap: () {},
                      primary: primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Center Reticle + Model
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Heart model
                Opacity(
                  opacity: 0.92,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.35),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCwzZMf3H09T3UjbS4aX3P0kC4rPmtr08js89ur92QLaddOHDIXPxw_KHWF9DStk6Qy-4WGoKSM_fY-rGUhIm0BnC3tVzR-1V_3zsxQkxf-9P-6n50snXZX86gnqMf4UPybyY0dVYhl4tyZC5NuRKZGEL-i_jTY8WxCexJaBDUidESKnyzDBJZrpNp0DD4NyQPty1GThrxF2IZwGKXO8sVyCA2iJQFcNnMaKc-IAQUAMs28HIQQfQ1N2PeC0Foy7DWVzTIfVfUO9pc',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.favorite,
                          size: 140,
                          color: Color(0xFFAB47BC),
                        ),
                      ),
                    ),
                  ),
                ),

                // Reticle
                SizedBox(
                  width: 288,
                  height: 288,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: primary.withOpacity(0.45),
                    backgroundColor: primary.withOpacity(0.10),
                  ),
                ),

                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: primary.withOpacity(0.20), width: 1.5),
                  ),
                ),

                ..._buildCornerBrackets(primary),
              ],
            ),
          ),

          // Example label (Aorta)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22,
            right: 60,
            child: _AnimatedLabel(label: "Aorta", primary: primary),
          ),

          // Right-side panel
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.5 - 140,
            child: Column(
              children: [
                // Quick Facts Card
                Container(
                  width: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: glassBase.withOpacity(glassOpacity),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primary.withOpacity(0.28)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.42),
                          blurRadius: 20,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Symbols.vital_signs, color: primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "QUICK FACTS",
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primary,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FactRow(
                          label: "Daily Activity",
                          value: "The heart beats ~100k times a day."),
                      const Divider(color: Colors.white24, height: 24),
                      _FactRow(
                          label: "Capacity",
                          value: "It pumps 2,000 gallons of blood daily."),
                      const SizedBox(height: 16),
                      _LearnMoreButton(primary: primary),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Zoom Slider
                _ZoomSlider(
                  value: zoomLevel,
                  onChanged: (v) => setState(() => zoomLevel = v),
                  primary: primary,
                ),
              ],
            ),
          ),

          // Bottom area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (surfaceDetected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: glassBase.withOpacity(glassOpacity),
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.14)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Symbols.check_circle,
                                color: primary, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              "Surface detected",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Symbols.add_circle, size: 28),
                      label: const Text(
                        "PLACE OBJECT",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 18),
                        shape: const StadiumBorder(),
                        elevation: 12,
                        shadowColor: primary.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BottomActionButton(
                            icon: Symbols.image,
                            label: "Gallery",
                            primary: primary),
                        const SizedBox(width: 60),
                        _ShutterButton(primary: primary),
                        const SizedBox(width: 60),
                        _BottomActionButton(
                            icon: Symbols.history,
                            label: "Recent",
                            primary: primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Home indicator
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 135,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets(Color primary) {
    // ...existing code...
    const double offset = -6;
    return [
      Positioned(
          top: offset, left: offset, child: _Bracket(primary, topLeft: true)),
      Positioned(
          top: offset, right: offset, child: _Bracket(primary, topRight: true)),
      Positioned(
          bottom: offset,
          left: offset,
          child: _Bracket(primary, bottomLeft: true)),
      Positioned(
          bottom: offset,
          right: offset,
          child: _Bracket(primary, bottomRight: true)),
    ];
  }

  Widget _Bracket(Color color,
      {bool topLeft = false,
      bool topRight = false,
      bool bottomLeft = false,
      bool bottomRight = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Reusable Components (updated colors)
// ────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color primary;

  const _GlassButton({required this.icon, this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F1C).withOpacity(0.68),
          shape: BoxShape.circle,
          border: Border.all(color: primary.withOpacity(0.28)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12)
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _AnimatedLabel extends StatelessWidget {
  final String label;
  final Color primary;

  const _AnimatedLabel({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F1C).withOpacity(0.68),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withOpacity(0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;

  const _FactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 0.6),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, height: 1.3)),
      ],
    );
  }
}

class _LearnMoreButton extends StatelessWidget {
  final Color primary;

  const _LearnMoreButton({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary.withOpacity(0.20),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Learn More",
                style: TextStyle(
                    color: primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Icon(Symbols.arrow_forward, size: 16, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final Color primary;

  const _ZoomSlider(
      {required this.value, required this.onChanged, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F1C).withOpacity(0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          Icon(Symbols.zoom_in, color: Colors.white60, size: 28),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                      color: primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(999)),
                ),
                FractionallySizedBox(
                  heightFactor: value,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                Align(
                  alignment: Alignment(0, (1 - value * 2) + 0.08),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: primary, width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.black38, blurRadius: 8)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Icon(Symbols.zoom_out, color: Colors.white60, size: 28),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;

  const _BottomActionButton(
      {required this.icon, required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A0F1C).withOpacity(0.68),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Icon(icon, color: Colors.white70, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final Color primary;

  const _ShutterButton({required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration:
                    BoxDecoration(color: primary, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
