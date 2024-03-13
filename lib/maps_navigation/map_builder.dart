import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helper/internet_connectivity.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';
import '../navigation/navigation_helper.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              appBar: customAppBar(
                context,
                localization(context).mapPage,
                const Color.fromRGBO(11, 20, 32, 1),
              ),
              bottomNavigationBar: const CustomBottomNavigationBar(
                unselectedColor: Color.fromRGBO(11, 20, 32, 1),
              ),
              body: buildMap(screenWidth, screenHeight),
            );
          },
        );
      },
    );
  }
}

Widget buildMapWithMarkers(List<Marker> markers) {
  return FutureBuilder<bool>(
    future: checkInitialInternetConnection(),
    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Tooltip(
          message: localization(context).loading,
          child: CircularProgressIndicator(
            semanticsLabel: localization(context).loading,
          ),
        );
      } else {
        return StreamBuilder<bool>(
          stream: hasInternetConnection(),
          initialData: snapshot.data,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return buildLayout(context, constraints);
                },
              );
            } else {
              return FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(44.267, 19.886),
                  initialZoom: 13.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  Stack(
                    children: [
                      Semantics(
                        label: localization(context).map,
                        child: TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                      ),
                      MarkerLayer(markers: markers),
                      Positioned(
                        bottom: 5.0,
                        right: 5.0,
                        child: Container(
                          width: max(50, screenWidth * 0.6),
                          height: max(50, screenHeight * 0.01),
                          color: Colors.white,
                          child: GestureDetector(
                            onTap: () {
                              launchUrlString(
                                'https://www.openstreetmap.org/',
                              );
                            },
                            child: Semantics(
                              link: true,
                              label: localization(context).mapCredits,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '© OpenStreetMap contributors',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: screenWidth * 0.04,
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w300,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        );
      }
    },
  );
}

// Creating markers on map dynamically
Widget buildWithMarkers(
  BuildContext context,
  List<Map<String, dynamic>> data,
  Widget Function(Map<String, dynamic>) buildDetailsPage,
) {
  List<Marker> markers = data.map((itemData) {
    LatLng position =
        LatLng(itemData['latitude'] as double, itemData['longitude'] as double);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Marker(
      point: position,
      width: max(screenWidth * 0.1, 50),
      height: max(screenHeight * 0.1, 50),
      child: GestureDetector(
        onTap: () => showDetailsPage(context, buildDetailsPage(itemData)),
        child: Tooltip(
          message: '${itemData['title']}',
          child: Icon(
            Icons.location_pin,
            size: min(50, screenWidth * 0.09),
            semanticLabel: '${itemData['title']}',
            color: const Color.fromRGBO(11, 20, 32, 1),
            applyTextScaling: true,
          ),
        ),
      ),
    );
  }).toList();

  return buildMapWithMarkers(markers);
}

Widget buildMap(double screenWidth, double screenHeight) {
  return FutureBuilder<bool>(
    future: checkInitialInternetConnection(),
    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Tooltip(
          message: localization(context).loading,
          child: CircularProgressIndicator(
            semanticsLabel: localization(context).loading,
          ),
        );
      } else {
        return StreamBuilder<bool>(
          stream: hasInternetConnection(),
          initialData: snapshot.data,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return buildLayout(context, constraints);
                },
              );
            } else {
              return FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(44.267, 19.886),
                  initialZoom: 13.0,
                ),
                children: [
                  Stack(
                    children: [
                      Semantics(
                        label: localization(context).map,
                        child: TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                      ),
                      Positioned(
                        bottom: 5.0,
                        right: 5.0,
                        child: Container(
                          width: max(50, screenWidth * 0.6),
                          height: max(50, screenHeight * 0.01),
                          color: Colors.white,
                          child: GestureDetector(
                            onTap: () {
                              launchUrlString(
                                'https://www.openstreetmap.org/',
                              );
                            },
                            child: Semantics(
                              link: true,
                              label: localization(context).mapCredits,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '© OpenStreetMap contributors',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: screenWidth * 0.04,
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w300,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        );
      }
    },
  );
}

Widget buildLayout(BuildContext context, BoxConstraints constraints) {
  return Center(
    child: SizedBox(
      width: constraints.maxWidth * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: constraints.maxHeight * 0.1),
          Semantics(
            liveRegion: true,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                localization(context).noInternetConnection,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: constraints.maxWidth * 0.05,
                      fontWeight: FontWeight.w300,
                    ),
              ),
            ),
          ),
          Semantics(
              liveRegion: true,
              child: Tooltip(
                message: localization(context).noInternetConnection,
                child: Icon(
                  Icons.wifi_off_outlined,
                  semanticLabel: localization(context).noInternetConnection,
                  size: max(50, constraints.maxWidth * 0.3),
                  applyTextScaling: true,
                ),
              )),
          Semantics(
            button: true,
            enabled: true,
            label: localization(context).openSettings,
            child: ElevatedButton(
              onPressed: () {
                AppSettings.openAppSettings(type: AppSettingsType.wireless);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(11, 20, 32, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                localization(context).settings,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.05,
                    ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
