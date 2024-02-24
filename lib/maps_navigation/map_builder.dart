import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vodic_kroz_valjevo/navigation/cutom_app_bar.dart';

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
  return FlutterMap(
    options: const MapOptions(
      initialCenter: LatLng(44.267, 19.886),
      initialZoom: 13.0,
      minZoom: 10.0,
      maxZoom: 18.0,
    ),
    children: [
      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
      MarkerLayer(markers: markers),
    ],
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
  return FlutterMap(
    options: const MapOptions(
      initialCenter: LatLng(44.267, 19.886),
      initialZoom: 13.0,
    ),
    children: [
      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
    ],
  );
}
