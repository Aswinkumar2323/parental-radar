import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../apis/get.dart';

class WhatsAppSummaryCard extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const WhatsAppSummaryCard({
    super.key,
    required this.username,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<WhatsAppSummaryCard> createState() => _WhatsAppSummaryCardState();
}

class _WhatsAppSummaryCardState extends State<WhatsAppSummaryCard> {
  int incoming = 0;
  int outgoing = 0;
  bool loading = true;
  String topChatName = 'N/A';
  int topChatCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final decryptedData = await fetchModuleData(
      module: 'whatsapp',
      userId: widget.username,
    );

    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(decryptedData);
    final List allMessages = data.expand((e) => e['data']).toList();

    outgoing = allMessages.where((m) => m['sender'] == "Them").length;
    incoming = allMessages.where((m) => m['sender'] != "Them").length;

    final Map<String, List> groupedByChat = {};
    for (var msg in allMessages) {
      final chatName = msg['chat_name'] ?? msg['phone'] ?? 'Unknown';
      groupedByChat.putIfAbsent(chatName, () => []).add(msg);
    }

    if (groupedByChat.isNotEmpty) {
      final sorted = groupedByChat.entries.toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));
      topChatName = sorted.first.key;
      topChatCount = sorted.first.value.length;
    }

    setState(() => loading = false);
    widget.onModuleLoaded();
  }

  Widget _buildBasicCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$title\n$subtitle',
                style: const TextStyle(
                  fontFamily: 'NexaBold',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'WhatsApp Summary',
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBasicCard(
                    context: context,
                    title: 'Incoming Messages',
                    subtitle: '$incoming message${incoming == 1 ? '' : 's'}',
                    icon: Icons.call_received,
                    onTap: () => widget.onJumpToIndex(6),
                  ),
                  const SizedBox(height: 8),
                  _buildBasicCard(
                    context: context,
                    title: 'Outgoing Messages',
                    subtitle: '$outgoing message${outgoing == 1 ? '' : 's'}',
                    icon: Icons.call_made,
                    onTap: () => widget.onJumpToIndex(6),
                  ),
                  const SizedBox(height: 8),
                  _buildBasicCard(
                    context: context,
                    title: 'Top Chat',
                    subtitle: '$topChatName: $topChatCount msg${topChatCount == 1 ? '' : 's'}',
                    icon: Icons.person,
                    onTap: () => widget.onJumpToIndex(6),
                  ),
                ],
              ),
      ),
    );
  }
}
