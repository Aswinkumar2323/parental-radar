import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;

Future<void> requestPermissions() async {
  // Request location permissions first
  await Permission.location.request();
  await Permission.locationWhenInUse.request();
  await Permission.notification.request();

  // Check if location permissions are granted
  if (await Permission.location.isGranted ||
      await Permission.locationWhenInUse.isGranted) {
    // Check if location services are enabled
    Location location = Location();
    bool isLocationEnabled = await location.serviceEnabled();

    if (!isLocationEnabled) {
      // Request the user to enable location services
      bool isEnabled = await location.requestService();
      if (isEnabled) {
        print("✅ Location services enabled");
      } else {
        print("❌ Location services are still disabled");
      }
    }
  } else {
    print("❌ Location permissions denied");
    // Handle the situation when location permissions are denied (if needed)
  }
}

Future<void> requestAccuracyLocation() async {
  loc.Location location = loc.Location();

  bool serviceEnabled;
  loc.PermissionStatus permissionGranted;

  // Check if location service is enabled
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  // Check for location permission
  permissionGranted = await location.hasPermission();
  if (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != loc.PermissionStatus.granted) {
      return;
    }
  }

  // Set high accuracy mode
  await location.changeSettings(accuracy: loc.LocationAccuracy.high);
}