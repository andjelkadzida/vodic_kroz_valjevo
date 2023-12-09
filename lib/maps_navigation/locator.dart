import 'package:geolocator/geolocator.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:map_launcher/map_launcher.dart';

class MapScreen {
  Position? currentPosition; // Store current position

  // Obtaining user's location
  Future<void> getCurrentLocation() async {
    var gpsEnabled = await Geolocator.isLocationServiceEnabled();
    var gpsPermission = await Geolocator.checkPermission();

    // Check if GPS is enabled and permissions granted
    if (gpsPermission == LocationPermission.denied) {
      gpsPermission = await Geolocator.requestPermission();
    } else if (gpsEnabled) {
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      currentPosition = position; // Update the current position
    }
  }

  Future<void> navigateToDestination(
      double destinationLatitude, double destinationLongitude) async {
    if (currentPosition != null) {
      // Show installed maps application
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isNotEmpty) {
        final coords = Coords(destinationLatitude, destinationLongitude);
        await availableMaps.first.showDirections(
            destination: coords, directionsMode: DirectionsMode.walking);
      } else {
        // Launch platform specific app store to install Google maps
        LaunchReview.launch(
            androidAppId: "com.google.android.apps.maps",
            iOSAppId: "id585027354");
      }
    }
  }
}
