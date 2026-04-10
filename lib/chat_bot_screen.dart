import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:helloworld/app_theme.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'text': 'Hi! I\'m CinemaBot 🤖\nHow can I help you today?'},
  ];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isTyping = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({'role': 'bot', 'text': _getResponse(text.toLowerCase())});
      });
      _scrollToBottom();
    });
  }

  String _getResponse(String q) {
    if (q.contains('hi') || q.contains('hello') || q.contains('hey')) {
      return 'Hello! 👋 Hope you\'re excited for a great movie experience at CinemaBook!';
    }
    if (q.contains('price') || q.contains('ticket') || q.contains('cost')) {
      return '🎟 Ticket prices range from ₹280 to ₹350 depending on the movie and seat type.';
    }
    if (q.contains('location') || q.contains('where')) {
      return '📍 Your location is detected automatically. Make sure location permission is enabled in your phone settings.';
    }
    if (q.contains('payment') || q.contains('pay') || q.contains('upi')) {
      return '💳 We support UPI payments. Scan the QR code shown on the payment screen with any UPI app.';
    }
    if (q.contains('cancel') || q.contains('refund')) {
      return '🔄 Cancellations are not supported in the app yet. Please contact us at support@cinemabook.com.';
    }
    if (q.contains('ar') || q.contains('augmented')) {
      return '🥽 The AR Cinema View in seat selection lets you see a 3D perspective of the cinema hall! Tap "AR View" in the seat screen.';
    }
    if (q.contains('show') || q.contains('time') || q.contains('schedule')) {
      return '⏰ Shows are available at 10 AM, 1 PM, 4 PM, 7 PM & 10 PM daily across all listed movies.';
    }
    if (q.contains('book') || q.contains('how')) {
      return '📖 To book:\n1. Pick a movie from the Home screen\n2. Select your seats\n3. Pay via UPI\n4. Done! Your ticket is confirmed. 🎉';
    }
    return '🤔 I\'m still learning! For more help, reach us at support@cinemabook.com. I can help with: ticket prices, payment, show times, and more.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowShadow,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CinemaBot', style: AppTheme.label(15)),
                Text('AI Cinema Assistant',
                    style: AppTheme.body(11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Messages list ──────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return _TypingBubble();
                }
                final msg = _messages[i];
                final isBot = msg['role'] == 'bot';
                return _MessageBubble(
                  text: msg['text']!,
                  isBot: isBot,
                  index: i,
                );
              },
            ),
          ),

          // ── Quick replies ───────────────────────────────────────────────
          _buildQuickReplies(),

          // ── Input bar ──────────────────────────────────────────────────
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final suggestions = ['Prices', 'Show times', 'How to book', 'AR View'];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: suggestions.map((s) {
          return GestureDetector(
            onTap: () {
              _ctrl.text = s;
              _send();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Center(
                child: Text(s, style: AppTheme.body(12, color: AppTheme.textPrimary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: AppTheme.label(14),
                    decoration: InputDecoration(
                      hintText: 'Ask CinemaBot anything…',
                      hintStyle: AppTheme.body(14),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final int index;
  const _MessageBubble(
      {required this.text, required this.isBot, required this.index});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isBot) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 8, bottom: 2),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 14),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isBot
                      ? null
                      : AppTheme.primaryGradient,
                  color: isBot ? AppTheme.card : null,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isBot
                        ? const Radius.circular(4)
                        : const Radius.circular(18),
                    bottomRight: isBot
                        ? const Radius.circular(18)
                        : const Radius.circular(4),
                  ),
                  border: isBot
                      ? Border.all(color: AppTheme.divider)
                      : null,
                  boxShadow: isBot
                      ? AppTheme.cardShadow
                      : AppTheme.glowShadow,
                ),
                child: Text(
                  text,
                  style: AppTheme.body(14,
                      color: isBot
                          ? AppTheme.textPrimary
                          : Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }
}

// ── Typing indicator ───────────────────────────────────────────────────────────
class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                    begin: 0,
                    end: -6,
                    delay: (i * 150).ms,
                    duration: 400.ms,
                    curve: Curves.easeOut)
                .then()
                .moveY(
                    begin: -6,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeIn),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
