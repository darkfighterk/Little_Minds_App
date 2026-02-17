import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../controllers/login_controller.dart';
import '../models/user_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final LoginController _loginController = LoginController();

  bool isLoading = false;

  // Sign Up method
  void _onSignUpPressed() async {
    final name = firstNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => isLoading = true);

    final User? user = await _loginController.addUser(name, email, password);

    setState(() => isLoading = false);

    if (user != null) {
      if (!mounted) return;

      // Clear fields
      firstNameController.clear();
      emailController.clear();
      passwordController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Registration successful! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );

      // Redirect to LoginView
      Navigator.pushReplacementNamed(context, '/');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration failed. Email might already exist or backend is not running.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build text field
  Widget _buildTextField(
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          // Decorative purple circles
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

                  const SizedBox(height: 60),

                  // Title
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

                  // Name field
                  _buildTextField("Full Name", controller: firstNameController),

                  const SizedBox(height: 20),

                  // Email field
                  _buildTextField(
                    "Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  _buildTextField(
                    "Password",
                    controller: passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 40),

                  // Sign Up button
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
                      onPressed: isLoading ? null : _onSignUpPressed,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Ink(
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
                      _SocialIcon(Icons.business, Colors.blueAccent),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Login link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: const TextStyle(
                              color: Color(0xFF8E2DE2),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  Navigator.pushReplacementNamed(context, '/'),
                          ),
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
}

// Social Icon widget
class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
