import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Map<String, dynamic> _statistics = {
    'todayIncoming': 0,
    'todayOutgoing': 0,
    'longestCall': null,
  };

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

      _calculateStatistics();
      widget.onModuleLoaded();
    } catch (e) {
      print("Error fetching call logs: $e");
    }
  }

  void _calculateStatistics() {
    _statistics = {'todayIncoming': 0, 'todayOutgoing': 0, 'longestCall': null};

    if (_callList.isEmpty) return;

    final today = DateTime.now();
    List<dynamic> todayIncomingCalls = [];
    List<dynamic> todayOutgoingCalls = [];

    for (var call in _callList) {
      final duration = call['duration'] as int? ?? 0;

      if (_statistics['longestCall'] == null ||
          duration > (_statistics['longestCall']?['duration'] as int? ?? 0)) {
        _statistics['longestCall'] = call;
      }

      final callDateStr = call['date']?.toString() ?? '';
      if (callDateStr.isEmpty) continue;

      DateTime? callDate;
      try {
        callDate = DateTime.tryParse(callDateStr);
        if (callDate == null) {
          callDate = DateFormat("yyyy-MM-dd HH:mm:ss").tryParse(callDateStr);
        }
        if (callDate == null) {
          callDate = DateFormat("dd/MM/yyyy").tryParse(callDateStr);
        }

        if (callDate != null &&
            callDate.year == today.year &&
            callDate.month == today.month &&
            callDate.day == today.day) {
          if (call['callType'] == 'incoming') {
            todayIncomingCalls.add(call);
          } else if (call['callType'] == 'outgoing') {
            todayOutgoingCalls.add(call);
          }
        }
      } catch (e) {
        print("Error parsing date: $e for $callDateStr");
        continue;
      }
    }

    setState(() {
      _statistics['todayIncoming'] = todayIncomingCalls.length;
      _statistics['todayOutgoing'] = todayOutgoingCalls.length;
    });
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
                      fontFamily: 'NexaBold',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'NexaBold',
                    ),
                    maxLines: null,
                    softWrap: true,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes}m ${remaining}s';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      try {
        final date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
        return DateFormat('dd MMM yyyy, hh:mm a').format(date);
      } catch (_) {
        return dateString;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final incoming = _statistics['todayIncoming'];
    final outgoing = _statistics['todayOutgoing'];
    final longestCall = _statistics['longestCall'];

    String longestCallInfo = 'No calls recorded';

    if (longestCall != null) {
      final name = longestCall['name'] ?? longestCall['number'] ?? 'Unknown';
      final number = longestCall['number'] ?? '-';
      final duration = _formatDuration(longestCall['duration'] ?? 0);
      final date = _formatDate(longestCall['date'] ?? '-');
      longestCallInfo = '$name | $number\n⏱ $duration\n📅 $date';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          // <-- Add this
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Good practice
            children: [
              Row(
                children: const [
                  Icon(Icons.call, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Call Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NexaBold',
                        overflow: TextOverflow.ellipsis,
                      ),
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
              const SizedBox(height: 10),
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
      ),
    );
  }
}