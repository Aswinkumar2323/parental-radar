import 'package:flutter/material.dart';
import '../../../apis/get.dart';
import '../../../decryption/parent_decryption.dart';

class GeofenceCard extends StatefulWidget {
  final String userId;
  final Function(int)? onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const GeofenceCard({
    super.key,
    required this.userId,
    this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<GeofenceCard> createState() => _GeofenceCardState();
}

class _GeofenceCardState extends State<GeofenceCard> {
  Map<String, dynamic>? geofenceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGeofenceData();
  }

  Future<void> loadGeofenceData() async {
    final data = await fetchModuleData(
      module: 'geofencing',
      userId: widget.userId,
    );
    final result = await ParentDecryption.decrypt(data, widget.userId);
    if (result != null && result['data'] != null) {
      setState(() {
        geofenceData = Map<String, dynamic>.from(result['data']);
        isLoading = false;
      });
      widget.onModuleLoaded();
    } else {
      setState(() => isLoading = false);
    }
  }

  Widget _buildDataTile({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: widget.onJumpToIndex != null ? () => widget.onJumpToIndex!(2) : null,
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
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NexaBold',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = geofenceData?['status'] ?? 'Unknown';
    final lat = geofenceData?['latitude']?.toString() ?? '-';
    final lng = geofenceData?['longitude']?.toString() ?? '-';
    final time = geofenceData?['time']?.toString() ?? '-';
    final regionId = geofenceData?['regionId'];

    final statusColor = regionId == 'inside' ? Colors.green : Colors.red;

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
                Icon(Icons.gps_fixed, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Geofence Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NexaBold',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildDataTile(
                context: context,
                label: 'Current Status',
                value: status,
                icon: Icons.location_on,
                color: statusColor,
              ),
              const SizedBox(height: 5),
              _buildDataTile(
                context: context,
                label: 'Last Coordinates',
                value: 'Lat: $lat, Lng: $lng',
                icon: Icons.map,
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              _buildDataTile(
                context: context,
                label: 'Last Updated',
                value: time,
                icon: Icons.access_time,
                color: Colors.deepPurple,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
