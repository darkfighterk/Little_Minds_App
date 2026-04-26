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
  late AnimationController _floatController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -7, end: 7).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _onSignUpPressed() async {
    final name = firstNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showToast('Please fill in all fields 🎈', Colors.orange);
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showToast('Please enter a valid email address 📧', Colors.orangeAccent);
      return;
    }

    if (password.length < 6) {
      _showToast('Password must be at least 6 characters long 🔐', Colors.orangeAccent);
      return;
    }

    setState(() => isLoading = true);
    final User? user = await _loginController.addUser(name, email, password);
    setState(() => isLoading = false);

    if (user != null && mounted) {
      _showToast('Welcome to Adventure! 🎉', Colors.green);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pushReplacement(context, _smoothRoute(MainTabView(user: user)));
    } else if (mounted) {
      _showToast('Registration failed. Try again.', Colors.redAccent);
    }
  }

  Route _smoothRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final fade =
              CurvedAnimation(parent: animation, curve: Curves.easeOut);
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      );

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // ── Ambient blobs ──
          _AmbientBlobs(isDark: isDark),

          // ── Gradient Header ──
          _GradientHeader(isDark: isDark, floatAnimation: _float),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      // ── Back Button ──
                      _BackButton(isDark: isDark),

                      const SizedBox(height: 28),

                      // ── Heading ──
                      Text(
                        "Create\nAccount",
                        style: GoogleFonts.fredoka(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start your learning adventure today ✨",
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 64),

                      // ── Fields ──
                      _EnhancedField(
                        controller: firstNameController,
                        hint: 'Full Name',
                        label: 'FULL NAME',
                        icon: Icons.person_rounded,
                        accentColor: mainBlue,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),
                      _EnhancedField(
                        controller: emailController,
                        hint: 'Email Address',
                        label: 'EMAIL',
                        icon: Icons.email_rounded,
                        accentColor: mainBlue,
                        isDark: isDark,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      _EnhancedField(
                        controller: passwordController,
                        hint: 'Password',
                        label: 'PASSWORD',
                        icon: Icons.vpn_key_rounded,
                        accentColor: secondaryPurple,
                        isDark: isDark,
                        isPassword: true,
                        obscure: _obscurePassword,
                        onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),

                      const SizedBox(height: 36),

                      // ── Sign Up Button ──
                      _GradientButton(
                        onPressed: isLoading ? null : _onSignUpPressed,
                        label: "Create Account",
                        isLoading: isLoading,
                        gradientColors: const [
                          secondaryPurple,
                          Color(0xFF7B3FEF),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Terms hint ──
                      Center(
                        child: Text(
                          "By signing up, you agree to our Terms & Privacy Policy",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: isDark ? Colors.white24 : Colors.black26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                      _LoginRedirect(isDark: isDark),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }
}

// ─────────────── Gradient Header ───────────────

class _GradientHeader extends StatelessWidget {
  final bool isDark;
  final Animation<double> floatAnimation;
  const _GradientHeader({required this.isDark, required this.floatAnimation});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(52)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2B9FFF),
              const Color(0xFF3AAFFF),
              secondaryPurple.withValues(alpha: isDark ? 0.55 : 0.75),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Large circle top-right
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Medium circle bottom-left
            Positioned(
              bottom: -25,
              left: -35,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Floating yellow dot
            Positioned(
              top: 55,
              right: 90,
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, floatAnimation.value * 0.6),
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: sunnyYellow,
                    ),
                  ),
                ),
              ),
            ),
            // Floating white dot
            Positioned(
              top: 110,
              left: 55,
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -floatAnimation.value * 0.5),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            // Floating orange dot
            Positioned(
              bottom: 55,
              right: 55,
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (_, __) => Transform.translate(
                  offset: Offset(floatAnimation.value * 0.4, 0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentOrange.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Back Button ───────────────

class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

// ─────────────── Ambient Background Blobs ───────────────

class _AmbientBlobs extends StatelessWidget {
  final bool isDark;
  const _AmbientBlobs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          bottom: h * 0.06,
          right: -55,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? secondaryPurple.withValues(alpha: 0.06)
                  : secondaryPurple.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          top: h * 0.55,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? mainBlue.withValues(alpha: 0.05)
                  : mainBlue.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: h * 0.72,
          right: w * 0.18,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? sunnyYellow.withValues(alpha: 0.15)
                  : sunnyYellow.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────── Enhanced Input Field ───────────────

class _EnhancedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? onToggle;
  final TextInputType type;

  const _EnhancedField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    this.isPassword = false,
    this.obscure = false,
    this.onToggle,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final Color fieldBg = isDark ? const Color(0xFF1E1C2A) : Colors.white;
    final Color borderColor = isDark
        ? accentColor.withValues(alpha: 0.30)
        : accentColor.withValues(alpha: 0.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDark ? accentColor.withValues(alpha: 0.8) : accentColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.8),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.10 : 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.nunito(
                color: isDark ? Colors.white24 : Colors.black26,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(icon,
                  color: accentColor.withValues(alpha: isDark ? 0.7 : 0.6),
                  size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: isDark ? Colors.white24 : Colors.black26,
                        size: 20,
                      ),
                      onPressed: onToggle,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────── Gradient Sign Up Button ───────────────

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final List<Color> gradientColors;

  const _GradientButton({
    this.onPressed,
    required this.label,
    this.isLoading = false,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: onPressed == null
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  label,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────── Login Redirect ───────────────

class _LoginRedirect extends StatelessWidget {
  final bool isDark;
  const _LoginRedirect({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white38 : Colors.black38,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          children: [
            TextSpan(
              text: 'Login',
              style: TextStyle(
                color: isDark ? Colors.blueAccent : secondaryPurple,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap =
                    () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
    );
  }
}
