import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool keepSignedIn = true;
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // You can later connect this to the same LoginController your friend uses
  void _onLoginPressed() {
    // TODO: call your friend's LoginController or your own logic
    // For testing right now → just print or navigate
    print("Phone login attempt: ${phoneController.text}");
    // Example navigation (change to your real home screen later)
    // Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFCE4F9,
      ), // very light magenta/pink-purple
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background bubbles (like in proposal)
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8C1FA).withOpacity(0.7),
                ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD7B0E8).withOpacity(0.5),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back arrow (same style as proposal)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFFAB47BC),
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 44),

                  // Kids illustration (must match proposal)
                  Center(
                    child: Image.asset(
                      'assets/illustrations/welcome_kids.png', // ← put your image here
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Welcome back text
                  const Center(
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFAB47BC), // vivid purple
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Login to continue your learning adventure',
                      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email / Phone tabs (exactly like proposal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TabItem(
                        text: 'Email',
                        isActive: false,
                        onTap: () {
                          // Later: navigate to friend's email login if you want
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switching to Email login...'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 60),
                      _TabItem(
                        text: 'Phone number',
                        isActive: true,
                        onTap: () {}, // already here
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Phone number field with +94
                  _InputField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hint: '71 234 5678',
                    prefix: const Text(
                      '+94 ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),

                  // Password field
                  _InputField(
                    controller: passwordController,
                    label: 'Password',
                    hint: '••••••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: Icons.visibility_off,
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFFAB47BC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: keepSignedIn,
                        onChanged: (v) =>
                            setState(() => keepSignedIn = v ?? false),
                        activeColor: const Color(0xFFAB47BC),
                      ),
                      const Text('Keep me signed in'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Big Login button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB47BC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Center(
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Social buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton('assets/icons/google.png'),
                      const SizedBox(width: 20),
                      _SocialButton('assets/icons/facebook.png'),
                      const SizedBox(width: 20),
                      _SocialButton('assets/icons/x.png'),
                      const SizedBox(width: 20),
                      _SocialButton('assets/icons/linkedin.png'),
                    ],
                  ),

                  const SizedBox(height: 48),

                  Center(
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.black87, fontSize: 15),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: Color(0xFFAB47BC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widgets

class _TabItem extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFFAB47BC) : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: text.length * 9.0,
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFAB47BC) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefix: prefix,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFFAB47BC))
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String assetPath;

  const _SocialButton(this.assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Image.asset(assetPath, height: 28),
    );
  }
}
