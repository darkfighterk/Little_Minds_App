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
                children: [
                  const SizedBox(height: 15),
                  _buildBackButton(context),
                  const SizedBox(height: 35),
                  _buildIllustration(context),
                  const SizedBox(height: 30),

                  //  Header Text in Fredoka/Premium style
                  const Text('Verification Code',
                      style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  _buildSubtitle(context),

                  const SizedBox(height: 40),

                  //  OTP Input Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => _buildOtpBox(i, context)),
                  ),

                  const SizedBox(height: 45),

                  //  Verify Button
                  _buildVerifyButton(),

                  const SizedBox(height: 30),
                  _buildTimerSection(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBackButton(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
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
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : secondaryPurple.withValues(alpha: 0.05),
          shape: BoxShape.circle),
      child: Image.asset(
        'assets/illustrations/verification_code.png',
        height: 180,
        errorBuilder: (_, __, ___) => Icon(Icons.mark_email_read_rounded,
            size: 100, color: isDark ? Colors.white : secondaryPurple),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text('Please enter the 4 digit code sent to',
            style: GoogleFonts.nunito(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(widget.email,
            style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.blueAccent : Colors.white)),
      ],
    );
  }

  Widget _buildOtpBox(int index, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 65,
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : mainBlue.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _focusNodes[index].hasFocus
                ? mainBlue
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : mainBlue.withValues(alpha: 0.1)),
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
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87),
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

  Widget _buildTimerSection(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text('00:${_secondsRemaining.toString().padLeft(2, '0')}',
            style: GoogleFonts.nunito(
                color: isDark ? Colors.blueAccent : mainBlue,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        const SizedBox(height: 5),
        TextButton(
          onPressed: _canResend ? _onResendPressed : null,
          child: Text('Resend magic code',
              style: TextStyle(
                  color: _canResend
                      ? (isDark ? Colors.blueAccent : secondaryPurple)
                      : (isDark ? Colors.white24 : Colors.black26),
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
