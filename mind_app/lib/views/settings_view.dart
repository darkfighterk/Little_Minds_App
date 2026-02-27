import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'AboutPage.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ImagePicker _picker = ImagePicker();
  File? _avatarImage; // Mobile file
  Uint8List? _avatarBytes; // Web file

  // ⚠️ Login eken ganna one (danata test ekata 1 dammu)
  String loggedUserId = "1";

  bool get isWeb => identical(0, 0.0); // Flutter Web check

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ImageProvider avatarProvider() {
      if (_avatarBytes != null) return MemoryImage(_avatarBytes!);
      if (_avatarImage != null) return FileImage(_avatarImage!);
      return const NetworkImage(
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      );
    }

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
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: avatarProvider(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
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

                _buildSettingsTile(
                  icon: Icons.person,
                  iconColor: const Color(0xFF00D4FF),
                  title: "Profile",
                  subtitle: "View and edit your account",
                  onTap: () {},
                ),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  icon: Icons.admin_panel_settings,
                  iconColor: const Color(0xFFFF5252),
                  title: "Admin",
                  subtitle: "Management & controls",
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                _buildSettingsTile(
                  icon: Icons.translate,
                  iconColor: const Color(0xFF00D4FF),
                  title: "App Language",
                  subtitle: "English (US)",
                  onTap: () {},
                ),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  icon: Icons.palette,
                  iconColor: const Color(0xFFFF80AB),
                  title: "Appearance",
                  subtitle: isDark
                      ? "Dark Mode, Purple Theme"
                      : "Light Mode, Purple Theme",
                  onTap: () {},
                ),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  icon: Icons.help,
                  iconColor: const Color(0xFFAB47BC),
                  title: "Help & Support",
                  subtitle: "FAQs and Chat",
                  onTap: () {},
                ),

                const SizedBox(height: 40),

                GestureDetector(
                  onTap: () {},
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

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- IMAGE PICKER ----------------

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile == null) return;

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
      });
    } else {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }

    // ⚡ Temporary: comment backend upload to test preview
    // await _uploadImageToServer(_avatarImage!);
  }

  Future<void> _uploadImageToServer(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8080/upload-profile'),
    );

    request.fields['user_id'] = loggedUserId;

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_image',
        imageFile.path,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image uploaded successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed")),
      );
    }
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
