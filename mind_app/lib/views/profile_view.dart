
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          // Background design - purple space theme for kids
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6B48FF),     // vibrant purple
                  Color(0xFF4A2B99),     // deeper cosmic purple
                  Color(0xFF2A1A66),     // dark space purple
                ],
              ),
            ),
            child: Opacity(
              opacity: 0.18,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.0, 0.7],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: Center(
                  child: Transform.scale(
                    scale: 1.8,
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Optional: You can add a real asset image instead:
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/images/space_bg_purple_kids.png',
          //     fit: BoxFit.cover,
          //     opacity: const AlwaysStoppedAnimation(0.4),
          //   ),
          // ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Settings & Share icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Avatar + level badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.shade900.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1620332360178-664f4d97b0d8?w=400', // placeholder boy avatar
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Text(
                          'Level 12',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Name + title
                  const Text(
                    'Alex the Brave',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.purpleAccent,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade700.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Level 12 Explorer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats cards
                  _buildStatCard(
                    icon: Icons.star,
                    iconColor: Colors.amber,
                    title: 'Total Stars',
                    value: '2,450',
                    today: '+150 Today',
                  ),

                  const SizedBox(height: 16),

                  _buildStatCard(
                    icon: Icons.rocket_launch,
                    iconColor: const Color(0xFF00D4FF),
                    title: 'Level 13 Progress',
                    value: '750 / 1000 XP',
                    subtitle: 'Earn 250 more XP to unlock the Moon Walker title!',
                    showProgress: true,
                    progress: 0.75,
                  ),

                  const SizedBox(height: 32),

                  // Badges section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Earned Badges',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(color: Color(0xFF00D4FF), fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _BadgeCircle(color: Colors.purple, icon: Icons.rocket, label: 'Space Ace'),
                        SizedBox(width: 16),
                        _BadgeCircle(color: Colors.orange, icon: Icons.dangerous, label: 'Dino Hunter'),
                        SizedBox(width: 16),
                        _BadgeCircle(color: Colors.teal, icon: Icons.bug_report, label: 'Bug Catcher'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Recent Missions
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Missions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildMissionCard(
                    title: 'The Jurassic Trail',
                    subtitle: 'Found 4/4 Fossils',
                    imageUrl: 'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=400', // forest path placeholder
                    completed: true,
                  ),

                  const SizedBox(height: 16),

                  _buildMissionCard(
                    title: 'Solar System Scout',
                    subtitle: 'Mars Orbit reached',
                    imageUrl: 'https://images.unsplash.com/photo-1614732414444-096e5f1122d5?w=400', // mars placeholder
                    completed: true,
                  ),

                  const SizedBox(height: 80), // bottom padding
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation (simplified)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple.shade900.withOpacity(0.8),
        selectedItemColor: const Color(0xFF00D4FF),
        unselectedItemColor: Colors.white70,
        currentIndex: 1, // Profile selected
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? today,
    String? subtitle,
    bool showProgress = false,
    double progress = 0.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (today != null) ...[
            const SizedBox(height: 4),
            Text(
              today,
              style: TextStyle(color: Colors.greenAccent.shade200, fontSize: 14),
            ),
          ],
          if (showProgress) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required bool completed,
  }) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          if (completed)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 36,
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeCircle extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _BadgeCircle({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.6)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}