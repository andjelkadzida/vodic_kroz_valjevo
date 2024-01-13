import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../database_config/database_helper.dart';
import '../../localization/supported_languages.dart';
import '../../styles/common_styles.dart';

class Hotels extends StatelessWidget {
  Hotels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
            label: localization(context).hotels,
            child: Text(
              localization(context).hotels,
              style: AppStyles.defaultAppBarTextStyle(textScaler),
            )),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getHotelsDataFromDatabase(localization(context).localeName),
        builder: (context, snapshot) {
          return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
            context: context,
            snapshot: snapshot,
            onData: (data) => buildWithMarkers(context, data),
          );
        },
      ),
    );
  }

  Widget buildWithMarkers(
      BuildContext context, List<Map<String, dynamic>> hotelsData) {
    List<Marker> markers = hotelsData.map((hotelData) {
      LatLng position = LatLng(
          hotelData['latitude'] as double, hotelData['longitude'] as double);

      return Marker(
        point: position,
        child: IconButton(
          icon: const Icon(
            Icons.pin_drop,
            size: 20,
          ),
          color: Colors.black,
          onPressed: () => showHotelDetailsDialog(context, hotelData),
        ),
      );
    }).toList();

    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(44.275, 19.898),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  void showHotelDetailsDialog(
      BuildContext context, Map<String, dynamic> hotelData) {
    final textScaler = MediaQuery.textScalerOf(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // Data processing
          Uint8List imageBytes = hotelData['hotel_image_path'];
          int numberOfStars = hotelData['noStars'];

          //List of stars icon
          List<Widget> hotelStars = List.generate(numberOfStars,
              ((index) => Icon(Icons.star, color: Colors.amber)));

          // Alert dialog with data about hotel
          return AlertDialog(
            title: Text(hotelData['title'],
                style: AppStyles.sightTitleStyle(textScaler)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
                Row(mainAxisSize: MainAxisSize.min, children: hotelStars),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  Future<List<Map<String, dynamic>>> _getHotelsDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT 
        hotel_image_path, 
        title_$languageCode AS title, 
        latitude, 
        longitude, 
        noStars 
      FROM Hotels
    ''');
    return data;
  }
}
