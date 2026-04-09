import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class ProfileView extends StatefulWidget {
  final User user;
  const ProfileView({required this.user, super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  late TextEditingController _nameController;
  String? _photoUrl;
  bool _isLoading = false;

  final Color mainBlue = const Color(0xFF3AAFFF);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _photoUrl = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
      
      // Return the updated user data to the previous screen
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontFamily: 'Recoleta',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: mainBlue.withValues(alpha: 0.2), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: mainBlue.withValues(alpha: 0.1),
                      backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                          ? NetworkImage(_photoUrl!)
                          : null,
                      child: _photoUrl == null || _photoUrl!.isEmpty
                          ? Icon(Icons.person_rounded, size: 70, color: mainBlue)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: mainBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: mainBlue.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const Positioned.fill(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF3AAFFF)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Input Fields
            _buildInputField("Full Name", _nameController, Icons.person_outline_rounded),
            const SizedBox(height: 20),
            _buildReadOnlyField("Email Address", widget.user.email, Icons.email_outlined),
            const SizedBox(height: 50),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Logout
            TextButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await _authService.signOut();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: Text(
                "Sign Out",
                style: GoogleFonts.nunito(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: mainBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
