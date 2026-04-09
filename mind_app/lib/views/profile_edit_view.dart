import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color canvasBg = Color(0xFFF8FAFC);

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //  Later: load data from your backend service
    _nameController.text = "kaushlya";
    _emailController.text = "kaushlya@example.com";
    _bioController.text = "Little Minds Explorer 🌟";
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Update Photo",
                style: TextStyle(
                    fontFamily: 'Recoleta',
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPickerTile(Icons.photo_library_rounded, 'Choose from Gallery',
                () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() => _profileImage = File(image.path));
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            }),
            _buildPickerTile(Icons.camera_alt_rounded, 'Take Photo with Camera',
                () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                setState(() => _profileImage = File(image.path));
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: mainBlue),
      title:
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated successfully! 🎉'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

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
        title: const Text('Edit Profile',
            style: TextStyle(
                fontFamily: 'Recoleta',
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        actions: [
          IconButton(
              icon: const Icon(Icons.check_circle_rounded,
                  color: mainBlue, size: 28),
              onPressed: _saveProfile),
        ],
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
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ──  Modern Profile Photo Section ──
                _buildPhotoSelector(),
                const SizedBox(height: 40),

                // ──  Input Fields Section ──
                _buildCustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_rounded),
                const SizedBox(height: 20),
                _buildCustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_rounded,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildCustomTextField(
                    controller: _bioController,
                    label: 'About Me',
                    icon: Icons.auto_awesome_rounded,
                    maxLines: 3),

                const SizedBox(height: 50),

                // ──  Save Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: mainBlue.withValues(alpha: 0.3),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSelector() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration:
              const BoxDecoration(color: mainBlue, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 75,
            backgroundColor: canvasBg,
            backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null
                ? const Icon(Icons.person_rounded,
                    size: 80, color: Colors.black12)
                : null,
          ),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: accentOrange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3)),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      int maxLines = 1,
      TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: mainBlue.withValues(alpha: 0.6),
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: mainBlue.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: mainBlue.withValues(alpha: 0.1), width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: mainBlue, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1)),
            contentPadding: const EdgeInsets.all(18),
          ),
          validator: (v) => v!.isEmpty ? '$label is required' : null,
        ),
      ],
    );
  }
}
