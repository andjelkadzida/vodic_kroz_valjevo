import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_store/open_store.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

class MapScreen {
  Position? currentPosition; // Store current position

  // Obtaining user's location
  Future<void> getCurrentLocation(BuildContext buildContext) async {
    var gpsEnabled = await Geolocator.isLocationServiceEnabled();
    var gpsPermission = await Geolocator.checkPermission();

    // Check if GPS is enabled and permissions granted
    if (gpsPermission == LocationPermission.denied) {
      gpsPermission = await Geolocator.requestPermission();
    } else if (!gpsEnabled) {
      await Geolocator.openLocationSettings();
    } else if (gpsEnabled &&
        (gpsPermission == LocationPermission.always ||
            gpsPermission == LocationPermission.whileInUse)) {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      currentPosition = position; // Update the current position
    } else {
      showLocationDeniedForeverDialog(buildContext);
    }
  }

  Future<void> navigateToDestination(
      double destinationLatitude, double destinationLongitude) async {
    if (currentPosition != null) {
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

  void showLocationDeniedForeverDialog(BuildContext buildContext) {
    showPlatformDialog(
      context: buildContext,
      builder: (context) => AlertDialog(
        title: Text(
          localization(context).locationUnavailable,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          localization(context).locationUnavailableMsg,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              localization(context).cancel,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: openAppSettings,
            child: Text(
              localization(context).openSettings,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}