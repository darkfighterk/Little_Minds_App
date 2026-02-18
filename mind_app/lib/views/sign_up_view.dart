import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../controllers/login_controller.dart';
import '../models/user_model.dart';

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
  late AnimationController _formController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formController.forward();
    });
  }

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
      firstNameController.clear();
      emailController.clear();
      passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );

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

  @override
  void dispose() {
    firstNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1A0533),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0533),
              Color(0xFF2D0B5A),
              Color(0xFF4A1278),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative orbs
            Positioned(
              top: -100,
              left: -80,
              child: _GlowOrb(
                  size: 320, color: const Color(0xFF8B2FC9), opacity: 0.28),
            ),
            Positioned(
              top: -80,
              right: -100,
              child: _GlowOrb(
                  size: 280, color: const Color(0xFFDA22FF), opacity: 0.22),
            ),
            Positioned(
              bottom: -120,
              right: -60,
              child: _GlowOrb(
                  size: 300, color: const Color(0xFF6B1FA8), opacity: 0.2),
            ),

            SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Back button
                      _GlassButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Header text
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF9EF5), Color(0xFFFFFFFF)],
                        ).createShader(bounds),
                        child: const Text(
                          'Create\nAccount',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Start your learning adventure today ✨',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 44),

                      // Form fields in glass card
                      SlideTransition(
                        position: _formSlide,
                        child: FadeTransition(
                          opacity: _formController.view,
                          child: _GlassCard(
                            child: Column(
                              children: [
                                _SignUpInputField(
                                  controller: firstNameController,
                                  label: 'Full Name',
                                  hint: 'Your name',
                                  icon: Icons.person_outline_rounded,
                                ),
                                _Divider(),
                                _SignUpInputField(
                                  controller: emailController,
                                  label: 'Email',
                                  hint: 'your@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                _Divider(),
                                _SignUpInputField(
                                  controller: passwordController,
                                  label: 'Password',
                                  hint: '••••••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: !_passwordVisible,
                                  suffixWidget: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white38,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _passwordVisible = !_passwordVisible),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Password strength hint
                      _PasswordHint(password: passwordController.text),

                      const SizedBox(height: 32),

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onSignUpPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: isLoading
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF8E2DE2),
                                        Color(0xFFDA22FF),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                              color: isLoading ? Colors.white12 : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isLoading
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFFDA22FF)
                                            .withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or sign up with',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1))),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIcon(Icons.g_mobiledata, Colors.red),
                          const SizedBox(width: 16),
                          _SocialIcon(
                              Icons.facebook_rounded, const Color(0xFF1877F2)),
                          const SizedBox(width: 16),
                          _SocialIcon(Icons.apple_rounded, Colors.white),
                          const SizedBox(width: 16),
                          _SocialIcon(Icons.business_center_rounded,
                              const Color(0xFF0A66C2)),
                        ],
                      ),

                      const SizedBox(height: 36),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: Color(0xFFFF9EF5),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      Navigator.pushReplacementNamed(
                                          context, '/'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
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

// ─────────────── Helper Widgets ───────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _GlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.white.withOpacity(0.08),
    );
  }
}

class _SignUpInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixWidget;
  final TextInputType? keyboardType;

  const _SignUpInputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixWidget,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: const Color(0xFFDA22FF),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
          prefixIcon:
              Icon(icon, color: Colors.white.withOpacity(0.35), size: 20),
          suffixIcon: suffixWidget,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}

class _PasswordHint extends StatelessWidget {
  final String password;

  const _PasswordHint({required this.password});

  int get strength {
    if (password.isEmpty) return 0;
    int s = 0;
    if (password.length >= 8) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final labels = ['Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.greenAccent
    ];
    final s = strength.clamp(1, 4) - 1;

    return Row(
      children: [
        ...List.generate(4, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: i <= s ? colors[s] : Colors.white12,
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(
          labels[s],
          style: TextStyle(
              color: colors[s], fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
