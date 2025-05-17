import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../apis/get.dart';
import 'package:collection/collection.dart';
import '../../decryption/parent_decryption.dart';
import '../../widgets/breathing_loader.dart';

class CallScreen extends StatefulWidget {
  final String username;
  const CallScreen({super.key, required this.username});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late Future<List<dynamic>> callLogsFuture;
  List<dynamic> _allCalls = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    callLogsFuture = _fetchCallLogs();
  }

  Future<List<dynamic>> _fetchCallLogs() async {
    final apidata = await fetchModuleData(
      module: 'call',
      userId: widget.username,
    );
    final data = await ParentDecryption.decrypt(apidata, widget.username);
    _allCalls = data?['data']?['call_data'] ?? [];
    return _allCalls;
  }

  void refresh() {
    setState(() {
      callLogsFuture = _fetchCallLogs();
      _selectedFilter = 'all';
    });
  }

  IconData _getCallIcon(String type) {
    switch (type) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'missed':
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }

  Color _getCallColor(String type) {
    switch (type) {
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
      return dateString;
    }
  }

  void _filterCalls(String type) {
    setState(() {
      _selectedFilter = type;
    });
  }

  List<dynamic> _getFilteredCalls() {
    if (_selectedFilter == 'all') return _allCalls;
    return _allCalls.where((c) => c['callType'] == _selectedFilter).toList();
  }

  Widget _buildCard({required Widget child, required bool isDark}) {
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                    : [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
          ),
          child: const Text(
            'Call Monitoring',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NexaBold',
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: refresh),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark
                  ? const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Colors.black, Colors.black, Colors.black],
                  )
                  : const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xFF0090FF),
                      Color(0xFF15D6A6),
                      Color(0xFF123A5B),
                    ],
                  ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: callLogsFuture,
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

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text(
                  'Failed to load call logs.',
                  style: TextStyle(color: Colors.white, fontFamily: 'NexaBold'),
                ),
              );
            }

            final calls = _getFilteredCalls();
            final today = DateTime.now();

            final todayCalls =
                _allCalls.where((c) {
                  final date =
                      DateTime.tryParse(c['date'] ?? '') ?? DateTime(2000);
                  return date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                }).toList();

            final incomingToday =
                todayCalls.where((c) => c['callType'] == 'incoming').toList();
            final outgoingToday =
                todayCalls.where((c) => c['callType'] == 'outgoing').toList();

            final avgIncoming =
                incomingToday.isNotEmpty
                    ? incomingToday
                            .map((c) => c['duration'])
                            .reduce((a, b) => a + b) ~/
                        incomingToday.length
                    : 0;

            final avgOutgoing =
                outgoingToday.isNotEmpty
                    ? outgoingToday
                            .map((c) => c['duration'])
                            .reduce((a, b) => a + b) ~/
                        outgoingToday.length
                    : 0;

            final longest =
                _allCalls.isNotEmpty
                    ? _allCalls.reduce(
                      (a, b) =>
                          (a['duration'] ?? 0) > (b['duration'] ?? 0) ? a : b,
                    )
                    : null;

            final frequency = <String, int>{};
            for (var log in _allCalls) {
              final name = log['name'] ?? log['number'] ?? 'Unknown';
              frequency[name] = (frequency[name] ?? 0) + 1;
            }
            final mostFrequent =
                (frequency.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value)))
                    .firstOrNull
                    ?.key ??
                'Unknown';

            return ListView(
              padding: const EdgeInsets.only(top: 80, bottom: 16),
              children: [
                _buildCard(
                  isDark: isDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Incoming Calls",
                        style: TextStyle(fontSize: 16, fontFamily: 'NexaBold'),
                      ),
                      Text(
                        '${incomingToday.length} Calls',
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCard(
                  isDark: isDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Outgoing Calls",
                        style: TextStyle(fontSize: 16, fontFamily: 'NexaBold'),
                      ),
                      Text(
                        '${outgoingToday.length} Calls',
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCard(
                  isDark: isDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Avg Incoming Duration",
                        style: TextStyle(fontSize: 16, fontFamily: 'NexaBold'),
                      ),
                      Text(
                        _formatDuration(avgIncoming),
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCard(
                  isDark: isDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Avg Outgoing Duration",
                        style: TextStyle(fontSize: 16, fontFamily: 'NexaBold'),
                      ),
                      Text(
                        _formatDuration(avgOutgoing),
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                if (longest != null)
                  _buildCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Longest Call",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NexaBold',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "With: ${longest['name'] ?? longest['number'] ?? 'Unknown'}",
                          style: TextStyle(
                            fontFamily: 'NexaBold',
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "Duration: ${_formatDuration(longest['duration'])}",
                          style: TextStyle(
                            fontFamily: 'NexaBold',
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildCard(
                  isDark: isDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Most Frequent Contact",
                        style: TextStyle(fontSize: 16, fontFamily: 'NexaBold'),
                      ),
                      Text(
                        mostFrequent,
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCategoryBar(isDark),
                const Divider(color: Colors.white70),
                ...calls.map((call) => _buildCallTile(call, isDark)).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryBar(bool isDark) {
    final filters = ['all', 'incoming', 'outgoing', 'missed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        children:
            filters.map((type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'NexaBold',
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: type == _selectedFilter,
                  onSelected: (_) => _filterCalls(type),
                  selectedColor: isDark ? Colors.white24 : Colors.white,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.white70,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCallTile(Map call, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark ? Colors.white10 : Colors.blue.shade100,
          child: Icon(
            _getCallIcon(call['callType']),
            color: _getCallColor(call['callType'] ?? ''),
          ),
        ),
        title: Text(
          call['name'] ?? call['number'] ?? 'Unknown',
          style: TextStyle(
            fontFamily: 'NexaBold',
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          'Duration: ${_formatDuration(call['duration'] ?? 0)}',
          style: TextStyle(
            fontFamily: 'NexaBold',
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        trailing: Text(
          _formatDate(call['date'] ?? ''),
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'NexaBold',
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}