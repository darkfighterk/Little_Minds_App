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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //  Decorative Wave Background
          _buildBackgroundDecor(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                //  Main Illustration with Glow
                _buildIllustration(),

                const Spacer(flex: 1),

                //  Catchy Title in Recoleta
                _buildTitleSection(),

                const SizedBox(height: 15),

                //  Subtitle in Nunito
                _buildSubtitle(),

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

  Widget _buildBackgroundDecor() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: mainBlue.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: secondaryPurple.withValues(alpha: 0.1),
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
          color: secondaryPurple,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      children: [
        Text(
          "Let’s Start Your",
          style: TextStyle(
            fontFamily: 'Recoleta',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          "Learning Adventure",
          style: TextStyle(
            fontFamily: 'Recoleta',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: mainBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        "Discover fun games, magic art, and amazing stories made just for you!",
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black45,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
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
                  color: Colors.black38,
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
