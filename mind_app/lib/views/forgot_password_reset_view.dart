import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class ForgotPasswordResetView extends StatefulWidget {
  final String email;
  final String otp;

  const ForgotPasswordResetView(
      {super.key, required this.email, required this.otp});

  @override
  State<ForgotPasswordResetView> createState() =>
      _ForgotPasswordResetViewState();
}

class _ForgotPasswordResetViewState extends State<ForgotPasswordResetView> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  // ──  Reset Logic (Preserved your logic) ──
  void _onSavePressed() async {
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (pass.isEmpty || confirm.isEmpty || pass != confirm || pass.length < 6) {
      _showError('Please check your passwords (min 6 characters)');
      return;
    }

    setState(() => isLoading = true);
    //  Later: Integrate your real reset API here
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password updated successfully! 🎉'),
            backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginView()));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.orangeAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //  Soft Background Decor
          _buildBackgroundDecor(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  _buildBackButton(),
                  const SizedBox(height: 30),

                  //  Illustration Section
                  _buildIllustration(),
                  const SizedBox(height: 35),

                  //  Header Text in Recoleta
                  const Text(
                    'Create New Password',
                    style: TextStyle(
                        fontFamily: 'Recoleta',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your new password must be different from your old one for safety! 🛡️',
                    style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: Colors.black38,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  //  Input Fields
                  _InputField(
                    controller: passwordController,
                    label: 'New Password',
                    obscureText: obscure1,
                    icon: Icons.lock_outline_rounded,
                    suffix: obscure1
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    onSuffixTap: () => setState(() => obscure1 = !obscure1),
                  ),
                  const SizedBox(height: 20),
                  _InputField(
                    controller: confirmController,
                    label: 'Confirm Password',
                    obscureText: obscure2,
                    icon: Icons.verified_user_outlined,
                    suffix: obscure2
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    onSuffixTap: () => setState(() => obscure2 = !obscure2),
                  ),

                  const SizedBox(height: 45),

                  //  Save Button
                  _buildSaveButton(),
                  const SizedBox(height: 30),
                ],
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
              color: mainBlue.withOpacity(0.06), shape: BoxShape.circle)),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ]),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: sunnyYellow.withOpacity(0.1), shape: BoxShape.circle),
      child: Image.asset(
        'assets/illustrations/reset_password.png',
        height: 180,
        errorBuilder: (_, __, ___) => const Icon(
            Icons.enhanced_encryption_rounded,
            size: 100,
            color: secondaryPurple),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onSavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryPurple,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: secondaryPurple.withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : const Text('Save Password',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final IconData icon;
  final IconData? suffix;
  final VoidCallback? onSuffixTap;

  const _InputField(
      {required this.controller,
      required this.label,
      required this.icon,
      this.obscureText = false,
      this.suffix,
      this.onSuffixTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: mainBlue.withOpacity(0.6),
                letterSpacing: 1.1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: mainBlue.withOpacity(0.5)),
              suffixIcon: suffix != null
                  ? IconButton(
                      icon: Icon(suffix, color: Colors.black26),
                      onPressed: onSuffixTap)
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      BorderSide(color: mainBlue.withOpacity(0.1), width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      BorderSide(color: mainBlue.withOpacity(0.08), width: 2)),
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
