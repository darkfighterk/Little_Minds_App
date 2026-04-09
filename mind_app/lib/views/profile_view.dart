import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_edit_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile',
            style: TextStyle(
                fontFamily: 'Recoleta',
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withValues(alpha: 0.05), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ──  Modern Profile Header ──
              _buildModernProfileHeader(context),
              const SizedBox(height: 35),

              // ──  Stats Cards Section ──
              _buildStatCard(
                icon: Icons.star_rounded,
                iconColor: sunnyYellow,
                title: 'Total Stars Earned',
                value: '2,450',
                today: '+150 Today!',
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                icon: Icons.rocket_launch_rounded,
                iconColor: mainBlue,
                title: 'Level 13 Progress',
                value: '750 / 1000 XP',
                showProgress: true,
                progress: 0.75,
              ),

              const SizedBox(height: 32),

              // ──  Badges Section ──
              _buildSectionTitle('Earned Badges'),
              const SizedBox(height: 16),
              _buildBadgesRow(),

              const SizedBox(height: 32),

              // ──  Recent Missions ──
              _buildSectionTitle('Recent Missions'),
              const SizedBox(height: 16),
              _buildMissionCard(
                title: 'The Jurassic Trail',
                subtitle: 'Discovery Complete! Found 4 Fossils',
                color: accentOrange,
                icon: Icons.auto_awesome_rounded,
              ),
              const SizedBox(height: 12),
              _buildMissionCard(
                title: 'Solar System Scout',
                subtitle: 'Mission Active: Reached Mars Orbit',
                color: secondaryPurple,
                icon: Icons.public_rounded,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration:
              const BoxDecoration(color: mainBlue, shape: BoxShape.circle),
          child: const CircleAvatar(
            radius: 65,
            backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1620332360178-664f4d97b0d8?w=400'),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Alex the Brave",
            style: TextStyle(
                fontFamily: 'Recoleta',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        Text("Level 12 Explorer",
            style: GoogleFonts.nunito(
                color: mainBlue,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.2)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileEditView())),
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text("Edit Profile"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black54,
            side: const BorderSide(color: Colors.black12, width: 2),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Recoleta',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        Text("See All",
            style: GoogleFonts.nunito(
                color: mainBlue, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildStatCard(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String value,
      String? today,
      bool showProgress = false,
      double progress = 0.0}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: mainBlue.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15)),
                  child: Icon(icon, color: iconColor, size: 24)),
              const SizedBox(width: 15),
              Text(title,
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: Colors.black45,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Recoleta',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          if (today != null)
            Text(today,
                style: GoogleFonts.nunito(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          if (showProgress) ...[
            const SizedBox(height: 12),
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: mainBlue.withValues(alpha: 0.05),
                    valueColor: const AlwaysStoppedAnimation(mainBlue))),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildBadgeItem('Space Ace', secondaryPurple, Icons.rocket_rounded),
          _buildBadgeItem('Dino Hunter', accentOrange, Icons.pets_rounded),
          _buildBadgeItem('Bug Catcher', Colors.teal, Icons.bug_report_rounded),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800, color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
      {required String title,
      required String subtitle,
      required Color color,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 2),
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text(subtitle,
                    style: GoogleFonts.nunito(
                        color: Colors.black38,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
        ],
      ),
    );
  }
}
