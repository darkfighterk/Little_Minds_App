import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String githubRepoUrl =
      'https://github.com/darkfighterk/Little_Minds_App.git';

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: githubRepoUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('GitHub link copied to clipboard!'),
        backgroundColor: const Color(0xFF6B48FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Little Minds',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B48FF),
              Color(0xFF4A2B99),
              Color(0xFF2A1A66),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Title
                const Text(
                  "Little Minds",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.8,
                    shadows: [
                      Shadow(
                        color: Colors.deepPurpleAccent,
                        offset: Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Fun Learning Adventures for Curious Little Explorers",
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Description card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    "Welcome to Little Minds! 🌈✨\n\n"
                    "Little Minds is a safe, colorful, and joyful learning app made especially for children aged 2–7.\n\n"
                    "Through playful games, delightful songs, interactive stories, shapes, colors, numbers, letters, animals and kind characters — every moment helps tiny minds grow with happiness and wonder.\n\n"
                    "• No advertisements\n"
                    "• No complicated menus\n"
                    "• Just safe, happy learning adventures!\n\n"
                    "Designed with love to spark curiosity and build confidence.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.94),
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 60),

                Text(
                  "Made with 💜 by group 7",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.80),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // GitHub button — copies link (no url_launcher needed)
                GestureDetector(
                  onTap: () => _copyToClipboard(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.code_rounded, color: Colors.white, size: 30),
                        SizedBox(width: 16),
                        Text(
                          "View on GitHub",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Show the URL so users can copy/open manually
                GestureDetector(
                  onLongPress: () => _copyToClipboard(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      githubRepoUrl,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Tap to copy link • Open source • Made for little dreamers everywhere",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                Text(
                  "© ${DateTime.now().year} Little Minds • Happy Learning!",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.50),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
