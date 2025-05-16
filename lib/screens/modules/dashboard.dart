import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../apis/get.dart';
import '../../decryption/parent_decryption.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;

  const DashboardPage({
    super.key,
    required this.username,
    required this.onJumpToIndex,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? geofenceData;
  List<dynamic> smsList = [];
  List<dynamic> callList = [];
  List<dynamic> keyloggerList = [];
  List<dynamic> whatsappList = [];
  bool isLoading = true;
  Future<List<dynamic>> _fetchInstalledAppsData() async {
  final apidata = await fetchModuleData(
    module: 'iapp',
    userId: widget.username,
  );
  final data = await ParentDecryption.decrypt(apidata, widget.username);
  return data?['data']?['InstalledApps'] ?? [];
}
  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => isLoading = true);
    try {
      final geoData = await fetchModuleData(module: 'geofencing', userId: widget.username);
      final geoResult = await ParentDecryption.decrypt(geoData, widget.username);

      final smsData = await fetchModuleData(module: 'sms', userId: widget.username);
      final smsResult = await ParentDecryption.decrypt(smsData, widget.username);

      final callData = await fetchModuleData(module: 'call_logs', userId: widget.username);
      final callResult = await ParentDecryption.decrypt(callData, widget.username);

      final keyData = await fetchModuleData(module: 'keylogger', userId: widget.username);
      final keyResult = await ParentDecryption.decrypt(keyData, widget.username);

      final whatsappData = await fetchModuleData(module: 'whatsapp', userId: widget.username);
      final whatsappResult = await ParentDecryption.decrypt(whatsappData, widget.username);

      setState(() {
        if (geoResult?['data'] != null) {
          geofenceData = Map<String, dynamic>.from(geoResult['data']);
        }
        if (smsResult?['data']?['sms_data'] != null) {
          smsList = List.from(smsResult['data']['sms_data']);
        }
        if (callResult?['data']?['call_logs'] != null) {
          callList = List.from(callResult['data']['call_logs']);
        }
        if (keyResult?['data']?['keylogs'] != null) {
          keyloggerList = List.from(keyResult['data']['keylogs']);
        }
        if (whatsappResult?['data']?['messages'] != null) {
          whatsappList = List.from(whatsappResult['data']['messages']);
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error loading dashboard data: $e");
      setState(() => isLoading = false);
    }
  }
@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Top Row: Live Geofence (left) + Blank (right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildGeofenceDataCard(context)),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()), // Blank right space
          ],
        ),
        const SizedBox(height: 16),

        // Middle Row: SMS Summary (left) + Call Summary (right)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildSmsSummarySection()),
              const SizedBox(width: 16),
              Expanded(child: _buildCallSummarySection()),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bottom Row: WhatsApp Summary (left) + Keylogger Summary (right)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildWhatsAppSummarySection()),
              const SizedBox(width: 16),
              Expanded(child: _buildKeyloggerSummarySection()),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}




  Widget _buildWhatsAppSummarySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();

    final todayMessages = whatsappList.where((msg) {
      final timestamp = DateTime.tryParse(msg['timestamp'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(msg['timestamp'] ?? '0') ?? 0);
      return timestamp.year == today.year &&
          timestamp.month == today.month &&
          timestamp.day == today.day;
    }).toList();

    final incoming = todayMessages.where((m) => m['isIncoming'] == true).length;
    final outgoing = todayMessages.where((m) => m['isIncoming'] == false).length;

    final contactMap = <String, int>{};
    for (var msg in todayMessages) {
      final name = msg['contactName'] ?? msg['phone'] ?? 'Unknown';
      contactMap[name] = (contactMap[name] ?? 0) + 1;
    }

    final topContact = contactMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topName = topContact.isNotEmpty ? topContact.first.key : 'N/A';
    final topCount = topContact.isNotEmpty ? topContact.first.value : 0;

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
                Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'WhatsApp Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              title: 'Incoming Messages',
              subtitle: '$incoming message${incoming == 1 ? '' : 's'}',
              icon: Icons.call_received,
              onTap: () => widget.onJumpToIndex(6),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              title: 'Outgoing Messages',
              subtitle: '$outgoing message${outgoing == 1 ? '' : 's'}',
              icon: Icons.call_made,
              onTap: () => widget.onJumpToIndex(6),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              title: 'Top Contact Today',
              subtitle: '$topName: $topCount msg${topCount == 1 ? '' : 's'}',
              icon: Icons.person,
              onTap: () => widget.onJumpToIndex(6),
            ),
          ],
        ),
      ),
    );
  }

  // Existing helper widgets remain unchanged below

  Widget _buildKeyloggerSummarySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();

    final todayLogs = keyloggerList.where((log) {
      final ts = DateTime.tryParse(log['timestamp'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(log['timestamp'] ?? '0') ?? 0);
      return ts.year == today.year && ts.month == today.month && ts.day == today.day;
    }).toList();

    final keystrokesToday = todayLogs.length;

    final appUsage = <String, int>{};
    for (var log in todayLogs) {
      final app = log['app_name'] ?? 'Unknown';
      appUsage[app] = (appUsage[app] ?? 0) + 1;
    }

    final topAppEntry = appUsage.entries.isNotEmpty
        ? (appUsage.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first
        : const MapEntry('N/A', 0);

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
              title: 'Keystrokes Today',
              subtitle: '$keystrokesToday keystroke${keystrokesToday == 1 ? '' : 's'}',
              icon: Icons.keyboard,
              onTap: () => widget.onJumpToIndex(5),
            ),
            const SizedBox(height: 25),
            _buildBasicCard(
              title: 'Top App Today',
              subtitle: '${topAppEntry.key}: ${topAppEntry.value} keystroke${topAppEntry.value == 1 ? '' : 's'}',
              icon: Icons.apps,
              onTap: () => widget.onJumpToIndex(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofenceDataCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final data = geofenceData != null
        ? {
            "Status": geofenceData!['status'] ?? "Unknown",
            "Latitude": geofenceData!['latitude'] ?? "-",
            "Longitude": geofenceData!['longitude'] ?? "-",
            "Last Update": geofenceData!['time'] ?? "-",
          }
        : {"Status": "No geofence data"};

    final statusColor =
        geofenceData?['regionId'] == 'inside' ? Colors.green : Colors.red;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.satelliteDish,
                    color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  "📡 Live Geofence Data",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "${entry.key}: ",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: entry.key == "Status"
                              ? statusColor
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsSummarySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inbox = smsList.where((msg) => msg['type'] == '1').length;
    final sent = smsList.where((msg) => msg['type'] == '2').length;

    final contactFreq = <String, int>{};
    for (var sms in smsList) {
      final address = sms['address'] ?? 'Unknown';
      contactFreq[address] = (contactFreq[address] ?? 0) + 1;
    }
    final topContact = contactFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topName = topContact.isNotEmpty ? topContact.first.key : 'N/A';
    final topCount = topContact.isNotEmpty ? topContact.first.value : 0;

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
                Icon(Icons.sms, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'SMS Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBasicCard(
              title: 'INCOMING SMS',
              subtitle: '$inbox msg${inbox == 1 ? '' : 's'}',
              icon: Icons.call_received,
              onTap: () => widget.onJumpToIndex(3),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              title: 'OUTGOING SMS',
              subtitle: '$sent msg${sent == 1 ? '' : 's'}',
              icon: Icons.call_made,
              onTap: () => widget.onJumpToIndex(3),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              title: 'Top Contact Today',
              subtitle: '$topName: $topCount msg${topCount == 1 ? '' : 's'}',
              icon: Icons.person,
              onTap: () => widget.onJumpToIndex(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallSummarySection() {
    final today = DateTime.now();
    final todayCalls = callList.where((call) {
      final timestamp = DateTime.tryParse(call['timestamp'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(call['timestamp'] ?? '0') ?? 0);
      return timestamp.year == today.year &&
          timestamp.month == today.month &&
          timestamp.day == today.day;
    }).toList();

    final incoming =
        todayCalls.where((c) => c['call_type'] == 'INCOMING').length;
    final outgoing =
        todayCalls.where((c) => c['call_type'] == 'OUTGOING').length;

    final longestCall = callList.fold<Map<String, dynamic>?>(null, (prev, curr) {
      return prev == null ||
              (int.tryParse(curr['duration'] ?? '0') ?? 0) >
                  (int.tryParse(prev['duration'] ?? '0') ?? 0)
          ? curr
          : prev;
    });

    final name = longestCall?['name'] ?? 'Unknown';
    final number = longestCall?['number'] ?? '-';
    final duration = longestCall?['duration'] ?? '0';
    final start = longestCall?['timestamp'] ?? '-';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).brightness == Brightness.dark
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
                Text(
                  'Call Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBasicCard(
              title: 'Incoming Calls Today',
              subtitle: '$incoming call${incoming == 1 ? '' : 's'}',
              icon: Icons.call_received,
              onTap: () => widget.onJumpToIndex(4),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              title: 'Outgoing Calls Today',
              subtitle: '$outgoing call${outgoing == 1 ? '' : 's'}',
              icon: Icons.call_made,
              onTap: () => widget.onJumpToIndex(4),
            ),
            const SizedBox(height: 8),
            _buildBasicCard(
              title: 'Longest Call',
              subtitle: '$name | $number\n⏱ $duration sec | ⏰ $start',
              icon: Icons.access_time,
              onTap: () => widget.onJumpToIndex(4),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstalledAppsSummaryCard(List<Map<String, dynamic>> apps) {
  final totalApps = apps.length;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.apps, color: Colors.indigo),
              SizedBox(width: 8),
              Text(
                'Installed Apps Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBasicCard(
            title: 'Total Installed Apps',
            subtitle: '$totalApps app${totalApps == 1 ? '' : 's'} found',
            icon: Icons.check_circle_outline,
            onTap: () => widget.onJumpToIndex(8),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildBasicCard({
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
