import 'package:flutter/material.dart';
import '../../apis/get.dart'; // Adjust path if needed
import 'ChatDetailScreen.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations
import '../../decryption/parent_decryption_array.dart';

class WhatsAppScreen extends StatefulWidget {
  final String username;

  const WhatsAppScreen({super.key, required this.username});

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen> {
  String? expandedChatName;

  void refresh() {
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _loadDecryptedWhatsAppData() async {
    final decryptedData = await fetchModuleData(
      module: 'whatsapp',
      userId: widget.username,
    );

    return List<Map<String, dynamic>>.from(decryptedData);
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
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            'Whatsapp Monitoring',
            style: TextStyle(
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
        decoration: isDark
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
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
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

            final List data = snapshot.data!;
            final allMessages = data.expand((e) => e['data']).toList();

            final Map<String, List> groupedByChat = {};
            for (var msg in allMessages) {
              final chatName = msg['chat_name'];
              groupedByChat.putIfAbsent(chatName, () => []).add(msg);
            }

            final groupChats = groupedByChat.entries
                .where((entry) => entry.value.first['isGroup'] == true)
                .toList();
            final individualChats = groupedByChat.entries
                .where((entry) => entry.value.first['isGroup'] == false)
                .toList();

            return ListView(
              padding: const EdgeInsets.only(top: 90, bottom: 16, left: 12, right: 12),
              children: [
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
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...chats
              .map(
                (entry) => _buildChatTile(entry.key, entry.value, isDark),
              )
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
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        title: Text(
          chatName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
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
              builder: (_) => ChatDetailScreen(
                chatName: chatName,
                messages: messages,
              ),
            ),
          );
        },
      ),
    ).animate().slideX(begin: 0.1).fadeIn(duration: 300.ms);
  }
}
