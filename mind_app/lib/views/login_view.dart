import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import 'main_home_view.dart';
import '../models/user_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;
  bool _passwordVisible = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  final Color mainBlue = const Color(0xFF3AAFFF);
  final Color secondaryPurple = const Color(0xFFA55FEF);
  final Color secondaryOrange = const Color(0xFFFF8811);
  final Color secondaryYellow = const Color(0xFFFDDF50);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields 🎈')),
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
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login failed. Try again!'),
            backgroundColor: Colors.orangeAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withValues(alpha: 0.15), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 80),

                Text(
                  "Little Minds",
                  style: GoogleFonts.fredoka(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: mainBlue,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome to your learning journey",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: secondaryPurple.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 70),

                // Clean & Rounded Input Fields
                _KidField(
                  controller: emailController,
                  hint: "Email Address",
                  icon: Icons.alternate_email_rounded,
                  color: mainBlue,
                ),
                const SizedBox(height: 20),
                _KidField(
                  controller: passwordController,
                  hint: "Password",
                  icon: Icons.vpn_key_rounded,
                  color: secondaryPurple,
                  isPassword: true,
                  obscureText: !_passwordVisible,
                  suffix: IconButton(
                    icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: secondaryPurple.withValues(alpha: 0.4)),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text("Forgot Password?",
                        style: GoogleFonts.nunito(
                            color: mainBlue, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 30),

                // Action Button
                _ActionButton(
                  onTap: isLoading ? null : _onLoginPressed,
                  text: "Login",
                  color: secondaryOrange,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 40),

                // Social Login Section
                Text("Or continue with",
                    style: GoogleFonts.nunito(color: Colors.grey[500])),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialIcon(
                        asset: 'assets/icons/google.png',
                        color: secondaryYellow),
                    const SizedBox(width: 30),
                    _SocialIcon(
                        asset: 'assets/icons/facebook.png', color: mainBlue),
                  ],
                ),

                const SizedBox(height: 40),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: GoogleFonts.nunito(
                        color: Colors.grey[600], fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                            color: secondaryPurple,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => Navigator.pushNamed(context, '/register'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────── Clean UI Components ───────────────

class _KidField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color color;
  final bool isPassword;
  final bool obscureText;
  final Widget? suffix;

  const _KidField(
      {required this.controller,
      required this.hint,
      required this.icon,
      required this.color,
      this.isPassword = false,
      this.obscureText = false,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: color),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Color color;
  final bool isLoading;

  const _ActionButton(
      {this.onTap,
      required this.text,
      required this.color,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(text,
                  style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String asset;
  final Color color;
  const _SocialIcon({required this.asset, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: Image.asset(asset,
          height: 28,
          errorBuilder: (_, __, ___) => Icon(Icons.star, color: color)),
    );
  }
}
