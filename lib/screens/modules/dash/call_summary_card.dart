import 'package:flutter/material.dart';
import '../../../apis/get.dart';
import '../../../decryption/parent_decryption.dart';

class CallSummaryCard extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const CallSummaryCard({
    super.key,
    required this.username,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<CallSummaryCard> createState() => _CallSummaryCardState();
}

class _CallSummaryCardState extends State<CallSummaryCard> {
  List<dynamic> _callList = [];

  @override
  void initState() {
    super.initState();
    _loadCallLogs();
  }

  Future<void> _loadCallLogs() async {
    try {
      final apidata = await fetchModuleData(
        module: 'call',
        userId: widget.username,
      );
      final data = await ParentDecryption.decrypt(apidata, widget.username);
      final calls = data?['data']?['call_data'] ?? [];
      setState(() {
        _callList = calls;
      });
      widget.onModuleLoaded();
    } catch (e) {
      print("Error fetching call logs: $e");
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final todayCalls =
        _callList.where((call) {
          final timestamp =
              DateTime.tryParse(call['date'] ?? '') ?? DateTime(2000);
          return timestamp.year == today.year &&
              timestamp.month == today.month &&
              timestamp.day == today.day;
        }).toList();

    final incoming =
        todayCalls.where((c) => c['callType'] == 'incoming').length;
    final outgoing =
        todayCalls.where((c) => c['callType'] == 'outgoing').length;

    final longestCall = _callList.fold<Map<String, dynamic>?>(null, (
      prev,
      curr,
    ) {
      return prev == null || (curr['duration'] ?? 0) > (prev['duration'] ?? 0)
          ? curr
          : prev;
    });

    final name = longestCall?['name'] ?? longestCall?['number'] ?? 'Unknown';
    final number = longestCall?['number'] ?? '-';
    final duration = longestCall?['duration']?.toString() ?? '0';
    final start = longestCall?['date'] ?? '-';

    // Responsive subtitle with wrapping
    final longestCallInfo = '$name | $number\n⏱ $duration sec | ⏰ $start';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.call, color: Colors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Call Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBasicCard(
              context: context,
              title: 'Incoming Calls Today',
              subtitle: '$incoming call${incoming == 1 ? '' : 's'}',
              icon: Icons.call_received,
              onTap: () => widget.onJumpToIndex(4),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              context: context,
              title: 'Outgoing Calls Today',
              subtitle: '$outgoing call${outgoing == 1 ? '' : 's'}',
              icon: Icons.call_made,
              onTap: () => widget.onJumpToIndex(4),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              context: context,
              title: 'Longest Call',
              subtitle: longestCallInfo,
              icon: Icons.access_time,
              onTap: () => widget.onJumpToIndex(4),
            ),
          ],
        ),
      ),
    );
  }
}