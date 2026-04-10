import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import '../models/user_model.dart';
import 'main_tab_view.dart';

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
  bool _obscurePassword = true;

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
        MaterialPageRoute(builder: (_) => MainTabView(user: user)),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Premium Gradient Header ──
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mainBlue,
                  mainBlue.withValues(alpha: 0.8),
                  secondaryPurple.withValues(alpha: isDark ? 0.3 : 0.6),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(50)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
          ),

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

                    //  Heading in fredoka/Premium style
                    const Text("Create\nAccount",
                        style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1)),
                    const SizedBox(height: 10),
                    Text("Start your learning adventure today ✨",
                        style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600)),

                    const SizedBox(height: 70),

                    //  Input Section
                    _buildKidField(
                      controller: firstNameController,
                      hint: 'Full Name',
                      icon: Icons.person_rounded,
                      color: mainBlue,
                    ),
                    const SizedBox(height: 20),
                    _buildKidField(
                      controller: emailController,
                      hint: 'Email Address',
                      icon: Icons.email_rounded,
                      color: mainBlue,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildKidField(
                      controller: passwordController,
                      hint: 'Password',
                      icon: Icons.vpn_key_rounded,
                      color: secondaryPurple,
                      isPassword: true,
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    const SizedBox(height: 40),

                    //  Main Action Button
                    _buildSignUpButton(),

                    const SizedBox(height: 30),
                    _buildLoginRedirect(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBackButton() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
            ]),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildKidField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            hint.toUpperCase(),
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isDark ? color : color.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.1 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.nunito(
                color: isDark ? Colors.white24 : Colors.black26,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(icon, color: color.withValues(alpha: 0.5)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      onPressed: onToggle,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: GoogleFonts.nunito(
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: 'Login',
              style: TextStyle(
                  color: isDark ? Colors.blueAccent : secondaryPurple,
                  fontWeight: FontWeight.bold),
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
