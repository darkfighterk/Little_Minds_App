import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../controllers/login_controller.dart';
import 'home_view.dart';
import '../models/user_model.dart';
import 'forgot_password_email_view.dart'; // ← NEW: added this import

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool keepSignedIn = true;
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final LoginController _loginController = LoginController();

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  void _testConnection() async {
    final isConnected = await _loginController.testConnection();
    if (!mounted) return;

    if (isConnected) {
      print("✅ Backend is reachable");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Cannot connect to backend. Make sure it\'s running on port 8080',
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onLoginPressed() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    final User? user = await _loginController.login(email, password);

    setState(() => isLoading = false);

    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeView(user: user)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed. Check your credentials and make sure backend is running.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onRegisterPressed() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4F9),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative bubbles
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

                  // Back arrow
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

                  // Illustration
                  Center(
                    child: Image.asset(
                      'assets/illustrations/welcome_kids.png',
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.child_care,
                          size: 120,
                          color: Color(0xFFAB47BC),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Welcome text
                  const Center(
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFAB47BC),
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

                  // Email input
                  _InputField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'your@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 24),

                  // Password input
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordEmailView(),
                          ),
                        );
                      },
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

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB47BC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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

                  // Sign up link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: const TextStyle(
                              color: Color(0xFFAB47BC),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _onRegisterPressed,
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

// ================== Helper widgets ==================

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
      child: Image.asset(
        assetPath,
        height: 28,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.login, size: 28);
        },
      ),
    );
  }
}

//test
