import 'package:flutter/foundation.dart';
import '../models/event_context.dart';
import '../services/ai_service.dart';
import '../services/resilient_ai_service.dart';

class ChatMessage {
  final String sender; // 'user' or 'planner'
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

/// State controller for Q&A with event context injected.
class ChatController extends ChangeNotifier {
  final AiService _aiService;
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  ChatController({AiService? aiService})
      : _aiService = aiService ?? ResilientAiService() {
    _messages.add(ChatMessage(
      sender: 'planner',
      text:
          'Hello! I am your EventCraft AI planner. Ask me anything about your budget, seating layout, menu planning, or vendor negotiations!',
      timestamp: DateTime.now(),
    ));
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  Future<void> sendMessage(EventContext context, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _messages.add(ChatMessage(
      sender: 'user',
      text: trimmed,
      timestamp: DateTime.now(),
    ));
    _isSending = true;
    notifyListeners();

    try {
      final answer = await _aiService.askPlanner(context, trimmed);
      _messages.add(ChatMessage(
        sender: 'planner',
        text: answer,
        timestamp: DateTime.now(),
      ));
    } catch (_) {
      _messages.add(ChatMessage(
        sender: 'planner',
        text: 'Sorry, I had trouble answering that. Please try rephrasing!',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      sender: 'planner',
      text: 'Chat cleared. How can I assist with your event?',
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
