import 'package:flutter/material.dart';
import 'login_view.dart'; // adjust path if needed

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFCE4F9,
      ), // ≈ pink-purple from your screenshot
      body: SafeArea(
        child: Stack(
          children: [
            // Optional: subtle floating shapes or stars can be added here if desired
            Positioned(
              top: 40,
              right: 30,
              child: Icon(Icons.star, color: Colors.yellow[700], size: 60),
            ),
            Positioned(
              bottom: 100,
              left: 50,
              child: Icon(Icons.star, color: Colors.yellow[600], size: 40),
            ),
            Positioned(
              top: 120,
              left: 40,
              child: Icon(Icons.star, color: Colors.yellow[500], size: 50),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The main illustration with speech bubbles (single image as requested)
                  Image.asset(
                    'assets/illustrations/onboarding_girls.png', // ← put your combined image here
                    height: 380, // adjust based on your image aspect ratio
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Let’s Start",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAB47BC),
                    ),
                  ),
                  const Text(
                    "Your Learning Adventure",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAB47BC),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Optional: maybe show a tooltip or just do nothing
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginView(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFAB47BC),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFAB47BC),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginView(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFAB47BC),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                      ],
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
