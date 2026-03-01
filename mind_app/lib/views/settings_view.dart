import 'package:flutter/material.dart';
import 'AboutPage.dart';
import 'profile_edit_view.dart';
// Import the admin gate view (adjust path according to your project structure)
import '../views/admin_view.dart';   // ← added this line (change path if needed)

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
          'App Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Avatar + sparkle
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: const NetworkImage(
                          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                        ), // cute bird / character placeholder
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700), // gold/yellow sparkle
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Greeting
                const Text(
                  "Hi there, Explorer!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "LET'S CUSTOMIZE YOUR ADVENTURE",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // Settings group title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "APP SETTINGS",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Profile & Admin tiles
                _buildSettingsTile(
                  icon: Icons.person,
                  iconColor: const Color(0xFF00D4FF),
                  title: "Profile",
                  subtitle: "View and edit your account",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileEditView()),
                    );
                  },
                ),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  icon: Icons.admin_panel_settings,
                  iconColor: const Color(0xFFFF5252),
                  title: "Admin",
                  subtitle: "Management & controls",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminGateView(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Remaining settings
                _buildSettingsTile(
                  icon: Icons.translate,
                  iconColor: const Color(0xFF00D4FF),
                  title: "App Language",
                  subtitle: "English (US)",
                  onTap: () {
                    // TODO: Open language selector
                  },
                ),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  icon: Icons.palette,
                  iconColor: const Color(0xFFFF80AB),
                  title: "Appearance",
                  subtitle: isDark
                      ? "Dark Mode, Purple Theme"
                      : "Light Mode, Purple Theme",
                  onTap: () {
                    // TODO: Open theme / appearance selector (light/dark/toggle)
                  },
                ),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  icon: Icons.help,
                  iconColor: const Color(0xFFAB47BC),
                  title: "Help & Support",
                  subtitle: "FAQs and Chat",
                  onTap: () {
                    // TODO: Open help / support screen (or merge with About?)
                  },
                ),

                const SizedBox(height: 40),

                // Sign out button
                GestureDetector(
                  onTap: () {
                    // TODO: Show confirm dialog → sign out logic
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.redAccent.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 12),
                        Text(
                          "Sign Out of Explorer Account",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 80), // extra bottom space
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}