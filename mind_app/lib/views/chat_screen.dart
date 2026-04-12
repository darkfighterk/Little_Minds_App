import '../services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ── Brand palette (matches home) ──
const Color _mainBlue = Color(0xFF3AAFFF);
const Color _secondaryPurple = Color(0xFFA55FEF);
const Color _accentOrange = Color(0xFFFF8811);
const Color _sunnyYellow = Color(0xFFFDDF50);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final AIService _aiService = AIService();

  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  final math.Random _random = math.Random();
  final List<_DecoItem> _decoItems = [];

  @override
  void initState() {
    super.initState();

    final emojis = ['⭐', '✨', '🪐', '🦖', '💡', '🌈', '🔭', '📚'];
    for (int i = 0; i < 8; i++) {
      _decoItems.add(_DecoItem(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.8,
        size: _random.nextDouble() * 12 + 8,
        phase: _random.nextDouble() * 2 * math.pi,
        emoji: emojis[_random.nextInt(emojis.length)],
      ));
    }

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

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    _bounceController.dispose();
    super.dispose();
  }



  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isMe": true});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      // Build history for the AI Service
      final history = _messages.map((m) => {
        "role": m['isMe'] == true ? "user" : "assistant",
        "content": m['text'] as String,
      }).toList();

      final response = await _aiService.getAIResponse(history);
      setState(() {
        _messages.add({"text": response, "isMe": false});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "text":
              "Mindie is having a little nap! 💤 Maybe check the internet? ✨",
          "isMe": false,
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _quickAsk(String text) {
    _messageController.text = text;
    _handleSend();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          // ── Ambient blobs (matches home) ──
          _AmbientBlobs(isDark: isDark, floatController: _floatController),

          // ── Gradient header block ──
          _buildGradientHeader(isDark),

          // ── Floating emoji decorations ──
          ..._buildFloatingDeco(context),

          // ── Main content ──
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    _buildTopBar(isDark),
                    Expanded(
                      child: _messages.isNotEmpty
                          ? _buildMessageList(isDark)
                          : _buildHeroSection(isDark),
                    ),
                    if (_isLoading) _buildTypingIndicator(isDark),
                    _buildInputBar(isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(bool isDark) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _mainBlue,
            _mainBlue.withValues(alpha: 0.85),
            _secondaryPurple.withValues(alpha: isDark ? 0.4 : 0.65),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: _mainBlue.withValues(alpha: isDark ? 0.3 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          // Back button — glass pill (matches home)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat with Mindie',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Your AI learning buddy!',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Bouncing avatar
            AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _bounceAnim.value),
                child: child,
              ),
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
                  border: Border.all(
                    color: _mainBlue.withValues(alpha: 0.2),
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _mainBlue.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/mindie.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Text('🦄', style: TextStyle(fontSize: 64))),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Hi! I'm Mindie! 👋",
              style: GoogleFonts.fredoka(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Pick a fun topic to start! ✨',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),

            const SizedBox(height: 32),

            // Topic chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _TopicChip(
                  label: '🚀 Space Fact',
                  color: _secondaryPurple,
                  isDark: isDark,
                  onTap: () => _quickAsk('Tell me a super cool space fact! 🪐'),
                ),
                _TopicChip(
                  label: '🦖 Dinosaurs',
                  color: const Color(0xFF4CAF50),
                  isDark: isDark,
                  onTap: () => _quickAsk('Tell me a fun dinosaur fact! 🦖'),
                ),
                _TopicChip(
                  label: '🦁 Animals',
                  color: _accentOrange,
                  isDark: isDark,
                  onTap: () => _quickAsk('Tell me a funny animal fact! 🦁'),
                ),
                _TopicChip(
                  label: '🍎 Science',
                  color: Colors.pinkAccent,
                  isDark: isDark,
                  onTap: () => _quickAsk('Tell me a magic science fact! 🧪'),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      itemCount: _messages.length,
      itemBuilder: (context, i) => _buildBubble(_messages[i], isDark),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg, bool isDark) {
    final bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [_mainBlue, _secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color:
              isMe ? null : (isDark ? const Color(0xFF1E1C2A) : Colors.white),
          borderRadius: BorderRadius.circular(22).copyWith(
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(22),
            bottomLeft:
                isMe ? const Radius.circular(22) : const Radius.circular(4),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : _mainBlue.withValues(alpha: 0.12),
                  width: 1.5,
                ),
          boxShadow: [
            BoxShadow(
              color: isMe
                  ? _mainBlue.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg['text'],
          style: GoogleFonts.nunito(
            color: isMe
                ? Colors.white
                : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _mainBlue.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Text(
              '🦄 Mindie is thinking…',
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : _mainBlue.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText: 'Ask Mindie anything…',
                hintStyle: GoogleFonts.nunito(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_mainBlue, _secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingDeco(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return _decoItems
        .map((item) => AnimatedBuilder(
              animation: _floatController,
              builder: (context, _) {
                final yOff = math.sin(
                        _floatController.value * 2 * math.pi + item.phase) *
                    12;
                return Positioned(
                  left: item.x * sw,
                  top: item.y * sh + yOff,
                  child: Opacity(
                    opacity: 0.07,
                    child:
                        Text(item.emoji, style: TextStyle(fontSize: item.size)),
                  ),
                );
              },
            ))
        .toList();
  }
}

// ─────────────── Topic Chip ───────────────

class _TopicChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _TopicChip(
      {required this.label,
      required this.color,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.12 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────── Ambient Blobs (matches home exactly) ───────────────

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

// ─────────────── Deco Item ───────────────

class _DecoItem {
  final double x, y, size, phase;
  final String emoji;
  const _DecoItem({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.emoji,
  });
}
