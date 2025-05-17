import 'package:flutter/material.dart';
import '../dashboard.dart'; // Import to access _DashboardPageState
import '../../../apis/get.dart'; // <-- Make sure you have the correct path

class KeyloggerSummaryCard extends StatefulWidget {
  final String userId;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const KeyloggerSummaryCard({
    super.key,
    required this.userId,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<KeyloggerSummaryCard> createState() => _KeyloggerSummaryCardState();
}

class _KeyloggerSummaryCardState extends State<KeyloggerSummaryCard> {
  int keystrokesToday = 0;
  String topApp = 'N/A';
  int topAppCount = 0;

  @override
  void initState() {
    super.initState();
    _loadKeyloggerSummary();
  }

  Future<void> _loadKeyloggerSummary() async {
    final rawData = await fetchModuleData(
      module: 'keylogger',
      userId: widget.userId,
    );

    if (rawData == null || rawData is! List) return;

    final allLogs =
        rawData.expand<Map<String, dynamic>>((entry) {
          return (entry['data'] as List).map((e) {
            return {
              'app': e['app'],
              'messages': e['messages'],
              'fetchedTime': e['fetched time'],
            };
          });
        }).toList();

    final today = DateTime.now();

    final todayLogs =
        allLogs.where((log) {
          final fetchedTime = DateTime.tryParse(log['fetchedTime'] ?? '');
          return fetchedTime != null &&
              fetchedTime.year == today.year &&
              fetchedTime.month == today.month &&
              fetchedTime.day == today.day;
        }).toList();

    final appUsage = <String, int>{};
    int totalKeys = 0;

    for (var log in todayLogs) {
      final app = log['app'] ?? 'Unknown';
      final messages = List<String>.from(log['messages']);
      appUsage[app] = (appUsage[app] ?? 0) + messages.length;
      totalKeys += messages.length;
    }

    final topAppEntry =
        appUsage.entries.isNotEmpty
            ? (appUsage.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
            : const MapEntry('N/A', 0);

    setState(() {
      keystrokesToday = totalKeys;
      topApp = topAppEntry.key;
      topAppCount = topAppEntry.value;
    });
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
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$title\n$subtitle',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.keyboard_alt, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Keylogger Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _buildBasicCard(
              context: context,
              title: 'Keystrokes Today',
              subtitle:
                  '$keystrokesToday keystroke${keystrokesToday == 1 ? '' : 's'}',
              icon: Icons.keyboard,
              onTap: () => widget.onJumpToIndex(5),
            ),
            const SizedBox(height: 25),
            _buildBasicCard(
              context: context,
              title: 'Top App Today',
              subtitle:
                  '$topApp: $topAppCount keystroke${topAppCount == 1 ? '' : 's'}',
              icon: Icons.apps,
              onTap: () => widget.onJumpToIndex(5),
            ),
          ],
        ),
      ),
    );
  }
}