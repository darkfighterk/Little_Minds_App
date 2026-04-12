import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_otp_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class ForgotPasswordEmailView extends StatefulWidget {
  const ForgotPasswordEmailView({super.key});

  @override
  State<ForgotPasswordEmailView> createState() =>
      _ForgotPasswordEmailViewState();
}

class _ForgotPasswordEmailViewState extends State<ForgotPasswordEmailView> {
  final emailController = TextEditingController();
  bool isLoading = false;

  // ──  Send OTP Logic (Preserved your logic) ──
  void _onSendCodePressed() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showToast('Please enter a valid email address', Colors.orangeAccent);
      return;
    }

    setState(() => isLoading = true);
    //  Later: Backend API to send magic code
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    if (!mounted) return;

    _showToast('Magic code sent! Check your inbox 🪄', Colors.green);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordOtpView(email: email)),
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  _buildBackButton(),
                  const SizedBox(height: 35),

                  //  Illustration Section
                  _buildIllustration(context),
                  const SizedBox(height: 40),

                  //  Header Text in Fredoka/Premium style
                  const Center(
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Enter your email address to receive a magic verification code! ✨',
                      style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 45),

                  //  Email Input Field
                  _InputField(
                    controller: emailController,
                    label: 'Email Address',
                    hint: 'your@email.com',
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 45),

                  //  Action Button
                  _buildSendButton(),

                  const SizedBox(height: 25),
                  _buildFooterActions(context),
                  const SizedBox(height: 40),
                ],
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

  Widget _buildIllustration(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : mainBlue.withValues(alpha: 0.05),
            shape: BoxShape.circle),
        child: Image.asset(
          'assets/illustrations/forgot_password.png',
          height: 200,
          errorBuilder: (_, __, ___) => Icon(Icons.lock_open_rounded,
              size: 100, color: isDark ? Colors.white : mainBlue),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onSendCodePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: mainBlue,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: mainBlue.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : const Text('Send Magic Code',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Try another way',
            style: GoogleFonts.nunito(
                color: isDark ? Colors.blueAccent : secondaryPurple,
                fontWeight: FontWeight.w800,
                fontSize: 15)),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType type;

  const _InputField(
      {required this.controller,
      required this.label,
      required this.hint,
      required this.icon,
      this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? mainBlue : mainBlue.withValues(alpha: 0.6),
                letterSpacing: 1.1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : mainBlue.withValues(alpha: 0.5)),
              hintText: hint,
              hintStyle: GoogleFonts.nunito(
                  color: isDark ? Colors.white24 : Colors.black26),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : mainBlue.withValues(alpha: 0.1),
                      width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : mainBlue.withValues(alpha: 0.08),
                      width: 2)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: mainBlue, width: 2)),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }
}
