import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Shared brand palette ──
const Color _mainBlue = Color(0xFF3AAFFF);
const Color _secondaryPurple = Color(0xFFA55FEF);
const Color _accentOrange = Color(0xFFFF8811);
const Color _sunnyYellow = Color(0xFFFDDF50);

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> with TickerProviderStateMixin {
  static const String githubUrl =
      "https://github.com/darkfighterk/Little_Minds_App.git";

  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entrySlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> openGithub() async {
    final Uri url = Uri.parse(githubUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg =
        isDark ? const Color(0xFF12111A) : const Color(0xFFFFF8EE);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          _AmbientBlobs(isDark: isDark, floatController: _floatController),
          _GradientHeader(isDark: isDark, floatController: _floatController),
          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    // ── Top bar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'About',
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── App badge in header ──
                    const SizedBox(height: 16),
                    _buildAppBadge(),

                    const SizedBox(height: 20),

                    // ── Body card ──
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: scaffoldBg,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(40)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.3 : 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(22, 30, 22, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Vision & Mission ──
                              _SectionLabel(label: 'Our Story', isDark: isDark),
                              const SizedBox(height: 14),
                              _AboutCard(
                                title: 'Our Vision',
                                description:
                                    'To create a fun and engaging digital learning environment where young explorers can develop knowledge, creativity, and problem-solving skills.',
                                color: _secondaryPurple,
                                icon: Icons.remove_red_eye_outlined,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 14),
                              _AboutCard(
                                title: 'Our Mission',
                                description:
                                    'To support children aged 6 to 18 by providing interactive tools such as quizzes, puzzles, and digital notebooks that make learning simple.',
                                color: _accentOrange,
                                icon: Icons.rocket_launch_outlined,
                                isDark: isDark,
                              ),

                              const SizedBox(height: 30),

                              // ── Team section ──
                              _SectionLabel(
                                  label: 'Development Team', isDark: isDark),
                              const SizedBox(height: 14),
                              _buildTeamCard(isDark),

                              const SizedBox(height: 30),

                              // ── Action buttons ──
                              _SectionLabel(
                                  label: 'Quick Links', isDark: isDark),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionTile(
                                      icon: Icons.help_outline_rounded,
                                      label: 'FAQ',
                                      color: _sunnyYellow,
                                      isDark: isDark,
                                      onTap: () => _showFAQ(context),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _ActionTile(
                                      icon: Icons.mail_outline_rounded,
                                      label: 'Contact',
                                      color: const Color(0xFF26A69A),
                                      isDark: isDark,
                                      onTap: () => _showContact(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _ActionTile(
                                icon: Icons.terminal_rounded,
                                label: 'Source Code (GitHub)',
                                color: isDark
                                    ? const Color(0xFF3AAFFF)
                                    : const Color(0xFF1A1A2E),
                                isDark: isDark,
                                onTap: openGithub,
                                fullWidth: true,
                              ),

                              const SizedBox(height: 30),
                              Center(
                                child: Text(
                                  '© 2026 Little Minds Project',
                                  style: GoogleFonts.nunito(
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.black26,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App logo badge in header ──
  Widget _buildAppBadge() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const CircleAvatar(
            radius: 34,
            backgroundImage: AssetImage("assets/brand/play_store_512.png"),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Little Minds',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          'Version 2.0.1',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }

  // ── Team card ──
  Widget _buildTeamCard(bool isDark) {
    // Members — leader first, rest follow
    const members = [
      _TeamMember(
          name: 'W.M.P.B. Wanasinghe',
          id: '32318',
          asset: 'assets/Wanasinghe.png',
          isLeader: true),
      _TeamMember(
          name: 'A.K.A. Tharindu', id: '32372', asset: 'assets/Tharindu.png'),
      _TeamMember(
          name: 'U.D.S. Ranjith', id: '32747', asset: 'assets/Ranjith.png'),
      _TeamMember(
          name: 'R.A.V. Kavinda', id: '32327', asset: 'assets/Kavinda.png'),
      _TeamMember(
          name: 'G.A.P.O. Godamune', id: '32383', asset: 'assets/Godamune.png'),
      _TeamMember(
          name: 'R.A.V.M. Perera', id: '32953', asset: 'assets/Perera.png'),
      _TeamMember(
          name: 'P.H.D.K. Rathnayaka',
          id: '34232',
          asset: 'assets/Rathnayaka.png'),
      _TeamMember(
          name: 'I.A.C.S. Thilakarathna',
          id: '32231',
          asset: 'assets/Thilakarathna.png'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? _mainBlue.withValues(alpha: 0.18)
              : _mainBlue.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _mainBlue.withValues(alpha: isDark ? 0.10 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_mainBlue, _secondaryPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _mainBlue.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.groups_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Seven',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'NSBM Undergraduates',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            _mainBlue.withValues(alpha: isDark ? 0.75 : 0.70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
          ),

          // Member rows
          ...members.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            final isLast = i == members.length - 1;
            return _buildMemberRow(m, isDark, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildMemberRow(_TeamMember m, bool isDark, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar Placeholder
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : _mainBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _mainBlue.withValues(alpha: isDark ? 0.1 : 0.2),
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      m.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: _mainBlue.withValues(alpha: 0.4),
                            size: 26,
                          ),
                        );
                      },
                    ),
                  ),
                  if (m.isLeader)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: _sunnyYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: Colors.brown, size: 11),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.name,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        if (m.isLeader) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_sunnyYellow, _accentOrange],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Leader',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      m.id,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 70,
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
          ),
      ],
    );
  }

  // ── Dialogs ──
  void _showFAQ(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('FAQ',
            style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _faqItem(isDark, 'How do I play?',
                  'Choose any activity from the home screen like Quiz Arena or Puzzles.'),
              _faqItem(isDark, 'Is it free?',
                  'Yes, Little Minds is a free educational project for students.'),
              _faqItem(isDark, 'Can I save notes?',
                  'Yes, use the Notebook feature to save your ideas.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got it',
                style: GoogleFonts.nunito(
                    color: _mainBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(bool isDark, String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800, color: _mainBlue, fontSize: 14)),
          const SizedBox(height: 4),
          Text(a,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }

  void _showContact(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Contact Us',
            style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_rounded,
                    color: Colors.green, size: 20),
              ),
              title: Text('Call Tharindu',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
              subtitle: Text('0719361313',
                  style: GoogleFonts.nunito(
                      color: isDark ? Colors.white54 : Colors.black54)),
              onTap: () => launchUrl(Uri.parse("tel:0719361313")),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close',
                style: GoogleFonts.nunito(
                    color: _mainBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Team Member Model ───────────────

class _TeamMember {
  final String name;
  final String id;
  final String asset;
  final bool isLeader;
  const _TeamMember({
    required this.name,
    required this.id,
    required this.asset,
    this.isLeader = false,
  });
}

// ─────────────── About Card ───────────────

class _AboutCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _AboutCard({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.18)
              : color.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.10 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: isDark ? 0.75 : 0.70),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Action Tile ───────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? color.withValues(alpha: 0.20)
                : color.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.08 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              fullWidth ? MainAxisAlignment.center : MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Gradient Header ───────────────

class _GradientHeader extends StatelessWidget {
  final bool isDark;
  final AnimationController floatController;
  const _GradientHeader({required this.isDark, required this.floatController});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1030), const Color(0xFF0D1B40)]
                : [
                    const Color(0xFF2B9FFF),
                    const Color(0xFF3AAFFF),
                    const Color(0xFFA55FEF),
                  ],
            stops: isDark ? [0.0, 1.0] : [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -55,
              right: -55,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              top: 65,
              right: 90,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, sin(floatController.value * pi) * 5),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _sunnyYellow),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 55,
              child: AnimatedBuilder(
                animation: floatController,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -sin(floatController.value * pi) * 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Ambient Blobs ───────────────

class _AmbientBlobs extends StatelessWidget {
  final bool isDark;
  final AnimationController floatController;
  const _AmbientBlobs({required this.isDark, required this.floatController});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          bottom: h * 0.08,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? _secondaryPurple.withValues(alpha: 0.05)
                  : _secondaryPurple.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          top: h * 0.55,
          left: -50,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? _mainBlue.withValues(alpha: 0.04)
                  : _mainBlue.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: h * 0.72,
          right: w * 0.15,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? _sunnyYellow.withValues(alpha: 0.15)
                  : _sunnyYellow.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────── Section Label ───────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
        color: isDark ? Colors.white38 : Colors.black.withValues(alpha: 0.35),
      ),
    );
  }
}
