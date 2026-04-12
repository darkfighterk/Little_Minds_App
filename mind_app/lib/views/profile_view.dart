import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ── Shared brand palette ──
const Color _mainBlue = Color(0xFF3AAFFF);
const Color _secondaryPurple = Color(0xFFA55FEF);
const Color _sunnyYellow = Color(0xFFFDDF50);

class ProfileView extends StatefulWidget {
  final User user;
  const ProfileView({required this.user, super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late TextEditingController _nameController;
  String? _photoUrl;
  bool _isLoading = false;

  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _photoUrl = widget.user.photoUrl;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entrySlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // ── Logic untouched ──
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    setState(() => _isLoading = true);
    final String? uploadedUrl = await _authService.uploadProfilePicture(image);
    if (uploadedUrl != null) {
      final success = await _authService.updateUserProfile(
        widget.user.id,
        photoUrl: uploadedUrl,
      );
      if (success && mounted) {
        setState(() => _photoUrl = uploadedUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated! ✨")),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final success = await _authService.updateUserProfile(
      widget.user.id,
      name: _nameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully! ✅")),
      );
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text.trim(),
        email: widget.user.email,
        photoUrl: _photoUrl,
        token: widget.user.token,
      );
      Navigator.pop(context, updatedUser);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          _AmbientBlobs(isDark: isDark, floatController: _floatController),
          _GradientHeader(isDark: isDark, floatController: _floatController),
          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    // ── Top bar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'My Profile',
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Avatar section (inside header) ──
                    const SizedBox(height: 18),
                    _buildAvatarSection(isDark),

                    const SizedBox(height: 22),

                    // ── Body card ──
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: scaffoldBg,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(40)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.3 : 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(22, 30, 22, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(
                                  label: 'Personal Info', isDark: isDark),
                              const SizedBox(height: 16),

                              // Name field
                              _buildInputField(
                                label: 'FULL NAME',
                                controller: _nameController,
                                icon: Icons.person_outline_rounded,
                                accentColor: _mainBlue,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),

                              // Email field (read-only)
                              _buildReadOnlyField(
                                label: 'EMAIL ADDRESS',
                                value: widget.user.email,
                                icon: Icons.alternate_email_rounded,
                                accentColor: _secondaryPurple,
                                isDark: isDark,
                              ),

                              const SizedBox(height: 36),

                              // Save button
                              _buildSaveButton(isDark),

                              const SizedBox(height: 16),

                              // Sign out link
                              GestureDetector(
                                onTap: () async {
                                  final navigator = Navigator.of(context);
                                  await _authService.signOut();
                                  navigator.pushNamedAndRemoveUntil(
                                      '/login', (route) => false);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E1C2A)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.redAccent
                                          .withValues(alpha: 0.30),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.logout_rounded,
                                          color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sign Out',
                                        style: GoogleFonts.nunito(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar section ──
  Widget _buildAvatarSection(bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: _mainBlue.withValues(alpha: 0.15),
              backgroundImage: (_photoUrl?.isNotEmpty ?? false)
                  ? NetworkImage(_photoUrl!)
                  : null,
              child: (_photoUrl?.isNotEmpty ?? false)
                  ? null
                  : const Icon(Icons.person_rounded,
                      color: _mainBlue, size: 52),
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(_mainBlue),
              ),
            ),
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_mainBlue, _secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _mainBlue.withValues(alpha: 0.40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Save button ──
  Widget _buildSaveButton(bool isDark) {
    return GestureDetector(
      onTap: _isLoading ? null : _saveProfile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : [_mainBlue, _secondaryPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: _mainBlue.withValues(alpha: 0.40),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  'Save Profile',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Input field (matches login _EnhancedField) ──
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDark ? accentColor.withValues(alpha: 0.8) : accentColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? accentColor.withValues(alpha: 0.30)
                  : accentColor.withValues(alpha: 0.55),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: accentColor, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
            ),
          ),
        ),
      ],
    );
  }

  // ── Read-only field ──
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDark
                  ? accentColor.withValues(alpha: 0.5)
                  : accentColor.withValues(alpha: 0.50),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1C2A).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.07),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon,
                  color: isDark ? Colors.white30 : Colors.black26, size: 22),
              const SizedBox(width: 12),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────── Gradient Header ───────────────

class _GradientHeader extends StatelessWidget {
  final bool isDark;
  final AnimationController floatController;
  const _GradientHeader({required this.isDark, required this.floatController});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1030), const Color(0xFF0D1B40)]
                : [
                    const Color(0xFF2B9FFF),
                    const Color(0xFF3AAFFF),
                    const Color(0xFFA55FEF),
                  ],
            stops: isDark ? [0.0, 1.0] : [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -55,
              right: -55,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              top: 65,
              right: 90,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, sin(floatController.value * pi) * 5),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _sunnyYellow),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 55,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -sin(floatController.value * pi) * 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Ambient Blobs ───────────────

class _AmbientBlobs extends StatelessWidget {
  final bool isDark;
  final AnimationController floatController;
  const _AmbientBlobs({required this.isDark, required this.floatController});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          bottom: h * 0.08,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? _secondaryPurple.withValues(alpha: 0.05)
                  : _secondaryPurple.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          top: h * 0.55,
          left: -50,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? _mainBlue.withValues(alpha: 0.04)
                  : _mainBlue.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: h * 0.72,
          right: w * 0.15,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? _sunnyYellow.withValues(alpha: 0.15)
                  : _sunnyYellow.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────── Section Label ───────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
        color: isDark ? Colors.white38 : Colors.black.withValues(alpha: 0.35),
      ),
    );
  }
}
