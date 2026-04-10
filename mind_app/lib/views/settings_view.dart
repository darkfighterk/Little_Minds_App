import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import 'help_us_page.dart';
import 'admin_view.dart';
import 'profile_view.dart';
import 'about_view.dart';
import 'login_view.dart';
import 'appearance_view.dart';
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Premium Gradient Header ──
          Container(
            height: MediaQuery.of(context).size.height * 0.42,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
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
                context,
                icon: Icons.person_outline_rounded,
                color: mainBlue,
                title: "Profile Info",
                subtitle: "Update your name and avatar",
                onTap: _goToProfile,
              ),
              const SizedBox(height: 12),
              _buildSettingsTile(
                context,
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
                context,
                icon: Icons.palette_outlined,
                color: secondaryPurple,
                title: "Appearance",
                subtitle: "Customize themes and colors",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AppearanceView())),
              ),
              const SizedBox(height: 12),
              _buildSettingsTile(
                context,
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
                  color: isDark ? Colors.white30 : Colors.black26,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
          ),
        ],
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
                color: Colors.white)),
        Text("Customize your learning adventure",
            style: GoogleFonts.nunito(
                color: Colors.white70,
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
      BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black26 : mainBlue.withValues(alpha: 0.04),
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
            style: TextStyle(
                fontFamily: 'Recoleta',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle,
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black38,
                fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: isDark ? Colors.white24 : Colors.black12),
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
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Colors.redAccent,
          elevation: 0,
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2), width: 2),
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
        content: Text(
            'Are you sure you want to take a break, Little Explorer?',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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
