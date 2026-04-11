import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import 'main_home_view.dart';
import 'library_view.dart';
import 'settings_view.dart';
import 'bottom_nav_bar.dart';

class MainTabView extends StatefulWidget {
  final User user;
  const MainTabView({super.key, required this.user});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // ── Shared brand palette ──
  static const Color mainBlue = Color(0xFF3AAFFF);

  void _onTabSelected(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      HomePage(user: widget.user),
      LibraryView(user: widget.user),
      _MagicPlaceholder(isDark: isDark),
      SettingsView(user: widget.user),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE),
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        primaryColor: mainBlue,
        isDark: isDark, // ← was hardcoded false, now theme-aware
        user: widget.user,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

// ─────────────── Magic Placeholder ───────────────

class _MagicPlaceholder extends StatefulWidget {
  final bool isDark;
  const _MagicPlaceholder({required this.isDark});

  @override
  State<_MagicPlaceholder> createState() => _MagicPlaceholderState();
}

class _MagicPlaceholderState extends State<_MagicPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bg =
        widget.isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3AAFFF)
                    .withValues(alpha: widget.isDark ? 0.06 : 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA55FEF)
                    .withValues(alpha: widget.isDark ? 0.05 : 0.06),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing icon in gradient bubble
                AnimatedBuilder(
                  animation: _scale,
                  builder: (_, child) => Transform.scale(
                    scale: _scale.value,
                    child: child,
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3AAFFF), Color(0xFFA55FEF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF3AAFFF).withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 46)),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Magic Coming Soon',
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.isDark ? Colors.white : const Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Something extraordinary is brewing…',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white38 : Colors.black38,
                  ),
                ),

                const SizedBox(height: 32),

                // Coming soon pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFDDF50), Color(0xFFFF8811)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8811).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    '🚀  Coming Soon',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
