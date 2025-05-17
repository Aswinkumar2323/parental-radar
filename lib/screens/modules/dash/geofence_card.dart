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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    final double labelFontSize = isSmallScreen ? 12 : 14;
    final double valueFontSize = isSmallScreen ? 13 : 15;
    final double titleFontSize = isSmallScreen ? 16 : 18;

    final data =
        geofenceData != null
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
      child: InkWell(
        onTap:
            widget.onJumpToIndex != null
                ? () => widget.onJumpToIndex!(2)
                : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "📡 Live Geofence Data",
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                isSmallScreen
                    ? Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: data.entries.length,
                          itemBuilder: (context, index) {
                            final entry = data.entries.elementAt(index);
                            final isStatus = entry.key == "Status";
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      "${entry.key}:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: labelFontSize,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.value.toString(),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: valueFontSize,
                                        color:
                                            isStatus
                                                ? statusColor
                                                : theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    : Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 25,
                          ), // gap between title and data on big devices
                          ...data.entries.map((entry) {
                            final isStatus = entry.key == "Status";
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      "${entry.key}:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: labelFontSize,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      entry.value.toString(),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: valueFontSize,
                                        color:
                                            isStatus
                                                ? statusColor
                                                : theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
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
            ],
          ),
        ),
      ),
    );
  }
}