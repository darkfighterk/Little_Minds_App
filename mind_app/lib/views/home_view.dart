import 'package:flutter/material.dart';
import '../models/user_model.dart';

class HomeView extends StatelessWidget {
  final User user;

  const HomeView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9e8ff), // light purple-pinkish
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle starry/dotted background
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(painter: DotsPainter()),
              ),
            ),

            Column(
              children: [
                // Custom top bar (This is not the default app bar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.orange[300],
                        child: const Icon(Icons.person, size: 34, color: Colors.white),
                        // → later: backgroundImage: NetworkImage(user.avatarUrl ?? '')
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, ${user.username}!",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5c2d91),
                              ),
                            ),
                            Text(
                              "Level ${user.level ?? 1} Explorer",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_outlined,
                            size: 32, color: Colors.purple[700]),
                        onPressed: () {
                          // → open notifications
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Topic of the Day Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      // TODO: navigate to AR / Mission screen
                      debugPrint("Launch Mission to Mars!");
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6b48ff), Color(0xFFa78bfa)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOPIC OF THE DAY",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.85),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Mission To Mars\nLaunch your AR rover now!",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              "Start Adventure",
                              style: TextStyle(
                                color: Colors.purple[700],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Pick a World
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Pick a World",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Worlds grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: [
                        worldButton(Icons.nightlight_round, "Space", Colors.deepPurple),
                        worldButton(Icons.pets, "Animals", Colors.teal),
                        worldButton(Icons.favorite, "Human Body", Colors.redAccent),
                        worldButton(Icons.public, "Geography", Colors.blueAccent),
                      ],
                    ),
                  ),
                ),

                // Quick Scan section
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purple.shade300, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 40,
                          color: Colors.purple[700],
                        ),
                      ),
                      const SizedBox(height: 5),
                      /*Text(
                        "Quick Scan",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purple[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            // handle navigation
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.purple[700],
          unselectedItemColor: Colors.grey[500],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 32), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.book_rounded, size: 32), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.settings, size: 32), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.lightbulb_rounded, size: 32), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.menu_rounded, size: 32), label: ""),
          ],
        ),
      ),
    );
  }

  Widget worldButton(IconData icon, String label, Color baseColor) {
    return GestureDetector(
      onTap: () {
        debugPrint("$label tapped");
        // TODO: navigation to world screen
      },
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.5),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// dotted background
class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if (((x ~/ step + y ~/ step) % 2) == 0) {
          canvas.drawCircle(
            Offset(x + step / 2, y + step / 2),
            3.5,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}