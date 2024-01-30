import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
