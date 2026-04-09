import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_reset_view.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color accentOrange = Color(0xFFFF8811);
const Color sunnyYellow = Color(0xFFFDDF50);

class ForgotPasswordOtpView extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpView({super.key, required this.email});

  @override
  State<ForgotPasswordOtpView> createState() => _ForgotPasswordOtpViewState();
}

class _ForgotPasswordOtpViewState extends State<ForgotPasswordOtpView> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 40;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _setupAutoForward();
  }

  void _setupAutoForward() {
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
      if (!mounted) return;
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
      _showToast('Please enter the 4-digit code', Colors.orangeAccent);
      return;
    }
    //  Later: Backend OTP verification here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) =>
              ForgotPasswordResetView(email: widget.email, otp: _otp)),
    );
  }

  void _onResendPressed() {
    if (!_canResend) return;
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startTimer();
    _showToast('New magic code sent! 🪄', Colors.green);
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
          _buildBackgroundDecor(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  _buildBackButton(),
                  const SizedBox(height: 35),
                  _buildIllustration(),
                  const SizedBox(height: 30),

                  //  Header Text in Recoleta
                  const Text('Verification Code',
                      style: TextStyle(
                          fontFamily: 'Recoleta',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 12),
                  _buildSubtitle(),

                  const SizedBox(height: 40),

                  //  OTP Input Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => _buildOtpBox(i)),
                  ),

                  const SizedBox(height: 45),

                  //  Verify Button
                  _buildVerifyButton(),

                  const SizedBox(height: 30),
                  _buildTimerSection(),
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
              color: mainBlue.withValues(alpha: 0.06), shape: BoxShape.circle)),
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
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
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
          color: secondaryPurple.withValues(alpha: 0.05), shape: BoxShape.circle),
      child: Image.asset(
        'assets/illustrations/verification_code.png',
        height: 180,
        errorBuilder: (_, __, ___) => const Icon(Icons.mark_email_read_rounded,
            size: 100, color: secondaryPurple),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text('Please enter the 4 digit code sent to',
            style: GoogleFonts.nunito(
                fontSize: 15,
                color: Colors.black38,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(widget.email,
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800, color: mainBlue)),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 65,
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: mainBlue.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _focusNodes[index].hasFocus
                ? mainBlue
                : mainBlue.withValues(alpha: 0.1),
            width: 2),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 1,
          style: GoogleFonts.nunito(
              fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
          decoration:
              const InputDecoration(counterText: "", border: InputBorder.none),
          onChanged: (_) => setState(() {}), // Refresh border highlight
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _onVerifyPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryPurple,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: secondaryPurple.withValues(alpha: 0.4),
        ),
        child: const Text('Verify Code',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        Text('00:${_secondsRemaining.toString().padLeft(2, '0')}',
            style: GoogleFonts.nunito(
                color: mainBlue, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 5),
        TextButton(
          onPressed: _canResend ? _onResendPressed : null,
          child: Text('Resend magic code',
              style: TextStyle(
                  color: _canResend ? secondaryPurple : Colors.black26,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
