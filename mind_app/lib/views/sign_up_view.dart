import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import '../models/user_model.dart';
import 'main_home_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> with TickerProviderStateMixin {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  bool isLoading = false;
  bool _passwordVisible = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  // ──  Registration Logic (Identical to your version) ──
  void _onSignUpPressed() async {
    final name = firstNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showToast('Please fill in all fields', Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    final User? user = await _loginController.addUser(name, email, password);
    setState(() => isLoading = false);

    if (user != null && mounted) {
      _showToast('Welcome to Adventure! 🎉', Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } else if (mounted) {
      _showToast('Registration failed. Try again.', Colors.redAccent);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //  Modern Brand Gradient Background
          _buildBackgroundDecor(),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    _buildBackButton(),
                    const SizedBox(height: 35),

                    //  Heading in Recoleta
                    const Text("Create\nAccount",
                        style: TextStyle(
                            fontFamily: 'Recoleta',
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.1)),
                    const SizedBox(height: 10),
                    Text("Start your learning adventure today ✨",
                        style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: Colors.black38,
                            fontWeight: FontWeight.w600)),

                    const SizedBox(height: 45),

                    //  Input Section
                    _buildInputField(
                        controller: firstNameController,
                        label: 'Full Name',
                        icon: Icons.person_rounded),
                    const SizedBox(height: 20),
                    _buildInputField(
                        controller: emailController,
                        label: 'Email Address',
                        icon: Icons.email_rounded,
                        type: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: passwordController,
                      label: 'Password',
                      icon: Icons.lock_rounded,
                      isPassword: true,
                      obscure: !_passwordVisible,
                      onToggle: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                    ),

                    const SizedBox(height: 40),

                    //  Main Action Button
                    _buildSignUpButton(),

                    const SizedBox(height: 30),
                    _buildLoginRedirect(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
              color: mainBlue.withValues(alpha: 0.06), shape: BoxShape.circle)),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
            ]),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildInputField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false,
      bool obscure = false,
      VoidCallback? onToggle,
      TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: mainBlue.withValues(alpha: 0.6),
                letterSpacing: 1.1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: mainBlue.withValues(alpha: 0.4)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black26),
                    onPressed: onToggle)
                : null,
            filled: true,
            fillColor: mainBlue.withValues(alpha: 0.03),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: mainBlue.withValues(alpha: 0.08), width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: mainBlue, width: 2)),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onSignUpPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: secondaryPurple.withValues(alpha: 0.4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : const Text("Create Account",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: GoogleFonts.nunito(
              color: Colors.black38, fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: 'Login',
              style: const TextStyle(
                  color: secondaryPurple, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
