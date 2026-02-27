import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // ← Replace with your actual GitHub repository URL
  static const String githubRepoUrl = 'https://github.com/darkfighterk/Little_Minds_App.git';

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(githubRepoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Optional: handle launch failure (e.g. show SnackBar)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF2A1A5E), const Color(0xFF180F38)]
                : [const Color(0xFF7C5CFF), const Color(0xFF5A3CCC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // No logo / no sparkle → just title & tagline
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
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Description card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Welcome to Little Minds! 🌈✨\n\n"
                        "Little Minds is a safe, colorful, and joyful learning app made especially for children aged 2–7.\n\n"
                        "Through playful games, delightful songs, interactive stories, shapes, colors, numbers, letters, animals and kind characters — every moment helps tiny minds grow with happiness and wonder.\n\n"
                        "• No advertisements\n"
                        "• No complicated menus\n"
                        "• Just safe, happy learning adventures!\n\n"
                        "Designed with love to spark curiosity and build confidence.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.94),
                          height: 1.55,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                Text(
                  "Made with 💜 by group 7",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _launchUrl,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
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

                const SizedBox(height: 20),

                Text(
                  "Open source • Made for little dreamers everywhere",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),

                const SizedBox(height: 80),

                Text(
                  "© ${DateTime.now().year} Little Minds • Happy Learning!",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.50),
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