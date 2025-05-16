import 'package:flutter/material.dart';
import '../../apis/get.dart';
import 'ChatDetailScreen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';

class WhatsAppScreen extends StatefulWidget {
  final String username;

  const WhatsAppScreen({super.key, required this.username});

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen> {
  String? expandedChatName;
  String selectedFilter = "All";

  void refresh() => setState(() {});

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

            // Analytics calculation
            final today = DateTime.now();
            final todayMessages = allMessages.where((msg) {
              final msgTime = DateTime.parse(msg['timestamp']);
              return msgTime.year == today.year &&
                  msgTime.month == today.month &&
                  msgTime.day == today.day;
            }).toList();

            final incoming = todayMessages.where((msg) => msg['isIncoming']).length;
            final outgoing = todayMessages.where((msg) => !msg['isIncoming']).length;

            final contactCount = <String, int>{};
            for (var msg in todayMessages) {
              contactCount[msg['chat_name']] =
                  (contactCount[msg['chat_name']] ?? 0) + 1;
            }
            final frequentContact = contactCount.entries.sorted((a, b) => b.value.compareTo(a.value)).firstOrNull;

            final responseTimes = <Duration>[];
            for (int i = 1; i < todayMessages.length; i++) {
              if (todayMessages[i]['isIncoming'] != todayMessages[i - 1]['isIncoming']) {
                final prev = DateTime.parse(todayMessages[i - 1]['timestamp']);
                final current = DateTime.parse(todayMessages[i]['timestamp']);
                responseTimes.add(current.difference(prev));
              }
            }
            final averageResponse = responseTimes.isNotEmpty
                ? responseTimes.map((e) => e.inSeconds).reduce((a, b) => a + b) ~/ responseTimes.length
                : 0;

            final wordCount = <String, int>{};
            final flaggedWords = ['bomb', 'drugs', 'attack'];
            final flaggedCount = <String, int>{};

            for (var msg in todayMessages) {
              final words = msg['message'].toString().split(RegExp(r'\s+'));
              for (var word in words) {
                word = word.toLowerCase();
                wordCount[word] = (wordCount[word] ?? 0) + 1;
                if (flaggedWords.contains(word)) {
                  flaggedCount[word] = (flaggedCount[word] ?? 0) + 1;
                }
              }
            }

            final topWords = wordCount.entries
                .sorted((a, b) => b.value.compareTo(a.value))
                .take(5)
                .toList();

            final groupedByChat = <String, List>{};
            for (var msg in allMessages) {
              final chatName = msg['chat_name'];
              groupedByChat.putIfAbsent(chatName, () => []).add(msg);
            }

            final chats = groupedByChat.entries.toList();

            return ListView(
              padding: const EdgeInsets.only(top: 100, bottom: 16, left: 12, right: 12),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard("Incoming Messages", incoming.toString(), isDark, incoming >= outgoing),
                    _buildStatCard("Outgoing Messages", outgoing.toString(), isDark, outgoing >= incoming),
                    _buildStatCard("Frequent Contact", frequentContact?.key ?? '-', isDark, true, subtitle: frequentContact?.value.toString()),
                    _buildStatCard("Avg Response Time", "$averageResponse sec", isDark, true),
                    _buildStatCard("Top Words", topWords.map((e) => e.key).join(", "), isDark, true),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFlaggedWordsList(flaggedCount, isDark),
                const SizedBox(height: 16),
                _buildFilterBar(isDark),
                const SizedBox(height: 12),
                _buildChatListView(chats, isDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, bool isDark, bool isPositive, {String? subtitle}) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          if (subtitle != null)
            Text(subtitle, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildFlaggedWordsList(Map<String, int> flagged, bool isDark) {
    if (flagged.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: flagged.entries
            .map((entry) => Text(
                  '${entry.key} - ${entry.value} times',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    final filters = ['All', 'Today', 'Favorites', 'Individuals', 'Groups'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(f),
                  selected: selectedFilter == f,
                  onSelected: (_) => setState(() => selectedFilter = f),
                  selectedColor: Colors.blueAccent,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildChatListView(List<MapEntry<String, List>> chats, bool isDark) {
    return Column(
      children: chats.map((entry) {
        final lastMsg = entry.value.last;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
          ),
          child: ListTile(
            title: Text(entry.key, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text(
              lastMsg['message'] ?? '',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              lastMsg['timestamp'] != null
                  ? DateTime.parse(lastMsg['timestamp']).toLocal().toString().split('.')[0]
                  : '',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black38, fontSize: 10),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(
                    chatName: entry.key,
                    messages: entry.value,
                  ),
                ),
              );
            },
          ),
        ).animate().slideX(begin: 0.1).fadeIn(duration: 300.ms);
      }).toList(),
    );
  }
}
