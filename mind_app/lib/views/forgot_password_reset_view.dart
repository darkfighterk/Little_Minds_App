import 'package:flutter/material.dart';
import 'login_view.dart'; // adjust path if needed

class ForgotPasswordResetView extends StatefulWidget {
  final String email;
  final String otp;

  const ForgotPasswordResetView({super.key, required this.email, required this.otp});

  @override
  State<ForgotPasswordResetView> createState() => _ForgotPasswordResetViewState();
}

class _ForgotPasswordResetViewState extends State<ForgotPasswordResetView> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  void _onSavePressed() async {
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (pass.isEmpty || confirm.isEmpty || pass != confirm || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check your passwords')),
      );
      return;
    }

    setState(() => isLoading = true);
    // TODO: real reset password API
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated!'), backgroundColor: Colors.green),
    );

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4F9),

      body: SafeArea(
        child: Stack(
          children: [
            // Only top-right bubble kept (bottom one removed)
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
            // Bottom purple ball removed here

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFAB47BC), size: 24),
                    ),
                  ),

                  const SizedBox(height: 44),

                  const Text(
                    'Create new password',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFAB47BC)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'New password must be different from last password',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  Center(
                    child: Image.asset(
                      'assets/illustrations/reset_password.png',
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.lock_reset_rounded, size: 100, color: Color(0xFFAB47BC));
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  _InputField(
                    controller: passwordController,
                    label: 'Password',
                    hint: '••••••••••',
                    obscureText: obscure1,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: obscure1 ? Icons.visibility_off : Icons.visibility,
                    onSuffixTap: () => setState(() => obscure1 = !obscure1),
                  ),

                  const SizedBox(height: 24),

                  _InputField(
                    controller: confirmController,
                    label: 'Confirm Password',
                    hint: '••••••••••',
                    obscureText: obscure2,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: obscure2 ? Icons.visibility_off : Icons.visibility,
                    onSuffixTap: () => setState(() => obscure2 = !obscure2),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onSavePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB47BC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFFAB47BC)) : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(onTap: onSuffixTap, child: Icon(suffixIcon, color: Colors.grey[600]))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}