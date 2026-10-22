import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/chat_controller.dart';
import '../../state/plan_controller.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend(ChatController chatCtrl, PlanController planCtrl) {
    final text = _textController.text.trim();
    if (text.isEmpty || planCtrl.context == null) return;

    _textController.clear();
    chatCtrl.sendMessage(planCtrl.context!, text);
  }

  @override
  Widget build(BuildContext context) {
    final planCtrl = Provider.of<PlanController>(context, listen: false);

    return Consumer<ChatController>(
      builder: (ctx, chatCtrl, _) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: chatCtrl.messages.length,
                itemBuilder: (ctx, index) {
                  final msg = chatCtrl.messages[index];
                  final isUser = msg.sender == 'user';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      maxConstraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.indigo : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12).copyWith(
                          bottomRight: isUser ? const Radius.circular(0) : null,
                          bottomLeft: !isUser ? const Radius.circular(0) : null,
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (chatCtrl.isSending)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Planner thinking...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Ask planner e.g. "How to save on catering?"',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(chatCtrl, planCtrl),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.indigo),
                    onPressed: () => _handleSend(chatCtrl, planCtrl),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
