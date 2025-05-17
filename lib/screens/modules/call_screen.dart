import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../apis/get.dart';
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
  Map<String, dynamic> _statistics = {
    'todayIncoming': 0,
    'todayOutgoing': 0,
    'avgIncomingDuration': 0,
    'avgOutgoingDuration': 0,
    'longestCall': null,
    'mostFrequentContact': 'None',
  };

  @override
  void initState() {
    super.initState();
    callLogsFuture = _fetchCallLogs();
  }

  Future<List<dynamic>> _fetchCallLogs() async {
    try {
      final apidata = await fetchModuleData(
        module: 'call',
        userId: widget.username,
      );

      final data = await ParentDecryption.decrypt(apidata, widget.username);
      _allCalls = data?['data']?['call_data'] ?? [];

      // Calculate statistics after fetching data
      _calculateStatistics();

      return _allCalls;
    } catch (e) {
      print("Error fetching call logs: $e");
      return [];
    }
  }

  void _calculateStatistics() {
    // Reset statistics
    _statistics = {
      'todayIncoming': 0,
      'todayOutgoing': 0,
      'avgIncomingDuration': 0,
      'avgOutgoingDuration': 0,
      'longestCall': null,
      'mostFrequentContact': 'None',
    };

    if (_allCalls.isEmpty) return;

    // Get today's date
    final today = DateTime.now();
    final todayFormatted =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    List<dynamic> todayIncomingCalls = [];
    List<dynamic> todayOutgoingCalls = [];
    Map<String, int> contactFrequency = {};

    for (var call in _allCalls) {
      final duration = call['duration'] as int? ?? 0;

      // Process contact frequency
      final contactName = call['name'] ?? call['number'] ?? 'Unknown';
      contactFrequency[contactName] = (contactFrequency[contactName] ?? 0) + 1;

      // Check for longest call
      if (_statistics['longestCall'] == null ||
          duration > (_statistics['longestCall']['duration'] as int? ?? 0)) {
        _statistics['longestCall'] = call;
      }

      // Parse call date
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

    _statistics['todayIncoming'] = todayIncomingCalls.length;
    _statistics['todayOutgoing'] = todayOutgoingCalls.length;

    // Calculate average durations
    if (todayIncomingCalls.isNotEmpty) {
      int totalDuration = 0;
      for (var call in todayIncomingCalls) {
        totalDuration += (call['duration'] as int? ?? 0);
      }
      _statistics['avgIncomingDuration'] =
          totalDuration ~/ todayIncomingCalls.length;
    }

    if (todayOutgoingCalls.isNotEmpty) {
      int totalDuration = 0;
      for (var call in todayOutgoingCalls) {
        totalDuration += (call['duration'] as int? ?? 0);
      }
      _statistics['avgOutgoingDuration'] =
          totalDuration ~/ todayOutgoingCalls.length;
    }

    // Find most frequent contact
    String mostFrequent = 'None';
    int maxFreq = 0;
    contactFrequency.forEach((contact, count) {
      if (count > maxFreq) {
        maxFreq = count;
        mostFrequent = contact;
      }
    });
    _statistics['mostFrequentContact'] = mostFrequent;
  }

  void refresh() {
    setState(() {
      callLogsFuture = _fetchCallLogs();
      _selectedFilter = 'all';
    });
  }

  IconData _getCallIcon(String? type) {
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

  Color _getCallColor(String? type) {
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
      try {
        final date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
        return DateFormat('dd MMM yyyy, hh:mm a').format(date);
      } catch (_) {
        return dateString;
      }
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
            'Call Log Sensing',
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

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load call logs: ${snapshot.error}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'NexaBold',
                  ),
                ),
              );
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No call logs available.',
                  style: TextStyle(color: Colors.white, fontFamily: 'NexaBold'),
                ),
              );
            }

            final calls = _getFilteredCalls();
            final longestCall = _statistics['longestCall'];

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
                        '${_statistics['todayIncoming']} Calls',
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
                        '${_statistics['todayOutgoing']} Calls',
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
                        _formatDuration(_statistics['avgIncomingDuration']),
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
                        _formatDuration(_statistics['avgOutgoingDuration']),
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                if (longestCall != null)
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
                          "With: ${longestCall['name'] ?? longestCall['number'] ?? 'Unknown'}",
                          style: TextStyle(
                            fontFamily: 'NexaBold',
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "Duration: ${_formatDuration(longestCall['duration'] ?? 0)}",
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
                        _statistics['mostFrequentContact'],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => _filterCalls(filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? (isDark
                              ? Colors.tealAccent.shade700
                              : Colors.blueAccent)
                          : (isDark ? Colors.grey.shade800 : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow:
                      isDark
                          ? []
                          : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                ),
                child: Text(
                  filter[0].toUpperCase() + filter.substring(1),
                  style: TextStyle(
                    fontFamily: 'NexaBold',
                    color:
                        isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            );
          }).toList(),
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
            color: _getCallColor(call['callType']),
          ),
        ),
        title: Text(
          call['name'] ?? 'Unknown',
          style: TextStyle(
            fontFamily: 'NexaBold',
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              call['number'] ?? 'No Number',
              style: TextStyle(
                fontFamily: 'NexaBold',
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              'Duration: ${_formatDuration(call['duration'] ?? 0)}',
              style: TextStyle(
                fontFamily: 'NexaBold',
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
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