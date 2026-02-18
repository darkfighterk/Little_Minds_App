import 'package:flutter/material.dart';
import 'forgot_password_otp_view.dart';

class ForgotPasswordEmailView extends StatefulWidget {
  const ForgotPasswordEmailView({super.key});

  @override
  State<ForgotPasswordEmailView> createState() => _ForgotPasswordEmailViewState();
}

class _ForgotPasswordEmailViewState extends State<ForgotPasswordEmailView> {
  final emailController = TextEditingController();
  bool isLoading = false;

  void _onSendCodePressed() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    setState(() => isLoading = true);
    // TODO: real API call to send OTP
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent! Check your email')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordOtpView(email: email)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4F9),

      body: SafeArea(
        child: Stack(
          children: [
            // Only keep the TOP-RIGHT bubble (removed the bottom one)
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
            // The bottom purple ball is REMOVED here

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

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

                  const Center(
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFAB47BC),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      'Please enter your email address to receive a verification code',
                      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 36),

                  Center(
                    child: Image.asset(
                      'assets/illustrations/forgot_password.png',
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.sentiment_dissatisfied_rounded,
                          size: 100,
                          color: Color(0xFFAB47BC),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  _InputField(
                    controller: emailController,
                    label: 'Email Address',
                    hint: 'your@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onSendCodePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB47BC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              'Send Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Try another way',
                        style: TextStyle(color: Color(0xFFAB47BC), fontSize: 15),
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
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
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFFAB47BC))
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