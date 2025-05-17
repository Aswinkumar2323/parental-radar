import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../apis/get.dart';
import '../../../decryption/parent_decryption_array.dart';

class LocationMapCard extends StatefulWidget {
  final String username;
  final Function(int) onJumpToIndex;
  final VoidCallback onModuleLoaded;

  const LocationMapCard({
    super.key,
    required this.username,
    required this.onJumpToIndex,
    required this.onModuleLoaded,
  });

  @override
  State<LocationMapCard> createState() => _LocationMapCardState();
}

class _LocationMapCardState extends State<LocationMapCard> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<dynamic> _locations = [];
  bool _isLoading = true;
  late LatLng _latestLatLng;

  @override
  void initState() {
    super.initState();
    _fetchLocationData();
  }

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
        _buildMapData();
        _isLoading = false;
      });

      widget.onModuleLoaded();
    } else {
      setState(() {
        _isLoading = false;
        _locations = [];
      });
    }
  }

  void _buildMapData() {
    _markers.clear();
    _polylines.clear();

    final List<LatLng> pathPoints = [];

    for (int i = 0; i < _locations.length; i++) {
      final entry = _locations[i];
      final data = entry['data'];
      final LatLng point = LatLng(data['lat'], data['lng']);
      final String timeLabel = data['time'] ?? 'Unknown time';

      pathPoints.add(point);

      if (i == 0) {
        _latestLatLng = point;
      }

      _markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: i == 0 ? 'Latest Location' : 'History',
            snippet: timeLabel,
          ),
          onTap: () => _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(point, 15),
          ),
        ),
      );
    }

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('location_path'),
        color: Colors.blueAccent,
        width: 4,
        points: pathPoints,
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        widget.onJumpToIndex(1);
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _locations.isEmpty
                  ? const Text(
                      'No location data available',
                      style: TextStyle(
                        fontFamily: 'NexaBold',
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live GPS Location',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NexaBold',
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${_formatRelativeTime(_locations.first['timestamp'])}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NexaBold',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _latestLatLng,
                                zoom: 13,
                              ),
                              markers: _markers,
                              polylines: _polylines,
                              onMapCreated: (controller) =>
                                  _mapController = controller,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: true,
                              onTap: (LatLng latLng) {
                                widget.onJumpToIndex(1);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
