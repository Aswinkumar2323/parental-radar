import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../apis/get.dart';
import '../../apis/post.dart';
import './web_map_picker.dart';
import '../../utils/permissions.dart';
import '../../decryption/parent_decryption.dart';
import '../../widgets/breathing_loader.dart';

class GeofencingScreen extends StatefulWidget {
  final String username;
  const GeofencingScreen({super.key, required this.username});

  @override
  State<GeofencingScreen> createState() => _GeofencingScreenState();
}

class _GeofencingScreenState extends State<GeofencingScreen> {
  Map<String, dynamic>? geofenceData;
  Map<String, dynamic>? geofenceCmdData;
  bool isLoading = true;
  int waitTime = 0;
  Timer? _timer;

  double _selectedLat = 0.0;
  double _selectedLng = 0.0;
  double _selectedRadius = 200;
  final _radiusController = TextEditingController();
  String? _radiusWarning;

  @override
  void initState() {
    super.initState();
    loadAllData();
    _radiusController.text = _selectedRadius.toInt().toString();
    _requestPermissionsOnEnter();
  }

  _requestPermissionsOnEnter() async {
    await requestPermissions();
    await requestAccuracyLocation();
  }

  Future<void> loadAllData() async {
    await Future.wait([loadGeofenceCmdData(), loadGeofenceData()]);
    setState(() => isLoading = false);
  }

  Future<void> loadGeofenceData() async {
    final data = await fetchModuleData(
      module: 'geofencing',
      userId: widget.username,
    );
    final result = await ParentDecryption.decrypt(data, widget.username);
    if (result != null && result['data'] != null) {
      setState(() => geofenceData = Map<String, dynamic>.from(result['data']));
    }
  }

  Future<void> loadGeofenceCmdData() async {
    final result = await fetchModuleData(
      module: 'geofencingcmd',
      userId: widget.username,
    );
    if (result != null && result['data'] != null) {
      setState(() => geofenceCmdData = Map<String, dynamic>.from(result['data']));
    }
  }

  Future<void> sendGeofenceCommand() async {
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd hh:mm a').format(now);

    final payload = {
      'latitude': _selectedLat.toString(),
      'longitude': _selectedLng.toString(),
      'radius': _selectedRadius.toInt().toString(),
      'updatedAt': formattedTime,
    };

    await sendModuleData(
      module: 'geofencingcmd',
      data: payload,
      userId: widget.username,
    );
    await loadGeofenceCmdData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Geofence command set successfully",
              style: TextStyle(fontFamily: 'NexaBold'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
      ),
    );
    startCountdown();
  }

  void startCountdown() {
    setState(() => waitTime = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waitTime == 1) timer.cancel();
      setState(() => waitTime--);
    });
  }

  void onMapChanged(double lat, double lng) {
    setState(() {
      _selectedLat = lat;
      _selectedLng = lng;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFE2E2E2),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
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
              'Geofencing',
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
              onPressed: () async {
                setState(() => isLoading = true);
                await loadAllData();
                setState(() => isLoading = false);
              },
              tooltip: 'Refresh',
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: BreathingLoader())
          : Padding(
              padding: const EdgeInsets.only(
                top: 100,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Wrap(
                          spacing: isMobile ? 16 : 32,
                          runSpacing: 16,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildDataCard(
                              context: context,
                              title: "Current Geofence Command",
                              icon: Icons.location_on_outlined,
                              data: geofenceCmdData != null
                                  ? {
                                      "Latitude": geofenceCmdData!['latitude'],
                                      "Longitude": geofenceCmdData!['longitude'],
                                      "Radius":
                                          "${geofenceCmdData!['radius']} meters",
                                      "Last Updated":
                                          geofenceCmdData!['updatedAt'] ?? "-",
                                    }
                                  : {"Status": "No command data"},
                            ),
                            _buildDataCard(
                              context: context,
                              title: "Live Geofence Data",
                              icon: FontAwesomeIcons.satelliteDish,
                              data: geofenceData != null
                                  ? {
                                      "Status": geofenceData!['status'] ?? "Unknown",
                                      "Latitude": geofenceData!['latitude'],
                                      "Longitude": geofenceData!['longitude'],
                                      "Last Update": geofenceData!['time'],
                                    }
                                  : {"Status": "No geofence data"},
                              statusColor: geofenceData?['regionId'] == 'inside'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade900 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "🛠️ Set New Geofence",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: 'NexaBold',
                                  color: isDark
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 200,
                                  maxHeight: isMobile ? 300 : 400,
                                  minWidth: double.infinity,
                                ),
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: WebMapPicker(
                                    key: ValueKey(_selectedRadius),
                                    onChanged: onMapChanged,
                                    radius: _selectedRadius,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: _selectedRadius,
                                      min: 10,
                                      max: 2000,
                                      divisions: 20,
                                      label: "${_selectedRadius.toInt()}m",
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedRadius = val;
                                          _radiusController.text =
                                              val.toInt().toString();
                                          _radiusWarning = null;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: _radiusController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: "Manual",
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      onChanged: (val) {
                                        final parsed = double.tryParse(val);
                                        if (parsed != null) {
                                          if (parsed > 2000) {
                                            setState(() =>
                                                _radiusWarning = "Max 2000 meters.");
                                          } else if (parsed >= 10) {
                                            setState(() {
                                              _selectedRadius = parsed;
                                              _radiusWarning = null;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "meters",
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'NexaBold',
                                    ),
                                  ),
                                ],
                              ),
                              if (_radiusWarning != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _radiusWarning!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'NexaBold',
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: waitTime > 0 || _radiusWarning != null
                                      ? null
                                      : sendGeofenceCommand,
                                  icon: const Icon(Icons.send),
                                  label: Text(
                                    waitTime > 0
                                        ? "Please wait: $waitTime s"
                                        : "Send Geofence",
                                    style: const TextStyle(
                                      fontFamily: 'NexaBold',
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildDataCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Map<String, String> data,
    Color? statusColor,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 400,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NexaBold',
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NexaBold',
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'NexaBold',
                            color: entry.key == "Status"
                                ? statusColor
                                : theme.textTheme.bodyMedium!.color,
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
      ),
    );
  }
}
