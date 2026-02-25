import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
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

  late AnimationController _floatController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  final math.Random _random = math.Random();
  final List<_DecoItem> _decoItems = [];

  @override
  void initState() {
    super.initState();

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

  //Main Section for Connecting to the Go Backend
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
      final url = Uri.parse("http://10.0.2.2:8080/chat");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": userText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final botResponse = data['reply'];

        setState(() {
          _messages.add({"text": botResponse, "isMe": false});
          _isLoading = false;
        });
      } else {
        throw Exception(
            "Oops! Mindie is a bit confused right now. (Status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "text":
              "Mindie is taking a little nap! 🦄 (Please check if the server is running!)",
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
            colors: [Color(0xFFFFF9C4), Color(0xFFFCE4EC), Color(0xFFE8EAF6)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildFloatingDeco(context),
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _KidButton(bgColor: const Color(0xFFFF7043), child: const Text('☰')),
          const Spacer(),
          Row(
            children: [
              AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.translate(
                    offset: Offset(0, _bounceAnim.value * 0.4),
                    child: const Text('🦄', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 8),
              Text('Mindie',
                  style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFAD1457))),
            ],
          ),
          const Spacer(),
          _KidButton(bgColor: const Color(0xFF26C6DA), child: const Text('✏️')),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) => Transform.translate(
                offset: Offset(0, _bounceAnim.value), child: _MindieAvatar()),
          ),
          const SizedBox(height: 24),
          Text("Hi! I'm Mindie! 👋",
              style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFAD1457))),
          const SizedBox(height: 8),
          Text("Your smart learning buddy! 🌟",
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6A1B9A))),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _TopicChip(
                  label: '🦕 Dinosaurs',
                  color: const Color(0xFF66BB6A),
                  onTap: () =>
                      _quickAsk('Tell me a fun fact about dinosaurs!')),
              _TopicChip(
                  label: '🚀 Space',
                  color: const Color(0xFF42A5F5),
                  onTap: () =>
                      _quickAsk('Tell me something amazing about space!')),
              _TopicChip(
                  label: '📖 Story',
                  color: const Color(0xFFAB47BC),
                  onTap: () => _quickAsk('Tell me a short fun story!')),
            ],
          ),
        ],
      ),
    );
  }

  void _quickAsk(String text) {
    _messageController.text = text;
    _handleSend();
  }

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
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [Color(0xFFCE93D8), Color(0xFFAD1457)])),
              child: const Center(
                  child: Text('🦄', style: TextStyle(fontSize: 20))),
            ),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6F00), Color(0xFFFFB300)])
                    : const LinearGradient(
                        colors: [Color(0xFFCE93D8), Color(0xFFBA68C8)]),
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20)),
              ),
              child: Text(msg['text'],
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
        padding: EdgeInsets.only(left: 20, bottom: 10), child: _TypingDots());
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.90),
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _handleSend(),
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700, color: const Color(0xFF4A148C)),
              decoration: const InputDecoration(
                  hintText: 'Ask Mindie! 💬', border: InputBorder.none),
            ),
          ),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
                  borderRadius: BorderRadius.circular(14)),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Classes ---

class _MindieAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
          width: 175,
          height: 175,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
      const Text('🦄', style: TextStyle(fontSize: 95)),
    ]);
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TopicChip(
      {required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withOpacity(0.55), width: 2)),
        child: Text(label,
            style: GoogleFonts.fredoka(
                fontWeight: FontWeight.bold, color: color.withOpacity(0.9))),
      ),
    );
  }
}

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
            borderRadius: BorderRadius.circular(14)),
        child: Center(child: child));
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text('🦄 ', style: TextStyle(fontSize: 18)),
      Text('Mindie is thinking...',
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold, color: Colors.grey))
    ]);
  }
}

class _DecoItem {
  final double x, y, size, phase;
  final String emoji;
  const _DecoItem(
      {required this.x,
      required this.y,
      required this.size,
      required this.phase,
      required this.emoji});
}
