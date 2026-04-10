import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hi! I'm CinemaBot. How can I assist you?"}
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userText});
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      String response = _getBotResponse(userText.toLowerCase());
      setState(() {
        _messages.add({"role": "bot", "text": response});
      });
      _scrollToBottom();
    });
  }

  String _getBotResponse(String query) {
    // FIXED: Added braces to all if statements
    if (query.contains("hi") || query.contains("hello")) {
      return "Hello! Hope you're having a great day at CinemaBook!";
    }
    if (query.contains("location")) {
      return "If your location isn't showing, try clicking the refresh icon in the yellow bar.";
    }
    if (query.contains("price") || query.contains("ticket")) {
      return "Ticket prices range from ₹280 to ₹350.";
    }
    if (query.contains("payment")) {
      return "We support all major digital payments at checkout.";
    }
    return "I'm still learning! Contact us at support@cinemabook.com for more help.";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cinema Support"),
        backgroundColor: const Color(0xFFFF5252),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isBot = _messages[index]["role"] == "bot";
                return Align(
                  alignment:
                      isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey[200] : const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index]["text"]!,
                      style: TextStyle(
                          color: isBot ? Colors.black87 : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF5252)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
