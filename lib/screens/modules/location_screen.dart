import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../apis/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import './location_map_screen.dart';
import '../../decryption/parent_decryption_array.dart';
import '../../widgets/breathing_loader.dart';

class LocationScreen extends StatefulWidget {
  final String username;

  const LocationScreen({super.key, required this.username});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<dynamic> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocationData();
  }

  void refresh() => _fetchLocationData();

  Future<void> _fetchLocationData() async {
    final apidata = await fetchModuleData(
      module: 'location',
      userId: widget.username,
    );

    final data = await ParentDecryption.decrypt(
      apidata,
      username: widget.username,
    );

    if (data != null && data is List && data.isNotEmpty) {
      setState(() {
        _locations = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _locations = [];
      });
    }
  }

  String _formatRelativeTime(dynamic timestamp) {
    if (timestamp is Map && timestamp['_seconds'] != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        timestamp['_seconds'] * 1000,
      );
      return timeago.format(dt);
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final latest = _locations.isNotEmpty ? _locations.first : null;
    final history = _locations.length > 1 ? _locations.sublist(1) : [];
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
            'GPS Location Sensing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NexaBold',
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
            tooltip: 'Refresh',
            color: Colors.white,
          ),
          TextButton.icon(
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text(
              'View on Map',
              style: TextStyle(fontFamily: 'NexaBold', color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationMapScreen(locations: _locations),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: isDark ? Colors.black : const Color(0xFFE2E2E2),
        child: _isLoading
            ? Center(
                child: Container(
                  color: isDark ? Colors.black : const Color(0xFFE2E2E2),
                  child: const BreathingLoader(),
                ),
              )
            : latest == null
                ? Center(
                    child: Text(
                      'No location data available',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'NexaBold',
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 100, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLatestCard(
                          latest['data'],
                          latest['timestamp'],
                          isDark,
                        ).animate().fade(duration: 500.ms).moveY(),
                        const SizedBox(height: 16),
                        _buildHistoryList(history, isDark)
                            .animate()
                            .fade(duration: 500.ms)
                            .moveY(delay: 200.ms),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildLatestCard(
    Map<String, dynamic> data,
    dynamic timestamp,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NexaBold',
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLocationDetail('Latitude', data['lat'], isDark),
                  _buildLocationDetail('Longitude', data['lng'], isDark),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Time: ${_formatRelativeTime(timestamp)} (${data['time']})',
                style: TextStyle(
                  fontFamily: 'NexaBold',
                  color: Colors.greenAccent.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDetail(String label, dynamic value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NexaBold',
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value != null ? value.toStringAsFixed(6) : 'N/A',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'NexaBold',
            color:
                isDark ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<dynamic> history, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NexaBold',
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              ...history.map((entry) {
                final d = entry['data'];
                final t = entry['timestamp'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time: ${_formatRelativeTime(t)} (${d['time']})',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NexaBold',
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${d['lat']}  |  Lng: ${d['lng']}',
                        style: TextStyle(
                          fontFamily: 'NexaBold',
                          color:
                              isDark ? Colors.white54 : Colors.grey.shade700,
                        ),
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
