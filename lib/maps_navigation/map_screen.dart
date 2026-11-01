import 'package:flutter/services.dart';
import 'package:map_launcher/map_launcher.dart';

class MapScreen {
  MapScreen._privateConstructor();
  static final MapScreen _instance = MapScreen._privateConstructor();

  factory MapScreen() => _instance;

  Future<void> navigateToDestination(
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    HapticFeedback.selectionClick();

    await MapLauncher.directions(
      LocationCoords(destinationLatitude, destinationLongitude),
    ).show();
  }
}
