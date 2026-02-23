import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

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

  // TODO: Replace with your actual Gemini API Key
  final String _apiKey = "YOUR_GEMINI_API_KEY_HERE";

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  late AnimationController _floatController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  final math.Random _random = math.Random();
  final List<_DecoItem> _decoItems = [];

  @override
  void initState() {
    super.initState();

    // Generate floating background emojis
    final emojis = ['⭐', '🌟', '✨', '💫', '🌈', '🦋', '🌸', '🍭', '🎈', '🎀'];
    for (int i = 0; i < 14; i++) {
      _decoItems.add(_DecoItem(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.85,
        size: _random.nextDouble() * 14 + 8,
        phase: _random.nextDouble() * 2 * math.pi,
        emoji: emojis[_random.nextInt(emojis.length)],
      ));
    }

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        "Your name is Mindie. You are a friendly and encouraging AI learning assistant designed for children aged 5 to 11. "
        "Always communicate using simple, age-appropriate language that is easy for young learners to understand. "
        "Use a warm, positive, and enthusiastic tone to keep children motivated and engaged. "
        "Include relevant emojis to make responses more visual and appealing. "
        "Keep answers concise and well-structured — avoid long paragraphs. "
        "When explaining concepts, use relatable real-life examples children can connect with. "
        "Always celebrate curiosity and effort, and never make a child feel discouraged. "
        "If a question is beyond the scope of learning, gently redirect to an age-appropriate topic.",
      ),
    );
    _chatSession = _model.startChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _floatController.dispose();
    _bounceController.dispose();
    super.dispose();
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

  Future<void> _handleSend() async {
    if (_messageController.text.trim().isEmpty) return;
    final userText = _messageController.text.trim();
    setState(() {
      _messages.add({"text": userText, "isMe": true});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(userText));
      setState(() {
        _messages.add({
          "text": response.text ??
              "Sorry, I couldn't get a response. Please try again! 😊",
          "isMe": false,
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "text":
              "Oops! I couldn't connect right now. Please check your internet and try again! 🔌",
          "isMe": false,
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  bool get _hasMessages => _messages.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF9C4), // warm sunny yellow
              Color(0xFFFCE4EC), // soft pink
              Color(0xFFE8EAF6), // lavender
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating decorative emojis
              ..._buildFloatingDeco(context),
              // Main UI
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _hasMessages
                        ? _buildMessageList()
                        : _buildHeroSection(),
                  ),
                  if (_isLoading && _hasMessages) _buildTypingIndicator(),
                  _buildInputBar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Floating background emojis ─────────────────────────────────────────────
  List<Widget> _buildFloatingDeco(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    return _decoItems.map((item) {
      return AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          final yOffset =
              math.sin(_floatController.value * 2 * math.pi + item.phase) * 18;
          return Positioned(
            left: item.x * screenW,
            top: item.y * screenH * 0.8 + yOffset,
            child: Opacity(
              opacity: 0.28,
              child: Text(item.emoji, style: TextStyle(fontSize: item.size)),
            ),
          );
        },
      );
    }).toList();
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.80),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFAB91).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _KidButton(
            bgColor: const Color(0xFFFF7043),
            child: const Text('☰', style: TextStyle(fontSize: 17)),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _bounceAnim.value * 0.4),
                  child: const Text('🦄', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Mindie',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFAD1457),
                ),
              ),
            ],
          ),
          const Spacer(),
          _KidButton(
            bgColor: const Color(0xFF26C6DA),
            child: const Text('✏️', style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
    );
  }

  // ── Hero section (empty state) ─────────────────────────────────────────────
  Widget _buildHeroSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Animated mascot
          AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _bounceAnim.value),
              child: child,
            ),
            child: _MindieAvatar(),
          ),
          const SizedBox(height: 24),
          // Greeting text
          Text(
            "Hi! I'm Mindie! 👋",
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFAD1457),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your smart learning buddy! 🌟",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 28),
          // Quick topic chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _TopicChip(
                label: '🦕 Dinosaurs',
                color: const Color(0xFF66BB6A),
                onTap: () => _quickAsk('Tell me a fun fact about dinosaurs!'),
              ),
              _TopicChip(
                label: '🚀 Space',
                color: const Color(0xFF42A5F5),
                onTap: () =>
                    _quickAsk('Tell me something amazing about space!'),
              ),
              _TopicChip(
                label: '🧮 Math Help',
                color: const Color(0xFFFF7043),
                onTap: () => _quickAsk('Can you teach me a fun math trick?'),
              ),
              _TopicChip(
                label: '📖 Tell a Story',
                color: const Color(0xFFAB47BC),
                onTap: () => _quickAsk('Tell me a short fun story!'),
              ),
              _TopicChip(
                label: '🐬 Animals',
                color: const Color(0xFF26C6DA),
                onTap: () => _quickAsk('What is the coolest animal fact?'),
              ),
              _TopicChip(
                label: '🎨 Draw Ideas',
                color: const Color(0xFFFFCA28),
                onTap: () => _quickAsk('Give me a fun drawing idea!'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _quickAsk(String text) {
    _messageController.text = text;
    _handleSend();
  }

  // ── Message list ───────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildBubble(_messages[index]),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFCE93D8), Color(0xFFAD1457)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFAD1457).withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🦄', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFCE93D8), Color(0xFFBA68C8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMe
                            ? const Color(0xFFFF6F00)
                            : const Color(0xFFAB47BC))
                        .withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg['text'],
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Typing indicator ───────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFCE93D8), Color(0xFFAD1457)],
                ),
              ),
              child: const Center(
                child: Text('🦄', style: TextStyle(fontSize: 18)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const _TypingDots(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sticker button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🎨', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _handleSend(),
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A148C),
              ),
              decoration: InputDecoration(
                hintText: 'Ask Mindie a question! 💬',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFCE93D8),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Mic button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Color(0xFF7E57C2),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Send button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: _handleSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: hasText
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: hasText ? null : const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: hasText
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6F00).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: hasText
                        ? const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20)
                        : const Text('😊', style: TextStyle(fontSize: 20)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Mindie Avatar (hero mascot) ───────────────────────────────────────────────
class _MindieAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFCE93D8).withOpacity(0.4),
                const Color(0xFFF8BBD9).withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // White circle
        Container(
          width: 175,
          height: 175,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCE93D8).withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        // Unicorn mascot emoji
        const Text('🦄', style: TextStyle(fontSize: 95)),
        // Sparkle decorations around
        const Positioned(
          top: 12,
          right: 22,
          child: Text('✨', style: TextStyle(fontSize: 24)),
        ),
        const Positioned(
          bottom: 22,
          left: 18,
          child: Text('⭐', style: TextStyle(fontSize: 20)),
        ),
        const Positioned(
          top: 34,
          left: 16,
          child: Text('🌟', style: TextStyle(fontSize: 17)),
        ),
        const Positioned(
          bottom: 30,
          right: 16,
          child: Text('💫', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}

// ── Topic chip ────────────────────────────────────────────────────────────────
class _TopicChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.55), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

// ── Kid nav button ────────────────────────────────────────────────────────────
class _KidButton extends StatelessWidget {
  final Color bgColor;
  final Widget child;

  const _KidButton({required this.bgColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bgColor.withOpacity(0.4), width: 1.5),
      ),
      child: Center(child: child),
    );
  }
}

// ── Typing dots animation ─────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  final List<Color> _dotColors = [
    const Color(0xFFFF6F00),
    const Color(0xFFAD1457),
    const Color(0xFF6A1B9A),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0, -6 * _controllers[i].value),
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dotColors[i],
                  boxShadow: [
                    BoxShadow(
                      color: _dotColors[i].withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
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
