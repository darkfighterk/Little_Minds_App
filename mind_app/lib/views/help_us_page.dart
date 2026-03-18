import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpUsPage extends StatelessWidget {
  const HelpUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                const Text(
                  "Hello, How can we help you? 👋",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search for ideas, feedback, or suggestions...",
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B48FF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),

                const SizedBox(height: 40),

                // How You Can Help
                _buildSectionCard(
                  icon: Icons.favorite_rounded,
                  title: "How You Can Help 💕",
                  description: "Little Minds grows with your love and ideas!",
                  items: const [
                    "Tell us what your child loves the most",
                    "Suggest new games, stories, or features",
                    "Report if something is hard to use",
                    "Share ideas for Quiz Arena, Story Time, Text to Image, Notebook & Puzzle",
                    "Rate us on the Play Store ❤️",
                  ],
                ),

                const SizedBox(height: 24),

                // Suggest New Features
                _buildSectionCard(
                  icon: Icons.lightbulb_rounded,
                  title: "Suggest New Features",
                  description: "What would make Little Minds even more magical?",
                  items: const [
                    "New learning games",
                    "More stories or characters",
                    "Better parental controls",
                    "New puzzle types",
                  ],
                ),

                const SizedBox(height: 24),

                // Give Feedback
                _buildSectionCard(
                  icon: Icons.feedback_rounded,
                  title: "Give Feedback",
                  description: "We read every message from parents & teachers",
                  items: const [
                    "What your child enjoys most",
                    "What needs improvement",
                    "Any safety or usability concerns",
                  ],
                ),

                const SizedBox(height: 40),

                // Contact Section (without GitHub)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.email_rounded,
                          color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        "Send us your ideas!",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We truly value every suggestion from parents and teachers 💌\n\n"
                        "Your input helps us create a safer and more fun experience for curious little explorers.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Email Button (you can replace with your actual email later)
                      GestureDetector(
                        onTap: () {
                          // TODO: Add your email function here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email feature coming soon! 💌'),
                              backgroundColor: Color(0xFF6B48FF),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_rounded,
                                  color: Colors.white, size: 28),
                              SizedBox(width: 14),
                              Text(
                                "Send Email",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                Center(
                  child: Text(
                    "Thank you for helping make Little Minds magical! ✨\n"
                    "Made with love for tiny explorers everywhere 🌟",
                    style: TextStyle(
                      fontSize: 15.5,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    "© ${DateTime.now().year} Little Minds",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
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

  // Reusable Section Card
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("•  ",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.93),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}