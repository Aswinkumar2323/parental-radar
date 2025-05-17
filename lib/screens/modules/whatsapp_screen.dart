import 'package:flutter/material.dart';
import '../../apis/get.dart';
import 'ChatDetailScreen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/breathing_loader.dart';

class WhatsAppScreen extends StatefulWidget {
  final String username;

  const WhatsAppScreen({super.key, required this.username});

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen> {
  String? expandedChatName;
  int incomingToday = 0;
  int outgoingToday = 0;
  int previousIncoming = 0;
  int previousOutgoing = 0;
  String highestChatName = '';
  List highestChatMessages = [];

  void refresh() {
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _loadDecryptedWhatsAppData() async {
    final decryptedData = await fetchModuleData(
      module: 'whatsapp',
      userId: widget.username,
    );

    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      decryptedData,
    );

    final List allMessages = data.expand((e) => e['data']).toList();

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    incomingToday =
        allMessages
            .where(
              (m) =>
                  m['type'] == 'received' &&
                  DateTime.parse(m['timestamp']).isAfter(today),
            )
            .length;

    outgoingToday =
        allMessages
            .where(
              (m) =>
                  m['type'] == 'sent' &&
                  DateTime.parse(m['timestamp']).isAfter(today),
            )
            .length;

    previousIncoming =
        allMessages
            .where(
              (m) =>
                  m['type'] == 'received' &&
                  DateTime.parse(m['timestamp']).isAfter(yesterday) &&
                  DateTime.parse(m['timestamp']).isBefore(today),
            )
            .length;

    previousOutgoing =
        allMessages
            .where(
              (m) =>
                  m['type'] == 'sent' &&
                  DateTime.parse(m['timestamp']).isAfter(yesterday) &&
                  DateTime.parse(m['timestamp']).isBefore(today),
            )
            .length;

    final Map<String, List> groupedByChat = {};
    for (var msg in allMessages) {
      final chatName = msg['chat_name'];
      groupedByChat.putIfAbsent(chatName, () => []).add(msg);
    }

    if (groupedByChat.isNotEmpty) {
      final sortedChats =
          groupedByChat.entries.toList()
            ..sort((a, b) => b.value.length.compareTo(a.value.length));
      highestChatName = sortedChats.first.key;
      highestChatMessages = sortedChats.first.value;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                isDark
                    ? null
                    : [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(
            'Whatsapp Monitoring',
            style: TextStyle(
              fontFamily: 'NexaBold',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
            color: Colors.white,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration:
            isDark
                ? const BoxDecoration(color: Color.fromARGB(255, 0, 0, 0))
                : const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0.0, 0.5, 1.0],
                    colors: [
                      Color(0xFF0090FF),
                      Color(0xFF15D6A6),
                      Color(0xFF123A5B),
                    ],
                  ),
                ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadDecryptedWhatsAppData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
                ),
                child: const Center(child: BreathingLoader()),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  "No data found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final data = snapshot.data!;
            final allMessages = data.expand((e) => e['data']).toList();

            final Map<String, List> groupedByChat = {};
            for (var msg in allMessages) {
              final chatName = msg['chat_name'];
              groupedByChat.putIfAbsent(chatName, () => []).add(msg);
            }

            final groupChats =
                groupedByChat.entries
                    .where((entry) => entry.value.first['isGroup'] == true)
                    .toList();
            final individualChats =
                groupedByChat.entries
                    .where((entry) => entry.value.first['isGroup'] == false)
                    .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                12,
                kToolbarHeight + 12,
                12,
                16,
              ),
              children: [
                _buildStatCard(
                  "INCOMING MESSAGES",
                  incomingToday,
                  previousIncoming,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  "OUTGOING MESSAGES",
                  outgoingToday,
                  previousOutgoing,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildTopChatCard(isDark),
                const SizedBox(height: 16),
                _buildChatSection(
                  title: "Group Chats",
                  chats: groupChats,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildChatSection(
                  title: "Individual Chats",
                  chats: individualChats,
                  isDark: isDark,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int current, int previous, bool isDark) {
    bool increased = current >= previous;
    IconData icon = increased ? Icons.arrow_upward : Icons.arrow_downward;
    Color iconColor = increased ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'NexaBold',
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$current messages",
                style: TextStyle(
                  fontFamily: 'NexaBold',
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Icon(icon, color: iconColor),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTopChatCard(bool isDark) {
    if (highestChatName.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChatDetailScreen(
                  chatName: highestChatName,
                  messages: highestChatMessages,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Top Conversation: $highestChatName",
                style: TextStyle(
                  fontFamily: 'NexaBold',
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.chat_bubble_outline, color: Colors.blueAccent),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildChatSection({
    required String title,
    required List<MapEntry<String, List>> chats,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'NexaBold',
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...chats
              .map((entry) => _buildChatTile(entry.key, entry.value, isDark))
              .toList()
              .animate()
              .fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildChatTile(String chatName, List messages, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        title: Text(
          chatName,
          style: TextStyle(
            fontFamily: 'NexaBold',
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      ChatDetailScreen(chatName: chatName, messages: messages),
            ),
          );
        },
      ),
    ).animate().slideX(begin: 0.1).fadeIn(duration: 300.ms);
  }
}