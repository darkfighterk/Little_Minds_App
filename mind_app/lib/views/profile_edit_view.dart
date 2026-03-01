import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import '../models/user_model.dart'; // uncomment if needed

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
    // TODO: load real user data here
    _nameController.text = "kaushlya";
    _emailController.text = "kaushlya@example.com";
    _bioController.text = "Little Minds Explorer 🌟";
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() => _profileImage = File(image.path));
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo with Camera'),
            onTap: () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                setState(() => _profileImage = File(image.path));
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // TODO: real save logic (to database / service)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully! 🎉')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7C5CFF), // top - lighter purple
              Color(0xFF5A3CCC), // bottom - deep purple-blue
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Edit Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveProfile,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Photo Section
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFFFD700),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.deepPurple),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                        value!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Email is required';
                      if (!value.contains('@'))
                        return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bio Field
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'About Me (optional)',
                      prefixIcon: const Icon(Icons.info),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes',
                        style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
