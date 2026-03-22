import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/chat_message.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/session_service.dart';
import 'package:mobile/theme/virtum_theme.dart';
import 'package:mobile/widgets/brand_assets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "👋 Hello! I'm Jeffrey — your personal health assistant.\n\n"
          'I can help you with:\n'
          '• Analyzing your health data\n'
          '• Providing activity recommendations\n'
          '• Explaining metrics (heart rate, blood pressure, steps)\n'
          '• Offering healthy lifestyle advice\n\n'
          'Ask me about your steps, heart rate, blood pressure, or request recommendations!',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > 8000 || _sending) return;

    final user = await SessionService.getUser();
    final token = await SessionService.getToken();
    if (user == null) return;

    setState(() {
      _sending = true;
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _controller.clear();
    });
    _scrollToEnd();

    try {
      final reply = await ApiService.sendChat(userId: user.id, message: text, token: token);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e is SocketException ? 'Network error.' : 'Sorry, I could not respond right now.';
      setState(() {
        _messages.add(ChatMessage(text: msg, isUser: false, timestamp: DateTime.now()));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: VirtumColors.surface2,
                      foregroundColor: VirtumColors.textPrimary,
                    ),
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const JeffreyBotAvatar(size: 32),
                            const SizedBox(width: 8),
                            Text(
                              'Jeffrey',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Text(
                          'Ask anything about your health data',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: VirtumColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final align = m.isUser ? Alignment.centerRight : Alignment.centerLeft;
                  final bg = m.isUser ? VirtumColors.surface2 : VirtumColors.accent.withValues(alpha: 0.12);
                  final bubble = Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VirtumColors.lineSoft),
                    ),
                    child: Text(m.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35)),
                  );
                  return Align(
                    alignment: align,
                    child: m.isUser
                        ? bubble
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6, right: 6),
                                child: JeffreyBotAvatar(size: 28),
                              ),
                              Flexible(child: bubble),
                            ],
                          ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 8000,
                      decoration: const InputDecoration(
                        hintText: 'Message Jeffrey…',
                        counterText: '',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
