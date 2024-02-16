import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../styles/common_styles.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
            label: localization(context).mapPage,
            child: Text(localization(context).mapPage,
                style: AppStyles.defaultAppBarTextStyle(
                    MediaQuery.of(context).textScaler))),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Color of drawer icon
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: buildMap(),
    );
  }
}

Widget buildMapWithMarkers(List<Marker> markers) {
  return FlutterMap(
    options: const MapOptions(
      initialCenter: LatLng(44.267, 19.886),
      initialZoom: 13.0,
    ),
    children: [
      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
      MarkerLayer(markers: markers),
    ],
  );
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
