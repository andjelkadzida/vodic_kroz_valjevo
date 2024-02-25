import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vodic_kroz_valjevo/navigation/cutom_app_bar.dart';

import '../helper/internet_connectivity.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/navigation_helper.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              appBar: customAppBar(context, localization(context).mapPage),
              bottomNavigationBar: const CustomBottomNavigationBar(),
              body: buildMap(),
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
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(
          semanticsLabel: localization(context).loading,
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
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                  MarkerLayer(markers: markers),
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

    return Marker(
      point: position,
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.1,
      child: GestureDetector(
        onTap: () => showDetailsPage(context, buildDetailsPage(itemData)),
        child: Semantics(
          label: '${itemData['title']}',
          child: Tooltip(
            message: '${itemData['title']}',
            child: Icon(
              Icons.location_pin,
              size: MediaQuery.of(context).size.width * 0.07,
              semanticLabel: '${itemData['title']}',
              color: Colors.blue,
              applyTextScaling: true,
            ),
          ),
        ),
      ),
    );
  }).toList();

  return buildMapWithMarkers(markers);
}

Widget buildMap() {
  return FutureBuilder<bool>(
    future: checkInitialInternetConnection(),
    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(
          semanticsLabel: localization(context).loading,
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
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
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
            label: localization(context).noInternetConnection,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                localization(context).noInternetConnection,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: constraints.maxWidth * 0.05,
                    ),
              ),
            ),
          ),
          Semantics(
            child: Icon(
              Icons.wifi_off_outlined,
              semanticLabel: localization(context).noInternetConnection,
              size: constraints.maxWidth * 0.3,
            ),
          ),
          Semantics(
            button: true,
            enabled: true,
            label: localization(context).openSettings,
            child: ElevatedButton(
              onPressed: () {
                AppSettings.openAppSettings(type: AppSettingsType.wireless);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
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
