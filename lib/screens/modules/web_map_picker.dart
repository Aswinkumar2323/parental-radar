import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class WebMapPicker extends StatefulWidget {
  final void Function(double lat, double lng) onChanged;
  final double radius;

  const WebMapPicker({
    super.key,
    required this.onChanged,
    required this.radius,
  });

  @override
  State<WebMapPicker> createState() => _WebMapPickerState();
}

class _WebMapPickerState extends State<WebMapPicker> {
  GoogleMapController? _controller;
  LatLng? _selectedPosition;
  double _radius = 200.0;

  @override
  void initState() {
    super.initState();
    _radius = widget.radius;
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(covariant WebMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.radius != oldWidget.radius) {
      setState(() => _radius = widget.radius);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedPosition = currentLatLng;
    });

    widget.onChanged(currentLatLng.latitude, currentLatLng.longitude);
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15.0));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition!,
              zoom: 15.0,
            ),
            onMapCreated: (controller) => _controller = controller,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedPosition!,
                draggable: true,
                onDragEnd: (newPosition) {
                  setState(() => _selectedPosition = newPosition);
                  widget.onChanged(newPosition.latitude, newPosition.longitude);
                },
              ),
            },
            circles: {
              Circle(
                circleId: const CircleId('radius_circle'),
                center: _selectedPosition!,
                radius: _radius,
                strokeWidth: 2,
                strokeColor: Colors.blueAccent,
                fillColor: Colors.blueAccent.withOpacity(0.1),
              ),
            },
            onTap: (LatLng pos) {
              setState(() => _selectedPosition = pos);
              widget.onChanged(pos.latitude, pos.longitude);
            },
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton(
            heroTag: "current_location_btn",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}