import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../apis/get.dart';
import '../../decryption/parent_decryption.dart';
import './geofencing_screen.dart'; // <-- Ensure correct path

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? geofenceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGeofenceData();
  }

  Future<void> loadGeofenceData() async {
    setState(() => isLoading = true);
    final data = await fetchModuleData(
      module: 'geofencing',
      userId: widget.username,
    );
    final result = await ParentDecryption.decrypt(data, widget.username);
    if (result != null && result['data'] != null) {
      setState(() {
        geofenceData = Map<String, dynamic>.from(result['data']);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofencing'),
        backgroundColor: isDark ? Colors.black : const Color(0xFF0090FF),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadGeofenceData,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: isDark
                ? [Colors.black, Colors.black, Colors.black]
                : [Color(0xFF0090FF), Color(0xFF15D6A6), Color(0xFF123A5B)],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GeofencingScreen (username: widget.username),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: size.width < 500 ? size.width * 0.9 : 400,
                      ),
                      child: _buildGeofenceDataCard(context),
                    ),
                  ),
                ),
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
        : {
            "Status": "No geofence data",
          };

    final statusColor = geofenceData?['regionId'] == 'inside' ? Colors.green : Colors.red;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.satelliteDish, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  "📡 Live Geofence Data",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                        entry.value,
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
}
