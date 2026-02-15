import 'package:flutter/material.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          // Background decorative purple circles
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDA22FF).withOpacity(0.5),
                    const Color(0xFF8E2DE2).withOpacity(0.7),
                  ],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8E2DE2).withOpacity(0.6),
                    const Color(0xFFC737E6).withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: 40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDA22FF).withOpacity(0.35),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back Button
                  CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.purple),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(height: 60), // extra space so title doesn't overlap circles too much

                  const Center(
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E2DE2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  Row(
                    children: [
                      Expanded(child: _buildTextField("First Name")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("Last Name")),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildTextField("Email"),

                  const SizedBox(height: 20),
                  _buildTextField("Contact Number"),

                  const SizedBox(height: 20),
                  _buildTextField("Password", isPassword: true),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      onPressed: () {
                        // TODO: implement sign up logic
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8E2DE2),
                              Color(0xFFDA22FF),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Center(
                    child: Text(
                      "or sign up with",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _SocialIcon(Icons.g_mobiledata, Colors.red),
                      _SocialIcon(Icons.facebook, Colors.blue),
                      _SocialIcon(Icons.apple, Colors.black),
                      _SocialIcon(Icons.business, Colors.blueAccent), // can change to X or another icon
                    ],
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Color(0xFF8E2DE2),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialIcon(this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: 28),
    );
  }
}