import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const String githubUrl =
      "https://github.com/darkfighterk/Little_Minds_App.git";

  final Color mainBlue = const Color(0xFF3AAFFF);
  final Color secondaryPurple = const Color(0xFFA55FEF);
  final Color secondaryOrange = const Color(0xFFFF8811);
  final Color secondaryYellow = const Color(0xFFFDDF50);

  Future<void> openGithub() async {
    final Uri url = Uri.parse(githubUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About Little Minds",
          style: TextStyle(
            fontFamily: 'Recoleta',
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Wave Section ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 110, bottom: 40),
              decoration: BoxDecoration(
                color: mainBlue,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                      color: mainBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/brand/play_store_512.png"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Explorer App",
                    style: TextStyle(
                      fontFamily: 'Recoleta',
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Version 1.0.0",
                    style: GoogleFonts.nunito(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  // ──  Strategy Cards ──
                  _buildAboutCard(
                      "OUR VISION",
                      "To create a fun and engaging digital learning environment where young explorers can develop knowledge, creativity, and problem-solving skills.",
                      secondaryPurple),
                  const SizedBox(height: 18),
                  _buildAboutCard(
                      "OUR MISSION",
                      "To support children aged 6 to 18 by providing interactive tools such as quizzes, puzzles, and digital notebooks that make learning simple.",
                      secondaryOrange),

                  const SizedBox(height: 35),

                  // ──  Developers Tile ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Development Team",
                        style: TextStyle(
                            fontFamily: 'Recoleta',
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),
                  _buildDeveloperTile(context),

                  const SizedBox(height: 30),

                  // ── Action Buttons ──
                  Row(
                    children: [
                      Expanded(
                          child: _buildActionBtn("FAQ", Icons.help_rounded,
                              secondaryYellow, () => _showFAQ(context))),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _buildActionBtn(
                              "Contact",
                              Icons.mail_rounded,
                              Colors.greenAccent[700]!,
                              () => _showContact(context))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionBtn("Source Code (GitHub)",
                        Icons.terminal_rounded, Colors.black87, openGithub),
                  ),

                  const SizedBox(height: 40),
                  Text("© 2026 Little Minds Project",
                      style: GoogleFonts.nunito(
                          color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──  Component Builders ──────────────────────────────────────────────

  Widget _buildAboutCard(String title, String desc, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 2),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontFamily: 'Recoleta',
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildDeveloperTile(BuildContext context) {
    return InkWell(
      onTap: () => _showTeamDialog(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: mainBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: mainBlue.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: mainBlue,
                child: const Icon(Icons.groups_rounded, color: Colors.white)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Group Seven Team",
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold, fontSize: 17)),
                Text("NSBM Undergraduates",
                    style: GoogleFonts.nunito(
                        color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: mainBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(label,
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }

  // ──  Dialogs ────────────────────────────────────────────────────────

  void _showTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text("Developer Team",
            style: TextStyle(fontFamily: 'Recoleta')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _devItem("A.K.A.Tharindu", "32372", "assets/Tharindu.png"),
              _devItem("W.M.P.B.Wanasinghe", "32318", "assets/Wanasinghe.png"),
              _devItem("U.D.S.Ranjith", "32747", "assets/Ranjith.png"),
              _devItem("R.A.V.Kavinda", "32327", "assets/Kavinda.png"),
              _devItem("G.A.P.O.Godamune", "IT0005", "assets/Godamune.png"),
              _devItem("R.A.V.M.Perera", "IT0006", "assets/Perera.png"),
              _devItem("P.H.D.K.Rathnayaka", "IT0007", "assets/Rathnayaka.png"),
              _devItem("I.A.C.S.Thilakarathna", "IT0008",
                  "assets/Thilakarathna.png"),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"))
        ],
      ),
    );
  }

  Widget _devItem(String name, String id, String asset) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(asset), radius: 22),
      title: Text(name,
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(id, style: GoogleFonts.nunito(fontSize: 12)),
    );
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("FAQ", style: TextStyle(fontFamily: 'Recoleta')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _faqItem("How do I play?",
                  "Choose any activity from the home screen like Quiz Arena or Puzzles."),
              _faqItem("Is it free?",
                  "Yes, Little Minds is a free educational project for students."),
              _faqItem("Can I save notes?",
                  "Yes, use the Notebook feature to save your ideas."),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it"))
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold, color: mainBlue)),
          Text(a,
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  void _showContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title:
            const Text("Contact Us", style: TextStyle(fontFamily: 'Recoleta')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text("Call Tharindu"),
              subtitle: const Text("0719361313"),
              onTap: () => launchUrl(Uri.parse("tel:0719361313")),
            ),
          ],
        ),
      ),
    );
  }
}
