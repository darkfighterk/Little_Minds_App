import '../services/ai_service.dart';
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
  final AIService _aiService = AIService();

  final Color mainBlue = const Color(0xFF3AAFFF);
  final Color secondaryPurple = const Color(0xFFA55FEF);
  final Color accentOrange = const Color(0xFFFF8811);
  final Color sunnyYellow = const Color(0xFFFDDF50);

  late AnimationController _floatController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  final math.Random _random = math.Random();
  final List<_DecoItem> _decoItems = [];

  @override
  void initState() {
    super.initState();
    // Background decorations
    final emojis = ['⭐', '✨', '🪐', '🦖', '💡', '🌈', '🔭', '📚'];
    for (int i = 0; i < 10; i++) {
      _decoItems.add(_DecoItem(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.8,
        size: _random.nextDouble() * 15 + 10,
        phase: _random.nextDouble() * 2 * math.pi,
        emoji: emojis[_random.nextInt(emojis.length)],
      ));
    }

    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
    _bounceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _floatController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  String get _systemPrompt =>
      "You are Mindie, a super friendly AI buddy for kids. "
      "Rules: 1. Use lots of emojis. 2. Keep answers under 3 short sentences. "
      "3. Use simple words kids understand. 4. Always end with a fun question. "
      "5. Be exciting and encouraging!";

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final userText = text;

    setState(() {
      _messages.add({"text": userText, "isMe": true});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.getAIResponse("$_systemPrompt\n\nUser: $userText");

      setState(() {
        _messages.add({"text": response, "isMe": false});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "text":
              "Mindie is having a little nap! 💤 Maybe check the internet? ✨",
          "isMe": false
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          ..._buildFloatingDeco(context),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                    child: _messages.isNotEmpty
                        ? _buildMessageList()
                        : _buildHeroSection()),
                if (_isLoading) _buildTypingIndicator(),
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : Colors.black87)),
          Text('Chat with Mindie',
              style: TextStyle(
                  fontFamily: 'Recoleta',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : mainBlue)),
          const Text('🦄', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) => Transform.translate(
                offset: Offset(0, _bounceAnim.value),
                child: _MindieAvatar(mainBlue)),
          ),
          const SizedBox(height: 25),
          Text("Hi! I'm Mindie! 👋",
              style: TextStyle(
                  fontFamily: 'Recoleta',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : mainBlue)),
          const SizedBox(height: 10),
          Text("Pick a fun topic to start! ✨",
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.blueGrey)),
          const SizedBox(height: 35),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _TopicChip(
                  label: '🚀 Space Fact',
                  color: secondaryPurple,
                  onTap: () =>
                      _quickAsk('Tell me a super cool space fact! 🪐')),
              _TopicChip(
                  label: '🦖 Dinosaurs',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _quickAsk('Tell me a fun dinosaur fact! 🦖')),
              _TopicChip(
                  label: '🦁 Animals',
                  color: accentOrange,
                  onTap: () => _quickAsk('Tell me a funny animal fact! 🦁')),
              _TopicChip(
                  label: '🍎 Science',
                  color: Colors.pinkAccent,
                  onTap: () => _quickAsk('Tell me a magic science fact! 🧪')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isMe ? mainBlue : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(24).copyWith(
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(24),
            bottomLeft:
                isMe ? const Radius.circular(24) : const Radius.circular(4),
          ),
        ),
        child: Text(msg['text'],
            style: GoogleFonts.nunito(
                color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                fontWeight: FontWeight.w700,
                fontSize: 15)),
      ),
    );
  }

  Widget _buildInputBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 20)
          ]),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
              child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  onSubmitted: (_) => _handleSend(),
                  decoration: InputDecoration(
                      hintText: 'Ask Mindie anything...',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      border: InputBorder.none))),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(color: mainBlue, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
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

  List<Widget> _buildFloatingDeco(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return _decoItems
        .map((item) => AnimatedBuilder(
              animation: _floatController,
              builder: (context, _) {
                final yOff = math.sin(
                        _floatController.value * 2 * math.pi + item.phase) *
                    15;
                return Positioned(
                    left: item.x * sw,
                    top: item.y * sh + yOff,
                    child: Opacity(
                        opacity: 0.1,
                        child: Text(item.emoji,
                            style: TextStyle(fontSize: item.size))));
              },
            ))
        .toList();
  }

  Widget _buildTypingIndicator() => const Padding(
      padding: EdgeInsets.only(left: 30, bottom: 15),
      child: Text('🦄 Mindie is thinking...',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
}

class _MindieAvatar extends StatelessWidget {
  final Color color;
  const _MindieAvatar(this.color);
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.1), width: 8),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 30)
          ]),
      child: const Center(child: Text('🦄', style: TextStyle(fontSize: 70))),
    );
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
    return ActionChip(
        onPressed: onTap,
        label: Text(label,
            style:
                GoogleFonts.nunito(fontWeight: FontWeight.bold, color: color)),
        backgroundColor: color.withValues(alpha: 0.1),
        shape: StadiumBorder(side: BorderSide(color: color.withValues(alpha: 0.3))));
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
