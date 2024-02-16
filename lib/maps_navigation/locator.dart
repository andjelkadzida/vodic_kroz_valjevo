import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:open_store/open_store.dart';

class MapScreen {
  // Store current position
  Position? currentPosition;

  MapScreen._privateConstructor();
  static final MapScreen _instance = MapScreen._privateConstructor();
  factory MapScreen() {
    return _instance;
  }

  Future<void> navigateToDestination(
      double destinationLatitude, double destinationLongitude) async {
    // Show installed maps application
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isNotEmpty) {
      final coords = Coords(destinationLatitude, destinationLongitude);
      // Gets first found maps app
      await availableMaps.first.showDirections(
          destination: coords, directionsMode: DirectionsMode.walking);
    } else {
      // Launch platform specific app store to install Google maps
      OpenStore.instance.open(
        androidAppBundleId: "com.google.android.apps.maps",
        appStoreId: "id585027354",
      );
    }
  }
}
