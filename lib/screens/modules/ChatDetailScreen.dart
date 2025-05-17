import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatDetailScreen extends StatelessWidget {
  final String chatName;
  final List messages;

  const ChatDetailScreen({
    Key? key,
    required this.chatName,
    required this.messages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chatName,
          style: const TextStyle(
            fontFamily: 'NexaBold',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: isDark ? Colors.black : const Color(0xFFE2E2E2),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, kToolbarHeight + 16, 12, 20),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isYou = msg['sender'] == "You";

            return Align(
              alignment: isYou ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isYou
                      ? (isDark ? Colors.blueGrey.shade800 : Colors.blue.shade100)
                      : (isDark ? Colors.grey.shade800 : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isYou ? 12 : 0),
                    bottomRight: Radius.circular(isYou ? 0 : 12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      isYou ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg['message'],
                      style: TextStyle(
                        fontFamily: 'NexaBold',
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${msg['sender']} • ${msg['time']}",
                      style: TextStyle(
                        fontFamily: 'NexaBold',
                        fontSize: 11,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fade()
                .slideX(
                  begin: isYou ? 0.3 : -0.3,
                  duration: 400.ms,
                  delay: (index * 40).ms,
                );
          },
        ),
      ),
    );
  }
}
