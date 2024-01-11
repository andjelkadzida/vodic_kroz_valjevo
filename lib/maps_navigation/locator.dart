import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_store/open_store.dart';

import '../localization/supported_languages.dart';

class MapScreen {
  // Store current position
  Position? currentPosition;

  MapScreen._privateConstructor();
  static final MapScreen _instance = MapScreen._privateConstructor();
  factory MapScreen() {
    return _instance;
  }

  // Obtaining user's location
  Future<void> getCurrentLocation() async {
    var gpsEnabled = await Geolocator.isLocationServiceEnabled();
    var gpsPermission = await Geolocator.checkPermission();

    // Check if GPS is enabled and permissions granted
    if (gpsPermission == LocationPermission.denied ||
        gpsPermission == LocationPermission.deniedForever) {
      gpsPermission = await Geolocator.requestPermission();
    }

    if (!gpsEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Check if permission is granted
    if (gpsEnabled &&
        (gpsPermission == LocationPermission.always ||
            gpsPermission == LocationPermission.whileInUse)) {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      // Update the current position
      currentPosition = position;
    }
  }

  Future<void> navigateToDestination(
      double destinationLatitude, double destinationLongitude) async {
    await getCurrentLocation();

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
