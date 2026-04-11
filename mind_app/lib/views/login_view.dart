import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/login_controller.dart';
import 'main_tab_view.dart';
import '../models/user_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  bool isLoading = false;
  bool _passwordVisible = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  // ── Brand Palette ──
  static const Color mainBlue = Color(0xFF3AAFFF);
  static const Color secondaryPurple = Color(0xFFA55FEF);
  static const Color secondaryOrange = Color(0xFFFF8811);
  static const Color secondaryYellow = Color(0xFFFDDF50);

  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _float;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Route _smoothRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
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
        _smoothRoute(MainTabView(user: user)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Try again!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // ── Warm cream for light, rich dark for dark ──
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // ── Ambient background blobs ──
          _AmbientBlobs(isDark: isDark),

          // ── Gradient Header with decorative circles ──
          _GradientHeader(isDark: isDark, floatAnimation: _float),

          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 72),

                      // ── Floating Logo Badge ──
                      AnimatedBuilder(
                        animation: _float,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _float.value * 0.5),
                          child: child,
                        ),
                        child: _LogoBadge(isDark: isDark),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Little Minds",
                        style: GoogleFonts.fredoka(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Welcome to your learning journey",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // ── Input Fields ──
                      _EnhancedField(
                        controller: emailController,
                        hint: "Email Address",
                        label: "EMAIL",
                        icon: Icons.alternate_email_rounded,
                        accentColor: mainBlue,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),
                      _EnhancedField(
                        controller: passwordController,
                        hint: "Password",
                        label: "PASSWORD",
                        icon: Icons.vpn_key_rounded,
                        accentColor: secondaryPurple,
                        isDark: isDark,
                        isPassword: true,
                        obscureText: !_passwordVisible,
                        suffix: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: secondaryPurple.withValues(alpha: 0.45),
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.nunito(
                              color: isDark ? Colors.white60 : mainBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Gradient Login Button ──
                      _GradientButton(
                        onTap: isLoading ? null : _onLoginPressed,
                        text: "Login",
                        gradientColors: [
                          secondaryOrange,
                          const Color(0xFFFF5F5F)
                        ],
                        isLoading: isLoading,
                      ),

                      const SizedBox(height: 36),

                      // ── Divider ──
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              "Or continue with",
                              style: GoogleFonts.nunito(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialPill(
                            icon: const FaIcon(FontAwesomeIcons.google,
                                color: Colors.redAccent, size: 18),
                            label: "Google",
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          _SocialPill(
                            icon: const FaIcon(FontAwesomeIcons.facebookF,
                                color: Color(0xFF1877F2), size: 18),
                            label: "Facebook",
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.nunito(
                            color: isDark ? Colors.white38 : Colors.black45,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.blueAccent
                                    : secondaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Navigator.pushNamed(context, '/register'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
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
}

// ─────────────── Gradient Header with Decorative Circles ───────────────

class _GradientHeader extends StatelessWidget {
  final bool isDark;
  final Animation<double> floatAnimation;

  const _GradientHeader({required this.isDark, required this.floatAnimation});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(52)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2B9FFF),
              const Color(0xFF3AAFFF),
              const Color(0xFFA55FEF).withValues(alpha: isDark ? 0.55 : 0.75),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative large circle top-right
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Decorative medium circle bottom-left
            Positioned(
              bottom: -20,
              left: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Small accent dot top-center
            Positioned(
              top: 60,
              right: 80,
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, floatAnimation.value * 0.7),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFDDF50),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 50,
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -floatAnimation.value * 0.5),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              right: 50,
              child: AnimatedBuilder(
                animation: floatAnimation,
                builder: (_, __) => Transform.translate(
                  offset: Offset(floatAnimation.value * 0.4, 0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF8811).withValues(alpha: 0.7),
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

// ─────────────── Logo Badge ───────────────

class _LogoBadge extends StatelessWidget {
  final bool isDark;
  const _LogoBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFDDF50), Color(0xFFFF8811)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8811).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text("🎓", style: TextStyle(fontSize: 36)),
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
        // Blob bottom-right
        Positioned(
          bottom: h * 0.08,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFFA55FEF).withValues(alpha: 0.06)
                  : const Color(0xFFA55FEF).withValues(alpha: 0.08),
            ),
          ),
        ),
        // Blob center-left
        Positioned(
          top: h * 0.52,
          left: -50,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF3AAFFF).withValues(alpha: 0.05)
                  : const Color(0xFF3AAFFF).withValues(alpha: 0.07),
            ),
          ),
        ),
        // Small dot
        Positioned(
          top: h * 0.7,
          right: w * 0.15,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFFFDDF50).withValues(alpha: 0.15)
                  : const Color(0xFFFDDF50).withValues(alpha: 0.5),
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
  final bool obscureText;
  final Widget? suffix;

  const _EnhancedField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    this.isPassword = false,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    // Light: solid white with a visible colored border
    // Dark: deep dark surface
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
            borderRadius: BorderRadius.circular(18),
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
            obscureText: obscureText,
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
              prefixIcon: Icon(icon, color: accentColor, size: 22),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────── Gradient Button ───────────────

class _GradientButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final List<Color> gradientColors;
  final bool isLoading;

  const _GradientButton({
    this.onTap,
    required this.text,
    required this.gradientColors,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: onTap == null
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: onTap == null
              ? []
              : [
                  BoxShadow(
                    color: gradientColors.last.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
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
                  text,
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

// ─────────────── Social Pill Button ───────────────

class _SocialPill extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isDark;

  const _SocialPill(
      {required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
