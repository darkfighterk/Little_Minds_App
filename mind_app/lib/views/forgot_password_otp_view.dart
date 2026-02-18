import 'dart:async';
import 'package:flutter/material.dart';
import 'forgot_password_reset_view.dart';

class ForgotPasswordOtpView extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpView({super.key, required this.email});

  @override
  State<ForgotPasswordOtpView> createState() => _ForgotPasswordOtpViewState();
}

class _ForgotPasswordOtpViewState extends State<ForgotPasswordOtpView> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 40;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 3) {
          _focusNodes[i + 1].requestFocus();
        } else if (_controllers[i].text.isEmpty && i > 0) {
          _focusNodes[i - 1].requestFocus();
        }
      });
    }
  }

  void _startTimer() {
    _secondsRemaining = 40;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onVerifyPressed() {
    if (_otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 4-digit code')),
      );
      return;
    }

    // TODO: Verify OTP with backend

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordResetView(email: widget.email, otp: _otp),
      ),
    );
  }

  void _onResendPressed() {
    if (!_canResend) return;

    // TODO: Resend OTP

    _controllers.forEach((c) => c.clear());
    _focusNodes[0].requestFocus();
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New code sent!')),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
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
                    'Verification code',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFAB47BC)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Please enter the 4 digit code sent to',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.email,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFAB47BC)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  Center(
                    child: Image.asset(
                      'assets/illustrations/verification_code.png',
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.sms_rounded, size: 100, color: Color(0xFFAB47BC));
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Center(
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _onVerifyPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB47BC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Verify code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('00:${_secondsRemaining.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0xFFAB47BC), fontWeight: FontWeight.w600)),
                    ],
                  ),

                  TextButton(
                    onPressed: _canResend ? _onResendPressed : null,
                    child: Text(
                      'Resend code',
                      style: TextStyle(color: _canResend ? const Color(0xFFAB47BC) : Colors.grey, fontWeight: FontWeight.w600),
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