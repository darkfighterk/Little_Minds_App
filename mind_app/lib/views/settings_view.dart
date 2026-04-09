import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import 'help_us_page.dart';
import 'admin_view.dart';
import 'profile_view.dart';
import 'about_view.dart';
import 'login_view.dart';
import '../services/game_service.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color softBlueBg = Color(0xFFF1F5F9);

class SettingsView extends StatefulWidget {
  final User user;
  const SettingsView({required this.user, super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140), // Increased bottom padding for nav bar clearance
          child: Column(
            children: [
              // ──  Custom Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Balance for center alignment
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      fontFamily: 'Recoleta',
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: mainBlue),
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const HelpUsPage())),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ──  Explorer Profile Header ──
              _buildModernProfileHeader(),
              const SizedBox(height: 50),

              // ──  Account Section ──
              _buildSectionHeader("MY ACCOUNT"),
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                color: mainBlue,
                title: "Profile Info",
                subtitle: "Update your name and avatar",
                onTap: _goToProfile,
              ),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.admin_panel_settings_outlined,
                color: Colors.redAccent,
                title: "Admin Gate",
                subtitle: "Content management & controls",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminGateView())),
              ),

              const SizedBox(height: 32),

              // ──  Preferences Section ──
              _buildSectionHeader("EXPERIENCE"),
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                color: secondaryPurple,
                title: "Appearance",
                subtitle: "Customize themes and colors",
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                color: accentOrange,
                title: "About Little Minds",
                subtitle: "FAQs, Version 2.0.1",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutView())),
              ),

              const SizedBox(height: 60),

              // ──  Logout CTA ──
              _buildSignOutButton(context),

              const SizedBox(height: 10),
              Text(
                "Little Minds v2.0.1\nMade with ❤️ for tiny explorers",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.black26,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToProfile() async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileView(user: _currentUser),
      ),
    );

    if (updatedUser != null && mounted) {
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }

  Widget _buildModernProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration:
                  const BoxDecoration(color: mainBlue, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: mainBlue.withValues(alpha: 0.1),
                backgroundImage: _currentUser.photoUrl != null && _currentUser.photoUrl!.isNotEmpty
                    ? NetworkImage(_currentUser.photoUrl!)
                    : null,
                child: _currentUser.photoUrl == null || _currentUser.photoUrl!.isEmpty
                    ? const Icon(Icons.person_rounded, color: Colors.white, size: 55)
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Color(0xFFFFD700), shape: BoxShape.circle),
              child:
                  const Icon(Icons.star_rounded, color: Colors.brown, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Hi, ${_currentUser.name}!",
            style: const TextStyle(
                fontFamily: 'Recoleta',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        Text("Customize your learning adventure",
            style: GoogleFonts.nunito(
                color: Colors.black45,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 12),
        child: Text(title,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: mainBlue.withValues(alpha: 0.6),
                letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildSettingsTile(
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: mainBlue.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Recoleta',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black87)),
        subtitle: Text(subtitle,
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.black38,
                fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Colors.black12),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text("Sign Out Explorer",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.redAccent,
          elevation: 0,
          side: const BorderSide(color: Color(0xFFFFEBEE), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('Sign Out?',
            style:
                TextStyle(fontFamily: 'Recoleta', fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to take a break, Little Explorer?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Stay',
                  style: GoogleFonts.nunito(
                      color: Colors.grey, fontWeight: FontWeight.bold))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign Out',
                  style: GoogleFonts.nunito(
                      color: Colors.red, fontWeight: FontWeight.w900))),
        ],
      ),
    );

    if (confirmed == true) {
      await GameService.clearSession();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false);
      }
    }
  }
}
