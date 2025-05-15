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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Colors.black, Colors.black, Colors.black],
                )
              : const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xFF0090FF), // Primary
                    Color(0xFF15D6A6), // Secondary
                    Color(0xFF123A5B), // Tertiary
                  ],
                ),
        ),
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
                  gradient: LinearGradient(
                    colors: isYou
                        ? (isDark
                            ? [Colors.blueGrey.shade800, Colors.blueGrey.shade600]
                            : [Colors.blue.shade100, Colors.blue.shade300])
                        : (isDark
                            ? [Colors.grey.shade800, Colors.grey.shade700]
                            : [Colors.white.withOpacity(0.85), Colors.grey.shade200]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${msg['sender']} • ${msg['time']}",
                      style: textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 11,
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
