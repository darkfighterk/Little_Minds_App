import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color canvasBg = Color(0xFFF8FAFC);

class HelpUsPage extends StatelessWidget {
  const HelpUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
              fontFamily: 'Recoleta',
              color: Colors.black87,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ──  Header ──
              const Text(
                "Hello! How can we\nhelp you today? 👋",
                style: TextStyle(
                  fontFamily: 'Recoleta',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // ──  Modern Search Bar ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: mainBlue.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for ideas or feedback...",
                    hintStyle: GoogleFonts.nunito(color: Colors.black38),
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: mainBlue),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ──  Section Cards ──
              _buildModernSectionCard(
                icon: Icons.auto_awesome_rounded,
                title: "How You Can Help",
                color: mainBlue,
                items: [
                  "Tell us what your child loves the most",
                  "Suggest new games or stories",
                  "Rate us on the Play Store ❤️",
                ],
              ),
              const SizedBox(height: 20),
              _buildModernSectionCard(
                icon: Icons.lightbulb_outline_rounded,
                title: "New Features",
                color: secondaryPurple,
                items: [
                  "New learning game ideas",
                  "More characters or puzzle types",
                  "Better parental controls",
                ],
              ),

              const SizedBox(height: 40),

              // ── Contact CTA ──
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [mainBlue, secondaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: mainBlue.withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.mail_outline_rounded,
                        color: Colors.white, size: 50),
                    const SizedBox(height: 16),
                    const Text(
                      "Send us your ideas!",
                      style: TextStyle(
                          fontFamily: 'Recoleta',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Your input helps us create a safer and more fun experience for curious little explorers.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: mainBlue,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        elevation: 0,
                      ),
                      child: const Text("Send Email",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  "© ${DateTime.now().year} Little Minds\nMade with love for tiny explorers 🌟",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.black38, fontSize: 12, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Recoleta',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: color.withOpacity(0.5), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(item,
                            style: GoogleFonts.nunito(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w600))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
