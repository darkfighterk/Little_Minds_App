import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color canvasBg = Color(0xFFF8FAFC);

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Premium Gradient Header ──
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mainBlue,
                  mainBlue.withValues(alpha: 0.8),
                  secondaryPurple.withValues(alpha: isDark ? 0.3 : 0.6),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(50)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                //  Main Illustration with Glow
                _buildIllustration(context),

                const Spacer(flex: 1),

                //  Theme-aware Title Section
                _buildTitleSection(context),

                const SizedBox(height: 15),

                //  Theme-aware Subtitle
                _buildSubtitle(context),

                const Spacer(flex: 2),

                //  Action Buttons
                _buildButtonSection(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : secondaryPurple.withValues(alpha: 0.1),
            blurRadius: 50,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        'assets/illustrations/onboarding_girls.png',
        height: 320,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.auto_awesome_motion_rounded,
          size: 150,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          "Let’s Start Your",
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          "Learning Adventure",
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.blueAccent : mainBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        "Discover fun games, magic art, and amazing stories made just for you!",
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          // ── Skip Button ──
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              ),
              child: Text(
                "Skip",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white24 : Colors.black38,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // ── Start Button ──
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryPurple,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: secondaryPurple.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
