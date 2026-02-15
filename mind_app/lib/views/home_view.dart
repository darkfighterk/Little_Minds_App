import 'package:flutter/material.dart';
import '../models/user_model.dart';

class HomeView extends StatelessWidget {
  final User user;

  const HomeView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50] ?? Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Level 12 Explorer",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              "Hi, ${user.username}!",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic of the Day Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[700] ?? Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOPIC OF THE DAY",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Mission To Mars\nLaunch your AR rover now!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[700] ?? Colors.purple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Start Adventure"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Pick a World",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Grid of worlds
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  worldButton(Icons.nightlight_round, "Space", Colors.purple),
                  worldButton(Icons.pets, "Animals", Colors.green),
                  worldButton(Icons.favorite, "Human Body", Colors.red),
                  worldButton(Icons.public, "Geography", Colors.lightBlue),
                ],
              ),
            ),

            // Quick Scan placeholder
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.purple),
                  ),
                  const SizedBox(height: 8),
                  const Text("Quick Scan",
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // default selected index
        onTap: (index) {
          // handle navigation here if needed
        },
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ""),
        ],
      ),
    );
  }

  // Helper for each world button
  Widget worldButton(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
