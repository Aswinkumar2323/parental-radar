import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapScreen extends StatefulWidget {
  final List<dynamic> locations;

  const LocationMapScreen({super.key, required this.locations});

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late LatLng _latestLatLng;

  @override
  void initState() {
    super.initState();
    _buildMapData();
  }

  void _buildMapData() {
    final locations = widget.locations;
    if (locations.isEmpty) return;

    final List<LatLng> pathPoints = [];

    for (int i = 0; i < locations.length; i++) {
      final entry = locations[i];
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
          onTap: () => _animateTo(point),
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

  void _animateTo(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  void _recenterToLatest() {
    _animateTo(_latestLatLng);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locations.isEmpty) {
      return const Scaffold(body: Center(child: Text('No location data')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Location Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _latestLatLng,
              zoom: 13,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController = controller,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
          Positioned(
            bottom: 200,
            right: 7,
            child: FloatingActionButton(
              heroTag: 'recenter_fab',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _recenterToLatest,
              child: const Icon(Icons.center_focus_strong, color: Color.fromARGB(255, 112, 112, 112)),
              tooltip: 'Recenter',
            ),
          ),
        ],
      ),
    );
  }
}