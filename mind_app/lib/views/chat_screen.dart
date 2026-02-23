import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // TODO: Replace with your actual Gemini API Key from Google AI Studio
  final String _apiKey = "YOUR_GEMINI_API_KEY_HERE";

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    // Initialize Gemini AI model with system instructions
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
          "You are a kind and helpful teacher for kids on the Little Minds app. Answer their study questions simply."),
    );
    // Start a new chat session
    _chatSession = _model.startChat();
  }

  // Auto-scroll to the latest message
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

  // Handle sending user messages and getting AI response
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
      // Send user message to Gemini API
      final response = await _chatSession.sendMessage(Content.text(userText));

      setState(() {
        _messages.add({
          "text": response.text ?? "Sorry, I didn't understand that.",
          "isMe": false
        });
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors like no internet or invalid API key
      setState(() {
        _messages.add({
          "text": "Error: Please check your API key or internet connection.",
          "isMe": false
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFAB47BC); // Purple theme color

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Teacher Chat Bot",
            style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildChatBubble(_messages[index]),
            ),
          ),
          // Loading indicator while AI is thinking
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child:
                  Center(child: CircularProgressIndicator(color: primaryColor)),
            ),
          // Input area for typing messages
          _buildInputArea(primaryColor),
        ],
      ),
    );
  }

  // UI for individual chat bubbles
  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFAB47BC) : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(
          msg['text'],
          style: GoogleFonts.inter(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // UI for the bottom message input field
  Widget _buildInputArea(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a study question...",
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _handleSend,
              child: CircleAvatar(
                backgroundColor: primary,
                radius: 24,
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
